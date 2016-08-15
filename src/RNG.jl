__precompile__(true)

"""
Main module for `RNG.jl` -- a random number generator package for Julia Language.


This module exports one abstract type and four submodules:

- [`AbstractRNG`](@ref). The base type of all the RNGs.
- [`PCG`](@ref).
- [`MersenneTwisters`](@ref).
- [`Random123`](@ref).
- [`Xorshifts`](@ref).
"""
module RNG

    export AbstractRNG
    export PCG, MersenneTwisters, Random123, Xorshifts

    include("utils.jl")
    include("common.jl")

    include("./PCG/PCG.jl")
    include("./MersenneTwisters/MersenneTwisters.jl")
    include("./Random123/Random123.jl")
    include("./Xorshifts/Xorshifts.jl")

end
