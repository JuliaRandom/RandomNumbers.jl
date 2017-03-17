__precompile__(true)

"The module for [PCG Family](@ref)."
module PCG

# PCG
export PCGStateMCG, PCGStateOneseq, PCGStateUnique, PCGStateSetseq

# PCG Methods
export PCG_XSH_RS, PCG_XSH_RR, PCG_RXS_M_XS, PCG_XSL_RR, PCG_XSL_RR_RR

export PCGUInt, PCGMethod, PCG_LIST

export bounded_rand, advance!

const pcg_uints = (UInt8, UInt16, UInt32, UInt64, UInt128)
const PCGUInt = Union{pcg_uints...}

"""
One of PCG output method: high xorshift, followed by a random shift.

Fast.
"""
const PCG_XSH_RS = Val{:XSH_RS}
"""
One of PCG output method: high xorshift, followed by a random rotate.

Fast. Slightly better statistically than `PCG_XSH_RS`.
"""
const PCG_XSH_RR = Val{:XSH_RR}
"""
One of PCG output method: random xorshift, mcg multiply, fixed xorshift.

The most statistically powerful generator, but slower than some of the others.
"""
const PCG_RXS_M_XS = Val{:RXS_M_XS}
"""
One of PCG output method: fixed xorshift (to low bits), random rotate.

Useful for 128-bit types that are split across two CPU registers.
"""
const PCG_XSL_RR = Val{:XSL_RR}
"""
One of PCG output method: fixed xorshift (to low bits), random rotate (both parts).

Useful for 128-bit types that are split across two CPU registers. Use this in need of an invertable 128-bit
RNG.
"""
const PCG_XSL_RR_RR = Val{:XSL_RR_RR}

const pcg_methods = (PCG_XSH_RS, PCG_XSH_RR, PCG_RXS_M_XS, PCG_XSL_RR, PCG_XSL_RR_RR)

"""
The `Union` of all the PCG method types: `PCG_XSH_RS`, `PCG_XSH_RR`, `PCG_RXS_M_XS`, `PCG_XSL_RR`, and `PCG_XSL_RR_RR`.
"""
const PCGMethod = Union{pcg_methods...}

include("pcg_list.jl")

include("bases.jl")

include("main.jl")

end
