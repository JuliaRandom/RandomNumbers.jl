const TEST_NAME = "Xoroshiro128Plus"

include("common.jl")

using RNG.Xorshifts

r = Xoroshiro128Plus(123)

test_all(r, 100_000_000)
