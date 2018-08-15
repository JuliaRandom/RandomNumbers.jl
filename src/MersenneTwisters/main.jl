import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: gen_seed, seed_type

@inline rand(r::MT19937, ::Type{UInt32}) = mt_get(r)

seed!(r::MT19937, seed::Integer) = mt_set!(r, seed % UInt32)
seed!(r::MT19937, seed::NTuple{N, UInt32}=gen_seed(UInt32, N)) = mt_set!(r, seed)

seed_type(::Type{MT19937}) = NTuple{N, UInt32}

function copyto!(dest::MT19937, src::MT19937)
    copyto!(dest.mt, src.mt)
    dest.mti = src.mti
    dest
end

copy(src::MT19937) = MT19937(copy(src.mt), src.mti)

==(r1::MT19937, r2::MT19937) = r1.mt == r2.mt && r1.mti == r2.mti
