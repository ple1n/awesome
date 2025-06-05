
There are three types of bundles of solutions to ZK. 

1. ZKVMs. They compile general programming languages to ZK bytecode and interpret them and generate proofs. 
    They are limited to the imperative execution style of Turning model.
    The lack of high level information and the model limits their room for optimization

- https://github.com/risc0/risc0 

Risc0 is production-ready, works over std Rust, and produces STARK proofs. 

It doesn't expose an easy way to efficiently work on field arithmetics like doing poseidon hashes, so I had to continue the search. 

Either, it optimizes by replacing things such as SHA256 with a syscall, or with a cargo-patch, which often fails, because every library almost uses diffferent field arithmetic primitives. 

- https://github.com/succinctlabs/sp1/
    - which bases on https://github.com/Plonky3/Plonky3

Plonky3 looks like a usable enough framework to handwrite provers. 

Similarly, there is https://github.com/zcash/halo2

2. Frameworks and compositions

This is the second type of choice, which the VMs use under the hood.

- https://github.com/facebook/winterfell also a STARK framework. The way it looks seems to enoucrage handwritten composition and direct use of the lib. I sort of like this compared to the blind VMs.
    This one is not production-ready

- https://github.com/zcash/halo2 is another ergonomic framework way of ZK-system cosntruction. It's probably not quantum-proof.

3. DSLs

The one I like most should be 

- https://github.com/starkware-libs/cairo

It comes with a cargo equivalent `scarb`. 

You can compile the DSL to byte code (I mean low level representations in general), and do `scarb prove  --execution-id 1` to generate a proof. This command is NOT production-ready yet.
It depends on stwo. I still want to use this because their v1 is implemented in c++. The entire v2 suite in written in Rust. 

I have the goal of `easy shipping of provers and verifiers` to end-clients, which diverge from their intended goals. Ideally, I want the system delivered to end-devices with minimal deplolyment risks. You know how much of a problem compiling C++. There is the determinism in the Rust-based codebase, for delivery.

Freenet2 (https://github.com/freenet/freenet-core/) is not Freenet1. They are completely different things. 

Freenet2 models every Freenet-App as a state machine, which is, literally represented by blobs of WASM. The idea is to ship provers and verifiers in the WASM blobs. 

It's certainly okay to ship their STARK V1 prover (named, stone) in the WASM, but we, would become a single point of faliure. I don't want users to handle the compiling problems either. 

- The second-line choice is Noir, https://github.com/noir-lang/noir

which is not stable, nor quantum-proof, as it compiles to R1CS typically used in ZK-snarks systems, but at least it exposes convenient built-in functions such as pedersen hashes, https://noir-lang.org/docs/noir/standard_library/cryptographic_primitives/hashes#pedersen_hash 

It also exposes field arithmetic, but it's *unclear* how optimized the std provided poseiden hash function can be. I did not do a benchmark. 

That why I want the frameworks to expose low level field arimetic intrinsics is that I have been having the idea to implement crypto-heavy data structures like sparse merkle tree in the proving system, which RISC0 can not handle because it doesn't expose poseiden, or at least, field arithmetic, properly. Sp1 failes the requirement too. 

Cairo does expose Posieden, Modular arithmetic, Pedersen, as builtins, which is nice. https://book.cairo-lang.org/ch204-02-07-poseidon.html

> One question left for later investigation is whether the Poseiden builtin can be tuned to use t=3, which is a smaller parameter than whats usually used in the larger proving system. 
> Such as small parameter is suited for arity=2 Merkle trees. 

Then, as a DSL it can capture all the field operations, unlike what happens in Risc0, that the VM might miss some operations and exectue them as regular `usizes`.

Noir's main backend is barretenberg https://github.com/AztecProtocol/aztec-packages 

SOTA ZK-snark systems should be much faster and smaller than STARK systems. 

Good list for plonky3 https://github.com/Plonky3/awesome-plonky3