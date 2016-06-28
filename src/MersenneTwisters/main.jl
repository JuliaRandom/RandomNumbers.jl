import Base.Random: rand, srand
import RNG: gen_seed

@inline rand(r::MT19937, ::Type{UInt32}) = mt_get(r)

srand(r::MT19937, seed::UInt32=gen_seed(UInt32)) = mt_set!(r, seed)
