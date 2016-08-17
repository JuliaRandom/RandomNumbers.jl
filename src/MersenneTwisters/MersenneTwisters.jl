__precompile__(true)

"""
The module for [Mersenne Twisters](@ref).

Currently only provide one RNG type:

- [`MT19937`](@ref)
"""
module MersenneTwisters

export MT19937

include("bases.jl")
include("main.jl")

end
