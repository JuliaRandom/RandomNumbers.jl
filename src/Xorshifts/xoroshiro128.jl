import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXoroshiro128 <: AbstractRNG{UInt64}
```

The base abstract type for `Xoroshiro128`, `Xoroshiro128Star` and `Xoroshiro128Plus`.
"""
abstract AbstractXoroshiro128 <: AbstractRNG{UInt64}

@inline xorshift_rotl(x::UInt64, k) = (x << k) | (x >> (64 - k))

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xoroshiro128", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name <: AbstractXoroshiro128
            x::UInt64
            y::UInt64
            function $rng_name(seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
                r = new(0, 0)
                srand(r, seed)
                r
            end
        end

        $rng_name(seed::Integer) = $rng_name(split_uint(seed % UInt128))

        @inline function xorshift_next(r::$rng_name)
            $(plus ? :(p = r.x + r.y) : nothing)
            s1 = r.y $ r.x
            r.x = xorshift_rotl(r.x, 55) $ s1 $ (s1 << 14)
            r.y = xorshift_rotl(s1, 36)
            $(star ? :(r.y * 2685821657736338717) :
              plus ? :(p) : :(r.y))
        end
    end
end

srand(r::AbstractXoroshiro128, seed::Integer) = srand(r, split_uint(seed % UInt128))
function srand(r::AbstractXoroshiro128, seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
    r.x = seed[1]
    r.y = seed[2]
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline seed_type{T<:AbstractXoroshiro128}(::Type{T}) = NTuple{2, UInt64}

@inline rand(r::AbstractXoroshiro128, ::Type{UInt64}) = xorshift_next(r)
