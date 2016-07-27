import Base.Random: rand, srand
import RNG: AbstractRNG

const librandom123 = Pkg.dir("RNG/deps/Random123/librandom123")

typealias R123Array1x{T<:Union{UInt128}} NTuple{1, T}
typealias R123Array2x{T<:Union{UInt32, UInt64}} NTuple{2, T}
typealias R123Array4x{T<:Union{UInt32, UInt64}} NTuple{4, T}

abstract AbstractR123{T<:Union{UInt32, UInt64, UInt128}} <: AbstractRNG{T}

abstract R123Generator1x{T} <: AbstractR123{T}
abstract R123Generator2x{T} <: AbstractR123{T}
abstract R123Generator4x{T} <: AbstractR123{T}

@inline function rand{T<:UInt128}(r::R123Generator1x{T}, ::Type{T})
    r.ctr += 1
    random123_r(r)
    r.x
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::R123Generator2x{T}, ::Type{T})
    if r.p == 1
        r.ctr1 += 1
        random123_r(r)
        r.p = 0
        return r.x2
    end
    r.p = 1
    r.x1
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::R123Generator4x{T}, ::Type{T})
    if r.p == 4
        r.ctr1 += 1
        random123_r(r)
        r.p = 0
    end
    r.p += 1
    getfield(r, r.p)
end

@inline function rand{T<:UInt128}(r::R123Generator1x{T}, ::Type{R123Array1x{T}})
    r.ctr += 1
    random123_r(r)
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::R123Generator2x{T}, ::Type{R123Array2x{T}})
    r.ctr1 += 1
    r.p = 0
    random123_r(r) # which returns a Tuple{T, T}
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::R123Generator4x{T}, ::Type{R123Array4x{T}})
    r.ctr1 += 1
    r.p = 0
    random123_r(r)
end

for (T, DT) in ((UInt32, UInt64), (UInt64, UInt128))
    @eval @inline function rand(r::R123Generator2x{$T}, ::Type{$DT})
        if r.p == 1
            r.ctr1 += 1
            random123_r(r)
        end
        r.p = 1
        unsafe_load(Ptr{$DT}(pointer_from_objref(r)), 1)
    end
end

@inline function rand(r::R123Generator4x{UInt32}, ::Type{UInt128})
    if r.p > 0
        r.ctr1 += 1
        random123_r(r)
    end
    r.p = 4
    unsafe_load(Ptr{UInt128}(pointer_from_objref(r)), 1)
end
