import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, split_uint, seed_type

"""
```julia
AbstractXoshiro128 <: AbstractRNG{UInt32}
```

The base abstract type for `Xoshiro128Plus` and `Xoshiro128StarStar`.
"""
abstract type AbstractXoshiro128 <: AbstractRNG{UInt32} end

for (plus, starstar) in (
        (true, false),
        (false, true),
    )
    rng_name = Symbol(string("Xoshiro128", plus ? "Plus" : starstar ? "StarStar" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXoshiro128
            x::UInt32
            y::UInt32
            z::UInt32
            w::UInt32
        end

        function $rng_name(seed::NTuple{4, UInt32}=gen_seed(UInt32, 4))
            o = zero(UInt32)
            r = $rng_name(o, o, o, o)
            seed!(r, seed)
            r
        end

        $rng_name(seed::Integer) = $rng_name(init_seed(seed, UInt32, 4))

        @inline function xorshift_next(r::$rng_name)
            p = $(plus ? :(r.x + r.w)
                : starstar ? :(xorshift_rotl(r.x * (5 % UInt32), 7) * (9 % UInt32)) : nothing)
            t = r.y << 9
            r.z ⊻= r.x
            r.w ⊻= r.y
            r.y ⊻= r.z
            r.x ⊻= r.w
            r.z ⊻= t
            r.w = xorshift_rotl(r.w, 11)
            p
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXoshiro128 = NTuple{4, UInt32}

function copyto!(dest::T, src::T) where T <: AbstractXoshiro128
    dest.x = src.x
    dest.y = src.y
    dest.z = src.z
    dest.w = src.w
    dest
end

copy(src::T) where T <: AbstractXoshiro128 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXoshiro128 = r1.x == r2.x && r1.y == r2.y && r1.z == r2.z && r1.w == r2.w

seed!(r::AbstractXoshiro128, seed::Integer) = seed!(r, split_uint(seed % UInt128, UInt32))
function seed!(r::AbstractXoshiro128, seed::NTuple{4, UInt32}=gen_seed(UInt32, 4))
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

@inline rand(r::AbstractXoshiro128, ::Type{UInt32}) = xorshift_next(r)
