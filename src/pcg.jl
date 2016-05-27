abstract PCG <: AbstractRNG

const uint_types = (UInt8, UInt16, UInt32, UInt64, UInt128)
typealias UIntTypes Union{uint_types...}

const default_multipliers = (0x8d, 0x321d, 0x2c9277b5, 0x5851f42d4c957f2d, 0x2360ed051fc65da44385df649fccf645)


# Shift and Rotate functions

# Rotate functions. TODO: this can be rewrite in assembly
for uint_type in uint_types
    @eval @inline function pcg_rotr(value::$uint_type, rot::$uint_type)
        (tmp >> rot) | (tmp << ((-rot) & $(sizeof(uint_type) * 8 - 1)))
    end
end

# pcg_output_xsh_rs_XX_YY
# XX is one of the UInt types except UInt8, and YY is half of XX.
# Xorshift High, Random Shift.
for (uint_type, return_type, p1, p2, p3) in zip(uint_types[2:end], uint_types[1:end-1],
    (7, 11, 22, 43), (14, 30, 61, 124), (3, 11, 22, 45))
    @eval @inline function pcg_xsh_rs_output(state::$uint_type)
        $return_type(((state >> $(uint_type(p1))) $ state) >> 
            ((state >> $(uint_type(p2))) + $(uint_type(p3))))
    end
end

# pcg_output_xsh_rr_XX_YY
# XX is one of the UInt types except UInt8, and YY is half of XX.
# Xorshift High, Random Rotation.
for (uint_type, return_type, p1, p2, p3) in zip(uint_types[2:end], uint_types[1:end-1],
    (5, 10, 18, 29), (5, 12, 27, 58), (13, 28, 59, 122))
    @eval @inline function pcg_xsh_rr_output(state::$uint_type)
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
for (uint_type, p1, p2, p3, p4) in zip(uint_types,
    (6, 13, 28, 59, 122), (2, 3, 4, 5, 6),
    (217, 62169, 277803737, 12605985483714917081, 327738287884841127335028083622016905945),
    (6, 11, 22, 43, 86))
    @eval @inline function pcg_rxs_m_xs_output(state::$uint_type)
        word = ((state >> ((state >> $(uint_type(p1))) + $(uint_type(p2)))) $ state) * $(uint_type(p3))
        (word >> $(uint_type(p4))) ^ word
    end
end

# pcg_output_xsl_rr_XX_YY
# XX is 64 or 128, and YY is half of XX.
# Xorshift Low, Random Rotation.
for (uint_type, return_type, p1) in ((UInt64, UInt32, 59), (UInt128, UInt64, 122))
    @eval @inline function pcg_xsl_rr(state::$uint_type)
        pcg_rotr(
            $return_type((state >> $(sizeof(return_type) * 8)) $ state), # The high bits will become 0.
            $return_type(state >> $p1)
        )
    end
end

# pcg_output_xsl_rr_rr_XX_XX
# XX is 64 or 128.
# Xorshift Low, Random Rotation, Random Rotation.
# Insecure.
for (uint_type, half_type, p1) in ((UInt64, UInt32, 59), (UInt128, UInt64, 122))
    @eval @inline function pcg_xsl_rr_rr(state::$uint_type)
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

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateOneseq{T<:UIntTypes}
    state::T
    function PCGStateOneseq(init_state::T)
        s = PCGStateOneseq(0)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end 

# pcg_oneseq_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier, default_increment) in zip(uint_types, default_multipliers,
    (0x4d, 0xbb75, 0xac564b05, 0x14057b7ef767814f, 0x5851f42d4c957f2d14057b7ef767814f))
    @eval @inline function pcg_step(s::PCGStateOneseq{$uint_type})
        s.state = s.state * $default_multiplier + $default_increment
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateMCG{T<:UIntTypes}
    state::T
    PCGStateMCG(init_state::T) = PCGStateMCG(init_state | 1)
end

# pcg_mcg_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateMCG{$uint_type})
        s.state = s.state * $default_multiplier
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateUnique{T<:UIntTypes}
    state::T
    function PCGStateUnique(init_state::T)
        s = PCGStateUnique(0)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end

# pcg_unique_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateUnique{$uint_type})
        s.state = s.state * $default_multiplier + $uint_type(UInt(rng_ptr) | 1)
    end
end

# pcg_state_XX
# XX is one of the UInt types.
type PCGStateSetseq{T<:UIntTypes}
    state::T
    inc::T
    function PCGStateSetseq(init_state::T, init_seq::T)
        s = PCGStateSetseq(0, (init_seq << 1) | 1)
        pcg_step(s)
        s.state += init_state
        pcg_step(s)
        s
    end
end

# pcg_setseq_XX_step_r
# XX is one of the UInt types.
for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval @inline function pcg_step(s::PCGStateSetseq{$uint_type})
        s.state = s.state * $default_multiplier + s.inc
    end
end

const pcg_state_types = (PCGStateOneseq, PCGStateMCG, PCGStateUnique, PCGStateSetseq)


# Random and Bounded Random functions

# pcg_setseq_XX_xsh_rs_YY_random_r
# XX is one of the UInt types except UInt8, and YY is half of XX.
for state_type in pcg_state_types
    for uint_type in uint_types[2:end]
        @eval @inline function pcg_xsh_rs_random(s::$state_type{$uint_type})
            old_state = s.state
            pcg_step(s)
            pcg_xsh_rs_output(old_state);
        end
    end

    # pcg_setseq_XX_xsh_rs_YY_boundedrand_r
    # XX is one of the UInt types except UInt8, and YY is half of XX.
    for (uint_type, return_type) in zip(uint_types[2:end], uint_types[1:end-1])
        @eval @inline function pcg_xsh_rs_boundedrand(s::$state_type{$uint_type}, bound::$return_type)
            threshold = (-bound) % bound
            while (r = pcg_xsh_rs_random(s)) < threshold end
            r % bound
        end
    end
end
