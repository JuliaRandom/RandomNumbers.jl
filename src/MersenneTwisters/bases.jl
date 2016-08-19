import RNG: AbstractRNG, gen_seed

"""
```julia
MersenneTwister{T} <: RNG.AbstractRNG{T}
```

The base type of Mersenne Twisters.
"""
abstract MersenneTwister{T<:Number} <: AbstractRNG{T}

const N = 624
const M = 397
const UPPER_MASK = 0x800000000
const LOWER_MASK = 0x7ffffffff

"""
```julia
MT19937 <: MersenneTwister{UInt32}
MT19937([seed])
```

MT19937 RNG. The `seed` is a `Tuple` of $N `UInt32` numbers, or an `Integer` which will be automatically
convert to an `UInt32` number.
"""
type MT19937 <: MersenneTwister{UInt32}
    mt::Vector{UInt32}
    mti::Int
end
MT19937(seed::Integer) = srand(MT19937(Vector{UInt32}(N), 1), seed % UInt32)
MT19937(seed::NTuple{N, UInt32}=gen_seed(UInt32, N)) = srand(MT19937(Vector{UInt32}(N), 1), seed)

"Set up a `MT19937` RNG object using a `Tuple` of $N `UInt32` numbers."
@inline function mt_set!(r::MT19937, s::NTuple{N, UInt32})
    @inbounds for i in 1:N
        r.mt[i] = s[i]
    end
    r.mti = N + 1
    r
end

"Set up a `MT19937` RNG object using an `UInt32` number."
@inline function mt_set!(r::MT19937, s::UInt32)
    r.mt[1] = s
    @inbounds for i in 2:N
        r.mt[i] = (0x6c078965 * (r.mt[i-1] $ (r.mt[i-1] >> 30)) + i - 1)
    end
    r.mti = N + 1
    r
end

@inline mt_magic(y) = y & 1 == 1 ? 0x9908b0df : (0 % UInt32)
"Get a random `UInt32` number from a `MT19937` object."
@inline function mt_get(r::MT19937)
    mt = r.mt
    if r.mti > N
        @inbounds for i in 1:N-M
            y = (mt[i] & UPPER_MASK) | (mt[i+1] & LOWER_MASK)
            mt[i] = mt[i + M] $ (y >> 1) $ mt_magic(y)
        end
        @inbounds for i in N-M+1:N-1
            y = (mt[i] & UPPER_MASK) | (mt[i+1] & LOWER_MASK)
            mt[i] = mt[i + M - N] $ (y >> 1) $ mt_magic(y)
        end
        @inbounds begin
            y = (mt[N] & UPPER_MASK) | (mt[1] & LOWER_MASK)
            mt[N] = mt[M] $ (y >> 1) $ mt_magic(y)
        end
        r.mti = 1
    end
    k = mt[r.mti]
    k $= (k >> 11)
    k $= (k >> 7) & 0x9d2c5680
    k $= (k >> 15) & 0xefc60000
    k $= (k >> 18)

    r.mti += 1
    k
end
