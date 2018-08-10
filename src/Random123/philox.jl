import Base: copy, copyto!, ==
import Random: seed!
import RandomNumbers: gen_seed, seed_type, unsafe_copyto!, unsafe_compare

for (w, T, Td) in ((32, UInt32, UInt64), (64, UInt64, UInt128))
    @eval @inline function philox_mulhilo(a::$T, b::$T)
        product = (a % $Td) * (b % $Td)
        hi = (product >> $w) % $T
        lo = product % $T
        (hi, lo)
    end
end

@inline PHILOX_M2x_0(::Type{UInt64}) = 0xD2B74407B1CE6E93
@inline PHILOX_M4x_0(::Type{UInt64}) = 0xD2E7470EE14C6C93
@inline PHILOX_M4x_1(::Type{UInt64}) = 0xCA5A826395121157

@inline PHILOX_M2x_0(::Type{UInt32}) = 0xd256d193
@inline PHILOX_M4x_0(::Type{UInt32}) = 0xD2511F53
@inline PHILOX_M4x_1(::Type{UInt32}) = 0xCD9E8D57

@inline PHILOX_W_0(::Type{UInt64}) = 0x9E3779B97F4A7C15
@inline PHILOX_W_1(::Type{UInt64}) = 0xBB67AE8584CAA73B

@inline PHILOX_W_0(::Type{UInt32}) = 0x9E3779B9
@inline PHILOX_W_1(::Type{UInt32}) = 0xBB67AE85


"""
```julia
Philox2x{T, R} <: R123Generator2x{T}
Philox2x([seed, R])
Philox2x(T[, seed, R])
```

Philox2x is one kind of Philox Counter-Based RNGs. It generates two numbers at a time.

`T` is `UInt32` or `UInt64`(default).

`seed` is an `Integer` which will be automatically converted to `T`.

`R` denotes to the Rounds which must be at least 1 and no more than 16. With 10 rounds (by default), it has a
considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.
"""
mutable struct Philox2x{T<:Union{UInt32, UInt64}, R} <: R123Generator2x{T}
    x1::T
    x2::T
    key::T
    ctr1::T
    ctr2::T
    p::Int
end

function Philox2x(::Type{T}=UInt64, seed::Integer=gen_seed(T), R::Integer=10) where T <: Union{UInt32, UInt64}
    @assert 1 <= R <= 16
    r = Philox2x{T, Int(R)}(0, 0, 0, 0, 0, 0)
    seed!(r, seed)
end
Philox2x(seed::Integer, R::Integer=10) = Philox2x(UInt64, seed, R)

function seed!(r::Philox2x{T}, seed::Integer=gen_seed(T)) where T <: Union{UInt32, UInt64}
    r.x1 = r.x2 = 0
    r.key = seed % T
    r.ctr1 = r.ctr2 = 0
    random123_r(r)
    r.p = 0
    r
end

@inline seed_type(::Type{Philox2x{T, R}}) where {T, R} = T

function copyto!(dest::Philox2x{T, R}, src::Philox2x{T, R}) where {T, R}
    unsafe_copyto!(dest, src, T, 5)
    dest.p = src.p
    dest
end

copy(src::Philox2x{T, R}) where {T, R} = Philox2x{T, R}(src.x1, src.x2, src.key, src.ctr1, src.ctr2, src.p)

==(r1::Philox2x{T, R}, r2::Philox2x{T, R}) where {T, R} = unsafe_compare(r1, r2, T, 5) && r1.p == r2.p

@inline function philox2x_round(ctr1::T, ctr2::T, key::T) where T <: Union{UInt32, UInt64}
    hi, lo = philox_mulhilo(PHILOX_M2x_0(T), ctr1)
    hi ⊻ key ⊻ ctr2, lo
end

@inline function philox2x_bumpkey(key::T) where T <: Union{UInt32, UInt64}
    key + PHILOX_W_0(T)
end

@inline function random123_r(r::Philox2x{T, R}) where {T <: Union{UInt32, UInt64}, R}
    ctr1, ctr2, key = r.ctr1, r.ctr2, r.key
    if R > 0                               ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 1  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 2  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 3  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 4  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 5  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 6  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 7  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 8  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 9  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 10 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 11 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 12 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 13 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 14 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 15 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    r.x1, r.x2 = ctr1, ctr2
end

"""
```julia
Philox4x{T, R} <: R123Generator4x{T}
Philox4x([seed, R])
Philox4x(T[, seed, R])
```

Philox4x is one kind of Philox Counter-Based RNGs. It generates four numbers at a time.

`T` is `UInt32` or `UInt64`(default).

`seed` is a `Tuple` of two `Integer`s which will both be automatically converted to `T`.

`R` denotes to the Rounds which must be at least 1 and no more than 16. With 10 rounds (by default), it has a
considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.
"""
mutable struct Philox4x{T<:Union{UInt32, UInt64}, R} <: R123Generator4x{T}
    x1::T
    x2::T
    x3::T
    x4::T
    key1::T
    key2::T
    ctr1::T
    ctr2::T
    ctr3::T
    ctr4::T
    p::Int
end

function Philox4x(::Type{T}=UInt64, seed::NTuple{2, Integer}=gen_seed(T, 2), R::Integer=10) where
        T <: Union{UInt32, UInt64}
    @assert 1 <= R <= 16
    r = Philox4x{T, Int(R)}(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    seed!(r, seed)
end
Philox4x(seed::NTuple{2, Integer}, R::Integer=10) = Philox4x(UInt64, seed, R)

function seed!(r::Philox4x{T}, seed::NTuple{2, Integer}=gen_seed(T, 2)) where T <: Union{UInt32, UInt64}
    r.x1 = r.x2 = r.x3 = r.x4 = 0
    r.key1 = seed[1] % T
    r.key2 = seed[2] % T
    r.ctr1 = r.ctr2 = r.ctr3 = r.ctr4 = 0
    random123_r(r)
    r.p = 0
    r
end

@inline seed_type(::Type{Philox4x{T, R}}) where {T, R} = NTuple{2, T}

function copyto!(dest::Philox4x{T, R}, src::Philox4x{T, R}) where {T, R}
    unsafe_copyto!(dest, src, T, 10)
    dest.p = src.p
    dest
end

copy(src::Philox4x{T, R}) where {T, R} = Philox4x{T, R}(src.x1, src.x2, src.x3, src.x4, src.key1, src.key2,
                                                        src.ctr1, src.ctr2, src.ctr3, src.ctr4, src.p)

==(r1::Philox4x{T, R}, r2::Philox4x{T, R}) where {T, R} = unsafe_compare(r1, r2, T, 10)  && r1.p == r2.p

@inline function philox4x_round(ctr1::T, ctr2::T, ctr3::T, ctr4::T, key1::T, key2::T) where
        T <: Union{UInt32, UInt64}
    hi1, lo1 = philox_mulhilo(PHILOX_M4x_0(T), ctr1)
    hi2, lo2 = philox_mulhilo(PHILOX_M4x_1(T), ctr3)
    hi2 ⊻ ctr2 ⊻ key1, lo2, hi1 ⊻ ctr4 ⊻ key2, lo1
end

@inline function philox4x_bumpkey(key1::T, key2::T) where T <: Union{UInt32, UInt64}
    key1 + PHILOX_W_0(T), key2 + PHILOX_W_1(T)
end

@inline function random123_r(r::Philox4x{T, R}) where {T <: Union{UInt32, UInt64}, R}
    ctr1, ctr2, ctr3, ctr4 = r.ctr1, r.ctr2, r.ctr3, r.ctr4
    key1, key2 = r.key1, r.key2
    if R > 0
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 1
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 2
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 3
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 4
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 5
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 6
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 7
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 8
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 9
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 10
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 11
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 12
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 13
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 14
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    if R > 15
        key1, key2 = philox4x_bumpkey(key1, key2);
        ctr1, ctr2, ctr3, ctr4 = philox4x_round(ctr1, ctr2, ctr3, ctr4, key1, key2);
    end
    r.x1, r.x2, r.x3, r.x4 = ctr1, ctr2, ctr3, ctr4
end
