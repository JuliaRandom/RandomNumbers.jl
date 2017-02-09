import Base: copy, copy!, ==
import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed, seed_type, unsafe_copy!, unsafe_compare

"""
```julia
AbstractXorshift1024 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift1024`, `Xorshift1024Star` and `Xorshift1024Plus`.
"""
abstract AbstractXorshift1024 <: AbstractRNG{UInt64}

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift1024", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name <: AbstractXorshift1024
            s0::UInt64
            s1::UInt64
            s2::UInt64
            s3::UInt64
            s4::UInt64
            s5::UInt64
            s6::UInt64
            s7::UInt64
            s8::UInt64
            s9::UInt64
            s10::UInt64
            s11::UInt64
            s12::UInt64
            s13::UInt64
            s14::UInt64
            s15::UInt64
            p::Int
            function $rng_name(seed::NTuple{16, UInt64}=gen_seed(UInt64, 16))
                r = new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                srand(r, seed)
                r
            end
        end
    end # If no another @eval: type definition not allowed inside a local scope. (It's a bug of julia)
    @eval begin
        function $rng_name(seed::Integer...)
            l = length(seed)
            @assert 0 ≤ l ≤ 16
            if l == 0
                return $rng_name(gen_seed(UInt64, 16))
            end
            $rng_name(map(x -> x % UInt64, (seed..., [i for i in l+1:16]...)))
        end

        @inline function xorshift_next(r::$rng_name)
            p = r.p
            s0 = unsafe_load(Ptr{UInt64}(pointer_from_objref(r)), p + 1)
            p = (p + 1) % 16
            s1 = unsafe_load(Ptr{UInt64}(pointer_from_objref(r)), p + 1)
            s1 $= s1 << 31
            s1 $= s1 >> 11
            s1 $= s0 >> 30
            s1 $= s0
            unsafe_store!(Ptr{UInt64}(pointer_from_objref(r)), s1, p + 1)
            r.p = p
            $(star ? :(s1 * 2685821657736338717) :
              plus ? :(s1 + s0) : :s1)
        end
    end
end

@inline seed_type{T<:AbstractXorshift1024}(::Type{T}) = NTuple{16, UInt64}

function copy!{T<:AbstractXorshift1024}(dest::T, src::T)
    unsafe_copy!(dest, src, UInt64, 16)
    dest.p = src.p
    dest
end

copy{T<:AbstractXorshift1024}(src::T) = copy!(T(), src)

=={T<:AbstractXorshift1024}(r1::T, r2::T) = unsafe_compare(r1, r2, UInt64, 16) && r1.p == r2.p

function srand(r::AbstractXorshift1024, seed::NTuple{16, UInt64})
    @inbounds for i in 1:16
        unsafe_store!(Ptr{UInt64}(pointer_from_objref(r)), seed[i], i)
    end
    r.p = 0
    for i in 1:16
        xorshift_next(r)
    end
    r
end

function srand(r::AbstractXorshift1024, seed::Integer...)
    l = length(seed)
    @assert 0 ≤ l ≤ 16 
    if l == 0
        srand(r, gen_seed(UInt64, 16))
    end
    if 0 < l < 16
        warn("Seed sequencing for Xorshift1024 family is unconfirmed. Please use 0 or 16 UInt64 numbers" +
             " for the seed.")
    end
    # TODO: this is really awful..
    srand(r, map(x -> x % UInt64, (seed..., [i for i in l+1:16]...)))
end

@inline rand(r::AbstractXorshift1024, ::Type{UInt64}) = xorshift_next(r)
