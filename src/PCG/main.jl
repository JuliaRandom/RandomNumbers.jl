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

@inline function srand{StateType<:PCGUInt}(s::AbstractPCG{StateType},
        seed::Union{StateType, Tuple{StateType, StateType}})
    pcg_srand(s, seed...)
end

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

for (pcg_type_t, uint_type, method_symbol, return_type) in include("pcg_list.jl")
    pcg_type = Symbol("PCGState$pcg_type_t")
    method = Val{method_symbol}

    @eval $pcg_type(state_type::Type{$uint_type}, method::Type{$method}) = 
        $pcg_type{state_type, method, $return_type}()

    if pcg_type_t != :Setseq
        @eval function $pcg_type(state_type::Type{$uint_type}, method::Type{$method}, init_state::$uint_type)
            s = $pcg_type(state_type, method)
            pcg_srand(s, init_state)
            s
        end
    else
        @eval function $pcg_type(state_type::Type{$uint_type}, method::Type{$method}, init_state::$uint_type,
                init_seq::$uint_type)
            s = $pcg_type(state_type, method)
            pcg_srand(s, init_state, init_seq)
            s
        end
    end

end
