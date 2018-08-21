import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: gen_seed, union_uint, seed_type, unsafe_copyto!, unsafe_compare

"The key for AESNI."
mutable struct AESNIKey
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

copyto!(dest::AESNIKey, src::AESNIKey) = unsafe_copyto!(dest, src, UInt128, 11)

copy(src::AESNIKey) = copyto!(AESNIKey(), src)

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
mutable struct AESNI1x <: R123Generator1x{UInt128}
    x::UInt128
    ctr::UInt128
    key::AESNIKey
    function AESNI1x(seed::Integer=gen_seed(UInt128))
        Sys.iswindows() && @warn "`AESNI1x` would be unstable on Windows platform in this version, please use other RNGs."
        r = new(0, 0, AESNIKey())
        seed!(r, seed)
        r
    end
end

function seed!(r::AESNI1x, seed::Integer=gen_seed(UInt128))
    initkey(r, seed % UInt128)
    r.ctr = 0
    random123_r(r)
    r
end

seed_type(::Type{AESNI1x}) = UInt128

function copyto!(dest::AESNI1x, src::AESNI1x)
    dest.x = src.x
    copyto!(dest.key, src.key)
    dest.ctr = src.ctr
    dest
end

copy(src::AESNI1x) = copyto!(AESNI1x(), src)

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
mutable struct AESNI4x <: R123Generator4x{UInt32}
    x1::UInt32
    x2::UInt32
    x3::UInt32
    x4::UInt32
    ctr1::UInt128
    key::AESNIKey
    p::Int
    function AESNI4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        Sys.iswindows() && @warn "`AESNI4x` would be unstable on Windows platform in this version, please use other RNGs."
        r = new(0, 0, 0, 0, 0, AESNIKey(), 0)
        seed!(r, seed)
        r
    end
end

function seed!(r::AESNI4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
    key = union_uint(map(x -> x % UInt32, seed))
    initkey(r, key)
    r.ctr1 = 0
    p = 0
    random123_r(r)
    r
end

seed_type(::Type{AESNI4x}) = NTuple{4, UInt32}

function copyto!(dest::AESNI4x, src::AESNI4x)
    unsafe_copyto!(dest, src, UInt32, 4)
    copyto!(dest.key, src.key)
    dest.ctr1 = src.ctr1
    dest.p = src.p
    dest
end
  
copy(src::AESNI4x) = copyto!(AESNI4x(), src)

==(r1::AESNI4x, r2::AESNI4x) = unsafe_compare(r1, r2, UInt32, 4) && r1.key == r2.key &&
    r1.ctr1 == r2.ctr1 && r1.p == r2.p
  
function initkey(r::AESNI1x, key::UInt128)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    ref = Ref(key)
    k2 = Ptr{UInt128}(pointer_from_objref(ref))
    ccall((:keyinit, librandom123), Nothing, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
    ), k2, k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160)
    r
end

function initkey(r::AESNI4x, key::UInt128)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    ref = Ref(key)
    k2 = Ptr{UInt128}(pointer_from_objref(ref))
    ccall((:keyinit, librandom123), Nothing, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
    ), k2, k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160)
    r
end

function aesni1xm128i(r::AESNI1x)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    p = Ptr{UInt128}(pointer_from_objref(r))
    ref = Ref(r.ctr)
    p1 = Ptr{UInt128}(pointer_from_objref(ref))
    ccall((:aesni1xm128i, librandom123), Nothing, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}
    ), p1, k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160, p)
    unsafe_load(p, 1)
end

function aesni1xm128i(r::AESNI4x)
    k = Ptr{UInt128}(pointer_from_objref(r.key))
    p = Ptr{UInt128}(pointer_from_objref(r))
    ref = Ref(r.ctr1)
    p1 = Ptr{UInt128}(pointer_from_objref(ref))
    ccall((:aesni1xm128i, librandom123), Nothing, (
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
    Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
    Ptr{UInt128}
    ), p1, k, k + 16, k + 32, k + 48, k + 64, k + 80, k + 96,
    k + 112, k + 128, k + 144, k + 160, p)
    unsafe_load(p, 1)
end

function random123_r(r::AESNI1x)
    (aesni1xm128i(r),)
end

function random123_r(r::AESNI4x)
    aesni1xm128i(r)
    x = unsafe_wrap(Array, Ptr{UInt32}(pointer_from_objref(r)), 4)
    x[1], x[2], x[3], x[4]
end


# FIXME: Unstable AESNI4x.
