__precompile__(true)

module Random123

    include("common.jl")

    export Threefry2x, Threefry4x
    include("threefry.jl")

    export Philox2x, Philox4x
    include("philox.jl")

end
