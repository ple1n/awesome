
= Overview of design of Matrix-2

The _ui_ in the file name can be seen as _user interaction_

A few major forms of user interfaces of social platforms exist

- The news feed, such as Reddit
  - Interactions are presented in the Tree of comments
  - Threads and comments are separated
- The algorithmically sorted, homogenous posts, Twitter
  - There is no distinction between threads and comments
  - Posts are presented to readers, fairly randomly, as determined by the feed algorithm
- The instant messaging platforms
  - Main objects of interest include, Rooms, Channels, Spaces

Motivation: It's better to design better _modes of interaction_ to optimize user experience and reduce roundtrips.

= Backlog

+ Find a primary ZKVM
  - sp1, blocked by #link("https://github.com/succinctlabs/sp1/issues/2315", [native hash])
  - compile #link("https://github.com/starkware-libs/stwo", [stwo]) to wasm and run it in freenet2
+ Opportunistic consensus scheme with Mina
  - run it in freenet2
+ Reputation proof system, blocked by *1*
+ Evaluate reputation models