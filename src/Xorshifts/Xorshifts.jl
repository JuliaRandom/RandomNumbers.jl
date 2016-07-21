__precompile__(true)

module Xorshifts

    export Xorshift64, Xorshift64Star
    include("xorshift64.jl")

    export Xorshift128, Xorshift128Star, Xorshift128Plus
    include("xorshift128.jl")

    export Xorshift1024, Xorshift1024Star, Xorshift1024Plus
    include("xorshift1024.jl")

    export Xoroshiro128, Xoroshiro128Star, Xoroshiro128Plus
    include("xoroshiro128.jl")

end
