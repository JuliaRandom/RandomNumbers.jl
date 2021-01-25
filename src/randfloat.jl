const Xoroshiro128P = Xorshifts.Xoroshiro128Plus()    # use as default RNG for randfloat

"""Random number generator for Float32 in [0,1) that samples from *all* floats.""" 
function randfloat(rng::AbstractRNG,::Type{Float32})
    # create exponent bits in 0000_0000 to 0111_1110
    # at following chances
    # e=01111110 at 50.0% for [0.5,1.0)
    # e=01111101 at 25.0% for [0.25,0.5)
    # e=01111100 at 12.5% for [0.125,0.25)
    # ...
    ui = rand(rng,UInt64) >> 1    # first bit always 0

    # count leading zeros of random UInt128 in two steps
    # only if first random UInt64 is zero create a second one
    # 0 leading zeros at 0% chance due to >> 1 above
    # 1 leading zero at 50% chance
    # 2 leading zeros at 25% chance etc.
    lz = ui == 0 ?
        64+leading_zeros(rand(rng,UInt64) | 0x1) : leading_zeros(ui) 
    e = ((127 - lz) % UInt32) << 23     # convert lz to exponent bits of float32

    # significant bits
    f = rand(rng,UInt32) >> 9 
    
    # combine exponent and significand (sign always 0)
    return reinterpret(Float32,e | f)
end

"""Random number generator for Float64 in [0,1) that samples from *all* floats.""" 
function randfloat(rng::AbstractRNG,::Type{Float64})
    # create exponent bits in 00_0000_0000 to 01_1111_1110
    # at following chances
    # e=0111111110 at 50.0% for [0.5,1.0)
    # e=0111111101 at 25.0% for [0.25,0.5)
    # e=0111111100 at 12.5% for [0.125,0.25)
    # ...
    ui = rand(rng,UInt64) >> 1    # first bit always 0

    # count leading zeros of random UInt128 in several steps
    # only if first random UInt64 is zero create a next one
    # 0 leading zeros at 0% chance due to >> 1 above
    # 1 leading zero at 50% chance
    # 2 leading zeros at 25% chance etc.
    # Technically one would need to draw up to 16 UInt64 to allow for up to 1022
    # leading zeros, however, most (all? TODO is that true?) RNGs don't produce
    # several UInt64(0) consequitively, so stop at 2
    lz = ui == 0 ?
        64+leading_zeros(rand(rng,UInt64)) : leading_zeros(ui) 
    e = ((1023 - lz) % UInt64) << 52     # convert lz to exponent bits of float64

    # significant bits
    f = rand(rng,UInt64) >> 12 
    
    # combine exponent and significand (sign always 0)
    return reinterpret(Float64,e | f)
end

# use Xoroshiro128Plus and Float64 as default
randfloat(::Type{T}=Float64) where T = randfloat(Xoroshiro128P,T)
randfloat(rng::AbstractRNG) = randfloat(rng,Float64)

# array versions
function randfloat!(rng::AbstractRNG, A::AbstractArray{T}) where T
    for i in eachindex(A)
        @inbounds A[i] = randfloat(rng, T)
    end
    A
end

randfloat(rng::AbstractRNG, ::Type{T}, dims::Integer...) where T = randfloat!(rng, Array{T}(undef,dims))
randfloat(rng::AbstractRNG,            dims::Integer...)         = randfloat!(rng, Array{Float64}(undef,dims))
randfloat(                  ::Type{T}, dims::Integer...) where T = randfloat!(Xoroshiro128P, Array{T}(undef,dims))
randfloat(                             dims::Integer...)         = randfloat!(Xoroshiro128P, Array{Float64}(undef,dims))