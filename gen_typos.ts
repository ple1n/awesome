// md-typo-ify.ts
// Usage: deno run --allow-read --allow-write md-typo-ify.ts input.md output.md [rate] [seed]

function usageAndExit() {
  console.error("Usage: deno run --allow-read --allow-write md-typo-ify.ts input.md output.md [rate] [seed]");
  Deno.exit(1);
}

if (Deno.args.length < 2) usageAndExit();
const [inPath, outPath, rateArg, seedArg] = Deno.args;
const TYPO_RATE = rateArg ? Math.max(0, Math.min(1, Number(rateArg) || 0.15)) : 0.15;
const SEED = seedArg ? Number(seedArg) : Date.now() % 2**31;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const text = await Deno.readTextFile(inPath);

// -------------------- seeded RNG (mulberry32) --------------------
function mulberry32(a: number) {
  return function() {
    let t = (a += 0x6D2B79F5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const rng = mulberry32(SEED);

// helper to pick an integer in [0, n)
function randInt(n: number) { return Math.floor(rng() * n); }
function chance(p: number) { return rng() < p; }

// -------------------- Levenshtein distance (iterative DP) --------------------
function levenshtein(a: string, b: string): number {
  if (a === b) return 0;
  const al = a.length, bl = b.length;
  if (al === 0) return bl;
  if (bl === 0) return al;
  const v0 = new Array(bl + 1);
  const v1 = new Array(bl + 1);
  for (let j = 0; j <= bl; j++) v0[j] = j;
  for (let i = 0; i < al; i++) {
    v1[0] = i + 1;
    for (let j = 0; j < bl; j++) {
      const cost = a[i] === b[j] ? 0 : 1;
      v1[j + 1] = Math.min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
    }
    for (let j = 0; j <= bl; j++) v0[j] = v1[j];
  }
  return v1[bl];
}

// -------------------- typo operations --------------------
const letters = "abcdefghijklmnopqrstuvwxyz";

// apply single-edit operations
function substituteChar(s: string): string {
  if (s.length === 0) return s;
  const i = randInt(s.length);
  const old = s[i];
  // keep case
  const pool = letters + letters.toUpperCase();
  let c = pool[randInt(pool.length)];
  // avoid same char
  let attempts = 0;
  while (c === old && attempts++ < 8) c = pool[randInt(pool.length)];
  return s.slice(0, i) + c + s.slice(i + 1);
}

function deleteChar(s: string): string {
  if (s.length === 0) return s;
  const i = randInt(s.length);
  return s.slice(0, i) + s.slice(i + 1);
}

function insertChar(s: string): string {
  const i = randInt(s.length + 1);
  const pool = letters + letters.toUpperCase();
  const c = pool[randInt(pool.length)];
  return s.slice(0, i) + c + s.slice(i);
}

function transposeChar(s: string): string {
  if (s.length < 2) return s;
  const i = randInt(s.length - 1);
  const arr = s.split("");
  const tmp = arr[i];
  arr[i] = arr[i + 1];
  arr[i + 1] = tmp;
  return arr.join("");
}

// one edit choice
function singleEdit(s: string): string {
  const ops = [substituteChar, deleteChar, insertChar, transposeChar];
  // bias to substitutions/transposes for readability
  const weights = [0.4, 0.15, 0.2, 0.25];
  const r = rng();
  let cum = 0;
  for (let idx = 0; idx < ops.length; idx++) {
    cum += weights[idx];
    if (r < cum) return ops[idx](s);
  }
  return ops[0](s);
}

// make a typo with distance <= 2
function makeTypo(word: string): string {
  // keep pure punctuation / numbers unchanged
  if (!/[A-Za-z]/.test(word)) return word;

  // short words: restrict to single edit for readability
  const maxEdits = word.length <= 3 ? 1 : (chance(0.6) ? 1 : 2);

  // try a few times to generate an edit(s) that yield distance <= 2
  for (let attempt = 0; attempt < 10; attempt++) {
    let w = word;
    const editsPerformed = randInt(maxEdits) + 1; // 1..maxEdits
    for (let e = 0; e < editsPerformed; e++) {
      w = singleEdit(w);
    }
    // avoid producing same word or empty
    if (w === word || w.length === 0) continue;
    const dist = levenshtein(word, w);
    if (dist <= 2) return preserveCase(word, w);
  }

  // fallback: do a single substitution guaranteed to change
  let fallback = singleEdit(word);
  if (fallback === word) {
    // force substitution at first char
    fallback = (letters[randInt(letters.length)].toUpperCase()) + word.slice(1);
  }
  if (levenshtein(word, fallback) <= 2) return preserveCase(word, fallback);
  // last resort: delete last char (distance 1-2)
  return word.slice(0, Math.max(0, word.length - 1));
}

function preserveCase(orig: string, modified: string): string {
  // try to copy capitalization pattern of orig into modified when lengths similar
  if (orig.toUpperCase() === orig) return modified.toUpperCase();
  if (orig[0] && orig[0].toUpperCase() === orig[0]) {
    return modified[0].toUpperCase() + modified.slice(1);
  }
  return modified;
}

// -------------------- Markdown-safe segmentation --------------------
/*
 We will split the document into "safe to modify" segments and "protected" segments.
 Protected: fenced code blocks (```), YAML frontmatter (--- at start), inline code (`...`),
 HTML tags <...>, URLs (http(s)://...), angle-bracketed links <...@...> or <http...>,
 and markdown link destinations: we will transform the link text but not the destination.
 Strategy:
  - First extract fenced code blocks and YAML frontmatter and replace with placeholders.
  - Then process the remainder performing safe regex replacements while avoiding inline code and URLs.
*/

type Placeholder = { id: string, content: string };
const placeholders: Placeholder[] = [];
let working = text;

// extract YAML frontmatter at very start
const yamlMatch = working.match(/^---\n[\s\S]*?\n---\n/);
if (yamlMatch) {
  const id = `__PL_HDR_${placeholders.length}__`;
  placeholders.push({ id, content: yamlMatch[0] });
  working = working.replace(yamlMatch[0], id);
}

// extract fenced code blocks ```...``` (including language hints)
working = working.replace(/```[\s\S]*?```/g, (m) => {
  const id = `__PL_FENCE_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// extract indented code blocks (4-space or tab) as a block (simple heuristic)
working = working.replace(/(^((?: {4}|\t).*(\n|$))+)/gm, (m) => {
  const id = `__PL_INDENT_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// extract HTML tags (block or inline)
working = working.replace(/<[^>]*>/g, (m) => {
  // crude: don't protect simple angle-bracket math or markdown less-than but OK
  const id = `__PL_HTML_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// extract inline code `...` (single backtick) and `` `...` `` variants
working = working.replace(/`[^`]*`/g, (m) => {
  const id = `__PL_INLINE_CODE_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// extract bare URLs (http(s)://\S+)
working = working.replace(/https?:\/\/[^\s)]+/g, (m) => {
  const id = `__PL_URL_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// extract link destinations like [text](destination) -> we want to keep (destination) protected
// We'll temporarily replace "(destination)" with a placeholder, process the visible text, then restore destination.
const linkDestPlaceholders: Placeholder[] = [];
working = working.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_m, textMatch, dest) => {
  const id = `__PL_LINKDEST_${linkDestPlaceholders.length}__`;
  linkDestPlaceholders.push({ id, content: `(${dest})` });
  return `[${textMatch}]${id}`;
});

// extract angle-bracketed links <...>
working = working.replace(/<[^>]+\@[^\s>]+>|<https?:\/\/[^>]+>/g, (m) => {
  const id = `__PL_ANGLE_${placeholders.length}__`;
  placeholders.push({ id, content: m });
  return id;
});

// -------------------- word-level mutation --------------------
// We'll treat a "word" as sequence of letters (plus internal apostrophes). Preserve punctuation.
const wordRegex = /\b[A-Za-z][A-Za-z']*\b/g;

function typoifySegment(seg: string): string {
  return seg.replace(wordRegex, (word) => {
    // skip all-caps acronyms (likely proper nouns or abbreviations) with low chance
    if (word.length <= 1) return word;
    if (word.toUpperCase() === word && chance(0.9)) return word;
    // probability to attempt typo
    if (!chance(TYPO_RATE)) return word;
    // avoid changing very short words too often
    if (word.length <= 2 && chance(0.7)) return word;
    try {
      return makeTypo(word);
    } catch (e) {
      return word;
    }
  });
}

// Apply to working text; but we should avoid altering link destination placeholders that are like __PL_LINKDEST_x__
let processed = working.replace(/__PL_LINKDEST_\d+__/g, (m) => m); // no-op, kept in text for now

// Now process the text but do not touch placeholders (they are uppercase with underscores)
processed = processed.split(/(__PL_[A-Z0-9_]+__)/g).map((part) => {
  if (part.startsWith("__PL_") && part.endsWith("__")) {
    return part; // protected placeholder
  } else {
    return typoifySegment(part);
  }
}).join("");

// restore link destination placeholders: replace each __PL_LINKDEST_n__ with its original "(dest)"
for (const ph of linkDestPlaceholders) {
  processed = processed.replace(ph.id, ph.content);
}

// restore other placeholders (yaml, fences, inline code, urls, html, etc.)
for (const ph of placeholders) {
  const re = new RegExp(ph.id.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g");
  processed = processed.replace(re, ph.content);
}

// final output
await Deno.writeTextFile(outPath, processed);
console.log(`Wrote typofied markdown to ${outPath}`);
console.log(`Settings: rate=${TYPO_RATE}, seed=${SEED}`);
