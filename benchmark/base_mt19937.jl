const TEST_NAME = "BaseMT19937"

include("common.jl")

r = MersenneTwister(123)

test_all(r, 100_000_000)
