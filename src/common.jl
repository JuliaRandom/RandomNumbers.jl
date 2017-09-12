import Base.Random: rand, rand_ui52, rand_ui52_raw

"""
```julia
AbstractRNG{T} <: Base.Random.AbstractRNG
```

The abstract type of Random Number Generators. T indicates the original output type of a RNG.
"""
abstract type AbstractRNG{T<:Number} <: Base.Random.AbstractRNG end

const BitTypes = Union{Bool, Signed, Unsigned}

# implement `rand_ui52_raw` instead of `rand_ui52` to avoid issues about `CloseOpen`.
@inline function rand_ui52_raw(rng::AbstractRNG)
    rand(rng, UInt64)
end

# see https://github.com/sunoru/RandomNumbers.jl/issues/8
# TODO: find a better approach.
@inline function rand(rng::AbstractRNG{T}, ::Type{Float64}=Float64) where T <: Union{UInt64, UInt128}
    reinterpret(Float64, Base.exponent_one(Float64) | rand_ui52(rng)) - 1.0
end
@inline function rand(rng::AbstractRNG{T}, ::Type{Float64}=Float64) where T <:Union{UInt8, UInt16, UInt32}
    rand(rng, T) * exp2(-sizeof(T) << 3)
end

@inline function rand(rng::AbstractRNG{T1}, ::Type{T2}) where {T1 <: BitTypes, T2 <: BitTypes}
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    t = rand(rng, T1) % T2
    s1 > s2 && return t
    for i in 2:(s2 ÷ s1)
        t |= (rand(rng, T1) % T2) << ((s1 << 3) * (i - 1))
    end
    t
end
