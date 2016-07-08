__precompile__(true)

module RNG

    export PCG, MersenneTwisters, Random123, Xorshifts

    include("utils.jl")
    include("common.jl")

    include("./PCG/PCG.jl")
    include("./MersenneTwisters/MersenneTwisters.jl")
    include("./Random123/Random123.jl")
    include("./Xorshifts/Xorshifts.jl")

end
