import Base.Random: rand

"""
```julia
AbstractRNG{T} <: Base.Random.AbstractRNG
```

The abstract type of Random Number Generators. T indicates the original output type of a RNG.
"""
abstract AbstractRNG{T<:Number} <: Base.Random.AbstractRNG

typealias BitTypes Union{Bool, Signed, Unsigned}

# TODO: convert to float64
for (output_type, scale) in (
    (UInt8, 3.906250000000000000000000000000e-03),
    (UInt16, 1.525878906250000000000000000000e-05),
    (UInt32, 2.328306436538696289062500000000e-10),
    (UInt64, 5.421010862427522170037264004350e-20),
    (UInt128, 2.938735877055718769921841343056e-39)
)
    @eval @inline function rand(rng::AbstractRNG{$output_type}, ::Type{Float64}=Float64)
        (rand(rng, $output_type)::$output_type * $scale)
    end
end

@inline function rand{T1<:BitTypes, T2<:BitTypes}(rng::AbstractRNG{T1}, ::Type{T2})
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    t = rand(rng, T1) % T2
    s1 > s2 && return t
    for i in 2:(s2 ÷ s1)
        t |= rand(rng, T1) << ((s1 << 3) * (i - 1))
    end
    t
end
