# Xorshift Family

```@meta
CurrentModule = RandomNumbers.Xorshifts
```
[`Xorshift`](http://xoroshiro.di.unimi.it/) family is a class of PRNGs based on linear transformation that
takes the *exclusive or* of a number with a *bit-shifted* version of itself[^1]. They are extremely fast on
mordern computer architectures, and are very suitable for non-cryptographically-secure use. The suffix `-Star`
and `-Plus` in the RNG names denote to two classes of improved RNGs[^2][^3], which make it to pass Big Crush
in TestU01. `-Star` RNGs are obtained by scrambling the output of a normal `Xorshift` generator with a 64-bit
invertible multiplier, while `-Plus` RNGs return the sum of two consecutive output of a `Xorshift` generator.

In this package there are four series of RNG types:

- [`Xorshift64`](@ref) and [`Xorshift64Star`](@ref):
    They have a period of ``2^{64}``, but not recommended because 64 bits of state are not enough for any
    serious purpose.

- [`Xorshift128`](@ref), [`Xorshift128Star`](@ref) and [`Xorshift128Plus`](@ref):
    They have a period of ``2^{128}``. `Xorshift128Plus` is presently used in the JavaScript engines of
    Chrome, Firefox and Safari.

- [`Xorshift1024`](@ref), [`Xorshift1024Star`](@ref) and [`Xorshift1024Plus`](@ref):
    They have a long period of ``2^{1024}``, and takes some more space for storing the state. If you are
    running large-scale parallel simulations, it's a good choice to use `Xorshift1024Star`.

- [`Xoroshiro128`](@ref), [`Xoroshiro128Star`](@ref) and [`Xoroshiro128Plus`](@ref):
    The successor to `Xorshift128` series. They make use of a carefully handcrafted shift/rotate-based linear
    transformation, resulting in a significant improvement in speed and in statistical quality. Therefore,
    `Xoroshiro128Plus` is the current best suggestion for replacing other low-quality generators.

```@meta
CurrentModule = RandomNumbers
```
All the RNG types produce `UInt64` numbers, if you have need for other output type, see [`WrappedRNG`](@ref).

## Examples
The usage of `Xorshift` family is very simple and common:

```jldoctest
julia> using RandomNumbers.Xorshifts

julia> r = Xoroshiro128Plus();  # create a RNG with truly random seed.

julia> r = Xoroshiro128Plus(0x1234567890abcdef)  # with a certain seed. Note that the seed must be non-zero.
Xoroshiro128Plus(0xe7eb72d97b4beac6, 0x9b86d56534ba1f9e)

julia> rand(r)
0.14263790854661185

julia> rand(r, UInt32)
0x0a0315b3
```

[^1]:
    Marsaglia G. Xorshift rngs[J]. Journal of Statistical Software, 2003, 8(14): 1-6.
    doi:[10.18637/jss.v008.i14](http://dx.doi.org/10.18637/jss.v008.i14)

[^2]:
    Vigna S. An experimental exploration of Marsaglia's xorshift generators, scrambled[J]. arXiv preprint
    [arXiv:1402.6246](http://arxiv.org/abs/1402.6246), 2014.

[^3]:
    Vigna S. Further scramblings of Marsaglia's xorshift generators[J]. arXiv preprint
    [arXiv:1404.0390](http://arxiv.org/abs/1404.0390), 2014.
