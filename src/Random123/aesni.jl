function test_lib()
    try
        ccall((:test, librandom123), Void, ())
    catch
        return false
    end
    return true
end

@static if test_lib()

    type AESNI1x{T<:UInt128} <: R123Generator1x{T}
        x::T
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
        crt::UInt128
    end

    function AESNI1x(seed::Integer=gen_seed(UInt128))
        r = AESNI1x{UInt128}([0 for i in 1:13]...)
        srand(r, seed)
    end

    function srand(r::AESNI1x, seed::Integer=gen_seed(UInt128))
        initkey(r, seed % UInt128)
        r.crt = 0
        random123_r(r)
        r
    end

    type AESNI4x{T<:UInt32} <: R123Generator4x{T}
        x1::T
        x2::T
        x3::T
        x4::T
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
        crt1::T
        crt2::T
        crt3::T
        crt4::T
        p::Int
    end

    function AESNI4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        r = AESNI4x{UInt32}([0 in 1:20]...)
        srand(r, seed)
    end

    function srand(r::AESNI4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
        key = 0 % UInt128
        for i in 1:4
            key <<= 32
            key |= seed[i] % UInt32
        end
        initkey(r, key)
        r.crt1 = r.crt2 = r.crt3 = r.crt4 = 0
        p = 0
        random123_r(r)
        r
    end

    @inline function initkey(r, key)
        ccall((:keyinit, librandom123), Void, (
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
        ), &key, pointer_from_objref(r.key1), pointer_from_objref(r.key2), pointer_from_objref(r.key3),
        pointer_from_objref(r.key4), pointer_from_objref(r.key5), pointer_from_objref(r.key6),
        pointer_from_objref(r.key7), pointer_from_objref(r.key8), pointer_from_objref(r.key9),
        pointer_from_objref(r.key10), pointer_from_objref(r.key11))
    end

    @inline function aesni1xm128i(r)
        x = 0 % UInt128
        ccall((:aesni1xm128i, librandom123), Void, (
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, 
            Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128},
            Ptr{UInt128}
        ), &key, pointer_from_objref(r.key1), pointer_from_objref(r.key2), pointer_from_objref(r.key3),
        pointer_from_objref(r.key4), pointer_from_objref(r.key5), pointer_from_objref(r.key6),
        pointer_from_objref(r.key7), pointer_from_objref(r.key8), pointer_from_objref(r.key9),
        pointer_from_objref(r.key10), pointer_from_objref(r.key11), pointer_from_objref(x))
        x
    end

    @inline function random123_r(r::AESNI1x)
        r.x = aesni1xm128i(r)
    end

    @inline function random123_r(r::AESNI4x)
        p = Ptr{UInt128}(pointer_from_objref(r))
        x = aesni1xm128i(r) 
        unsafe_store!(p, x, 1)
        (pointer_to_array(Ptr{UInt32}(pointer_from_objref(x)))...)
    end
end
