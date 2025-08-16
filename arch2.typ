
= Iteration 2 on Drafting a new chat protocol

Freenet is a greedy-routed, permissionless, distributed hash table.

Controlling large blocks of IPs that correspond to specific hashes can attack the corresponding contracts.

Contracts are stored at quasi-random locations depending on (code+init_parameters). Each peer prioritizes well-behaving direct connections.

Each new contract lookup takes $O(log n)$. Known contracts take $O(1)$.

Larger blocks of IPs directly correspond the ability to insert the attack itself as valid peers for any contract. eg. Controlling 20% of IPs correspond to the ability to insert itself into peer list of 20% contracts, at evenly distributed locations, to blackhole certain contracts or such.

Contracts are expected to persist for hours to months.

== Tip selection

In classical model, the central server acts the sole decider of directed acyclic graph where links represent message precedence.

+ Posting message hashes to blockchains with state proofs. This method will not be used currently until https://github.com/o1-labs/proof-systems matures


Proving anonymous set membership
- https://github.com/worldcoin/semaphore-rs
- https://github.com/semaphore-protocol/semaphore-rs

Arkworks circom has bn254 circom parser. These two projects use bn254 too.

This curve is also known as bn256 or bn128 (alt-bn128) referred to the bits of security. The bits of security of bn254 dropped from 128 to around 100 after the new algorithms of Kim-Barbulescu.

#quote(
  [At 128 bits of security we find that the best pairings in the BD model are BLS-24 and BLS-12. The best pairings are not affected by the new polynomial selection method. At 192 bits of security, we find that the new champions are the less known BLS-24, KSS-16 and KSS-18. At 256 bits of security we conclude that the best pairing is BLS-27.],
  attribution: [https://eprint.iacr.org/2019/485],
  block: true,
)

This problem is context dependent.

We demand each message to include a hash which acts as receipt for last message seen, by sender.

- An attacker may branch a chain to hijack current chat view

For users that are currently chatting, they have a chain of messages locally. The clients can simply ignore the branching, and place the message right below its receipt.

For new users, it can be a problem as the attack can create an arbitrarily long branch.

We introduce tip-witness servers or agents (same thng) for branch selection.

Consider a contract, it can have one or more hardcoded owners, etc. Contract code is root source of power.

The owner picks a few public servers, which can serve thousands of contracts.

We don't expect users to be constantly online. We keep a pool of witness servers.

The witness servers don't host contracts. They only witness events.

User creates a message $m$ and hash $H(m|n)$ with random $n$, sends $H$ to one or more servers.

The servers sign the message $S(H | t_1)$ attesting the time.

This commitment scheme is used to prevent servers from selectively refusing to sign.

The user aggregates the signatures and post his message in the chat room $m_1=(m,S,n,t_1)$

An honest server never signs messages in reverse order.

$
  S_1(H_1|t_1) \
  S_2(H_2|t_2)
$

If $H_2 -> H_1$, ie. $H_1$ is hashed into $H_2$, we have $t_2>t_1$

$
  P=S_1,S_2 "where" t_1 > t_2
$

We can show $P$ and the hash chain to prove a server is misbehaving. The whole proof can be posted to an aggregate contract which represents a set of bad witness servers.

Typically, some servers host the contracts and are selected by owners as trusted witness servers. But this scheme allows owners to choose non-hosting servers, which increases server capacity and censorship-resistance. 

If hosting servers are chosen as witness servers, they may selectively 'witness' branches, populate specific branch of chat logs, by colluding with room members.

== Indexing

In a chat room, besides locally indexing the content, the contract can also contain a list of indexing servers.

Servers/peers can be identified with Nym, Lokinet, raw IP, Tor addresses. 

Indexing can also be done by constructing an overlay hashtable over Freenet.

Such that, for a given message hash $X$, we can find it on contract $Y$ with adddress derived from $X$, by sorting the message hashes and distributing it over $k$ contracts.

We can have more than one levels, such that this index takes $k dot O(log n)$

== Fuctionalized quorum

Here I present an interesting construct. 

Consider, 

- Base currency of some sort that everyone would like more of that, regardless of personal goals.
- Voting power
- Some function we want the quorum to perform
- The quorum can not communicate with each other

We present an image to the quorum, or a randomly chosen subset of the panel.  

- Each member is asked whether the image is illegal and should be taken down. 
  - Of course, each member would have their personal goals and try to subvert the system
- The majority wins, and they get rewarded the _base currency_
- The quorum is chosen beforehand such that the majority of them aligns with our intention, answers honestly.
- The minority is gradually purged from the quorum. 
- This scheme self catalyzes "good behavior"

We investigate two cases of base currency:

- It being money
  - We should select the quorum to be money-seekers, not rich-already, or ideologically motivated people.
- It being community currency
  - We need to select people who value the currency, ie. for whom it has use. 

The limit with this system is that it only works with "easily decidable questions

== Room creation 

In freenet, contract address is $H("contract_code" | "init_params")$

Room contract shall be inited with $"init_params"=("moderation","rotation")$

Rotation is a parameter such that a room consists of a list of contracts, as buckets of messages, where each contract address can be computed without extra lookup. 

For contract $"rotation"=1$, it can store at most $k$ messages, and overlap with both preceding and suceeding contracts. Overlapping because moving to new contract takes some time. 

== Attributable content 

Here I present a new _construct_, attributable content, a type of content that can be easily proved in ZK to be attributed to some author, such as

- Chat messages with signatures, corresponding to some publickey
- Chat messages that are followed by hashes that are commitments. Let's call these hashes publickeys too, with hash function such as Poseidon2

This construct facilitates easier construction of anonymous reputation systesm. 

Piece of content, may contain endorsement of other content, in the form of mentioning their publickeys, almost like citation. 

Hereby we get a public graph of attributable content.

== Reputation processor

Reputation processor regularly publishes a hash table $f="publickey"->"score"$

Reputation proof can be constructed as 

$
  cases(
    "ownership of publickeys" v_p,
    v_p subset.eq f,
    sum "score" > "claimed score"
  )
$

The proof can be constructed in more than one way 

+ The proof may force the prover to reveal $H("secret")$ such that each publickey can only be used once
+ The proof may force the prover to reveal $H("secret" | "public_string")$ such that each publickey can only be used once _in some context_

For `publickey`, the `secret` can derive `publickey`, so it should never be revealed, in any proof protocol.

Rather than seeing the web as a collection of authors, we see attributable content. 

Reputation processors, may calculate reputation like regular blackbox servers, or they can make it trustless. 

=== Trustless reputation processors 

Such a processor takes a graph of attributable content, $G$, and runs a reputation estimation model, $f:G->("publickey"->"score")$, in ZK.

== Pool of benign dictatorships

Hereby I present a new _construct_, I see the optimal political structure here to be such a pool. 

+ The pool is open to competition
+ Dictatorships are designed to be as efficient and powerful as possible. 

Hence I will design an efficent chat moderation system that efficiently exercises the power of the dictator.

Mass redactions and blacklisting, within a room contract.

Room contract power is seen as a state machine $S->S_1$

To redact content, denote this state delta as $R$

$
  P(S_1) "zk-proof that I have power to perform such redactions over current state" \
  S={m} "set of hashes of messages to redact" \
  "TTL"=t_1
$

Trivially, we can fold past $R$s into one $R$ with ZK.

TTL is introduced because typically, redaction can be done within minutes. The state delta finishes its work when its fully propagated through the network, and can be thus pruned.

== Unique room and account names 

The best solution to that currently is to just use Mina blockchain.

Have each chat app run a Mina chain client, and a mapping of names to publickeys.

We may also, only run a Mina client, such that we have a trusted state root hash, and request $("key","value","zk-proof over state root")$ from servers on demand, which is trustless. 

== On ZK systems 

For robust and quantum proof the best choice so far is https://github.com/ProjectZKM/Ziren 

- Todo: check that it compiles in WASM

For fast proof generation we need Mina's system. 

Note, cloning Mina takes a lot of time, use `git submodule update --init --recursive --progress --depth 1`

I expect Mina to be obsoleted and replaced with a blockchain with recursive STARK.