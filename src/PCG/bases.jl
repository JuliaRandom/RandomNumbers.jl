# This file contains the basic functions of PCG.
import RandomNumbers: AbstractRNG

"Return the default multiplier for a certain type."
@inline default_multiplier(::Type{UInt8}) = 0x8d
@inline default_multiplier(::Type{UInt16}) = 0x321d
@inline default_multiplier(::Type{UInt32}) = 0x2c9277b5
@inline default_multiplier(::Type{UInt64}) = 0x5851f42d4c957f2d
@inline default_multiplier(::Type{UInt128}) = 0x2360ed051fc65da44385df649fccf645

"Return the default increment for a certain type."
@inline default_increment(::Type{UInt8}) = 0x4d
@inline default_increment(::Type{UInt16}) = 0xbb75
@inline default_increment(::Type{UInt32}) = 0xac564b05
@inline default_increment(::Type{UInt64}) = 0x14057b7ef767814f
@inline default_increment(::Type{UInt128}) = 0x5851f42d4c957f2d14057b7ef767814f

"Return the default MCG multiplier for a certain type."
@inline mcg_multiplier(::Type{UInt8}) = 0xd9
@inline mcg_multiplier(::Type{UInt16}) = 0xf2d9
@inline mcg_multiplier(::Type{UInt32}) = 0x108ef2d9
@inline mcg_multiplier(::Type{UInt64}) = 0xaef17502108ef2d9
@inline mcg_multiplier(::Type{UInt128}) = 0xf69019274d7f699caef17502108ef2d9

"Return the default MCG unmultiplier for a certain type."
@inline mcg_unmultiplier(::Type{UInt8}) = 0x69
@inline mcg_unmultiplier(::Type{UInt16}) = 0x6d69
@inline mcg_unmultiplier(::Type{UInt32}) = 0xacb86d69
@inline mcg_unmultiplier(::Type{UInt64}) = 0xd04ca582acb86d69
@inline mcg_unmultiplier(::Type{UInt128}) = 0xc827645e182bc965d04ca582acb86d69

@inline uint_index(::Type{UInt8}) = 1
@inline uint_index(::Type{UInt16}) = 2
@inline uint_index(::Type{UInt32}) = 3
@inline uint_index(::Type{UInt64}) = 4
@inline uint_index(::Type{UInt128}) = 5

@inline half_width(::Type{UInt16}) = UInt8
@inline half_width(::Type{UInt32}) = UInt16
@inline half_width(::Type{UInt64}) = UInt32
@inline half_width(::Type{UInt128}) = UInt64


# Shift and Rotate functions

# Rotate functions.
@inline function pcg_rotr(value::T, rot::T) where T <: PCGUInt
    s = sizeof(T) << 3
    (value >> (rot % s)) | (value << (-rot % s))
end


"General advance functions."
@inline function pcg_advance_lcg(state::T, delta::T, cur_mult::T, cur_plus::T) where T <: PCGUInt
    acc_mult = 1 % T
    acc_plus = 0 % T
    while delta > 0
        if delta & 1 == 1
            acc_mult *= cur_mult
            acc_plus = acc_plus * cur_mult + cur_plus
        end
        cur_plus = (cur_mult + (1 % T)) * cur_plus
        cur_mult *= cur_mult
        delta = delta >> 1
    end
    acc_mult * state + acc_plus
end


# output_xsh_rs
# Xorshift High, Random Shift.
# return half bits of T.
@inline function pcg_output(state::T, ::Type{PCG_XSH_RS}) where T <: Union{pcg_uints[2:end]...}
    return_bits = sizeof(T) << 2
    bits = return_bits << 1
    spare_bits = bits - return_bits
    op_bits = spare_bits - 5 >= 64 ? 5 :
              spare_bits - 4 >= 32 ? 4 :
              spare_bits - 3 >= 16 ? 3 :
              spare_bits - 2 >= 4  ? 2 :
              spare_bits - 1 >= 1  ? 1 : 0
    mask = (1 << op_bits) - 1
    xshift = op_bits + (return_bits + mask) >> 1
    rshift = op_bits != 0 ? (state >> (bits - op_bits)) & mask : 0 % T
    state = state ⊻ (state >> xshift)
    (state >> (spare_bits - op_bits - mask + rshift)) % half_width(T)
end

# output_xsh_rr
# Xorshift High, Random Rotation.
# return half bits of T.
@inline function pcg_output(state::T, ::Type{PCG_XSH_RR}) where T <: Union{pcg_uints[2:end]...}
    return_bits = sizeof(T) << 2
    bits = return_bits << 1
    spare_bits = bits - return_bits
    op_bits = return_bits >= 128 ? 7 :
              return_bits >=  64 ? 6 :
              return_bits >=  32 ? 5 :
              return_bits >=  16 ? 4 : 3
    mask = (1 << op_bits) - 1
    xshift = (op_bits + return_bits) >> 1
    rot = (state >> (bits - op_bits)) & mask
    state ⊻= (state >> xshift)
    result = (state >> (spare_bits - op_bits)) % half_width(T)
    pcg_rotr(result, rot % half_width(T))
end

# output_rxs_m_xs
# Random Xorshift, Multiplication, Xorshift.
# return the same bits as T.
# Insecure.
@inline function pcg_output(state::T, ::Type{PCG_RXS_M_XS}) where T <: PCGUInt
    bits = return_bits = sizeof(T) << 3
    op_bits = return_bits >= 128 ? 6 :
              return_bits >=  64 ? 5 :
              return_bits >=  32 ? 4 :
              return_bits >=  16 ? 3 : 2
    mask = (1 << op_bits) - 1
    rshift = (state >> (bits - op_bits)) & mask
    state ⊻= state >> (op_bits + rshift)
    state *= mcg_multiplier(T)
    state ⊻ (state >> ((return_bits << 1 + 2) ÷ 3))
end

# output_xsl_rr
# Xorshift Low, Random Rotation.
# return half bits of T.
@inline function pcg_output(state::T, ::Type{PCG_XSL_RR}) where T <: Union{UInt64, UInt128}
    return_bits = sizeof(T) << 2
    bits = return_bits << 1
    spare_bits = bits - return_bits
    op_bits = return_bits >= 128 ? 7 :
              return_bits >=  64 ? 6 :
              return_bits >=  32 ? 5 :
              return_bits >=  16 ? 4 : 3
    mask = (1 << op_bits) - 1
    xshift = (spare_bits + return_bits) >> 1
    rot = (state >> (bits - op_bits)) & mask
    pcg_rotr((state ⊻ (state >> xshift)) % half_width(T), rot % half_width(T))
end

# output_xsl_rr_rr
# Xorshift Low, Random Rotation, Random Rotation.
# return the same bits as T.
# Insecure.
@inline function pcg_output(state::T, ::Type{PCG_XSL_RR_RR}) where T <: Union{UInt64, UInt128}
    half_bits = sizeof(T) << 2
    bits = half_bits << 1
    spare_bits = bits - half_bits
    op_bits = half_bits >= 128 ? 7 :
              half_bits >=  64 ? 6 :
              half_bits >=  32 ? 5 :
              half_bits >=  16 ? 4 : 3
    mask = (1 << op_bits) - 1
    xshift = (spare_bits + half_bits) >> 1
    rot = (state >> (bits - op_bits)) & mask
    state ⊻= state >> xshift
    low_bits = state % half_width(T)
    low_bits = pcg_rotr(low_bits, rot % half_width(T))
    high_bits = (state >> spare_bits) % half_width(T)
    rot2 = low_bits & mask
    high_bits = pcg_rotr(high_bits, rot2 % half_width(T))
    ((high_bits % T) << spare_bits) ⊻ (low_bits % T)
end

# PCGState types, SRandom and Step functions.
"""
```julia
AbstractPCG{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <: AbstractRNG{OutputType}
```

The base abstract type for PCGs.
"""
abstract type AbstractPCG{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt
                         } <: AbstractRNG{OutputType} end

# pcg_state_XX
# XX is one of the UInt types.
mutable struct PCGStateOneseq{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
        AbstractPCG{StateType, MethodType, OutputType}
    state::StateType
    PCGStateOneseq{StateType, MethodType, OutputType}() where 
        {StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} = new()
end

@inline function pcg_seed!(s::PCGStateOneseq{T}, init_state::T) where T <: PCGUInt
    s.state = 0 % T
    pcg_step!(s)
    s.state += init_state
    pcg_step!(s)
    s
end

# pcg_oneseq_XX_step_r
# XX is one of the UInt types.
@inline function pcg_step!(s::PCGStateOneseq{T}) where T <: PCGUInt
    s.state = s.state * default_multiplier(T) + default_increment(T)
end

# pcg_oneseq_XX_advance_r
# XX is one of the UInt types.
@inline function pcg_advance!(s::PCGStateOneseq{T}, delta::T) where T <: PCGUInt
    s.state = pcg_advance_lcg(s.state, delta, default_multiplier(T), default_increment(T))
end

# pcg_state_XX
# XX is one of the UInt types.
mutable struct PCGStateMCG{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
        AbstractPCG{StateType, MethodType, OutputType}
    state::StateType
    PCGStateMCG{StateType, MethodType, OutputType}() where
        {StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} = new()
end

@inline function pcg_seed!(s::PCGStateMCG{T}, init_state::T) where T <: PCGUInt
    s.state = init_state | 1
    s
end

# pcg_mcg_XX_step_r
# XX is one of the UInt types.
@inline function pcg_step!(s::PCGStateMCG{T}) where T <: PCGUInt
    s.state = s.state * default_multiplier(T)
end

# pcg_mcg_XX_advance_r
# XX is one of the UInt types.
@inline function pcg_advance!(s::PCGStateMCG{T}, delta::T) where T <: PCGUInt
    s.state = pcg_advance_lcg(s.state, delta, default_multiplier(T), 0 % T)
end

# pcg_state_XX
# XX is one of the UInt types.
mutable struct PCGStateUnique{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
        AbstractPCG{StateType, MethodType, OutputType}
    state::StateType
    PCGStateUnique{StateType, MethodType, OutputType}() where
        {StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} = new()
end

@inline function pcg_seed!(s::PCGStateUnique{T}, init_state::T) where T <: PCGUInt
    s.state = 0 % T
    pcg_step!(s)
    s.state += init_state
    pcg_step!(s)
    s
end

# pcg_unique_XX_step_r
# XX is one of the UInt types.
@inline function pcg_step!(s::PCGStateUnique{T}) where T <: PCGUInt
    s.state = s.state * default_multiplier(T) + (UInt(pointer_from_objref(s)) | 1) % T
end

# pcg_unique_XX_advance_r
# XX is one of the UInt types.
@inline function pcg_advance!(s::PCGStateUnique{T}, delta::T) where T <: PCGUInt
    s.state = pcg_advance_lcg(s.state, delta, default_multiplier(T),
        (UInt(pointer_from_objref(s)) | 1) % T)
end

# pcg_state_XX
# XX is one of the UInt types.
mutable struct PCGStateSetseq{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
        AbstractPCG{StateType, MethodType, OutputType}
    state::StateType
    inc::StateType
    PCGStateSetseq{StateType, MethodType, OutputType}() where
        {StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} = new()
end

@inline function pcg_seed!(s::PCGStateSetseq{T}, init_state::T, init_seq::T) where T <: PCGUInt
    s.state = 0
    s.inc = (init_seq << 1) | 1
    pcg_step!(s)
    s.state += init_state
    pcg_step!(s)
    s
end

# pcg_setseq_XX_step_r
# XX is one of the UInt types.
@inline function pcg_step!(s::PCGStateSetseq{T}) where T <: PCGUInt
    s.state = s.state * default_multiplier(T) + s.inc
end

# pcg_setseq_XX_advance_r
# XX is one of the UInt types.
@inline function pcg_advance!(s::PCGStateSetseq{T}, delta::T) where T <: PCGUInt
    s.state = pcg_advance_lcg(s.state, delta, default_multiplier(T), s.inc)
end

"Return the output of a state for a certain PCG type."
pcg_output

"Initialize a PCG object."
pcg_seed!

"Do one iteration step for a PCG object."
pcg_step!

"Advance a PCG object."
pcg_advance!
