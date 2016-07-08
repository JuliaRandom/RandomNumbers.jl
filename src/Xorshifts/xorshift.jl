import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

abstract AbstractXorshift{T} <: AbstractRNG{T}

for T in (UInt32, UInt64)
    @eval @inline rand(r::AbstractXorshift{$T}, ::Type{$T}) = xorshift_next(r)
end

function srand{T}(r::AbstractXorshift{T}, seed::Integer=gen_seed(T))
    xorshift_srand(r, seed % T)
    r
end

"""
    Xorshift64([T=UInt64, seed])

Create a Xorshift64 random number generator providing a 2^s-1 period, where s is the number of bits of T.
"""
type Xorshift64{T<:Union{UInt32, UInt64}} <: AbstractXorshift{T}
    x::T
    function Xorshift64(seed::T)
        r = new{T}(0 % T)
        srand(r, seed)
        r
    end
end

Xorshift64{T<:Union{UInt32, UInt64}}(::Type{T}, seed::Integer=gen_seed(T)) = Xorshift64{T}(seed % T)

Xorshift64(seed::Integer=gen_seed(UInt64)) = Xorshift64(UInt64, seed)

@inline function xorshift_next(r::Xorshift64)
    r.x $= r.x << 18
    r.x $= r.x >> 31
    r.x $= r.x << 11
    r.x
end

@inline function xorshift_srand{T<:Union{UInt32, UInt64}}(r::Xorshift64{T}, seed::T)
    r.x = seed
    xorshift_next(r)
end
