import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

abstract Threefry{T<:Unsigned} <: AbstractRNG{T}

@inline threefry_rotl(x::UInt64, N) = (x << (N & 63)) | (x >> ((64-N) & 63))
@inline threefry_rotl(x::UInt32, N) = (x << (N & 31)) | (x >> ((32-N) & 31))

const SKEIN_KS_PARITY64 = 0x1BD11BDAA9FC1A22
const SKEIN_KS_PARITY32 = 0x1BD11BDA

const R_64x2_0_0 = 16
const R_64x2_1_0 = 42
const R_64x2_2_0 = 12
const R_64x2_3_0 = 31
const R_64x2_4_0 = 16
const R_64x2_5_0 = 32
const R_64x2_6_0 = 24
const R_64x2_7_0 = 21

const R_32x2_0_0 = 13
const R_32x2_1_0 = 15
const R_32x2_2_0 = 26
const R_32x2_3_0 =  6
const R_32x2_4_0 = 17
const R_32x2_5_0 = 29
const R_32x2_6_0 = 16
const R_32x2_7_0 = 24

"""
    Threefry2x{T, R} <: Threefry{T}

Threefry2x is one kind of Threefry RNGs. It generates two numbers at a time.

`R` denotes to the Rounds. With 20 rounds (by default), it has a considerable safety margin over
the minimum number of rounds with no known statistical flaws, but still has excellent performance.

Constructor: `Threefry2x([T=UInt64, (seed1, seed2), R=20])` where `T` is `UInt32` or `UInt64`
"""
type Threefry2x{T<:Union{UInt32, UInt64}, R} <: Threefry{T}
    k1::T
    k2::T
    in1::T
    in2::T
    x1::T
    x2::T
end
function Threefry2x{T<:Union{UInt32, UInt64}}(::Type{T}=UInt64, seed::Tuple{Integer, Integer}=gen_seed(T, 2), R::Integer=20)
    @assert 1 <= R <= 32
    r = Threefry2x{T, Int(R)}(seed[1] % T, seed[2] % T, 0 % T, 0 % T, 0 % T, 0 % T)
    r
end

function srand{T<:Union{UInt32, UInt64}}(r::Threefry2x{T}, seed::Tuple{Integer, Integer}=gen_seed(T, 2))
    r.k1 = seed[1]
    r.k2 = seed[2]
    r.in1 = 0
    r.in2 = 0
    r
end

@inline function rand{T<:Union{UInt32, UInt64}}(r::Threefry2x{T}, ::Type{T}=T)
    threefry_r(r)
    r.x1
end

for (T, Td) in ((UInt32, UInt64), (UInt64, UInt128))
    @eval @inline function rand(r::Threefry2x{$T}, ::Type{$Td})
        threefry_r(r)
        ((r.x1 % Td) << $(sizeof(T) << 3)) | r.x2
    end
end

for (w, T) in ((:32, UInt32), (:64, UInt64))
    @eval @inline function threefry_r{R}(r::Threefry2x{$T, R})
        ks2 = $(Symbol("SKEIN_KS_PARITY$w"))
        ks0 = r.k1
        x0 = r.in1
        ks2 $= ks0
        ks1 = r.k2
        x1 = r.in2
        ks2 $= ks1
        x0 += ks0
        x1 += ks1

        if R > 0 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_0_0")))); x1 $= x0; end
        if R > 1 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_1_0")))); x1 $= x0; end
        if R > 2 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_2_0")))); x1 $= x0; end
        if R > 3 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_3_0")))); x1 $= x0; end
        if R > 3
            x0 += ks1;
            x1 += ks2;
            x1 += 1;
        end
        if R > 4 x0 += x1; x1 = threefry_rotl(x1,$(Symbol(string("R_", w, "x2_4_0")))); x1 $= x0; end
        if R > 5 x0 += x1; x1 = threefry_rotl(x1,$(Symbol(string("R_", w, "x2_5_0")))); x1 $= x0; end
        if R > 6 x0 += x1; x1 = threefry_rotl(x1,$(Symbol(string("R_", w, "x2_6_0")))); x1 $= x0; end
        if R > 7 x0 += x1; x1 = threefry_rotl(x1,$(Symbol(string("R_", w, "x2_7_0")))); x1 $= x0; end
        if R > 7
            x0 += ks2; x1 += ks0;
            x1 += 2;
        end
        if R > 8 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_0_0")))); x1 $= x0; end
        if R > 9 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_1_0")))); x1 $= x0; end
        if R > 10 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_2_0")))); x1 $= x0; end
        if R > 11 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_3_0")))); x1 $= x0; end
        if R > 11
            x0 += ks0; x1 += ks1;
            x1 += 3;
        end
        if R > 12 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_4_0")))); x1 $= x0; end
        if R > 13 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_5_0")))); x1 $= x0; end
        if R > 14 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_6_0")))); x1 $= x0; end
        if R > 15 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_7_0")))); x1 $= x0; end
        if R > 15
            x0 += ks1; x1 += ks2;
            x1 += 4;
        end
        if R > 16 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_0_0")))); x1 $= x0; end
        if R > 17 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_1_0")))); x1 $= x0; end
        if R > 18 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_2_0")))); x1 $= x0; end
        if R > 19 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_3_0")))); x1 $= x0; end
        if R > 19
            x0 += ks2; x1 += ks0;
            x1 += 5;
        end
        if R > 20 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_4_0")))); x1 $= x0; end
        if R > 21 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_5_0")))); x1 $= x0; end
        if R > 22 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_6_0")))); x1 $= x0; end
        if R > 23 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_7_0")))); x1 $= x0; end
        if R > 23
            x0 += ks0; x1 += ks1;
            x1 += 6;
        end
        if R > 24 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_0_0")))); x1 $= x0; end
        if R > 25 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_1_0")))); x1 $= x0; end
        if R > 26 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_2_0")))); x1 $= x0; end
        if R > 27 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_3_0")))); x1 $= x0; end
        if R > 27
            x0 += ks1; x1 += ks2;
            x1 += 7;
        end
        if R > 28 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_4_0")))); x1 $= x0; end
        if R > 29 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_5_0")))); x1 $= x0; end
        if R > 30 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_6_0")))); x1 $= x0; end
        if R > 31 x0 += x1; x1 = threefry_rotl(x1, $(Symbol(string("R_", w, "x2_7_0")))); x1 $= x0; end
        if R > 31
            x0 += ks2; x1 += ks0;
            x1 += 8;
        end
        r.x1 = x0
        r.x2 = x1
        r.in1 += 1
        r
    end
end

#"""
#    Threefry4x{T, R} <: Threefry{T}
#
#Threefry4x is one kind of Threefry RNGs. It generates two numbers at a time.
#
#`R` denotes to the Rounds. With 20 rounds (by default), it has a considerable safety margin over
#the minimum number of rounds with no known statistical flaws, but still has excellent performance.
#
#Constructor: `Threefry4x([T=UInt64, (seed1, seed2, seed3, seed4), R=20])` where `T` is `UInt32` or `UInt64`
#"""
#type Threefry4x{T<:Union{UInt32, UInt64}, R} <: Threefry{T}
#    k1::T
#    k2::T
#    k3::T
#    k4::T
#    in1::T
#    in2::T
#    in3::T
#    in4::T
#    x1::T
#    x2::T
#    x3::T
#    x4::T
#end
