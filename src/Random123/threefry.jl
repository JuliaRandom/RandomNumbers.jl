import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

abstract Threefry{T<:Union{UInt32, UInt64}} <: AbstractRNG{T}

@inline threefry_rotl(x::UInt64, N) = (x << (N & 63)) | (x >> ((64-N) & 63))
@inline threefry_rotl(x::UInt32, N) = (x << (N & 31)) | (x >> ((32-N) & 31))

@inline SKEIN_KS_PARITY(::Type{UInt32}) = 0x1BD11BDA
@inline SKEIN_KS_PARITY(::Type{UInt64}) = 0x1BD11BDAA9FC1A22

@inline Rx4_0_0(::Type{UInt64}) = 14
@inline Rx4_0_1(::Type{UInt64}) = 16
@inline Rx4_1_0(::Type{UInt64}) = 52
@inline Rx4_1_1(::Type{UInt64}) = 57
@inline Rx4_2_0(::Type{UInt64}) = 23
@inline Rx4_2_1(::Type{UInt64}) = 40
@inline Rx4_3_0(::Type{UInt64}) =  5
@inline Rx4_3_1(::Type{UInt64}) = 37
@inline Rx4_4_0(::Type{UInt64}) = 25
@inline Rx4_4_1(::Type{UInt64}) = 33
@inline Rx4_5_0(::Type{UInt64}) = 46
@inline Rx4_5_1(::Type{UInt64}) = 12
@inline Rx4_6_0(::Type{UInt64}) = 58
@inline Rx4_6_1(::Type{UInt64}) = 22
@inline Rx4_7_0(::Type{UInt64}) = 32
@inline Rx4_7_1(::Type{UInt64}) = 32

@inline Rx2_0_0(::Type{UInt64}) = 16
@inline Rx2_1_0(::Type{UInt64}) = 42
@inline Rx2_2_0(::Type{UInt64}) = 12
@inline Rx2_3_0(::Type{UInt64}) = 31
@inline Rx2_4_0(::Type{UInt64}) = 16
@inline Rx2_5_0(::Type{UInt64}) = 32
@inline Rx2_6_0(::Type{UInt64}) = 24
@inline Rx2_7_0(::Type{UInt64}) = 21

@inline Rx4_0_0(::Type{UInt32}) = 10
@inline Rx4_0_1(::Type{UInt32}) = 26
@inline Rx4_1_0(::Type{UInt32}) = 11
@inline Rx4_1_1(::Type{UInt32}) = 21
@inline Rx4_2_0(::Type{UInt32}) = 13
@inline Rx4_2_1(::Type{UInt32}) = 27
@inline Rx4_3_0(::Type{UInt32}) = 23
@inline Rx4_3_1(::Type{UInt32}) =  5
@inline Rx4_4_0(::Type{UInt32}) =  6
@inline Rx4_4_1(::Type{UInt32}) = 20
@inline Rx4_5_0(::Type{UInt32}) = 17
@inline Rx4_5_1(::Type{UInt32}) = 11
@inline Rx4_6_0(::Type{UInt32}) = 25
@inline Rx4_6_1(::Type{UInt32}) = 10
@inline Rx4_7_0(::Type{UInt32}) = 18
@inline Rx4_7_1(::Type{UInt32}) = 20
@inline Rx2_0_0(::Type{UInt32}) = 13
@inline Rx2_1_0(::Type{UInt32}) = 15
@inline Rx2_2_0(::Type{UInt32}) = 26
@inline Rx2_3_0(::Type{UInt32}) =  6
@inline Rx2_4_0(::Type{UInt32}) = 17
@inline Rx2_5_0(::Type{UInt32}) = 29
@inline Rx2_6_0(::Type{UInt32}) = 16
@inline Rx2_7_0(::Type{UInt32}) = 24

# TODO: Provide a method to make use all the generated numbers.

"""
    Threefry2x{T, R} <: Threefry{T}

Threefry2x is one kind of Threefry Counter-Based RNGs. It generates two numbers at a time.

`R` denotes to the Rounds. With 20 rounds (by default), it has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance.

Constructor: `Threefry2x([T=UInt64, (seed1, seed2), R=20])` where `T` is `UInt32` or `UInt64`
"""
type Threefry2x{T<:Union{UInt32, UInt64}, R} <: Threefry{T}
    key1::T
    key2::T
    ctr1::T
    ctr2::T
    x1::T
    x2::T
end
function Threefry2x{T<:Union{UInt32, UInt64}}(::Type{T}=UInt64, seed::Tuple{Integer, Integer}=gen_seed(T, 2), R::Integer=20)
    @assert 1 <= R <= 32
    Threefry2x{T, Int(R)}(seed[1] % T, seed[2] % T, 0 % T, 0 % T, 0 % T, 0 % T)
end

function srand{T<:Union{UInt32, UInt64}}(r::Threefry2x{T}, seed::Tuple{Integer, Integer}=gen_seed(T, 2))
    r.key1, r.key2 = seed
    r.ctr1 = r.ctr2 = 0
    r.x1 = r.x2 = 0
    r
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::Threefry2x{T}, ::Type{T})
    threefry_r(r)
    r.ctr1 += 1 % T
    r.x1
end

@eval @inline function threefry_r{T<:Union{UInt32, UInt64}, R}(r::Threefry2x{T, R})
    ks2 = SKEIN_KS_PARITY(T)
    ks0 = r.key1
    x0 = r.ctr1
    ks2 $= ks0
    ks1 = r.key2
    x1 = r.ctr2
    ks2 $= ks1
    x0 += ks0
    x1 += ks1

    if R > 0 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 $= x0; end
    if R > 1 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 $= x0; end
    if R > 2 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 $= x0; end
    if R > 3 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 $= x0; end
    if R > 3
        x0 += ks1; x1 += ks2;
        x1 += 1 % T;
    end
    if R > 4 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 $= x0; end
    if R > 5 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 $= x0; end
    if R > 6 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 $= x0; end
    if R > 7 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 $= x0; end
    if R > 7
        x0 += ks2; x1 += ks0;
        x1 += 2 % T;
    end
    if R > 8 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 $= x0; end
    if R > 9 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 $= x0; end
    if R > 10 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 $= x0; end
    if R > 11 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 $= x0; end
    if R > 11
        x0 += ks0; x1 += ks1;
        x1 += 3 % T;
    end
    if R > 12 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 $= x0; end
    if R > 13 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 $= x0; end
    if R > 14 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 $= x0; end
    if R > 15 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 $= x0; end
    if R > 15
        x0 += ks1; x1 += ks2;
        x1 += 4 % T;
    end
    if R > 16 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 $= x0; end
    if R > 17 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 $= x0; end
    if R > 18 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 $= x0; end
    if R > 19 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 $= x0; end
    if R > 19
        x0 += ks2; x1 += ks0;
        x1 += 5 % T;
    end
    if R > 20 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 $= x0; end
    if R > 21 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 $= x0; end
    if R > 22 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 $= x0; end
    if R > 23 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 $= x0; end
    if R > 23
        x0 += ks0; x1 += ks1;
        x1 += 6 % T;
    end
    if R > 24 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 $= x0; end
    if R > 25 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 $= x0; end
    if R > 26 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 $= x0; end
    if R > 27 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 $= x0; end
    if R > 27
        x0 += ks1; x1 += ks2;
        x1 += 7 % T;
    end
    if R > 28 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 $= x0; end
    if R > 29 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 $= x0; end
    if R > 30 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 $= x0; end
    if R > 31 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 $= x0; end
    if R > 31
        x0 += ks2; x1 += ks0;
        x1 += 8 % T;
    end
    r.x1, r.x2 = x0, x1
    r
end

"""
    Threefry4x{T, R} <: Threefry{T}

Threefry4x is one kind of Threefry Counter-Based RNGs. It generates two numbers at a time.

`R` denotes to the Rounds. With 20 rounds (by default), it has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance.

Constructor: `Threefry4x([T=UInt64, (seed1, seed2, seed3, seed4), R=20])` where `T` is `UInt32` or `UInt64`
"""
type Threefry4x{T<:Union{UInt32, UInt64}, R} <: Threefry{T}
    key1::T
    key2::T
    key3::T
    key4::T
    ctr1::T
    ctr2::T
    ctr3::T
    ctr4::T
    x1::T
    x2::T
    x3::T
    x4::T
end

function Threefry4x{T<:Union{UInt32, UInt64}}(::Type{T}=UInt64,
        seed::Tuple{Integer, Integer, Integer, Integer}=gen_seed(T, 4), R::Integer=20)
    @assert 1 <= R <= 72
    Threefry4x{T, Int(R)}(
        seed[1] % T, seed[2] % T, seed[3] % T, seed[4] % T,
        0 % T, 0 % T, 0 % T, 0 % T, 0 % T, 0 % T, 0 % T, 0 % T
    )
end

function srand{T<:Union{UInt32, UInt64}}(r::Threefry4x{T},
        seed::Tuple{Integer, Integer, Integer, Integer}=gen_seed(T, 4))
    r.key1, r.key2, r.key3, r.key4 = seed
    r.ctr1 = r.ctr2 = r.ctr3 = r.ctr4 = 0
    r.x1 = r.x2 = r.x3 = r.x4 = 0
    r
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::Threefry4x{T}, ::Type{T})
    threefry_r(r)
    r.ctr1 += 1 % T
    r.x1
end

@inline function threefry_r{T<:Union{UInt32, UInt64}, R}(r::Threefry4x{T, R})
    ks4 = SKEIN_KS_PARITY(T)
    ks0 = r.key1
    x0 = r.ctr1
    ks4 $= ks0
    ks1 = r.key2
    x1 = r.ctr2
    ks4 $= ks1
    ks2 = r.key3
    x2 = r.ctr3
    ks4 $= ks2
    ks3 = r.key4
    x3 = r.ctr4
    ks4 $= ks3
    x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;

    if R > 0
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 1
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 2
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 3
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 3
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 1 % T;
    end
    if R > 4
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 5
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 6
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 7
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 7
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 2 % T;
    end
    if R > 8
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 9
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 10
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 11
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 11
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 3 % T;
    end
    if R > 12
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 13
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 14
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 15
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 15
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 4 % T;
    end
    if R > 16
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 17
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 18
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 19
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 19
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 5 % T;
    end
    if R > 20
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 21
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 22
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 23
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 23
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 6 % T;
    end
    if R > 24
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 25
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 26
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 27
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 27
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 7 % T;
    end
    if R > 28
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 29
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 30
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 31
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 31
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 8 % T;
    end
    if R > 32
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 33
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 34
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 35
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 35
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 9 % T;
    end
    if R > 36
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 37
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 38
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 39
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 39
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 10 % T;
    end
    if R > 40
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 41
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 42
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 43
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 43
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 11 % T;
    end
    if R > 44
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 45
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 46
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 47
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 47
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 12 % T;
    end
    if R > 48
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 49
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 50
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 51
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 51
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 13 % T;
    end
    if R > 52
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 53
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 54
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 55
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 55
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 14 % T;
    end
    if R > 56
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 57
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 58
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 59
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 59
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 15 % T;
    end
    if R > 60
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 61
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 62
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 63
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 63
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 16 % T;
    end
    if R > 64
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 $= x2;
    end
    if R > 65
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 $= x2;
    end
    if R > 66
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 $= x2;
    end
    if R > 67
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 $= x2;
    end
    if R > 67
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 17 % T;
    end
    if R > 68
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 $= x2;
    end
    if R > 69
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 $= x2;
    end
    if R > 70
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 $= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 $= x2;
    end
    if R > 71
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 $= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 $= x2;
    end
    if R > 71
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 18 % T;
    end
    r.x1, r.x2, r.x3, r.x4 = x0, x1, x2, x3
    r
end
