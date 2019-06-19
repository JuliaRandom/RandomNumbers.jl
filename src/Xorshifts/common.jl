@inline xorshift_rotl(x::UInt64, k::Int) = (x >>> (0x3f & -k)) | (x << (0x3f & k))
@inline xorshift_rotl(x::UInt32, k::Int) = (x >>> (0x1f & -k)) | (x << (0x1f & k))

"""
SplitMix64: only for initializing a random seed.
"""
@inline function splitmix64(x::UInt64)
    x += 0x9e3779b97f4a7c15
    x = (x ⊻ (x >> 30)) * 0xbf58476d1ce4e5b9
    x = (x ⊻ (x >> 27)) * 0x94d049bb133111eb
    x ⊻ (x >> 31)
end

# for xoshiro256
function init_seed(seed::UInt64)
    x2 = splitmix64(seed)
    x3 = splitmix64(x2)
    x4 = splitmix64(x3)
    (seed, x2, x3, x4)
end
