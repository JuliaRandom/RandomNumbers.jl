import Random: GLOBAL_RNG

"""Random number generator for Float32 in [0,1) that samples from 
42*2^23 float32s in [0,1) compared to 2^23 for rand(Float32).""" 
function randfloat(rng::Random.AbstractRNG,::Type{Float32})
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
    lz = leading_zeros(ui)
    e = ((126 - lz) % UInt32) << 23

    # for 64 leading zeros the smallest float32 that can be created is 2.7105054f-20
    # use last 23 bits for signficand, only when they are not part of the leading zeros
    # to sample from all floats in 2.7105054f-20 to prevfloat(1f0)
    ui = lz > 40 ? rand(rng,UInt64) : ui

    # combine exponent and signficand
    return reinterpret(Float32,e | ((ui % UInt32) & 0x007f_ffff))
end

"""Random number generator for Float64 in [0,1) that samples from 
64*2^52 floats compared to 2^52 for rand(Float64).""" 
function randfloat(rng::Random.AbstractRNG,::Type{Float64})
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

"""Random number generator for Float16 in [0,1) that samples from 
all 15360 float16s in that range.""" 
function randfloat(rng::Random.AbstractRNG,::Type{Float16})
    # create exponent bits in 00000 to 01110
    # at following chances
    # e=01110 at 50.0% for [0.5,1.0)
    # e=01101 at 25.0% for [0.25,0.5)
    # e=01100 at 12.5% for [0.125,0.25)
    # ...
    ui = rand(rng,UInt32) | 0x0002_0000
    # set 15th bit to 1 to have at most 14 leading zeros.

    # count leading zeros of random UInt64 in several steps
    # 0 leading zeros at 50% chance
    # 1 leading zero at 25% chance
    # 2 leading zeros at 12.5% chance etc.
    # then convert leading zeros to exponent bits of Float16
    lz = leading_zeros(ui)
    e = ((14 - lz) % UInt32) << 10
    
    # combine exponent and significand (sign always 0)
    return reinterpret(Float16,(e | (ui & 0x0000_03ff)) % UInt16)
end

# use stdlib default RNG as a default here too
randfloat(::Type{T}=Float64) where {T<:Base.IEEEFloat} = randfloat(GLOBAL_RNG,T)
randfloat(rng::Random.AbstractRNG) = randfloat(rng,Float64)

# randfloat for arrays - in-place
function randfloat!(rng::Random.AbstractRNG, A::AbstractArray{T}) where T
    for i in eachindex(A)
        @inbounds A[i] = randfloat(rng, T)
    end
    A
end

# randfloat for arrays with memory allocation
randfloat(rng::Random.AbstractRNG, ::Type{T}, dims::Integer...) where {T<:Base.IEEEFloat} = randfloat!(rng, Array{T}(undef,dims))
randfloat(rng::Random.AbstractRNG,            dims::Integer...)                           = randfloat!(rng, Array{Float64}(undef,dims))
randfloat(::Type{T}, dims::Integer...) where {T<:Base.IEEEFloat} = randfloat!(GLOBAL_RNG, Array{T}(undef,dims))
randfloat(           dims::Integer...)                           = randfloat!(GLOBAL_RNG, Array{Float64}(undef,dims))