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

    import Requires
    function __init__()
        # The code of Random123 has been moved to Random123.jl
        Requires.@require Random123="c3412330-2d8f-11e9-13ca-d9033ffe1343" import Random123
    end

end
