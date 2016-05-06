Pkg.add("RNGTest")
using RNG
using RNGTest
using Base.Test

const pval = 0.001

macro rng_test(rng)
    info("Testing $rng")
    return quote
        trng = $rng
        trand() = rand(trng)
        result = RNGTest.smallcrushJulia(trand)
        for x in result
            @test all(vcat(x...) .> pval)
        end
    end
end
