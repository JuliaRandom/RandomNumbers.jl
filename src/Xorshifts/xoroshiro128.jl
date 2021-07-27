import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXoroshiro128 <: AbstractRNG{UInt64}
```

The base abstract type for `Xoroshiro128`, `Xoroshiro128Star`, `Xoroshiro128Plus` and `Xoroshiro128StarStar`.
"""
abstract type AbstractXoroshiro128 <: AbstractRNG{UInt64} end

for (star, plus, starstar) in (
        (false, false, false),
        (true, false, false),
        (false, true, false),
        (false, false, true),
    )
    rng_name = Symbol(string("Xoroshiro128", star ? "Star" : plus ? "Plus" : starstar ? "StarStar" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXoroshiro128
            x::UInt64
            y::UInt64
        end

        function $rng_name(seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
            r = $rng_name(zero(UInt64), zero(UInt64))
            seed!(r, seed)
            r
        end

        $rng_name(seed::Integer) = $rng_name(init_seed(seed, UInt64, 2))

        @inline function xorshift_next(r::$rng_name)
            $(plus ? :(p = r.x + r.y)
                : starstar ? :(p = xorshift_rotl(r.x * 5, 7) * 9) : nothing)
            s1 = r.y ⊻ r.x
            r.x = xorshift_rotl(r.x, 24) ⊻ s1 ⊻ (s1 << 16)
            r.y = xorshift_rotl(s1, 37)
            $(star ? :(r.y * 2685821657736338717) :
              (plus || starstar) ? :(p) : :(r.y))
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXoroshiro128 = NTuple{2, UInt64}

function copyto!(dest::T, src::T) where T <: AbstractXoroshiro128
    dest.x = src.x
    dest.y = src.y
    dest
end

copy(src::T) where T <: AbstractXoroshiro128 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXoroshiro128 = r1.x == r2.x && r1.y == r2.y

seed!(r::AbstractXoroshiro128, seed::Integer) = seed!(r, split_uint(seed % UInt128))
function seed!(r::AbstractXoroshiro128, seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
    all(==(0), seed) && error("0 cannot be the seed")
    r.x = seed[1]
    r.y = seed[2]
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXoroshiro128, ::Type{UInt64}) = xorshift_next(r)
