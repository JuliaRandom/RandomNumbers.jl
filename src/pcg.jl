abstract PCG <: AbstractRNG

typealias UIntTypes Union{UInt8, UInt16, UInt32, UInt64, UInt128}
uint_types = (UInt8, UInt16, UInt32, UInt64, UInt128)

default_multipliers = (0x8d, 0x321d, 0x2c9277b5, 0x5851f42d4c957f2d, 0x2360ed051fc65da44385df649fccf645)

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

for (uint_type, default_multiplier, default_increment) in zip(uint_types, default_multipliers, 
    (0x4d, 0xbb75, 0xac564b05, 0x14057b7ef767814f, 0x5851f42d4c957f2d14057b7ef767814f))
    @eval function pcg_step(s::PCGStateOneseq{$uint_type})
        s.state = s.state * $default_multiplier + $default_increment
    end
end

type PCGStateMCG{T<:UIntTypes}
    state::T
    PCGStateMCG(init_state::T) = PCGStateMCG(init_state | 1)
end

for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval function pcg_step(s::PCGStateMCG{$uint_type})
        s.state = s.state * $default_multiplier
    end
end


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

for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval function pcg_step(s::PCGStateUnique{$uint_type})
        s.state = s.state * $default_multiplier + $uint_type(UInt(rng_ptr) | 1)
    end
end

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

for (uint_type, default_multiplier) in zip(uint_types, default_multipliers)
    @eval function pcg_step(s::PCGStateSetseq{$uint_type})
        s.state = s.state * $default_multiplier + s.inc
    end
end
