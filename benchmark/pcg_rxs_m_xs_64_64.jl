const TEST_NAME = "PCG_RXS_M_XS_64_64"

include("common.jl")

using RNG.PCG

r = PCGStateSetseq(UInt64, PCG_RXS_M_XS, 123 % UInt64, 456 % UInt64)

test_all(r, 100_000_000)
