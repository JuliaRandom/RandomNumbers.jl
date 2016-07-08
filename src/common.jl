import Base.Random: rand
abstract AbstractRNG{T<:Number} <: Base.Random.AbstractRNG

@inline function rand(rng::AbstractRNG, ::Type{Float64}=Float64)
    rand(rng, UInt64) * 5.421010862427522170037264004350e-20
end

@inline function rand(rng::AbstractRNG{UInt128}, ::Type{Float64}=Float64)
    rand(rng, UInt128) * 2.938735877055718769921841343056e-39
end

@inline function rand{T1<:Union{Signed, Unsigned}, T2<:Union{Bool, Signed, Unsigned}}(rng::AbstractRNG{T1}, ::Type{T2})
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    t = rand(rng, T1) % T2
    s1 > s2 && return t
    for i in 2:(s2÷s1)
        t <<= s1 << 3
        t |= rand(rng, T1)
    end
    t
end
