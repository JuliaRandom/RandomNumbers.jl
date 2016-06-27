const TEST_NAME = "PCG_RSH_RS_128_64"

include("common.jl")

using RNG.PCG

r = PCGStateSetseq(UInt128, PCG_XSH_RS, 123 % UInt128, 456 % UInt128)

test_all(r, 100_000_000)
