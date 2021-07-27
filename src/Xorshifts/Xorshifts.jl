__precompile__(true)

"""
The module for [Xorshift Family](@ref).

Provide 8 RNG types (others are to be deprecated):

- [`Xoroshiro64Star`](@ref)
- [`Xoroshiro64StarStar`](@ref)
- [`Xoroshiro128Plus`](@ref)
- [`Xoroshiro128StarStar`](@ref)
- [`Xoshiro128Plus`](@ref)
- [`Xoshiro128StarStar`](@ref)
- [`Xoshiro256Plus`](@ref)
- [`Xoshiro256StarStar`](@ref)
"""
module Xorshifts

include("common.jl")

include("splitmix64.jl")

include("xorshift64.jl")

include("xorshift128.jl")

include("xorshift1024.jl")

export Xoroshiro64Star, Xoroshiro64StarStar
include("xoroshiro64.jl")

export Xoroshiro128Plus, Xoroshiro128StarStar
include("xoroshiro128.jl")

export Xoshiro128Plus, Xoshiro128StarStar
include("xoshiro128.jl")

export Xoshiro256Plus, Xoshiro256StarStar
include("xoshiro256.jl")

include("docs.jl")

end
