const TEST_NAME = "AESNI1x128"

include("common.jl")

using RandomNumbers.Random123

r = AESNI1x(123)

test_all(r, 100_000_000)
