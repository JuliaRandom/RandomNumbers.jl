__precompile__(true)

module Xorshifts

    export Xorshift64, Xorshift64Star
    include("xorshift64.jl")

    export Xorshift128, Xorshift128Star, Xorshift128Plus
    include("xorshift128.jl")

end
