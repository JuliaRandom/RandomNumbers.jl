import Base: copy, copyto!, ==
import Random: rand, seed!
import RandomNumbers: gen_seed, seed_type

# Generic functions

@inline seed!(r::AbstractPCG{StateType}, seed::Integer=gen_seed(StateType)) where
    StateType <: PCGUInt = pcg_seed!(r, seed % StateType)
@inline seed!(r::PCGStateSetseq{StateType}, seed::NTuple{2, Integer}=gen_seed(StateType, 2)) where
    StateType <: PCGUInt = pcg_seed!(r, seed[1] % StateType, seed[2] % StateType)

@inline seed_type(::Type{PCGStateOneseq{T, T1, T2}}) where {T, T1, T2} = T
@inline seed_type(::Type{PCGStateMCG{   T, T1, T2}}) where {T, T1, T2} = T
@inline seed_type(::Type{PCGStateUnique{T, T1, T2}}) where {T, T1, T2} = T
@inline seed_type(::Type{PCGStateSetseq{T, T1, T2}}) where {T, T1, T2} = NTuple{2, T}

function copyto!(dest::T, src::T) where T <: AbstractPCG
    dest.state = src.state
    dest
end
function copyto!(dest::T, src::T) where T <: PCGStateSetseq
    dest.state = src.state
    dest.inc = src.inc
    dest
end

copy(src::T) where T <: AbstractPCG = copyto!(T(), src)

==(r1::T, r2::T) where T <: AbstractPCG = r1.state == r2.state
==(r1::T, r2::T) where T <: PCGStateSetseq = r1.state == r2.state && r1.inc == r2.inc


@inline function rand(r::AbstractPCG{StateType, MethodType, OutputType}, ::Type{OutputType}) where
        {StateType <: Union{pcg_uints[1:end-1]...}, MethodType <: PCGMethod, OutputType <: PCGUInt}
    old_state = r.state
    pcg_step!(r)
    pcg_output(old_state, MethodType)
end

@inline function rand(r::AbstractPCG{UInt128, MethodType, OutputType}, ::Type{OutputType}) where
        {MethodType <: PCGMethod, OutputType <: PCGUInt}
    pcg_step!(r)
    pcg_output(r.state, MethodType)
end

"""
```julia
bounded_rand(r, bound)
```

Producing a random number less than a given `bound` in the output type.
"""
@inline function bounded_rand(s::AbstractPCG{StateType, MethodType, OutputType}, bound::OutputType) where
        {StateType <: PCGUInt, MethodType <: PCGMethod, OutputType <: PCGUInt}
    threshold = (-bound) % bound
    r = rand(s, OutputType)
    while r < threshold
        r = rand(s, OutputType)
    end
    r % bound
end

"""
```julia
advance!(r, Δ)
```

Advance a PCG object `r` for `Δ` steps.

# Examples
```jldoctest
julia> r = PCGStateSetseq(UInt64, PCG_RXS_M_XS, (123, 321))
PCGStateSetseq{UInt64,Val{:RXS_M_XS},UInt64}(0x45389f8b27528b29, 0x0000000000000283)

julia> A = rand(r, UInt64, 2);

julia> p = rand(r);

julia> r
PCGStateSetseq{UInt64,Val{:RXS_M_XS},UInt64}(0x9b1fc763ae0ad702, 0x0000000000000283)

julia> advance!(r, -3)
PCGStateSetseq{UInt64,Val{:RXS_M_XS},UInt64}(0x45389f8b27528b29, 0x0000000000000283)

julia> @Test.test A == rand(r, UInt64, 2)
Test Passed

julia> @Test.test p == rand(r)
Test Passed
```
"""
@inline function advance!(r::AbstractPCG{StateType}, Δ::Integer) where StateType <: PCGUInt
    pcg_advance!(r, Δ % StateType)
    r
end

# Constructors.
for (pcg_type_t, uint_type, method_symbol, output_type) in PCG_LIST
    pcg_type = Symbol("PCGState$pcg_type_t")
    method = Val{method_symbol}

    if pcg_type_t != :Setseq
        @eval function $pcg_type(output_type::Type{$output_type}, method::Type{$method},
                seed::Integer=gen_seed($uint_type))
            s = $pcg_type{$uint_type, method, output_type}()
            seed!(s, seed)
            s
        end
    else
        @eval function $pcg_type(output_type::Type{$output_type}, method::Type{$method},
                seed::NTuple{2, Integer}=gen_seed($uint_type, 2))
            s = $pcg_type{$uint_type, method, output_type}()
            seed!(s, seed)
            s
        end
    end
end

"""
```julia
PCGStateOneseq{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
    AbstractPCG{StateType, MethodType, OutputType}
PCGStateOneseq([seed])
PCGStateOneseq(output_type[, seed])
PCGStateOneseq(method[, seed])
PCGStateOneseq(output_type[, method, seed])
```

PCG generator with *single streams*, where all instances use the same fixed constant, thus the RNG always
somewhere in same sequence.

`seed` is an `Integer` which will be automatically converted to the state type.

`output_type` is the type of the PCG's output. If missing it is set to `UInt64`.

`method` is one of the [`PCGMethod`](@ref). If missing it is set to `PCG_XSH_RS`.

See [`PCG_LIST`](@ref) for the available parameter combinations.
"""
PCGStateOneseq(seed::Integer=gen_seed(UInt128)) = PCGStateOneseq(UInt64, PCG_XSH_RS, seed)
PCGStateOneseq(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGUInt = PCGStateOneseq(T, PCG_XSH_RS, seed)
PCGStateOneseq(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGMethod = PCGStateOneseq(UInt64, T, seed)

"""
```julia
PCGStateMCG{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
    AbstractPCG{StateType, MethodType, OutputType}
PCGStateMCG([seed])
PCGStateMCG(output_type[, seed])
PCGStateMCG(method[, seed])
PCGStateMCG(output_type[, method, seed])
```

PCG generator with *MCG*, where the increment is zero, resulting in a single stream and reduced period.

`seed` is an `Integer` which will be automatically converted to the state type.

`output_type` is the type of the PCG's output. If missing it is set to `UInt64`.

`method` is one of the [`PCGMethod`](@ref). If missing it is set to `PCG_XSH_RS`.

See [`PCG_LIST`](@ref) for the available parameter combinations.
"""
PCGStateMCG(seed::Integer=gen_seed(UInt128)) = PCGStateMCG(UInt64, PCG_XSH_RS, seed)
PCGStateMCG(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGUInt = PCGStateMCG(T, PCG_XSH_RS, seed)
PCGStateMCG(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGMethod = PCGStateMCG(UInt64, T, seed)

"""
```julia
PCGStateSetseq{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
    AbstractPCG{StateType, MethodType, OutputType}
PCGStateSetseq([seed])
PCGStateSetseq(output_type[, seed])
PCGStateSetseq(method[, seed])
PCGStateSetseq(output_type[, method, seed])
```

PCG generator with *specific streams*, where the constant can be changed at any time, selecting a different
random sequence.

`seed` is a `Tuple` of two `Integer`s which will both be automatically converted to the state type.

`output_type` is the type of the PCG's output. If missing it is set to `UInt64`.

`method` is one of the [`PCGMethod`](@ref). If missing it is set to `PCG_XSH_RS`.

See [`PCG_LIST`](@ref) for the available parameter combinations.
"""
PCGStateSetseq(seed::NTuple{2, Integer}=gen_seed(UInt128, 2)) = PCGStateSetseq(UInt64, PCG_XSH_RS, seed)
PCGStateSetseq(::Type{T}, seed::NTuple{2, Integer}=gen_seed(UInt128, 2)) where
    T <: PCGUInt = PCGStateSetseq(T, PCG_XSH_RS, seed)
PCGStateSetseq(::Type{T}, seed::NTuple{2, Integer}=gen_seed(UInt128, 2)) where
    T <: PCGMethod = PCGStateSetseq(UInt64, T, seed)

"""
```julia
PCGStateUnique{StateType<:PCGUInt, MethodType<:PCGMethod, OutputType<:PCGUInt} <:
    AbstractPCG{StateType, MethodType, OutputType}
PCGStateUnique([seed])
PCGStateUnique(output_type[, seed])
PCGStateUnique(method[, seed])
PCGStateUnique(output_type[, method, seed])
```

PCG generator with *unique streams*, where the constant is based on the memory address of the object, thus
every RNG has its own unique sequence.

`seed` is an `Integer` which will be automatically converted to the state type.

`output_type` is the type of the PCG's output. If missing it is set to `UInt64`.

`method` is one of the [`PCGMethod`](@ref). If missing it is set to `PCG_XSH_RS`.

See [`PCG_LIST`](@ref) for the available parameter combinations.
"""
PCGStateUnique(seed::Integer=gen_seed(UInt128)) = PCGStateUnique(UInt64, PCG_XSH_RS, seed)
PCGStateUnique(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGUInt = PCGStateUnique(T, PCG_XSH_RS, seed)
PCGStateUnique(::Type{T}, seed::Integer=gen_seed(UInt128)) where
    T <: PCGMethod = PCGStateUnique(UInt64, T, seed)
