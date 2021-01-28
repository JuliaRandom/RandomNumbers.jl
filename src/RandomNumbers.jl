__precompile__(true)

"""
Main module for `RandomNumbers.jl` -- a random number generator package for Julia Language.


This module exports two types and four submodules:

- [`AbstractRNG`](@ref)
- [`WrappedRNG`](@ref)
- [`PCG`](@ref)
- [`MersenneTwisters`](@ref)
- [`Random123`](random123.md#Random123.Random123)
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
    include(joinpath("Xorshifts", "Xorshifts.jl"))

    export randfloat
    include("randfloat.jl")

    import Requires
    function __init__()
        # The code of Random123 has been moved to Random123.jl
        Requires.@require Random123="74087812-796a-5b5d-8853-05524746bad3" import .Random123
    end

end
