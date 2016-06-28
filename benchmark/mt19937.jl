const TEST_NAME = "MT19937"

include("common.jl")

using RNG.MersenneTwisters

r = MT19937()

test_all(r, 100_000_000)
