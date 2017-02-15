const TEST_NAME = "MT19937"

include("common.jl")

using RandomNumbers.MersenneTwisters

r = MT19937(123)

test_all(r, 100_000_000)
