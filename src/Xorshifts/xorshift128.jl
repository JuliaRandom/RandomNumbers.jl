import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

"""
```julia
AbstractXorshift128{T} <: AbstractRNG{T}
```

The base abstract type for `Xorshift128`, `Xorshift128Star` and `Xorshift128Plus`.
"""
abstract AbstractXorshift128{T} <: AbstractRNG{T}

@inline uint128to64(x::UInt128) = (x % UInt64, (x >> 64) % UInt64)

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift128", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name{T<:Union{UInt32, UInt64}} <: AbstractXorshift128{T}
            x::UInt64
            y::UInt64
            $((star || plus) ? :(result::UInt64) : nothing)
            flag::Bool
            function $rng_name(seed::NTuple{2, UInt64})
                $((star || plus) ? :(r = new{T}(0, 0, 0, false)) : :(r = new{T}(0, 0, false)))
                srand(r, seed)
                r
            end
        end

        $rng_name{T<:Union{UInt32, UInt64}}(::Type{T},
            seed::Integer) = $rng_name{T}(uint128to64(seed % UInt128))

        $rng_name{T<:Union{UInt32, UInt64}}(::Type{T},
            seed::NTuple{2, UInt64}=gen_seed(UInt64, 2)) = $rng_name{T}(seed)

        $rng_name(seed::Integer) = $rng_name(UInt64, seed)

        $rng_name(seed::NTuple{2, UInt64}=gen_seed(UInt64, 2)) = $rng_name(UInt64, seed)

        @inline function xorshift_next(r::$rng_name)
            t = r.x $ r.x << 23
            r.x = r.y
            r.y = t $ (t >> 3) $ r.y $ (r.y >> 24)
            $(star ? :(r.result = r.y * 2685821657736338717) :
              plus ? :(r.result = r.y + r.x) : :(r.y))
        end

        @inline function rand(r::$rng_name{UInt32}, ::Type{UInt32})
            if r.flag
                r.flag = false
                return ($((star || plus) ? :(r.result) : :(r.y)) >> 32) % UInt32
            else
                xorshift_next(r)
                r.flag = true
                return $((star || plus) ? :(r.result) : :(r.y)) % UInt32
            end
        end
    end
end

srand(r::AbstractXorshift128, seed::Integer) = srand(r,
    uint128to64(seed % UInt128))

function srand(r::AbstractXorshift128, seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
    r.x = seed[1]
    r.y = seed[2]
    r.flag = false
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXorshift128{UInt64}, ::Type{UInt64}) = xorshift_next(r)
