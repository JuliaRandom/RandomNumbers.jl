# TODO

## General
- Redesign the framework of RNG in Julia Base.
    - `advance!` function whenever possible.
    - `copy` and `copyto!`.
- Help improve `Distributions.jl`.

## PCG
- Implement the extended version of PCG generators, which supports larger periods.
- Figure out the performance issue of `PCG_XSH_RS`: it is expected to run faster than `PCG_RXS_M_XS`.

## Mersenne Twisters
- Implement the 64-bit version of `MT19937`.

## Random123
- Make use of `CUDA` or `OpenCL`.
- Improve the performance.
- Store counters in a better way.

## Wrapped RNG
- A function to be constructed from another `WrappedRNG`.

## Others
- Perhaps consider implementing `arc4random` or `Chacha20`, which is slow but cryptographically secure.
- Something like `seed_seq` in C++.
- Test submodules separately.
