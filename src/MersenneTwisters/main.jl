import Base.Random: rand, srand
import RNG: gen_seed, seed_type

@inline rand(r::MT19937, ::Type{UInt32}) = mt_get(r)

srand(r::MT19937, seed::Integer) = mt_set!(r, seed % UInt32)
srand(r::MT19937, seed::NTuple{N, UInt32}=gen_seed(UInt32, N)) = mt_set!(r, seed)

seed_type(::Type{MT19937}) = NTuple{N, UInt32}
