__precompile__(true)

"""
The module for [Xorshift Family](@ref).

Provide 11 RNG types:

- [`Xorshift64`](@ref)
- [`Xorshift64Star`](@ref)
- [`Xorshift128`](@ref)
- [`Xorshift128Star`](@ref)
- [`Xorshift128Plus`](@ref)
- [`Xorshift1024`](@ref)
- [`Xorshift1024Star`](@ref)
- [`Xorshift1024Plus`](@ref)
- [`Xoroshiro128`](@ref)
- [`Xoroshiro128Star`](@ref)
- [`Xoroshiro128Plus`](@ref)
"""
module Xorshifts

    export Xorshift64, Xorshift64Star
    include("xorshift64.jl")

    export Xorshift128, Xorshift128Star, Xorshift128Plus
    include("xorshift128.jl")

    export Xorshift1024, Xorshift1024Star, Xorshift1024Plus
    include("xorshift1024.jl")

    export Xoroshiro128, Xoroshiro128Star, Xoroshiro128Plus
    include("xoroshiro128.jl")

    include("docs.jl")
end
