import Base: copy, copy!, ==
import RNG: gen_seed, union_uint, seed_type, unsafe_copy!, unsafe_compare

"The key for AESNI."
type AESNIKey
    key1::UInt128
    key2::UInt128
    key3::UInt128
    key4::UInt128
    key5::UInt128
    key6::UInt128
    key7::UInt128
    key8::UInt128
    key9::UInt128
    key10::UInt128
    key11::UInt128
    AESNIKey() = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

copy!(dest::AESNIKey, src::AESNIKey) = unsafe_copy!(dest, src, UInt128, 11)

copy(src::AESNIKey) = copy!(AESNIKey(), src)

==(key1::AESNIKey, key2::AESNIKey) = unsafe_compare(key1, key2, UInt128, 11)

"""
```julia
AESNI1x <: R123Generator1x{UInt128}
AESNI1x([seed])
```

AESNI1x is one kind of AESNI Counter-Based RNGs. It generates one `UInt128` number at a time.

`seed` is an `Integer` which will be automatically converted to `UInt128`.

Only available when [`R123_USE_AESNI`](@ref).
"""
type AESNI1x <: R123Generator1x{UInt128}
    x::UInt128
    key::AESNIKey
    ctr::UInt128
    function AESNI1x(seed::Integer=gen_seed(UInt128))
        r = new(0, AESNIKey(), 0)
        srand(r, seed)
    end
end

function srand(r::AESNI1x, seed::Integer=gen_seed(UInt128))
    initkey(r, seed % UInt128)
    r.ctr = 0
    random123_r(r)
    r
end

@inline seed_type(::Type{AESNI1x}) = UInt128

function copy!(dest::AESNI1x, src::AESNI1x)
    dest.x = src.x
    copy!(dest.key, src.key)
    dest.ctr = src.ctr
    dest
end

copy(src::AESNI1x) = copy!(AESNI1x(), src)

==(r1::AESNI1x, r2::AESNI1x) = r1.x == r2.x && r1.key == r2.key && r1.ctr == r2.ctr

"""
```julia
AESNI4x <: R123Generator4x{UInt32}
AESNI4x([seed])
```

AESNI4x is one kind of AESNI Counter-Based RNGs. It generates four `UInt32` numbers at a time.

`seed` is a `Tuple` of four `Integer`s which will all be automatically converted to `UInt32`.

Only available when [`R123_USE_AESNI`](@ref).
"""
type AESNI4x <: R123Generator4x{UInt32}
    x1::UInt32
    x2::UInt32
    x3::UInt32
    x4::UInt32
    key::AESNIKey
    ctr1::UInt128
    p::Int
    function AESNI4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        r = new(0, 0, 0, 0, AESNIKey(), 0, 0)
        srand(r, seed)
    end
end

function srand(r::AESNI4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
    key = union_uint(map(x -> x % UInt32, seed))
    initkey(r, key)
    r.ctr1 = 0
    p = 0
    random123_r(r)
    r
end

@inline seed_type(::Type{AESNI4x}) = NTuple{4, UInt32}

function copy!(dest::AESNI4x, src::AESNI4x)
    unsafe_copy!(dest, src, UInt32, 4)
    copy!(dest.key, src.key)
    dest.ctr1 = src.ctr1
    dest.p = src.p
    dest
end
  
copy(src::AESNI4x) = copy!(AESNI4x(), src)

==(r1::AESNI4x, r2::AESNI4x) = unsafe_compare(r1, r2, UInt32, 4) && r1.key == r2.key &&
    r1.ctr1 == r2.ctr1 && r1.p == r2.p
  
@inline function initkey(r, key)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    ccall((:keyinit, librandom123), Void, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
    ), Ptr{UInt128}(pointer_from_objref(key)), k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160)
end

@inline function aesni1xm128i(r, ctr)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    p = Ptr{UInt128}(pointer_from_objref(r))
    ccall((:aesni1xm128i, librandom123), Void, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}
    ), Ptr{UInt128}(pointer_from_objref(ctr)), k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160, p)
    unsafe_load(p, 1)
end

@inline function random123_r(r::AESNI1x)
    (aesni1xm128i(r, r.ctr),)
end

@inline function random123_r(r::AESNI4x)
    aesni1xm128i(r, r.ctr1)
    x = unsafe_wrap(Array, Ptr{UInt32}(pointer_from_objref(r)), 4)
    x[1], x[2], x[3], x[4]
end
