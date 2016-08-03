import RNG: gen_seed

type ARS1x{T<:UInt128, R} <: R123Generator1x{T}
    x::T
    key::T
    ctr::T
end

function ARS1x(seed::Integer=gen_seed(UInt128), R::Integer=7)
    @assert 1 <= R <= 10
    r = ARS1x{UInt128, Int(R)}(0, 0, 0)
    srand(r, seed)
end

function srand(r::ARS1x, seed::Integer=gen_seed(UInt128))
    r.key = seed % UInt128
    r.ctr = 0
    random123_r(r)
    r
end

for R = 1:10
    @eval @inline function ars1xm128i(r, ::Type{Val{$R}}, ctr, key)
        p1 = Ptr{UInt128}(pointer_from_objref(ctr))
        p2 = Ptr{UInt128}(pointer_from_objref(key))
        p = Ptr{UInt128}(pointer_from_objref(r))
        ccall(($("ars1xm128i$R"), librandom123), Void, (
        Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
        ), p1, p2, p)
        unsafe_load(p, 1)
    end
end

@inline function random123_r{R}(r::ARS1x{UInt128, R})
    ars1xm128i(r, Val{R}, r.ctr, r.key)
    (r.x,)
end

type ARS4x{T<:UInt32, R} <: R123Generator4x{T}
    x1::T
    x2::T
    x3::T
    x4::T
    key::UInt128
    ctr1::UInt128
    p::Int
end

function ARS4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4), R::Integer=7)
    @assert 1 <= R <= 10
    r = ARS4x{UInt32, Int(R)}(0, 0, 0, 0, 0, 0, 0)
    srand(r, seed)
end

function srand(r::ARS4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
    r.key = unsafe_load(Ptr{UInt128}(pointer_from_objref(seed)), 1)
    r.ctr1 = 0
    p = 0
    random123_r(r)
    r
end

@inline function random123_r{R}(r::ARS4x{UInt32, R})
    ars1xm128i(r, Val{R}, r.ctr1, r.key)
    (r.x1, r.x2, r.x3, r.x4)
end
