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
