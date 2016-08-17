__precompile__(true)

"""
The module for [Random123 Family](@ref).

Provide 8 RNG types:

- [`Threefry2x`](@ref)
- [`Threefry4x`](@ref)
- [`Philox2x`](@ref)
- [`Philox4x`](@ref)
- [`AESNI1x`](@ref)
- [`AESNI4x`](@ref)
- [`ARS1x`](@ref)
- [`ARS4x`](@ref)
"""
module Random123

export R123_USE_AESNI
include("common.jl")

export Threefry2x, Threefry4x
include("threefry.jl")

export Philox2x, Philox4x
include("philox.jl")

if R123_USE_AESNI
    export AESNI1x, AESNI4x
    include("aesni.jl")

    export ARS1x, ARS4x
    include("ars.jl")
end

end
