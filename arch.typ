

= Opportunistic consensus

A system that can work when consensus can be obtained, and when it is inaccessible.

The system maintains consistent behavior. The withdrawal of consensus does not break the system according to a certain definition of 'breaking'

A system that can work with multiple sources of consensus.

*A consensus is defined as*, from the perspective of obtainer, with a given *seed data*, with finite steps, a globally unique state can be obtained, with regard to a time point (physical time, assuming Minkowski spacetime), in material reality. $f(t)=s$

$
  CC "from the obtainer" : ("Seed","Procedure",t) -> C(t):=s_t
$

The notable difference from typical algorithmic paper is that it involves physical time as an inherent, important, part of the description.

This definition involves material reality, which means it's not a construct that only involves abstract ideas.

This is a practical definition, that is to say, we don't care how it is achieved. We don't talk about consensus mechanisms. We talk about effects, the probability that such consensus fails, etc. This is the power of algebraic reasoning.

Blockchains match this definition, while web-of-trust systems don't. Wot heavily depend on parameters that vary by person. Blockchain only requires a genesis block as seed data.

This notion is formulated because the stronger system, always-consensus, is, practically speaking after this much surveying, hard to implement given goals stated below.

$
  CC_b:cases(
    S="genesis block",
    P="getting blocks and verifying",
    t="desired time of interest"
  )
  ->C(t) \
  CC_b "holds for all observers"
$

Now, here is the analysis of web-of-trust

$
  CC_w:cases(
    S="some people I found trustworthy from random community",
    P="getting relevant data",
    t="desired time of interest"
  )
  ->C(t) \
  CC_w "can vary greatly due to choice of "S
  "resulting in divergence of" C(t)
$

Some people may suggest that an alternative $C_1$ is, rather _the_ correct consensus.

No I am not postulating that $C$ is subjective, as that contradicts the definition. The definition represents an algorithm that reaches a consensus _per se_, regardless of observer.

So in WoT model, some believe its acceptable that there exist a pool of consensus, where each person can reach one, which is believed, to better suit him.

= Eventual consistency

An eventual consistent system reaches agreement when a node receives all the messages that have been sent.

The system consists of states, where each $s$ has an _equality relation_ defined by the system.

There exists a _partial order_, such that $forall s_1, s_2 exists s_3 >=s_1 and s_3>=s_2$, which is called a _join_

$
  Sigma=(S,=,>=,"join",Delta)
$

In a grow-only set, two nodes having divergent sets can exchange messages, \ and reach a _join_ = $A union B$

A grow-only set is isomorphic to $NN$ on eventual consistency $Sigma$

$
  U="all possible set elements"\
  S subset.eq U\
  >=' := supset.eq \
  "join" :=A union B \
  Delta subset.eq U
$

Typical chat protocols, without central server intervention, like Matrix, are not eventually consistent

Chat protocols tend to adopt a directed acyclic graph where nodes are signed messages with receipt of earlier messages.

A join is only possible when a message that merges all branches exist. Alternatively, redefine _equality_, or produce virtual states.


Is it possible to construct a distributed data structure, and reduce finding the join, to be a search problem.

Or structure it such that, after receiving $a$ states, a `max` can be guaranteed.

$
  t "for epoch, an interval of physical time as in physical reality" \
  e=(t,s) \
  "For" t' ,max_(forall e(t=t',s))(s) =>"the consensus at" t'
$

We can adopt an empirical constraint of $max$.

Blockchains do not satisfy this requirement, ie, lack of absolute finality. They can only constrain it by threat of slashing.

== Absolute finality

$
  S_t={e | (t',s) and t'=t} \
  exists max(S_t)
$

If $S_t$ is finite and unchanging, $max(S_t)$ is a constant. It can not represent a state.

If $S_t$ is infinite, $max(S_t)$ does not exist. 

We must make $max(S_t)$ encode a state we want to convey.

=== Honest signaler assumption

The signaler may release any message from the set, $s' in S_t$

We model observer as a node with state $S_o subset.eq S_t$

$
  S("Current state") = max(S_o)
$

Can we make $max(S_t)$ dependent on $S_o$. This may encode a useful state, but observers may not converge due to difference in $S_o$

==== The trivial case of $NN$ counter

The signaler may release any $n in NN$

$
exists.not max(NN)
$

The observers take $max(S_o)$. No shrinkage of $S_t$ can be expected.

=== Finite state transducer 

If the observers can be modelled as FSTs, an output string would be produced after finite reception of messages. The state changes are the messages, in the order of hash-chain order.

$|S_t|$ decreases as $|S_o|$ increases

=== First message wins

For $t_1$, a protocol can define the first message from the signaler to be accepted as consensus, because $|S_t|=1$ and _by honest signaler assumption_.

This is, however, not that useful. 

I should revise the assumption. In many cases, there is the the _reversion attack_. A key gets stolen and it's used to reverse a consensus.

This can be easily done, with a _state oracle_

+ An authoritative server
+ State proofs from some blockchain

=== re-Formalization of the hashed DAG

Nodes are messages, which are often state deltas, and _ultimately_ represent states.

Links based on cryptographic hashes are proofs of _temporal/causal precedence_

DAG is a set of states with a partial order. Note that this comes with something beyond math. The block linked by another block can only be created, first.

== Branching attack / Reversion attack

The central problem in the state synchronization turned out to be branching. 

$S_o$ is defined to be the internal belief of a node about some state. 

Theoretically, after $t_1$ passed, State before $t_1$ shouldn't change anymore, by definition.

The node may ignore further messages that change the past state, but new nodes can be "deceived".

The only solution to branching attack is "coercion", or "will" that complies with the protocol

For coercion, blockchain offers most coercion, and it can be very efficient. 

A blockchain with 1M dollars at stake can handle infinite amount of state. 

For will, you can use a "trust" based mechanism to pick _complying_ sources.

Consider a blog that has one signer and is stored as a DAG. The blogger is benign to himself, ie, he doesn't attack his own blog. 

One day he lost his key. The attack erases the entire blog by signing an alternative branch with empty content. 

The two branches are inherently non-comparable states. Old nodes can ignore the new message, but new nodes get deceived. 

The simple solution is to, finalize every blog change to a blockchain, ie. include the blog state in the blockchain state root.

Now, to attack a small blog the attacker has to go against the entire blockchain. 

Isn't this cost-efficient?

== TODO: Review blockchain state proof candidates

Recalling from meory, there are a few 

- ZK proofs that simply prove entire chain of state transitions up from genesis, eg. Mina.
- Multi-signatures from the quorum, eg. Ethereum.

== TODO: How do contracts use them 

- Contracts can use them by themselves, indenpdently. 
  -  I should write some lib for this. 
- Aggregate them to save gas fee on chain? 

= Web of trust

We characterise blockchains as innately trustworthy agents that follow the protocol, with the nuance that, they vary in degrees of reliability. 

- If, say, a blockchain has stakeholders that are in secret collusion. They can collectively defy the protocol. The goal of the field has therefore been optimizing towards a state apparatus where all the members know nothing but to follow the protocol. 
  - Culminating in Nullchinchilla's https://melproject.org/en/

Hereby, we define blockchain as an institution, wherein members are reduced to cogs and rules prevail, which as a whole is an _agent_ with some will, some expected behavior to outsiders.

The other _orthogonal_ perspective is to not make innately _aligned agents_ with regard to our goals. 

The story starts from that when you use a usual web service, you trust a single corporate operator, which they call a single point of failure.

Going up the metacognitive hierarchy we know it's only conceptualized as a single operator, but in reality it's under the influence of internal corporate employees and various dynamics. 

== Alignment 

Analysis has shown that all of that is ultimately directed towards _alignment_. We want a blockchain to follow a protocol; we want trusted CA roots in our browser to act "honestly". 

Either by coercion or voluntary alginment from the other side, it's going to be done. 

The society constantly does a web-of-trust thing, the credit ratings, the connections underlying business world, the bureaucracy of tangible state.

Consider, in the new social platform, you have a list of subscribed news channels. You maintain the list to kick out "malicious sources" that publish ADs, etc. 

As a form of decision making

- You may adopt information from other trusted agents, to efficiently remove more malicious sources
  - which forms the graph structure of web-of-trust

As a state apparatus

- You coerce people into behaving to your liking, ie, _alignment_ by the threat of unfollowing.
- You maximize coercion by forming coalition with other people
  - which necessitates the graph structure

Hereby I pointed out the metacognitive underpinnigs of the seemingly innocent idea of web-of-trust.

=== Avenues of improvement 

The part of coercion can be furthered by forming a larger governance structure where a ban happens decisively. Sure, this institution can go corrupt, or undesirable as in my views. 

There is a lot that can be done to engineer a better _institution_ in this realm of computation. 

- Anonymous voting that is decentralized
- Anonymous voting with more complex voting mechanisms

== Law of necessary solution

If a good, decentralized solution is not present, and a solution is demanded, people will opt-for whatever is available. 

- People go to corporate-run platforms because socialization is a necessary demand. 
- Matrix users run centralized ban-lists to keep out malicious actors

I disdain the centralized ban-lists due the above reasons. In any case, this section serves to warn you against ignoring any unsolved-demand. They can go in the ways you hate.

== Law of necessary existence

If you don't make an institution that removes CSAM, your protocol will face existential threat.

If you don't make an ideal, non-biased institution that removes CSAM, people will invent one themselves and it will probably be biased, corrupt, and centralized.

