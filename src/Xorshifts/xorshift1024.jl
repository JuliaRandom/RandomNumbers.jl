import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, seed_type, unsafe_copyto!, unsafe_compare

"""
```julia
AbstractXorshift1024 <: AbstractRNG{UInt64}
```

The base abstract type for `Xorshift1024`, `Xorshift1024Star` and `Xorshift1024Plus`.
"""
abstract type AbstractXorshift1024 <: AbstractRNG{UInt64} end

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift1024", star ? "Star" : plus ? "Plus" : ""))
    @eval begin
        mutable struct $rng_name <: AbstractXorshift1024
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
        end

        function $rng_name(seed::NTuple{16, UInt64}=gen_seed(UInt64, 16))
            o = zero(UInt64)
            r = $rng_name(
                o, o, o, o, o, o, o, o,
                o, o, o, o, o, o, o, o,
                zero(Int)
            )
            seed!(r, seed)
            r
        end

        function $rng_name(seed::Integer)
            $rng_name(init_seed(seed, UInt64, 16))
        end

        @inline function xorshift_next(r::$rng_name)
            ptr = Ptr{UInt64}(pointer_from_objref(r))
            p = r.p
            s0 = unsafe_load(ptr, p + 1)
            p = (p + 1) % 16
            s1 = unsafe_load(ptr, p + 1)
            s1 ⊻= s1 << 31
            s1 ⊻= s1 >> 11
            s1 ⊻= s0 >> 30
            s1 ⊻= s0
            unsafe_store!(ptr, s1, p + 1)
            r.p = p
            $(star ? :(s1 * 2685821657736338717) :
              plus ? :(s1 + s0) : :s1)
        end
    end
end

@inline seed_type(::Type{T}) where T <: AbstractXorshift1024 = NTuple{16, UInt64}

function copyto!(dest::T, src::T) where T <: AbstractXorshift1024
    unsafe_copyto!(dest, src, UInt64, 16)
    dest.p = src.p
    dest
end

copy(src::T) where T <: AbstractXorshift1024 = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractXorshift1024 = unsafe_compare(r1, r2, UInt64, 16) && r1.p == r2.p

function seed!(r::AbstractXorshift1024, seed::NTuple{16, UInt64})
    all(==(0), seed) && error("0 cannot be the seed")
    ptr = Ptr{UInt64}(pointer_from_objref(r))
    @inbounds for i in 1:16
        unsafe_store!(ptr, seed[i], i)
    end
    r.p = 0
    for i in 1:16
        xorshift_next(r)
    end
    r
end

function seed!(r::AbstractXorshift1024, seed::Integer...)
    l = length(seed)
    @assert 0 ≤ l ≤ 16 
    if l == 0
        return seed!(r, gen_seed(UInt64, 16))
    end
    seed = [x % UInt64 for x in seed]
    while length(seed) < 16
        push!(seed, splitmix64(seed[end]))
    end
    seed!(r, Tuple(seed))
end

@inline rand(r::AbstractXorshift1024, ::Type{UInt64}) = xorshift_next(r)
