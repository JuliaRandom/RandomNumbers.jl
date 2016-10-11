import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed, seed_type

"""
```julia
AbstractXorshift64 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift64` and `Xorshift64Star`.
"""
abstract AbstractXorshift64 <: AbstractRNG{UInt64}

for star in (false, true)
    rng_name = Symbol(string("Xorshift64", star ? "Star" : ""))
    @eval begin
        type $rng_name <: AbstractXorshift64
            x::UInt64
            function $rng_name(seed::UInt64=gen_seed(UInt64))
                r = new(0)
                srand(r, seed)
                r
            end
        end

        $rng_name(seed::Integer) = $rng_name(seed % UInt64)

        @inline function xorshift_next(r::$rng_name)
            r.x $= r.x << 18
            r.x $= r.x >> 31
            r.x $= r.x << 11
            $(star ? :(r.x * 2685821657736338717) : :(r.x))
        end
    end
end

function srand(r::AbstractXorshift64, seed::Integer=gen_seed(UInt64))
    r.x = seed % UInt64
    xorshift_next(r)
    r
end

@inline seed_type{T<:AbstractXorshift64}(::Type{T}) = UInt64

@inline rand(r::AbstractXorshift64, ::Type{UInt64}) = xorshift_next(r)
