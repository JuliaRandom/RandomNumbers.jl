__precompile__(true)

module RNG

    export PCG, MersenneTwisters

    include("utils.jl")
    include("common.jl")

    include("./PCG/PCG.jl")
    include("./MersenneTwisters/MersenneTwisters.jl")

end
