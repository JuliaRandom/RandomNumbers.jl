const TEST_NAME = "Xorshift1024Star"

include("common.jl")

using RandomNumbers.Xorshifts

r = Xorshift1024Star(123)

test_all(r, 100_000_000)
