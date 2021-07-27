import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXoroshiro64 <: AbstractRNG{UInt32}
```

The base abstract type for `Xoroshiro64Star` and `Xoroshiro64StarStar`.
"""
abstract type AbstractXoroshiro64 <: AbstractRNG{UInt32} end

for (star, starstar) in (
        (true, false),
        (false, true),
    )
    rng_name = Symbol(string("Xoroshiro64", star ? "Star" : starstar ? "StarStar" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXoroshiro64
            x::UInt32
            y::UInt32
        end

        function $rng_name(seed::NTuple{2, UInt32}=gen_seed(UInt32, 2))
            r = $rng_name(zero(UInt32), zero(UInt32))
            seed!(r, seed)
            r
        end

        $rng_name(seed::Integer) = $rng_name(init_seed(seed, UInt32, 2))

        @inline function xorshift_next(r::$rng_name)
            p = r.x * 0x9E3779BB
            $(starstar ? :(p = xorshift_rotl(p, 5) * (5 % UInt32)) : nothing)
            s1 = r.y ⊻ r.x
            r.x = xorshift_rotl(r.x, 26) ⊻ s1 ⊻ (s1 << 9)
            r.y = xorshift_rotl(s1, 13)
            p
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXoroshiro64 = NTuple{2, UInt32}

function copyto!(dest::T, src::T) where T <: AbstractXoroshiro64
    dest.x = src.x
    dest.y = src.y
    dest
end

copy(src::T) where T <: AbstractXoroshiro64 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXoroshiro64 = r1.x == r2.x && r1.y == r2.y

seed!(r::AbstractXoroshiro64, seed::Integer) = seed!(r, split_uint(seed % UInt64))
function seed!(r::AbstractXoroshiro64, seed::NTuple{2, UInt32}=gen_seed(UInt32, 2))
    all(==(0), seed) && error("0 cannot be the seed")
    r.x = seed[1]
    r.y = seed[2]
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXoroshiro64, ::Type{UInt32}) = xorshift_next(r)
