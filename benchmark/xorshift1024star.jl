const TEST_NAME = "Xorshift1024Star"

include("common.jl")

using RNG.Xorshifts

r = Xorshift1024Star(UInt64, 123)

test_all(r, 100_000_000)
