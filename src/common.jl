import Random
import Random: rand, UInt52, rng_native_52

"""
```julia
AbstractRNG{T} <: Random.AbstractRNG
```

The abstract type of Random Number Generators. T indicates the original output type of a RNG.
"""
abstract type AbstractRNG{T<:Number} <: Random.AbstractRNG end

const BitTypes = Union{Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128}

# For compatibility with functions in Random stdlib.
rng_native_52(::AbstractRNG) = UInt64
rand(rng::AbstractRNG, ::Random.SamplerType{T}) where {T<:BitTypes} = rand(rng, T)

# see https://github.com/JuliaRandom/RandomNumbers.jl/issues/8
# TODO: find a better approach.
@inline function rand(rng::AbstractRNG{T}, ::Type{Float64}=Float64) where {T<:Union{UInt64, UInt128}}
    reinterpret(Float64, Base.exponent_one(Float64) | rand(rng, UInt52())) - 1.0
end
@inline function rand(rng::AbstractRNG{T}, ::Type{Float64}=Float64) where {T<:Union{UInt8, UInt16, UInt32}}
    rand(rng, T) * exp2(-sizeof(T) << 3)
end

@inline function rand(rng::AbstractRNG{T1}, ::Type{T2}) where {T1<:BitTypes, T2<:BitTypes}
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    t = rand(rng, T1) % T2
    s1 > s2 && return t
    for i in 2:(s2 ÷ s1)
        t |= (rand(rng, T1) % T2) << ((s1 << 3) * (i - 1))
    end
    t
end
