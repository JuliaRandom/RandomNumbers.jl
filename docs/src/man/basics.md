# Basics

This page describes basic concepts and fundamental knowledge of **RandomNumbers.jl**.

!!! note
    Unless otherwise specified, all the random number generators in this package are *pseudorandom* number
    generators (or *deterministic* random bit generator), which means they only provide numbers whose
    properties approximate the properties of *truly random* numbers. Always, especially in secure-sensitive
    cases, keep in mind that they do not gaurantee a totally random performance.

## Installation

This package is registered. The stable version of this package requires Julia `0.7+`. You can install it by:
```julia
(v1.0) pkg> add RandomNumbers
```

It is recommended to run the test suites before using the package:
```julia
(v1.0) pkg> test RandomNumbers
```

## Interface

First of all, to use a RNG from this package, you can import `RandomNumbers.jl` and use RNG by declare its
submodule's name, or directly import the submodule. Then you can create a random number generator of certain
type. For example:

```julia
julia> using RandomNumbers
julia> r = Xorshifts.Xorshift1024Plus()
```
or
```julia
julia> using RandomNumbers.Xorshifts
julia> r = Xorshift1024Plus()
```

The submodules have some API in common and a few differently.

All the Random Number Generators (RNGs) are child types of `AbstractRNG{T}`, which is a child type of
`Base.Random.AbstractRNG` and replaces it. (`Base.Random` may be refactored sometime, anyway.) The type
parameter `T` indicates the original output type of a RNG, and it is usually a child type of `Unsigned`, such
as `UInt64`, `UInt32`, etc. Users can change the output type of a certain RNG type by use a wrapped type:
[`WrappedRNG`](@ref).

Consistent to what `Base.Random` does, there are generic functions:

- `seed!(::AbstractRNG{T}[, seed])`
    initializes a RNG by one or a sequence of numbers (called *seed*). The output sequences by two RNGs of
    the same type should be the same if they are initialized by the same seed, which makes them
    *deterministic*. The seed type of each RNG type can be different, you can refer to the corresponding
    manual pages for details. If no `seed` provided, then it will use [`RandomNumbers.gen_seed`](@ref) to get
    a "truly" random one.

- `rand(::AbstractRNG{T}[, ::Type{TP}=Float64])`
    returns a random number in the type `TP`. `TP` is usually an `Unsigned` type, and the return value is
    expected to be uniformly distributed in {0, 1} at every bit. When `TP` is `Float64` (as default), this
    function returns a `Float64` value that is expected to be uniformly distributed in ``[0, 1)``. The
    discussion about this is in the [Conversion to Float](@ref) section.

The other common functions such as `rand(::AbstractRNG, ::Dims)` and `rand!(::AbstractRNG, ::AbstractArray)`,
and the ones that generate random numbers in a certain distribution such as `randn`, `randexp`, `randcycle`,
etc. defined in the standard library `Random` still work well.
See the [official docs](https://docs.julialang.org/en/latest/stdlib/Random/) for details. You can also refer
to [this section](@ref common-functions) for the common functions.

The constructors of all the types of RNG are designed to take the same kind of parameters as `seed!`. For example:

```jldoctest
julia> using RandomNumbers.Xorshifts

julia> import Random: rand!

julia> r1 = Xorshift128Star(123)  # Create a RNG of Xorshift128Star with the seed "123"
Xorshift128Star(0x000000003a300074, 0x000000003a30004e)

julia> r2 = Xorshift128Star();  # Use a random value to be the seed.

julia> rand(r1)  # Generate a number uniformly distributed in ``[0, 1)``.
0.2552720033868119

julia> A = rand(r1, UInt64, 2, 3)  # Generate a 2x3 matrix `A` in `UInt64` type.
2×3 Array{UInt64,2}:
 0xbed3dea863c65407  0x607f5f9815f515af  0x807289d8f9847407
 0x4ab80d43269335ee  0xf78b56ada11ea641  0xc2306a55acfb4aaa

julia> rand!(r1, A)  # Refill `A` with random numbers.
2×3 Array{UInt64,2}:
 0xf729352e2a72b541  0xe89948b5582a85f0  0x8a95ebd6aa34fcf4
 0xc0c5a8df4c1b160f  0x8b5269ed6c790e08  0x930b89985ae0c865
```

People will get the same results in their own computers of the above lines. For
more interfaces and usage examples, please refer to the manual pages of each RNG.


## Empirical Statistical Testing

Empirical statistical testing is very important for random number generation, because the theoretical
mathematical analysis is insufficient to verify the performance of a random number generator.

The famous and highly evaluated [**TestU01** library](http://simul.iro.umontreal.ca/testu01/tu01.html) is
chosen to test the RNGs in `RandomNumbers.jl`. **TestU01** offers a collection of test suites, and
*Big Crush* is the largest and most stringent test battery for empirical testing (which usually takes several
hours to run). *Big Crush* has revealed a number of flaws of lots of well-used generators, even including the
*Mersenne Twister* (or to be more exact, the *dSFMT*) which is currently used in `Base.Random` as
GLOBAL_RAND`.[^1]

This package chooses [RNGTest.jl](https://github.com/andreasnoack/RNGTest.jl) to use TestU01.

The testing results are available on [Benchmark](@ref) page.

[^1]:
    [`rand` fails bigcrush #6464](https://github.com/JuliaLang/julia/issues/6464)


## Conversion to Float

Besides the statistical flaws, popular generators often neglect the importance of converting unsigned
integers to floating numbers. The most common situation is to convert an `UInt` to a `Float64` which is
uniformly distributed in ``[0.0, 1.0)``. For example, neither the `std::uniform_real_distribution` in
libstdc++ from gcc, libc++ from llvm, nor the standard library from MSVC has a correct performance, as they
all have a non-zero probability for generating the max value which is an open bound and should not be
produced.

The cause is that a `Float64` number in ``[0.0, 1.0)`` has only 53 *significand* bits (52 explicitly stored),
which means at least 11 bits of an `UInt64` are abandoned when being converted to `Float64`. If using the
naive approach to multiply an `UInt64` by ``2^{-64}``, users may get 1.0, and the distribution is not good
(although using ``2^{-32}`` for an `UInt32` is OK).

In this package, we make use of the fact that the distribution of the least 52 bits can be the same in an
`UInt64` and a `Float64` (if you are familiar with
[IEEE 754](https://en.wikipedia.org/wiki/IEEE_floating_point) this is easy to understand). An `UInt64` will
firstly be converted to a `Float64` that is perfectly uniformly distributed in [1.0, 2.0), and then subtract
one. This is a very fast approach, but not completely ideal, as the statistics of the least significant bits
are affected. Due to rounding in the subtraction,

- the least significant bit of `rand()` is always 0, the second last is only at 25% a 1, the third last bit is at 37.5% chance a 1, the n-th last bit is at p=1/2-2^(-n) chance a 1. In practice, this only affects the last few bits, but holds for `rand(Float32)` as well as for `rand(Float64)`.
- the sampling is not from all floats in [0,1) but only from 2^23 (Float32) or 2^52 (Float64).
- The subset of floats which is sampled from is every second float in [1/2,1), every 4th in [1/4,1/2), so every 2n-th in [1/2n,1/n).
- The smallest positive float (but note that 0f0/0.0 is also possible) that is sampled is `eps(Float32)=1.1920929f-7` (Float32) or `eps(Float64)=2.220446049250313e-16` (Float64).

The current default RNG in `Base.Random` library does the same thing, so it also causes some tricky problems.[^2]

To address some of these issues RandomNumbers.jl also provides `randfloat()` for `Float16`, `Float32` and `Float64`,
which

- has full entropy for all significant bits, i.e. 0 and 1 always occur at 50% chance
- samples from all floats in [2.7105054f-20,1) (Float32) and [2.710505431213761e-20,1) (Float64) and true [0,1) (Float16, including correct chances for subnormals) 
- As the true chance to obtain a 0 in [0,1) for floats is effectively 0, it is practically also 0 for randfloat (except for Float16).
- is about 20% slower than `rand`, see [#72](https://github.com/sunoru/RandomNumbers.jl/issues/72)

`randfloat()` is not based on the `[1,2) minus one`-approach but counts the leading zeros of a random `UInt` to obtain
the correct chances for the exponent bits (which are 50% for 01111110 meaning [1/2,1) in float32, 25% for 01111101
meaning [1/4,1/2), etc.). This is combined with random `UInt` bits for the significand.

[^2]:
    [Least significant bit of rand() is always zero #16344](https://github.com/JuliaLang/julia/issues/16344)
