import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed, uint128to64

"""
```julia
AbstractXorshift128 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift128`, `Xorshift128Star` and `Xorshift128Plus`.
"""
abstract AbstractXorshift128 <: AbstractRNG{UInt64}

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift128", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name <: AbstractXorshift128
            x::UInt64
            y::UInt64
            function $rng_name(seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
                r = new(0, 0)
                srand(r, seed)
                r
            end
        end

        $rng_name(seed::Integer) = $rng_name(uint128to64(seed % UInt128))

        @inline function xorshift_next(r::$rng_name)
            t = r.x $ r.x << 23
            r.x = r.y
            r.y = t $ (t >> 3) $ r.y $ (r.y >> 24)
            $(star ? :(r.y * 2685821657736338717) :
              plus ? :(r.y + r.x) : :(r.y))
        end
    end
end

srand(r::AbstractXorshift128, seed::Integer) = srand(r, uint128to64(seed % UInt128))

function srand(r::AbstractXorshift128, seed::NTuple{2, UInt64}=gen_seed(UInt64, 2))
    r.x = seed[1]
    r.y = seed[2]
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXorshift128, ::Type{UInt64}) = xorshift_next(r)
