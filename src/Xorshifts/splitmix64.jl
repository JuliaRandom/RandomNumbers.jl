import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: AbstractRNG, gen_seed, seed_type


"""
```julia
SplitMix64 <: AbstractRNG{UInt64}
SplitMix64([seed])
```

Used for initializing a random seed.
"""
mutable struct SplitMix64 <: AbstractRNG{UInt64}
    x::UInt64
end
function SplitMix64(seed::Integer=gen_seed(UInt64))
    r = SplitMix64(zero(UInt64))
    seed!(r, seed)
    r
end

@inline seed_type(::Type{SplitMix64}) = UInt64

function copyto!(dest::SplitMix64, src::SplitMix64)
    dest.x = src.x
    dest
end

copy(src::SplitMix64) = copyto!(SplitMix64(zero(UInt64)), src)

==(r1::SplitMix64, r2::SplitMix64) = r1.x == r2.x

function seed!(r::SplitMix64, seed::Integer=gen_seed(UInt64))
    r.x = splitmix64(seed % UInt64)
    r
end

@inline function rand(r::SplitMix64, ::Type{UInt64})
    r.x = splitmix64(r.x)
end

@inline function splitmix64(x::UInt64)
    x += 0x9e3779b97f4a7c15
    x = (x ⊻ (x >> 30)) * 0xbf58476d1ce4e5b9
    x = (x ⊻ (x >> 27)) * 0x94d049bb133111eb
    x ⊻ (x >> 31)
end

init_seed(seed, ::Type{UInt64}) = splitmix64(seed % UInt64)
function init_seed(seed, ::Type{UInt64}, N::Int)
    x = seed % UInt64
    NTuple{N, UInt64}(
        x = splitmix64(x)
        for _ in 1:N
    )
end
function init_seed(seed, ::Type{UInt32}, N::Int)
    x = seed % UInt64
    NTuple{N, UInt32}(begin
        x = splitmix64(x)
        x % UInt32
    end for _ in 1:N)
end
