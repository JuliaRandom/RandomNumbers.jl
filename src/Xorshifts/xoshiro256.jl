import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXoshiro256 <: AbstractRNG{UInt64}
```

The base abstract type for `Xoshiro256Plus` and `Xoshiro256StarStar`.
"""
abstract type AbstractXoshiro256 <: AbstractRNG{UInt64} end

for (plus, starstar) in (
        (true, false),
        (false, true),
    )
    rng_name = Symbol(string("Xoshiro256", plus ? "Plus" : starstar ? "StarStar" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXoshiro256
            x::UInt64
            y::UInt64
            z::UInt64
            w::UInt64
        end

        function $rng_name(seed::NTuple{4, UInt64}=gen_seed(UInt64, 4))
            o = zero(UInt64)
            r = $rng_name(o, o, o, o)
            seed!(r, seed)
            r
        end

        $rng_name(seed::Integer) = $rng_name(init_seed(seed, UInt64, 4))

        @inline function xorshift_next(r::$rng_name)
            p = $(plus ? :(r.x + r.w)
                : starstar ? :(xorshift_rotl(r.y * 5, 7) * 9) : nothing)
                # why here is r.y but in xoshiro128** is r.x?
            t = r.y << 17
            r.z ⊻= r.x
            r.w ⊻= r.y
            r.y ⊻= r.z
            r.x ⊻= r.w
            r.z ⊻= t
            r.w = xorshift_rotl(r.w, 45)
            p
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXoshiro256 = NTuple{4, UInt64}

function copyto!(dest::T, src::T) where T <: AbstractXoshiro256
    dest.x = src.x
    dest.y = src.y
    dest.z = src.z
    dest.w = src.w
    dest
end

copy(src::T) where T <: AbstractXoshiro256 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXoshiro256 = r1.x == r2.x && r1.y == r2.y && r1.z == r2.z && r1.w == r2.w

seed!(r::AbstractXoshiro256, seed::Integer) = seed!(r, init_seed(seed, UInt64, 4))
function seed!(r::AbstractXoshiro256, seed::NTuple{4, UInt64}=gen_seed(UInt64, 4))
    all(==(0), seed) && error("0 cannot be the seed")
    r.x = seed[1]
    r.y = seed[2]
    r.z = seed[3]
    r.w = seed[4]
    xorshift_next(r)
    xorshift_next(r)
    xorshift_next(r)
    xorshift_next(r)
    r
end

@inline rand(r::AbstractXoshiro256, ::Type{UInt64}) = xorshift_next(r)
