

const default_multipliers = (0x8d, 0x321d, 0x2c9277b5, 0x5851f42d4c957f2d, 0x2360ed051fc65da44385df649fccf645)


# Shift and Rotate functions

# Rotate functions. TODO: this can be rewrite in assembly
for uint_type in pcg_uints
    @eval @inline function pcg_rotr(value::$uint_type, rot::$uint_type)
        (value >> rot) | (value << ((-rot) & $(sizeof(uint_type) * 8 - 1)))
    end
end

# pcg_output_xsh_rs_XX_YY
# XX is one of the UInt types except UInt8, and YY is half of XX.
# Xorshift High, Random Shift.
for (uint_type, return_type, p1, p2, p3) in zip(pcg_uints[2:end], pcg_uints[1:end-1],
    (7, 11, 22, 43), (14, 30, 61, 124), (3, 11, 22, 45))
    @eval @inline function pcg_output(state::$uint_type, ::Type{PCG_XSH_RS})
        $return_type(((state >> $(uint_type(p1))) $ state) >>
        ((state >> $(uint_type(p2))) + $(uint_type(p3))))
    end
end

# pcg_output_xsh_rr_XX_YY
# XX is one of the UInt types except UInt8, and YY is half of XX.
# Xorshift High, Random Rotation.
for (uint_type, return_type, p1, p2, p3) in zip(pcg_uints[2:end], pcg_uints[1:end-1],
    (5, 10, 18, 29), (5, 12, 27, 58), (13, 28, 59, 122))
    @eval @inline function pcg_output(state::$uint_type, ::Type{PCG_XSH_RR})
        pcg_rotr(
            $return_type(((state >> $(uint_type(p1))) $ state) >> $(uint_type(p2))),
            $return_type(state >> $(uint_type(p3)))
        )
    end
end

# pcg_output_rxs_m_xs_XX_XX
# XX is one of the UInt types.
# Random Xorshift, Multiplication, Xorshift.
# Insecure.
for (uint_type, p1, p2, p3, p4) in zip(pcg_uints,
    (6, 13, 28, 59, 122), (2, 3, 4, 5, 6),
    (217, 62169, 277803737, 12605985483714917081, 327738287884841127335028083622016905945),
    (6, 11, 22, 43, 86))
    @eval @inline function pcg_output(state::$uint_type, ::Type{PCG_RXS_M_XS})
        word = ((state >> ((state >> $(uint_type(p1))) + $(uint_type(p2)))) $ state) * $(uint_type(p3))
        (word >> $(uint_type(p4))) ^ word
    end
end

# pcg_output_xsl_rr_XX_YY
# XX is 64 or 128, and YY is half of XX.
# Xorshift Low, Random Rotation.
for (uint_type, return_type, p1) in ((UInt64, UInt32, 59), (UInt128, UInt64, 122))
    @eval @inline function pcg_output(state::$uint_type, ::Type{PCG_XSL_RR})
        pcg_rotr(
            ((state >> $(sizeof(return_type) * 8)) $ state) % $return_type, # StateUIntTypehe high bits will become 0.
            $return_type(state >> $p1)
        )
    end
end

# pcg_output_xsl_rr_rr_XX_XX
# XX is 64 or 128.
# Xorshift Low, Random Rotation, Random Rotation.
# Insecure.
for (uint_type, half_type, p1) in ((UInt64, UInt32, 59), (UInt128, UInt64, 122))
    @eval @inline function pcg_output(state::$uint_type, ::Type{PCG_XSL_RR_RR})
        rot1 = $half_type(state >> $p1)
        high = $half_type(state >> $(sizeof(uint_type) * 4))
        low = state % $half_type
        xored = high $ low
        new_low = pcg_rotr(xored, rot1)
        new_high = pcg_rotr(high, newlow $ $(sizeof(uint_type) * 4 - 1))
        ($uint_type(new_high) << $(sizeof(uint_type) * 4)) | new_low
    end
end


# PCGState types, SRandom and Step functions.

abstract PCGState{StateUIntType<:PCGUInt, MethodType<:PCGMethod}

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateOneseq{StateUIntType<:PCGUInt, MethodType<:PCGMethod} <: PCGState{StateUIntType, MethodType}
    state::StateUIntType
    function PCGStateOneseq(init_state::StateUIntType)
        s = new(0)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end

# pcg_oneseq_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier, default_increment) in zip(pcg_uints, default_multipliers,
    (0x4d, 0xbb75, 0xac564b05, 0x14057b7ef767814f, 0x5851f42d4c957f2d14057b7ef767814f))
    @eval @inline function pcg_step(s::PCGStateOneseq{$uint_type})
        s.state = s.state * $default_multiplier + $default_increment
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateMCG{StateUIntType<:PCGUInt, MethodType<:PCGMethod} <: PCGState{StateUIntType, MethodType}
    state::StateUIntType
    PCGStateMCG(init_state::StateUIntType) = new(init_state | 1)
end

# pcg_mcg_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(pcg_uints, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateMCG{$uint_type})
        s.state = s.state * $default_multiplier
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateUnique{StateUIntType<:PCGUInt, MethodType<:PCGMethod} <: PCGState{StateUIntType, MethodType}
    state::StateUIntType
    function PCGStateUnique(init_state::StateUIntType)
        s = new(0)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end

# pcg_unique_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(pcg_uints, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateUnique{$uint_type})
        s.state = s.state * $default_multiplier + $uint_type(UInt(rng_ptr) | 1)
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateSetseq{StateUIntType<:PCGUInt, MethodType<:PCGMethod} <: PCGState{StateUIntType, MethodType}
    state::StateUIntType
    inc::StateUIntType
    function PCGStateSetseq(init_state::StateUIntType, init_seq::StateUIntType)
        s = new(0, (init_seq << 1) | 1)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end

# pcg_setseq_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(pcg_uints, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateSetseq{$uint_type})
        s.state = s.state * $default_multiplier + s.inc
    end
end

const pcg_state_types = (PCGStateOneseq, PCGStateMCG, PCGStateUnique, PCGStateSetseq)

# Random and Bounded Random functions

# pcg_ZZZ_XX_METHOD_YY_random_r, pcg_ZZZ_XX_METHOD_YY_boundedrand_r
# XX and YY is the data type.
# ZZZ is the state type. METHOD is the method.
let pcg_list = include("pcg_list.jl")
    for (state_type_t, uint_type, method_symbol, return_type) in pcg_list
        state_type = Symbol("PCGState$state_type_t")
        method = Val{method_symbol}
        @eval @inline function pcg_random(s::$state_type{$uint_type, $method})
            old_state = s.state
            pcg_step(s)
            pcg_output(old_state, $method);
        end

        @eval @inline function pcg_boundedrand(s::$state_type{$uint_type, $method}, bound::$return_type)
            threshold = (-bound) % bound
            r = pcg_random(s)
            while r < threshold
                r = pcg_random(s)
            end
            r % bound
        end
    end
end
