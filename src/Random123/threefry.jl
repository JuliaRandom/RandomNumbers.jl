import Base: copy, copyto!, ==
import Random: seed!
import RandomNumbers: gen_seed, seed_type, unsafe_copyto!, unsafe_compare

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

"""
```julia
Threefry2x{T, R} <: R123Generator2x{T}
Threefry2x([seed, R])
Threefry2x(T[, seed, R])
```

Threefry2x is one kind of Threefry Counter-Based RNGs. It generates two numbers at a time.

`T` is `UInt32` or `UInt64`(default).

`seed` is a `Tuple` of two `Integer`s which will both be automatically converted to `T`.

`R` denotes to the Rounds which must be at least 1 and no more than 32. With 20 rounds (by default), it has a
considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.
"""
mutable struct Threefry2x{T<:Union{UInt32, UInt64}, R} <: R123Generator2x{T}
    x1::T
    x2::T
    key1::T
    key2::T
    ctr1::T
    ctr2::T
    p::Int
end

function Threefry2x(::Type{T}=UInt64, seed::NTuple{2, Integer}=gen_seed(T, 2), R::Integer=20) where
        T <: Union{UInt32, UInt64}
    @assert 1 <= R <= 32
    r = Threefry2x{T, Int(R)}(0, 0, 0, 0, 0, 0, 0)
    seed!(r, seed)
end
Threefry2x(seed::NTuple{2, Integer}, R::Integer=20) = Threefry2x(UInt64, seed, R)

function seed!(r::Threefry2x{T}, seed::NTuple{2, Integer}=gen_seed(T, 2)) where T <: Union{UInt32, UInt64}
    r.x1 = r.x2 = 0
    r.key1 = seed[1] % T
    r.key2 = seed[2] % T
    r.ctr1 = r.ctr2 = 0
    random123_r(r)
    r
end

@inline seed_type(::Type{Threefry2x{T, R}}) where {T, R} = NTuple{2, T}

function copyto!(dest::Threefry2x{T, R}, src::Threefry2x{T, R}) where {T, R}
    unsafe_copyto!(dest, src, T, 6)
    dest.p = src.p
    dest
end

copy(src::Threefry2x{T, R}) where {T, R} = Threefry2x{T, R}(src.x1, src.x2, src.key1, src.key2,
                                                            src.ctr1, src.ctr2, src.p)

==(r1::Threefry2x{T, R}, r2::Threefry2x{T, R}) where {T, R} = unsafe_compare(r1, r2, T, 6) && r1.p == r2.p

@inline function random123_r(r::Threefry2x{T, R}) where {T <: Union{UInt32, UInt64}, R}
    ks2 = SKEIN_KS_PARITY(T)
    ks0 = r.key1
    x0 = r.ctr1
    ks2 ⊻= ks0
    ks1 = r.key2
    x1 = r.ctr2
    ks2 ⊻= ks1
    x0 += ks0
    x1 += ks1

    if R > 0 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 ⊻= x0; end
    if R > 1 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 ⊻= x0; end
    if R > 2 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 ⊻= x0; end
    if R > 3 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 ⊻= x0; end
    if R > 3
        x0 += ks1; x1 += ks2;
        x1 += 1 % T;
    end
    if R > 4 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 ⊻= x0; end
    if R > 5 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 ⊻= x0; end
    if R > 6 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 ⊻= x0; end
    if R > 7 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 ⊻= x0; end
    if R > 7
        x0 += ks2; x1 += ks0;
        x1 += 2 % T;
    end
    if R > 8 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 ⊻= x0; end
    if R > 9 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 ⊻= x0; end
    if R > 10 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 ⊻= x0; end
    if R > 11 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 ⊻= x0; end
    if R > 11
        x0 += ks0; x1 += ks1;
        x1 += 3 % T;
    end
    if R > 12 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 ⊻= x0; end
    if R > 13 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 ⊻= x0; end
    if R > 14 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 ⊻= x0; end
    if R > 15 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 ⊻= x0; end
    if R > 15
        x0 += ks1; x1 += ks2;
        x1 += 4 % T;
    end
    if R > 16 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 ⊻= x0; end
    if R > 17 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 ⊻= x0; end
    if R > 18 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 ⊻= x0; end
    if R > 19 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 ⊻= x0; end
    if R > 19
        x0 += ks2; x1 += ks0;
        x1 += 5 % T;
    end
    if R > 20 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 ⊻= x0; end
    if R > 21 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 ⊻= x0; end
    if R > 22 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 ⊻= x0; end
    if R > 23 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 ⊻= x0; end
    if R > 23
        x0 += ks0; x1 += ks1;
        x1 += 6 % T;
    end
    if R > 24 x0 += x1; x1 = threefry_rotl(x1, Rx2_0_0(T)); x1 ⊻= x0; end
    if R > 25 x0 += x1; x1 = threefry_rotl(x1, Rx2_1_0(T)); x1 ⊻= x0; end
    if R > 26 x0 += x1; x1 = threefry_rotl(x1, Rx2_2_0(T)); x1 ⊻= x0; end
    if R > 27 x0 += x1; x1 = threefry_rotl(x1, Rx2_3_0(T)); x1 ⊻= x0; end
    if R > 27
        x0 += ks1; x1 += ks2;
        x1 += 7 % T;
    end
    if R > 28 x0 += x1; x1 = threefry_rotl(x1, Rx2_4_0(T)); x1 ⊻= x0; end
    if R > 29 x0 += x1; x1 = threefry_rotl(x1, Rx2_5_0(T)); x1 ⊻= x0; end
    if R > 30 x0 += x1; x1 = threefry_rotl(x1, Rx2_6_0(T)); x1 ⊻= x0; end
    if R > 31 x0 += x1; x1 = threefry_rotl(x1, Rx2_7_0(T)); x1 ⊻= x0; end
    if R > 31
        x0 += ks2; x1 += ks0;
        x1 += 8 % T;
    end
    r.x1, r.x2 = x0, x1
end

"""
```julia
Threefry4x{T, R} <: R123Generator4x{T}
Threefry4x([seed, R])
Threefry4x(T[, seed, R])
```

Threefry2x is one kind of Threefry Counter-Based RNGs. It generates four numbers at a time.

`T` is `UInt32` or `UInt64`(default).

`seed` is a `Tuple` of four `Integer`s which will all be automatically converted to `T`.

`R` denotes to the Rounds which must be at least 1 and no more than 32. With 20 rounds (by default), it has a
considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.
"""
mutable struct Threefry4x{T<:Union{UInt32, UInt64}, R} <: R123Generator4x{T}
    x1::T
    x2::T
    x3::T
    x4::T
    key1::T
    key2::T
    key3::T
    key4::T
    ctr1::T
    ctr2::T
    ctr3::T
    ctr4::T
    p::Int
end

function Threefry4x(::Type{T}=UInt64, seed::NTuple{4, Integer}=gen_seed(T, 4), R::Integer=20) where
        T <: Union{UInt32, UInt64}
    @assert 1 <= R <= 72
    r = Threefry4x{T, Int(R)}(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    seed!(r, seed)
end
Threefry4x(seed::NTuple{4, Integer}, R::Integer=20) = Threefry4x(UInt64, seed, R)

function seed!(r::Threefry4x{T}, seed::NTuple{4, Integer}=gen_seed(T, 4)) where T <: Union{UInt32, UInt64}
    r.x1 = r.x2 = r.x3 = r.x4 = 0
    r.key1, r.key2, r.key3, r.key4 = seed[1] % T, seed[2] % T, seed[3] % T, seed[4] % T
    r.ctr1 = r.ctr2 = r.ctr3 = r.ctr4 = 0
    random123_r(r)
    r
end

@inline seed_type(::Type{Threefry4x{T, R}}) where {T, R} = NTuple{4, T}

function copyto!(dest::Threefry4x{T, R}, src::Threefry4x{T, R}) where {T, R}
    unsafe_copyto!(dest, src, T, 12)
    dest.p = src.p
    dest
end

copy(src::Threefry4x{T, R}) where {T, R} = Threefry4x{T, R}(src.x1, src.x2, src.x3, src.x4,
                                                     src.key1, src.key2, src.key3, src.key4,
                                                     src.ctr1, src.ctr2, src.ctr3, src.ctr4, src.p)

==(r1::Threefry4x{T, R}, r2::Threefry4x{T, R}) where {T, R} = unsafe_compare(r1, r2, T, 12) && r1.p == r2.p

@inline function random123_r(r::Threefry4x{T, R}) where {T <: Union{UInt32, UInt64}, R}
    ks4 = SKEIN_KS_PARITY(T)
    ks0 = r.key1
    x0 = r.ctr1
    ks4 ⊻= ks0
    ks1 = r.key2
    x1 = r.ctr2
    ks4 ⊻= ks1
    ks2 = r.key3
    x2 = r.ctr3
    ks4 ⊻= ks2
    ks3 = r.key4
    x3 = r.ctr4
    ks4 ⊻= ks3
    x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;

    if R > 0
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 1
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 2
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 3
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 3
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 1 % T;
    end
    if R > 4
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 5
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 6
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 7
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 7
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 2 % T;
    end
    if R > 8
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 9
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 10
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 11
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 11
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 3 % T;
    end
    if R > 12
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 13
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 14
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 15
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 15
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 4 % T;
    end
    if R > 16
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 17
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 18
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 19
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 19
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 5 % T;
    end
    if R > 20
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 21
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 22
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 23
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 23
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 6 % T;
    end
    if R > 24
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 25
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 26
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 27
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 27
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 7 % T;
    end
    if R > 28
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 29
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 30
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 31
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 31
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 8 % T;
    end
    if R > 32
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 33
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 34
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 35
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 35
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 9 % T;
    end
    if R > 36
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 37
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 38
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 39
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 39
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 10 % T;
    end
    if R > 40
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 41
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 42
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 43
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 43
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 11 % T;
    end
    if R > 44
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 45
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 46
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 47
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 47
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 12 % T;
    end
    if R > 48
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 49
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 50
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 51
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 51
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 13 % T;
    end
    if R > 52
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 53
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 54
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 55
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 55
        x0 += ks4; x1 += ks0; x2 += ks1; x3 += ks2;
        x3 += 14 % T;
    end
    if R > 56
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 57
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 58
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 59
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 59
        x0 += ks0; x1 += ks1; x2 += ks2; x3 += ks3;
        x3 += 15 % T;
    end
    if R > 60
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 61
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 62
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 63
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 63
        x0 += ks1; x1 += ks2; x2 += ks3; x3 += ks4;
        x3 += 16 % T;
    end
    if R > 64
        x0 += x1; x1 = threefry_rotl(x1, Rx4_0_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_0_1(T)); x3 ⊻= x2;
    end
    if R > 65
        x0 += x3; x3 = threefry_rotl(x3, Rx4_1_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_1_1(T)); x1 ⊻= x2;
    end
    if R > 66
        x0 += x1; x1 = threefry_rotl(x1, Rx4_2_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_2_1(T)); x3 ⊻= x2;
    end
    if R > 67
        x0 += x3; x3 = threefry_rotl(x3, Rx4_3_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_3_1(T)); x1 ⊻= x2;
    end
    if R > 67
        x0 += ks2; x1 += ks3; x2 += ks4; x3 += ks0;
        x3 += 17 % T;
    end
    if R > 68
        x0 += x1; x1 = threefry_rotl(x1, Rx4_4_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_4_1(T)); x3 ⊻= x2;
    end
    if R > 69
        x0 += x3; x3 = threefry_rotl(x3, Rx4_5_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_5_1(T)); x1 ⊻= x2;
    end
    if R > 70
        x0 += x1; x1 = threefry_rotl(x1, Rx4_6_0(T)); x1 ⊻= x0;
        x2 += x3; x3 = threefry_rotl(x3, Rx4_6_1(T)); x3 ⊻= x2;
    end
    if R > 71
        x0 += x3; x3 = threefry_rotl(x3, Rx4_7_0(T)); x3 ⊻= x0;
        x2 += x1; x1 = threefry_rotl(x1, Rx4_7_1(T)); x1 ⊻= x2;
    end
    if R > 71
        x0 += ks3; x1 += ks4; x2 += ks0; x3 += ks1;
        x3 += 18 % T;
    end
    r.x1, r.x2, r.x3, r.x4 = x0, x1, x2, x3
end
