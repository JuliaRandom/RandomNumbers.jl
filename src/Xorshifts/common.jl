@inline xorshift_rotl(x::UInt64, k::Int) = (x >>> (0x3f & -k)) | (x << (0x3f & k))
@inline xorshift_rotl(x::UInt32, k::Int) = (x >>> (0x1f & -k)) | (x << (0x1f & k))
