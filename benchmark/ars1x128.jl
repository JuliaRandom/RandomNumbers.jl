const TEST_NAME = "ARS1x128"

include("common.jl")

using RandomNumbers.Random123

r = ARS1x(123)

test_all(r, 100_000_000)
