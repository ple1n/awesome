I believe there are 2 avenues that are the best choice of time, that you may take to achiveve some certain goals.

1. Mass adoption of an easily deployed, performant, decentralied services, protocols.
2. Rejuvenation of Anonymous networks, or systems in general. 

There is also the 3rd problem, or avenue, or topic, that is parallel to both concerns.

3. The *direct* connectivity problem. 

For easier illustration of the 3rd problem, I'll start with Yggdrasil. 

It provides no anomymity, or encryption, or any guarantee of decentralization in the manner that the super-paranoid wants. It only tries its best to route any node from one point on the globe, to another point.

One interesting finding I want to add to (2), at the beginning of this writeup, is the inception of Verifiable Shuffle.  

https://github.com/kwonalbert/riffle

The fundamental working of mixnets, is the delinking of IPs. 

When some communication happens, the observer can link the source of a packet, to the destination. 

There is this leak of information that happens at the routing aspect of IP protocol. Yes, I have read about anonymity network designs that tries to directly address this problem at this layer.

We continue to formulate the notion of observers. 

We consider observers anyone who is not part of the communication process, eg, two nodes.

Mixnets cause that even strongest observers that log all the traffic that happen in public, unable to link one IP to another IP when it intercepts a packet, unable to link one IP to another IP when a node sends a packet. 

This entire thing can be done on a single server/node with *Verifiable Shuffle*. 

All packets are uploaded to the server, they can verifiably shuffled and re-delivered to designated recipients. 

All the packets are encrypted. To this node, which holds all the observable data in public, it's impossible to find the recipient IP given a pending packet, and impossible to find the sender IP when the shuffle has been done. 

Mixnets are probabilistic. That is to say, given an omnipotent observer is possible to de-anonymous all traffic. Verifiable Shuffle is NOT probablistic. 

Another idea is, *one-sided anomymity*. We can develop tools to faciliate this kind of anonymity. 

Take FHE for example, it's possible to query an encrypted database, get the data associated with a key, without revealing what the key is to the server. 

4. The specialized firewall evaders. 

https://gfw.report/

There is an entire literature regarding the caveats connected to the designs of systems that are compatible with users in censored regions. 

I recommend you make the worst assumptions. That the user doesn't have a stable connection. Massive delays, frequent changes of relay nodes, etc. 

These problems easily make usual system package managers non-functional. 

Here, I introduce Freenet2 which is fundamentally compatible with this suite of assumptions. 

Unlike the great old internet, Freenet2 works on the basis of states and their updates. The great old internet works on the basis of peer-to-peer, or recently, the peer-to-datacenter, structures. 

You can see how TCP specification deals with how the packets are resent and how the connection should be maintained; the underlying thing is that they work with *connections*

They are connection oriented protocols/paradigms. I never implied they should be phased out or anything or TCP should be dropped. No I specifically meant the paradigm not any specific protocol.

The demand of users are, I mean the technnological requirement of their Apps are intrinsically *mixed*. 

What I mean by *mixed* is that they can not be characterized by one overarhcing protocol primitive/goal. 

Say, a chat App, may require state-persistent text chat logs and real time voice calls. 

And on the other dimension the user may need the firewall evasion, the anonymity, the direct-connectivity (which haunts the modern internet).

Let's break down the demand analytically like some mathematical decomposition

- Persistent-state
    - solution, Freenet2
- Real time calls
    - Direct-connectivity
        - eg, Yggdrasil
    - Censor-evasion
        - solution, https://github.com/geph-official/geph5
- State fidelity
    - Cryptocurrency based verifiers
- Stickers, public resources that are shared widely
    - IPFS (I have negative impression about thsi thing if anything. It's routing is slow. I think it's just not taking my concerns into consideration)

The main point I wanna say is that I've seen peoeple who kind of want one technological notion to cover all the demands and be super narcissistic about it. 

Empirically, (as in from the angle of observation and statistics), users tend to use a combination of methods to reach their goals. 

Secondly I hate the people that want to bundle everything together naively to present a 'universal solution'.

## The workings2 of Freenet2

To understand freenet2, the notion of *state machine* must be introduced. 

It's everywhere.

Think of OOP languages (on a tangent I'd rather consider it a form of type system not OOP or some cool paradigms)

You create an object, and it has some methods. 

The internal variables of an object as a whole, is called the state of the object, and you perform state changes through the methods.

This notion is extended in Actor Model, actor systems, because this form of system is intrinsically amenable to async programming. 
Each object is then called an actor, and all state changes happen through an act of *communication*, which can be exactly framed as bytes passed around. 

Rust uses state machines for the async system. State machines, constructed to encode the data, are also used in some data strcutures to represent a set. 

Freenet2 is a distributed database, that contains a sea of state machines, where each state machine has a ruleset defining the set of acceptable states. 

This is a good enough assumption to work with when we want to address the routing problem independent of specific Apps. 

Federated networks such as Mastodon and Matrix have no routing. They are just a cluster of servers that communicate with each other whenever the RFCs demand it.

Oftentimes they form a fully connected network, where each state update is passed to every other server. Denote the number of nodes as n, we get n packets for one update, which for all nodes, is n^2. 

In the worst case a server can receive n redundant copies from all other servers, as all other servers have this new state and are not aware of each other. 

This does not happen in DHT-like systems in general, as state updates are only passed to nodes that are deeemed responsible for it. 

DHT systems like torrents are optimized for static files, which is out of scope for now. If X is not optimized for Y, we don't talk about it. That's a general truth. 

### Bluesky, Nostr, ...

There is one central feature I like about Freenet2 is its purity, as in minimal assumptiions about state machines. 

Bluesky contains a graph, like IPFS, and Nostr is just a very simple thing built around 20 years old cryptography. 

There will not be any need for RFCs. You want a new protocol. You just compile it and deploy it to the network with a oneliner. 

Freenet2 is naturally compatible with novel cryptography. Again, due to the minimalism. You can put novel cryptosystems in the compiled WASM blob that faciliates whatever n-signer anonymous voting.