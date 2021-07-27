import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, seed_type

"""
```julia
AbstractXorshift64 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift64` and `Xorshift64Star`.
"""
abstract type AbstractXorshift64 <: AbstractRNG{UInt64} end

for star in (false, true)
    rng_name = Symbol(string("Xorshift64", star ? "Star" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXorshift64
            x::UInt64
        end

        function $rng_name(seed::Integer=gen_seed(UInt64))
            r = $rng_name(zero(UInt64))
            seed = init_seed(seed, UInt64)
            seed!(r, seed)
            r
        end

        @inline function xorshift_next(r::$rng_name)
            r.x ⊻= r.x << 18
            r.x ⊻= r.x >> 31
            r.x ⊻= r.x << 11
            $(star ? :(r.x * 2685821657736338717) : :(r.x))
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXorshift64 = UInt64

function copyto!(dest::T, src::T) where T <: AbstractXorshift64
    dest.x = src.x
    dest
end

copy(src::T) where T <: AbstractXorshift64 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXorshift64 = r1.x == r2.x

function seed!(r::AbstractXorshift64, seed::Integer=gen_seed(UInt64))
    seed == 0 && error("0 cannot be the seed")
    r.x = seed % UInt64
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXorshift64, ::Type{UInt64}) = xorshift_next(r)
