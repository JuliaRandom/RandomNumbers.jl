using Test
@testset "RandomNumbers" begin
    for (i, testfile) in enumerate((
        "generic.jl",
        "wrapped_rng.jl",
        "randfloat.jl",
        "PCG/runtests.jl",
        "MersenneTwisters/runtests.jl",
        "Xorshifts/runtests.jl"))
        @eval module $(Symbol("T$i"))
            include("common.jl")
            include($testfile)
        end
    end
end