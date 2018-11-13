__precompile__(true)

"""
Main module for `RandomNumbers.jl` -- a random number generator package for Julia Language.


This module exports two types and four submodules:

- [`AbstractRNG`](@ref)
- [`WrappedRNG`](@ref)
- [`PCG`](@ref)
- [`MersenneTwisters`](@ref)
- [`Random123`](@ref)
- [`Xorshifts`](@ref)
"""
module RandomNumbers

    export AbstractRNG
    export WrappedRNG
    export output_type, seed_type
    export PCG, MersenneTwisters, Random123, Xorshifts

    include("common.jl")
    include("utils.jl")
    
    include("wrapped_rng.jl")

    include(joinpath("PCG", "PCG.jl"))
    include(joinpath("MersenneTwisters", "MersenneTwisters.jl"))
    include(joinpath("Random123", "Random123.jl"))
    include(joinpath("Xorshifts", "Xorshifts.jl"))

end
