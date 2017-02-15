const TEST_NAME = "Threefry2x64"

include("common.jl")

using RandomNumbers.Random123

r = Threefry2x(UInt64, (123, 321))

test_all(r, 100_000_000)
