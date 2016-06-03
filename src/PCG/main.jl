import RNG: AbstractRNG
import Base.Random: srand, rand

type PermutedCongruentialGenerator{StateType<:PCGState, MethodType<:PCGMethod, StateUIntType<:PCGUInt,
        OutputUIntType<:PCGUInt} <: AbstractRNG{OutputUIntType}
    state::StateType
    function PermutedCongruentialGenerator()
        new()
    end
end
function PermutedCongruentialGenerator{T1<:PCGState, T2<:PCGMethod, T3<:PCGUInt}(
    state_type::Type{T1}, method::Type{T2}, uint_type::Type{T3})

    if !method_exists(pcg_random, (state_type{uint_type, method}, ))
        error("Illegal combination of arguments.")
    end
    if method == PCG_RXS_M_XS || method == PCG_XSL_RR_RR
        return_type = uint_type
    else
        return_type = pcg_uints[log2(sizeof(uint_type))]
    end
    PermutedCongruentialGenerator{state_type, method, uint_type, return_type}()
end

function srand{StateType<:PCGState, MethodType<:PCGMethod, StateUIntType<:PCGUInt, OutputUIntType<:PCGUInt}(
        pcg::PermutedCongruentialGenerator{StateType, MethodType, StateUIntType, OutputUIntType},
        seed::Union{StateUIntType, Tuple{StateUIntType, StateUIntType}})
    pcg.state = StateType{StateUIntType, MethodType}(seed...)
    pcg
end

function rand_bounded{StateType<:PCGState, MethodType<:PCGMethod, StateUIntType<:PCGUInt,
        OutputUIntType<:PCGUInt}(pcg::PermutedCongruentialGenerator{StateType, MethodType, StateUIntType, OutputUIntType},
        bound::OutputUIntType)
    pcg_boundedrand(pcg.state, bound)
end

@inline function rand{StateType<:PCGState, MethodType<:PCGMethod, StateUIntType<:PCGUInt, OutputUIntType<:PCGUInt}(
        pcg::PermutedCongruentialGenerator{StateType, MethodType, StateUIntType, OutputUIntType}, ::Type{OutputUIntType})
    pcg_random(pcg.state)
end

function advance!{StateType<:PCGState, MethodType<:PCGMethod, StateUIntType<:PCGUInt, OutputUIntType<:PCGUInt}(
        pcg::PermutedCongruentialGenerator{StateType, MethodType, StateUIntType, OutputUIntType}, delta::StateUIntType)
    pcg_advance!(pcg.state, delta)
end
