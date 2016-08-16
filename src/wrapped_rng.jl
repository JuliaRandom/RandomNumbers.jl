import RNG: AbstractRNG

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

julia> RNG.output_type(r)
UInt64

julia> r1 = WrappedRNG(r, UInt32);

julia> RNG.output_type(r1)
UInt32

julia> r2 = WrappedRNG(Xorshifts.Xorshift128Star, UInt32, 123);

julia> RNG.output_type(r2)
UInt32

julia> @Test.test rand(r1, UInt32, 3) == rand(r2, UInt32, 3)
Test Passed
  Expression: rand(r1,UInt32,3) == rand(r2,UInt32,3)
   Evaluated: UInt32[0x18a21796,0x20241598,0x63c65407] == UInt32[0x18a21796,0x20241598,0x63c65407]
```
"""
type WrappedRNG{R<:AbstractRNG, T1<:BitTypes, T2<:BitTypes} <: AbstractRNG{T2}
    base_rng::R
    x::T1
    p::Int
    function WrappedRNG(r, x, p)
        @assert T1 ≠ T2
        wr = new(r, x, p)
        if sizeof(T1) > sizeof(T2)
            wr.x = rand(wr.base_rng, T1)
        end
        wr
    end
end
WrappedRNG{T1<:BitTypes, T2<:BitTypes}(
    base_rng::AbstractRNG{T1}, ::Type{T2}) = WrappedRNG{typeof(base_rng), T1, T2}(base_rng, 0, 0)
function WrappedRNG{R<:AbstractRNG, T2<:BitTypes}(::Type{R}, ::Type{T2}, args...)
    base_rng = R(args...)
    WrappedRNG{R, output_type(base_rng), T2}(base_rng, 0, 0)
end

@inline rand{R<:AbstractRNG, T1<:BitTypes}(rng::WrappedRNG{R, T1}, ::Type{T1}) = rand(rng.base_rng, T1)

@inline function rand{R<:AbstractRNG, T1<:BitTypes, T2<:BitTypes}(rng::WrappedRNG{R, T1, T2}, ::Type{T2})
    s1 = sizeof(T1)
    s2 = sizeof(T2)
    if s2 >= s1
        t = rand(rng.base_rng, T1) % T2
        for i in 2:(s2 ÷ s1)
            t |= rand(rng.base_rng, T1) << ((s1 << 3) * (i - 1))
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
