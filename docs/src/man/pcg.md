# PCG Family

```@meta
CurrentModule = RandomNumbers.PCG
DocTestSetup = quote
    using RandomNumbers.PCG
    r = PCGStateOneseq(1234567)
end
```

**[Permuted Congruential Generators](http://www.pcg-random.org/)** (PCGs) are a family of RNGs which uses a
*linear congruential generator* as the state-transition function, and uses *permutation functions on tuples*
to produce output that is much more random than the RNG's internal state.[^1]

## PCG Type

Each PCG generator is available in four variants, based on how it applies the additive constant for its
underlying LCG; the variations are:

- [`PCGStateOneseq`](@ref) (single stream):
    all instances use the same fixed constant, thus the RNG always somewhere in same sequence.
- [`PCGStateMCG`](@ref) (mcg):
    adds zero, resulting in a single stream and reduced period.
- [`PCGStateSetseq`](@ref) (specific stream):
    the constant can be changed at any time, selecting a different random sequence.
- [`PCGStateUnique`](@ref) (unique stream):
    the constant is based on the memory address of the object, thus every RNG has its own unique sequence.

## PCG Method Type

- [`PCG_XSH_RS`](@ref): high xorshift, followed by a random shift.
    It's fast and is a good performer.
- [`PCG_XSH_RR`](@ref): high xorshift, followed by a random rotate.
    It's fast and is a good performer. Slightly better statistically than `PCG_XSH_RS`.
- [`PCG_RXS_M_XS`](@ref): fixed xorshift (to low bits), random rotate.
    The most statistically powerful generator, but all those steps make it slower than some of the others.
    (but in this package the benchmark shows it's even fast than `PCG_XSH_RS`, which is an current issue.)
- [`PCG_XSL_RR`](@ref): fixed xorshift (to low bits), random rotate.
    Useful for 128-bit types that are split across two CPU registers.
- [`PCG_XSL_RR_RR`](@ref): fixed xorshift (to low bits), random rotate (both parts).
    Useful for 128-bit types that are split across two CPU registers. Use this in need of an invertable
    128-bit RNG.

## Interface and Examples

An instance of PCG generator can be created by specify the state type, the output type, the method and seed.
When seed is missing it is set to truly random numbers. The default output type is `UInt64`, and the default
method is `PCG_XSH_RS`. The seed will be converted to the internal state type (a kind of unsigned integer),
and for PCGs with specific stream (`PCGStateSetseq`) the seed should be a `Tuple` of two `Integer`s. Note that
not all parameter combinations are available (see [`PCG_LIST`](@ref)). For example:
```jldoctest
julia> using RandomNumbers.PCG

julia> PCGStateOneseq(UInt64, 1234567)  # create a single stream PCG, specifying the output type and seed.
PCGStateOneseq{UInt128,Val{:XSH_RS},UInt64}(0xa10d40ffc2b1e573e589b22b2450d1fd)

julia> PCGStateUnique(PCG_RXS_M_XS, 1234567);  # unique stream PCG, specifying the method and seed.

julia> PCGStateSetseq(UInt32, PCG_XSH_RR, (1234567, 7654321))
PCGStateSetseq{UInt64,Val{:XSH_RR},UInt32}(0xfc77de2cd901ff85, 0x0000000000e99763)
```

[`bounded_rand`](@ref) is provided by this module, in which the bound is must an integer in the output type:
```jldoctest
julia> r = PCGStateOneseq(1234567)
PCGStateOneseq{UInt128,Val{:XSH_RS},UInt64}(0xa10d40ffc2b1e573e589b22b2450d1fd)

julia> [bounded_rand(r, UInt64(100)) for i in 1:6]
6-element Array{UInt64,1}:
 0x0000000000000012
 0x000000000000000a
 0x000000000000002e
 0x0000000000000049
 0x0000000000000043
 0x000000000000002b
```

PCG also has an [`advance!`](@ref) function, used to advance the state of a PCG instance.
```jldoctest
julia> import Random

julia> Random.seed!(r, 1234567);

julia> rand(r, 4)
4-element Array{Float64,1}:
 0.5716257379273757
 0.9945058856417783
 0.8886220302794352
 0.08763836824057081

julia> advance!(r, -4);

julia> rand(r, 4)
4-element Array{Float64,1}:
 0.5716257379273757
 0.9945058856417783
 0.8886220302794352
 0.08763836824057081
```

[^1]:
    O’NEILL M E. PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation[J].
