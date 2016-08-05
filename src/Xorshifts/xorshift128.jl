import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

abstract AbstractXorshift128 <: AbstractRNG{UInt64}

type Xorshift128 <: AbstractXorshift128
    x::UInt64
    y::UInt64
end
type Xorshift128plus <: AbstractXorshift128
    x::UInt64
    y::UInt64
end
type Xorshift128star <: AbstractXorshift128
    x::UInt64
    y::UInt64
end

function (::Type{T}){T<:AbstractXorshift128}()
    r = T(0,0)
    srand(r)
    r
end

@inline function srand(r::AbstractXorshift128, seed::Integer=gen_seed(UInt64))
    r.x = seed % UInt64
    r.y = (seed >> 64) % UInt64
    xorshift_next!(r)
    xorshift_next!(r)
    r
end

@inline function xorshift_next!(r::AbstractXorshift128)
    t = r.x $ r.x << 23
    r.x = r.y
    r.y = t $ (t >> 3) $ r.y $ (r.y >> 24)
end

@inline function rand(r::Xorshift128, ::Type{UInt64})
    xorshift_next!(r)
end
@inline function rand(r::Xorshift128plus, ::Type{UInt64})
    xorshift_next!(r)
    r.y + r.x
end
@inline function rand(r::Xorshift128star, ::Type{UInt64})
    xorshift_next!(r)
    r.y * 2685821657736338717
end




type SplitRNG{R<:AbstractRNG,T} <: AbstractRNG{T}
    rng::R
    cache::T
    flag::Bool
end

SplitRNG(rng::AbstractRNG{UInt64}) = SplitRNG{typeof(rng),UInt32}(rng,0,false)
srand{R,T}(s::SplitRNG{R,T},args...) = srand(s.rng,args...)

@inline function rand{R<:AbstractRNG{UInt64}}(r::SplitRNG{R,UInt32}, ::Type{UInt32})
    if r.flag
        r.flag = false
        return r.cache
    else
        u = rand(r.rng, UInt64)
        r.flag = true
        r.cache = (u>>32) % UInt32
        return u % UInt32
    end
end
