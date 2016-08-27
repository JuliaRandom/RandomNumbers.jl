using RNG.Xorshifts

seed = RNG.gen_seed(UInt64, 2)
r = Xoroshiro128(seed)

r1 = WrappedRNG(r, UInt32)
r2 = WrappedRNG(Xoroshiro128, UInt32, seed)

@test rand(r1, UInt64) == rand(r2, UInt64)
@test rand(r1, UInt32) == rand(r2, UInt32)

rand(r2, UInt32)

r3 = WrappedRNG(r, UInt128)
@test rand(r3, UInt128) == rand(r2, UInt128)
