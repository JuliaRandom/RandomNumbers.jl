const TEST_NAME = "PCG_XSH_RS_128_64"

include("common.jl")

using RandomNumbers.PCG

r = PCGStateSetseq(UInt64, PCG_XSH_RS,
    (0x4e17a5abd5d47402ce332459f69eacfd, 0x96856028d0dc791c176537f21a77ab67))

test_all(r, 100_000_000)
