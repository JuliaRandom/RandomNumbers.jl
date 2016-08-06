const TEST_NAME = "Xoroshiro128Plus"

include("common.jl")

using RNG.Xorshifts

r = Xoroshiro128Plus(UInt64, 123)

test_all(r, 100_000_000)
