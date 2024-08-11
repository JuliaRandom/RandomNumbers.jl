# Random123 Family

```@meta
CurrentModule = Random123
DocTestSetup = quote
    using Random123
end
```

**[Random123](https://www.deshawresearch.com/resources_random123.html)** is a library of "counter-based"
random number generators (CBRNGs), developed by D.E.Shaw Research[^1]. *Counter-based* means the RNGs in this
family can produce the ``\mathrm{N}^\textrm{th}`` number by applying a stateless mixing function to the *counter*
``\mathrm{N}``, instead of the conventional approach of using ``\mathrm{N}`` iterations of a stateful
transformation. The current version of Random123 in this package is 1.09, and there are four kinds of RNGs:
[Threefry](@ref), [Philox](@ref), [AESNI](@ref), [ARS](@ref).

The original paper[^1] says all the RNGs in Random123 can pass Big Crush in TestU01, but in the
[benchmark](@ref Benchmark) we did, `ARS1x128` and `Philox2x64` have a slight failure.

## Random123 RNGs

All the RNG types in Random123 have a property `ctr1`, which denotes to its first *counter*, and some of them
have `ctr2` for the second *counter*. The suffix '-1x', '-2x' and '-4x' indicates how many numbers will be
generated per time. The first one or two or four properties of a RNG type in Random123 are
always `x`(or `x1`, `x2`, etc.), which denote to the produced numbers.

### Threefry

`Threefry` is a **non-cryptographic** adaptation of the Threefish block cipher from the
[Skein Hash Function](http://www.skein-hash.info/).

In this package, there are two `Type`s of `Threefry`: [`Threefry4x`](@ref) and [`Threefry2x`](@ref). Besides
the output type `T`, there is another parameter `R`, which denotes to the number of rounds, and must be at
least 1 and no more than 32. With 20 rounds (by default), `Threefry` has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance. They both
support `UInt32` and `UInt64` output.

### Philox

`Philox` uses a Feistel network and integer multiplication.

`Philox` also has two `Type`s: [`Philox4x`](@ref) and [`Philox2x`](@ref). The number of rounds must be at
least 1 and no more than 16. With 10 rounds (by default), Philox2x32 has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance. They both
support `UInt32` and `UInt64` output.

### AESNI

`AESNI` uses the Advanced Encryption Standard (AES) New Instruction, available on certain modern x86
processors (some models of Intel Westmere and Sandy Bridge, and AMD Interlagos, as of 2011). AESNI CBRNGs can
operate on `UInt128` type.

`AESNI` has two `Type`s: [`AESNI1x`](@ref) and [`AESNI4x`](@ref). `AESNI4x` only internally converts
`UInt128` to `UInt32`.

### ARS

`ARS` (Advanced Randomization System) is a **non-cryptographic** simplification of [AESNI](@ref).

`ARS` has two `Type`s: [`ARS1x`](@ref) and [`ARS4x`](@ref). `ARS4x` only internally converts `UInt128` to
`UInt32`. Note that although it uses some cryptographic primitives, `ARS1x` uses a cryptographically weak key
schedule and is **not** suitable for cryptographic use. The number of rounds must be at least 1 and no more
than 10, and is 7 by default.


## Examples

For detailed usage of each RNG, please refer to the [library docs](@ref Random123).

To use Random123, firstly import the module:
```julia
julia> using Random123
```

Take `Philox4x64` for example:
```jldoctest
julia> r = Philox4x();  # will output UInt64 by default, and two seed integers are truly randomly produced.

julia> r = Philox4x((0x12345678abcdef01, 0x10fedcba87654321));  # specify the seed.

julia> r = Philox4x(UInt64, (0x12345678abcdef01, 0x10fedcba87654321));  # specify both the output type and seed.

julia> rand(r, NTuple{4, UInt64})
(0x00d626ee85b7d2ed, 0xa57b4af2b68c655e, 0x82dad737de789de2, 0x8d390e05845e6c4d)

julia> set_counter!(r, 123);  # update the counter manually.

julia> rand(r, UInt64, 4)
4-element Array{UInt64,1}:
 0x56a4eb812faa9cd7
 0xf3d3464a49b23b56
 0xda5a5824aea0b2bb
 0x097a8d117a2bb20a

julia> set_counter!(r, 0);

julia> rand(r, NTuple{4, UInt64})
(0x00d626ee85b7d2ed, 0xa57b4af2b68c655e, 0x82dad737de789de2, 0x8d390e05845e6c4d)
```

[^1]:
    John K. Salmon, Mark A. Moraes, Ron O. Dror, and David E. Shaw, "Parallel Random Numbers: As Easy as
    1, 2, 3," Proceedings of the International Conference for High Performance Computing, Networking, Storage
    and Analysis (SC11), New York, NY: ACM, 2011.
    doi:[10.1145/2063384.2063405](http://dx.doi.org/10.1145/2063384.2063405)
