import Base: copy, copyto!, ==
import RandomNumbers: AbstractRNG, seed_type

"""
```julia
WrappedRNG{R, T1, T2} <: AbstractRNG{T2}
WrappedRNG(base_rng, T2)
WrappedRNG(R, T2, args...)
```

Wrap a RNG which originally provides output in T1 into a RNG that provides output in T2.

# Examples
```jldoctest
julia> r = Xorshifts.Xorshift128Star(123);

julia> RandomNumbers.output_type(r)
UInt64

julia> r1 = WrappedRNG(r, UInt32);

julia> RandomNumbers.output_type(r1)
UInt32

julia> r2 = WrappedRNG(Xorshifts.Xorshift128Star, UInt32, 123);

julia> RandomNumbers.output_type(r2)
UInt32

julia> @Test.test rand(r1, UInt32, 3) == rand(r2, UInt32, 3)
Test Passed
```
"""
mutable struct WrappedRNG{R<:AbstractRNG, T1<:BitTypes, T2<:BitTypes} <: AbstractRNG{T2}
    base_rng::R
    x::T1
    p::Int
    WrappedRNG{R, T1, T2}() where {R <: AbstractRNG, T1 <: BitTypes, T2 <: BitTypes} = 
        (@assert T1 ≠ T2; new())
end

function WrappedRNG(base_rng::AbstractRNG{T1}, ::Type{T2}) where {T1 <: BitTypes, T2 <: BitTypes}
    wr = WrappedRNG{typeof(base_rng), T1, T2}()
    wr.base_rng = copy(base_rng)
    if sizeof(T1) > sizeof(T2)
        wr.x = rand(wr.base_rng, T1)
    end
    wr.p = 0
    wr
end

function WrappedRNG(::Type{R}, ::Type{T2}, args...) where {R <: AbstractRNG, T2 <: BitTypes}
    base_rng = R(args...)
    WrappedRNG(base_rng, T2)
end

WrappedRNG(base_rng::WrappedRNG{R, T1, T2}, ::Type{T3}) where 
    {R <: AbstractRNG, T1 <: BitTypes, T2 <: BitTypes, T3 <: BitTypes} = WrappedRNG(base_rng.base_rng, T3)

seed_type(::Type{WrappedRNG{R, T1, T2}}) where {R, T1, T2} = seed_type(R)

function copyto!(dest::R, src::R) where R <: WrappedRNG
    copyto!(dest.base_rng, src.base_rng)
    dest.x = src.x
    dest.p = src.p
    dest
end

function copy(src::R) where R <: WrappedRNG
    wr = R()
    wr.base_rng = copy(src.base_rng)
    wr.x = src.x
    wr.p = src.p
    wr
end

==(r1::R, r2::R) where R <: WrappedRNG = r1.base_rng == r2.base_rng && r1.x == r2.x && r1.p == r2.p

function seed!(wr::WrappedRNG, seed...)
    seed!(wr.base_rng, seed...)
        if sizeof(T1) > sizeof(T2)
            wr.x = rand(wr.base_rng, T1)
        end
    wr.p = 0
    wr
end

@inline function rand(rng::WrappedRNG{R, T1, T2}, ::Type{T2}) where
        {R <: AbstractRNG, T1 <: BitTypes, T2 <: BitTypes}
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    if s2 >= s1
        t = rand(rng.base_rng, T1) % T2
        for i in 2:(s2 ÷ s1)
            t |= (rand(rng.base_rng, T1) % T2) << ((s1 << 3) * (i - 1))
        end
    else
        t = rng.x % T2
        rng.p += 1
        if rng.p == s1 ÷ s2
            rng.p = 0
            rng.x = rand(rng.base_rng, T1)
        else
            rng.x >>= s2 << 3
        end
    end
    return t
end
