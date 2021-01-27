import Random: default_rng, AbstractRNG

"""Random number generator for Float32 in [0,1) that samples from 
42*2^23 float32s in [0,1) compared to 2^23 for rand(Float32).""" 
function randfloat(rng::AbstractRNG,::Type{Float32})
    # create exponent bits in 0000_0000 to 0111_1110
    # at following chances
    # e=01111110 at 50.0% for [0.5,1.0)
    # e=01111101 at 25.0% for [0.25,0.5)
    # e=01111100 at 12.5% for [0.125,0.25)
    # ...
    ui = rand(rng,UInt64)

    # count leading zeros of random UInt64
    # 0 leading zeros at 50% chance
    # 1 leading zero at 25% chance
    # 2 leading zeros at 12.5% chance etc.
    # then convert leading zeros to exponent bits of Float32
    e = ((126 - leading_zeros(ui)) % UInt32) << 23

    # for 64 leading zeros the smallest float32 that
    # can be created is 2.7105054f-20

    # reuse last 23 bits for signficand, this impacts only
    # numbers <= 1.1368684f-13 where the sampled floats will
    # have zeros in their first significant bits, but only to
    # be expected after 35TB of data
    return reinterpret(Float32,e | ((ui % UInt32) & 0x007f_ffff))
end

"""Random number generator for Float64 in [0,1) that samples from 
64*2^52 floats compared to 2^52 for rand(Float64).""" 
function randfloat(rng::AbstractRNG,::Type{Float64})
    # create exponent bits in 000_0000_0000 to 011_1111_1110
    # at following chances
    # e=01111111110 at 50.0% for [0.5,1.0)
    # e=01111111101 at 25.0% for [0.25,0.5)
    # e=01111111100 at 12.5% for [0.125,0.25)
    # ...
    ui = rand(rng,UInt64)

    # count leading zeros of random UInt64 in several steps
    # 0 leading zeros at 50% chance
    # 1 leading zero at 25% chance
    # 2 leading zeros at 12.5% chance etc.
    # then convert leading zeros to exponent bits of Float64
    lz = leading_zeros(ui)
    e = ((1022 - lz) % UInt64) << 52

    # for 64 leading zeros the smallest float64 that
    # can be created is 2.710505431213761e-20

    # draw another UInt64 for significant bits in case the leading
    # zeros reach into the bits that would be used for the significand
    # (in which case the first signifcant bits would always be zero)
    ui = lz > 11 ? rand(rng,UInt64) : ui
    
    # combine exponent and significand (sign always 0)
    return reinterpret(Float64,e | (ui & 0x000f_ffff_ffff_ffff))
end

# use stdlib default RNG as a default here too
randfloat(::Type{T}=Float64) where T = randfloat(default_rng(),T)
randfloat(rng::AbstractRNG) = randfloat(rng,Float64)

# randfloat for arrays - in-place
function randfloat!(rng::AbstractRNG, A::AbstractArray{T}) where T
    for i in eachindex(A)
        @inbounds A[i] = randfloat(rng, T)
    end
    A
end

# randfloat for arrays with memory allocation
randfloat(rng::AbstractRNG, ::Type{T}, dims::Integer...) where T = randfloat!(rng, Array{T}(undef,dims))
randfloat(rng::AbstractRNG,            dims::Integer...)         = randfloat!(rng, Array{Float64}(undef,dims))
randfloat(                  ::Type{T}, dims::Integer...) where T = randfloat!(default_rng(), Array{T}(undef,dims))
randfloat(                             dims::Integer...)         = randfloat!(default_rng(), Array{Float64}(undef,dims))