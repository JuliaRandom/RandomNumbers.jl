# Bases

This page describes basic concepts and fundanmental knowledge of **RNG.jl**.

!!! note
    Unless otherwise specified, all the random number generators in this package are *pseudorandom* number
    generators (or *deterministic* random bit generator), which means they only provide numbers whose
    properties approximate the properties of *truly random* numbers. Always, especially in secure-sensitive
    cases, keep in mind that they do not gaurantee a totally random performance.

## Interface

First of all, to use a RNG from this package, you can import `RNG.jl` and use RNG by declare its submodule's
name, or directly import the submodule. Then you can create a random number generator of certain type.
For example:

```julia
julia> using RNG
julia> r = Xorshifts.Xorshift1024Plus()
```
or
```julia
julia> using RNG.Xorshifts
julia> r = Xorshift1024Plus()
```

The submodules have some API in common and a few differently.

All the Random Number Generators (RNGs) are child types of `AbstractRNG{T}`, which is a child type of
`Base.Random.AbstractRNG` and replaces it. (`Base.Random` may be refactored sometime, anyway.) The type
parameter `T` indicates the original output type of a RNG, and it is usually a child type of `Unsigned`, such
as `UInt64`, `UInt32`, etc. Users can change the output type of a certain RNG type by use a wrapped type:
[`WrappedRNG`](@ref)

Consistent to what `Base.Random` does, there are generic functions:

- `srand(::AbstractRNG{T}[, seed])`
    initializes a RNG by one or a sequence of numbers (called *seed*). The output sequences by two RNGs of
    the same type should be the same if they are initialized by the same seed, which makes them
    *deterministic*. The seed type of each RNG type can be different, you can refer to the corresponding
    manual pages for details. If no `seed` provided, then it will use [`RNG.gen_seed`](@ref) to get a "truly"
    random one.

- `rand(::AbstractRNG{T}[, ::Type{TP}=Float64])`
    returns a random number in the type `TP`. `TP` is usually an `Unsigned` type, and the return value is
    expected to be uniformly distributed in {0, 1} at every bit. When `TP` is `Float64` (as default), this
    function returns a `Float64` value that is expected to be uniformly distributed in [0, 1). The discussion
    about this is in the [Conversion to Float](@ref) section.

The other generic functions such as `rand(::AbstractRNG, ::Dims)` and `rand!(::AbstractRNG, ::AbstractArray)`
defined in `Base.Random` still work.

The constructors of all the types of RNG are designed to take the same kind of parameters as `srand`. For example:

```jldoctest
julia> using RNG.Xorshifts

julia> r1 = Xorshift128Star(123)  # Create a RNG of Xorshift128Star with the seed "123"
RNG.Xorshifts.Xorshift128Star(0x000000003a300074,0x000000003a30004e)

julia> r2 = Xorshift128Star();  # Use a random value to be the seed.

julia> rand(r1)  # Generate a number uniformly distributed in [0, 1).
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
chosen to test the RNGs in `RNG.jl`. **TestU01** offers a collection of test suites, and *Big Crush* is
the largest and most stringent test battery for empirical testing (which usually takes several hours to run).
*Bit Crush* has revealed a number of flaws of lots of well-used generators, even including the
*Mersenne Twister* (or to be more exact, the *dSFMT*) which is currently used in `Base.Random` as
`GLOBAL_RAND`.[^1]

The testing results are available on [Benchmark](@ref) page.

[^1]: 
    [`rand` fails bigcrush #6464](https://github.com/JuliaLang/julia/issues/6464)


## Conversion to Float

