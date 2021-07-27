import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXorshift128 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift128`, `Xorshift128Star` and `Xorshift128Plus`.
"""
abstract type AbstractXorshift128 <: AbstractRNG{UInt64} end

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift128", star ? "Star" : plus ? "Plus" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXorshift128
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
            t = r.x ⊻ r.x << 23
            r.x = r.y
            r.y = t ⊻ (t >> 3) ⊻ r.y ⊻ (r.y >> 24)
            $(star ? :(r.y * 2685821657736338717) :
              plus ? :(r.y + r.x) : :(r.y))
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXorshift128 = NTuple{2, UInt64}

function copyto!(dest::T, src::T) where T <: AbstractXorshift128
    dest.x = src.x
    dest.y = src.y
    dest
end

copy(src::T) where T <: AbstractXorshift128 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXorshift128 = r1.x == r2.x && r1.y == r2.y

seed!(r::AbstractXorshift128, seed::Integer) = seed!(r, split_uint(seed % UInt128))

function seed!(r::AbstractXorshift128, seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
    all(==(0), seed) && error("0 cannot be the seed")
    r.x = seed[1]
    r.y = seed[2]
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXorshift128, ::Type{UInt64}) = xorshift_next(r)
