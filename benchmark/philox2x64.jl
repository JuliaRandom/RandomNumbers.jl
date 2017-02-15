const TEST_NAME = "Philox2x64"

include("common.jl")

using RandomNumbers.Random123

r = Philox2x(UInt64, 123)

test_all(r, 100_000_000)
