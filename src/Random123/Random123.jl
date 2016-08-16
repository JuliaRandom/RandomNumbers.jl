__precompile__(true)

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
