import Base.Random: rand, srand
import RNG: gen_seed

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


# TODO: Provide a method to make use all the generated numbers.

"""
    Philox2x{T, R} <: R123Generator2x{T}

Philox2x is one kind of Philox Counter-Based RNGs. It generates two numbers at a time.

`R` denotes to the Rounds. With 10 rounds (by default), it has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance.

Constructor: `Philox2x([T=UInt64, seed, R=10])` where `T` is `UInt32` or `UInt64`
"""
type Philox2x{T<:Union{UInt32, UInt64}, R} <: R123Generator2x{T}
    x1::T
    x2::T
    key::T
    ctr1::T
    ctr2::T
    p::Int
end

function Philox2x{T<:Union{UInt32, UInt64}}(::Type{T}=UInt64, seed::Integer=gen_seed(T), R::Integer=10)
    @assert 1 <= R <= 16
    r = Philox2x{T, Int(R)}(0, 0, 0, 0, 0, 0)
    srand(r, seed)
end

function srand{T<:Union{UInt32, UInt64}}(r::Philox2x{T}, seed::Integer=gen_seed(T))
    r.x1 = r.x2 = 0
    r.key = seed % T
    r.ctr1 = r.ctr2 = 0
    random123_r(r)
    r
end

@inline function philox2x_round{T<:Union{UInt32, UInt64}}(ctr1::T, ctr2::T, key::T)
    hi, lo = philox_mulhilo(PHILOX_M2x_0(T), ctr1)
    hi $ key $ ctr2, lo
end

@inline function philox2x_bumpkey{T<:Union{UInt32, UInt64}}(key::T)
    key + PHILOX_W_0(T)
end

@inline function random123_r{T<:Union{UInt32, UInt64}, R}(r::Philox2x{T, R})
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
    Philox4x{T, R} <: R123Generator4x{T}

Philox4x is one kind of Philox Counter-Based RNGs. It generates four numbers at a time.

`R` denotes to the Rounds. With 10 rounds (by default), it has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance.

Constructor: `Philox4x([T=UInt64, (seed1, seed2), R=10])` where `T` is `UInt32` or `UInt64`
"""
type Philox4x{T<:Union{UInt32, UInt64}, R} <: R123Generator4x{T}
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

function Philox4x{T<:Union{UInt32, UInt64}}(::Type{T}=UInt64,
        seed::NTuple{2, Integer}=gen_seed(T, 2), R::Integer=10)
    @assert 1 <= R <= 16
    r = Philox4x{T, Int(R)}(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    srand(r, seed)
end

function srand{T<:Union{UInt32, UInt64}}(r::Philox4x{T}, seed::NTuple{2, Integer}=gen_seed(T, 2))
    r.x1 = r.x2 = r.x3 = r.x4 = 0
    r.key1 = seed[1] % T
    r.key2 = seed[2] % T
    r.ctr1 = r.ctr2 = r.ctr3 = r.ctr4 = 0
    random123_r(r)
    r.p = 0
    r
end

@inline function philox4x_round{T<:Union{UInt32, UInt64}}(
        ctr1::T, ctr2::T, ctr3::T, ctr4::T, key1::T, key2::T)
    hi1, lo1 = philox_mulhilo(PHILOX_M4x_0(T), ctr1)
    hi2, lo2 = philox_mulhilo(PHILOX_M4x_1(T), ctr3)
    hi2 $ ctr2 $ key1, lo2, hi1 $ ctr4 $ key2, lo1
end

@inline function philox4x_bumpkey{T<:Union{UInt32, UInt64}}(key1::T, key2::T)
    key1 + PHILOX_W_0(T), key2 + PHILOX_W_1(T)
end

@inline function random123_r{T<:Union{UInt32, UInt64}, R}(r::Philox4x{T, R})
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

