module PCG
    abstract PermutedCongruentialGenerator <: AbstractRNG

    const uint_types = (UInt8, UInt16, UInt32, UInt64, UInt128)
    typealias UIntTypes Union{uint_types...}

    for method in (:XSH_RS, :XSH_RR, :RXS_M_XS, :XSL_RR, :XSL_RR_RR)
        eval(parse("const PCG_$method = Val{:$method}"))
    end
    const pcg_methods = map(x -> Val{x}, (:XSH_RS, :XSH_RR, :RXS_M_XS, :XSL_RR, :XSL_RR_RR))

    include("bases.jl")

end
