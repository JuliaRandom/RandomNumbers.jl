# Mersenne Twisters

```@meta
CurrentModule = RandomNumbers.MersenneTwisters
DocTestSetup = quote
    using RandomNumbers.MersenneTwisters
    r = MT19937(Tuple(UInt32(i) for i in 1:624))
end
```

The **Mersenne Twister**[^1] is so far the most widely used PRNG. Mersenne Twisters are taken as default
random number generators of a great many of software systems, including the Julia language until the current
1.0 version. The most commonly used version of Mersenne Twisters is **MT19937**, which has a very long period
of ``2^{19937}-1`` and passes numerous tests including the Diehard tests.

However, it also has many flaws by today's standards. For the large period, MT19937 has to use a 2.5 KiB
state buffer, which place a load on the memory caches. More severely, it cannot pass all the TestU01
statistical tests[^2], and the speed is not so fast. **So it is not recommended in most situations.**

The [`MersenneTwisters`](@ref) in this package currently only provides one RNG: [`MT19937`](@ref). `MT19937`
can only produce `UInt32` numbers as output. Its state is an array of 624 `UInt32` numbers, so it takes 624
`UInt32`s as seed. A default function is also provided to deal with one `UInt32` as seed.

## Examples

To use the Mersenne Twisters, firstly import the module:
```jldoctest
julia> using RandomNumbers.MersenneTwisters
```

A certain sequence can be used to initialize an instance of MT19937:
```jldoctest
julia> seed = Tuple(UInt32(i) for i in 1:624);  # This is a Tuple of 1..624

julia> r = MT19937(seed);
```
Since MT19937 is a RNG based on linear-feedback shift-register techniques, this approach is not recommended
for an obivous reason:
```jldoctest
julia> rand(r, UInt32, 10)
10-element Array{UInt32,1}:
 0x23864fee
 0xdd51a593
 0x20c049a2
 0xde17a3df
 0x20804931
 0xde57a34c
 0x20c049a0
 0xde17a3dd
 0x20804933
 0xde57a34e
```
The firstly generated numbers are so poorly random. This is because the most bits of states are zeros. So it
is better to create a `MT19937` in this way:
```jldoctest
julia> r = MT19937();
```
In this case, all the 624 states will be filled with truly random numbers produced by `RandomDevice`. If
someone needs the reproducibility, just save the state `r.mt` and use it for next time.

An initialization function described in the original paper[^1] is also implemented here, so the seed can also
be just one `UInt32` number (or an `Integer` whose least 32 bits will be truncated):
```jldoctest
julia> import Random

julia> Random.seed!(r, 0xabcdef12);

julia> rand(r, UInt32, 10)
10-element Array{UInt32,1}:
 0x986c5150
 0xbb9e20f5
 0xfb59a25a
 0x189eb49c
 0xbcca5395
 0x48d9fdf5
 0x3193f581
 0xe0b6d080
 0x63154ca2
 0x72b28f0d
```
Note that if you use one `UInt32` number as seed, you will always get in a bias way.[^3]

[^1]:
    Matsumoto M, Nishimura T. Mersenne twister: a 623-dimensionally equidistributed uniform pseudo-random
    number generator[J]. ACM Transactions on Modeling and Computer Simulation (TOMACS), 1998, 8(1): 3-30.
    doi:[10.1145/272991.272995](https://dx.doi.org/10.1145/272991.272995).

[^2]:
    L'Ecuyer P, Simard R. TestU01: AC library for empirical testing of random number generators[J]. ACM
    Transactions on Mathematical Software (TOMS), 2007, 33(4): 22.
    doi:[10.1145/1268776.1268777](http://dx.doi.org/10.1145/1268776.1268777)

[^3]:
    [C++ Seeding Surprises](http://www.pcg-random.org/posts/cpp-seeding-surprises.html)
