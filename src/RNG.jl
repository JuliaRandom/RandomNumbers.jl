__precompile__(true)

"""
Main module for `RNG.jl` -- a random number generator package for Julia Language.
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
