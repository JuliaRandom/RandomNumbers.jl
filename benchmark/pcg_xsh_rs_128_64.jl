const TEST_NAME = "PCG_XSH_RS_128_64"

include("common.jl")

using RNG.PCG

r = PCGStateSetseq(UInt64, PCG_XSH_RS, (123, 456))

test_all(r, 100_000_000)
