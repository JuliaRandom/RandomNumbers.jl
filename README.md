# RandomNumbers.jl
*Random number generators for the Julia language.*

Build Status
[![Build Status](https://github.com/JuliaRandom/RandomNumbers.jl/workflows/CI%20Build/badge.svg?branch=master)](https://github.com/JuliaRandom/RandomNumbers.jl/actions)

Code Coverage:
[![codecov.io](https://codecov.io/github/JuliaRandom/RandomNumbers.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaRandom/RandomNumbers.jl?branch=master)

Documentation:
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliarandom.github.io/RandomNumbers.jl/stable/)
[![Devel Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliarandom.github.io/RandomNumbers.jl/dev/)

**RandomNumbers.jl** is a package of [Julia](http://julialang.org/), in which several random number generators (RNGs)
are provided.

If you use the Intel Math Kernel Library (MKL), [`VSL.jl`](https://github.com/JuliaRandom/VSL.jl) is also a good
choice for random number generation.

## Installation

This package is registered. The stable version of this package requires Julia `0.7+`. You can install it by:
```julia
(v1.0) pkg> add RandomNumbers
```
It is recommended to run the test suites before using the package:
```julia
(v1.0) pkg> test RandomNumbers
```

## RNG Families

There are four RNG families in this package:

- [PCG](http://juliarandom.github.io/RandomNumbers.jl/stable/man/pcg/):
    A new family of RNG, based on *linear congruential generators*, using a *permuted function* to produce much
    more random output.
- [Mersenne Twister](http://juliarandom.github.io/RandomNumbers.jl/stable/man/mersenne-twisters/):
    The most widely used RNG, with long period.
- [Random123](http://juliarandom.github.io/RandomNumbers.jl/stable/man/random123/):
    A family of good-performance *counter-based* RNG.
- [Xorshift](http://juliarandom.github.io/RandomNumbers.jl/stable/man/xorshifts/):
    A class of RNG based on *exclusive or* and *bit shift*.

Note that `Random123` is now made a separate package as [Random123.jl](https://github.com/JuliaRandom/Random123.jl).
You can still use your old code with `RandomNumbers.Random123` as long as you import `Random123` manually.

## Usage

Please see the [documentation](http://juliarandom.github.io/RandomNumbers.jl/stable/man/basics/) for usage of this package.

## License

This package is under [MIT License](./LICENSE.md).
