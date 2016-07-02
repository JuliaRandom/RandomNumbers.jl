import RNG: gen_seed

# Random and Bounded Random functions
import Base.Random: rand, srand

@inline function rand{StateType<:Union{pcg_uints[1:end-1]...}, MethodType<:PCGMethod, OutputType<:PCGUInt}(
        s::AbstractPCG{StateType, MethodType, OutputType}, ::Type{OutputType})
    old_state = s.state
    pcg_step!(s)
    pcg_output(old_state, MethodType)
end

@inline function rand{MethodType<:PCGMethod, OutputType<:PCGUInt}(
        s::AbstractPCG{UInt128, MethodType, OutputType}, ::Type{OutputType})
    pcg_step!(s)
    pcg_output(s.state, MethodType)
end

@inline srand{StateType<:PCGUInt}(s::AbstractPCG{StateType},
    seed::Integer=gen_seed(StateType)) = pcg_srand(s, seed % StateType)
@inline srand{StateType<:PCGUInt}(s::PCGStateSetseq{StateType},
    seed::Tuple{Integer, Integer}=gen_seed(StateType, 2)) = pcg_srand(s, seed[1] % StateType, seed[2] % StateType)

@inline function bounded_rand{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt}(
        s::AbstractPCG{StateType, MethodType, OutputType}, bound::OutputType)
    threshold = (-bound) % bound
    r = rand(s, OutputType)
    while r < threshold
        r = rand(s, OutputType)
    end
    r % bound
end

@inline function advance!{StateType<:PCGUInt}(s::AbstractPCG{StateType}, delta::Integer)
    pcg_advance!(s, delta % StateType)
end


# Constructors.
for (pcg_type_t, uint_type, method_symbol, return_type) in include("pcg_list.jl")
    pcg_type = Symbol("PCGState$pcg_type_t")
    method = Val{method_symbol}

    if pcg_type_t != :Setseq
        @eval function $pcg_type(state_type::Type{$uint_type}, method::Type{$method}, init_state::Integer=gen_seed($uint_type))
            s = $pcg_type{state_type, method, $return_type}()
            srand(s, init_state)
            s
        end
    else
        @eval function $pcg_type(state_type::Type{$uint_type}, method::Type{$method}, init_state::Integer=gen_seed($uint_type),
                init_seq::Integer=gen_seed($uint_type))
            s = $pcg_type{state_type, method, $return_type}()
            srand(s, (init_state, init_seq))
            s
        end
    end
end
