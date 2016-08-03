if R123_USE_AESNI @eval begin

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

    type AESNI1x{T<:UInt128} <: R123Generator1x{T}
        x::T
        key::AESNIKey
        ctr::UInt128
    end

    function AESNI1x(seed::Integer=gen_seed(UInt128))
        r = AESNI1x{UInt128}(0, AESNIKey(), 0)
        srand(r, seed)
    end

    function srand(r::AESNI1x, seed::Integer=gen_seed(UInt128))
        initkey(r, seed % UInt128)
        r.ctr = 0
        random123_r(r)
        r
    end

    type AESNI4x{T<:UInt32} <: R123Generator4x{T}
        x1::T
        x2::T
        x3::T
        x4::T
        key::AESNIKey
        ctr1::UInt128
        p::Int
    end

    function AESNI4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        r = AESNI4x{UInt32}(0, 0, 0, 0, AESNIKey(), 0, 0)
        srand(r, seed)
    end

    function srand(r::AESNI4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        key = unsafe_load(Ptr{UInt128}(pointer_from_objref(seed)), 1)
        initkey(r, key)
        r.ctr1 = 0
        p = 0
        random123_r(r)
        r
    end

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
        (unsafe_wrap(Array, Ptr{UInt32}(pointer_from_objref(r)), 4)...)
    end

end end
