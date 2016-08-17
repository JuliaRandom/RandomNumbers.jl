const PCG_LIST = (
    (:Oneseq, UInt16, :XSH_RS, UInt8),
    (:Oneseq, UInt32, :XSH_RS, UInt16),
    (:Oneseq, UInt64, :XSH_RS, UInt32),
    (:Oneseq, UInt128, :XSH_RS, UInt64),
    (:Unique, UInt16, :XSH_RS, UInt8),
    (:Unique, UInt32, :XSH_RS, UInt16),
    (:Unique, UInt64, :XSH_RS, UInt32),
    (:Unique, UInt128, :XSH_RS, UInt64),
    (:Setseq, UInt16, :XSH_RS, UInt8),
    (:Setseq, UInt32, :XSH_RS, UInt16),
    (:Setseq, UInt64, :XSH_RS, UInt32),
    (:Setseq, UInt128, :XSH_RS, UInt64),
    (:MCG, UInt16, :XSH_RS, UInt8),
    (:MCG, UInt32, :XSH_RS, UInt16),
    (:MCG, UInt64, :XSH_RS, UInt32),
    (:MCG, UInt128, :XSH_RS, UInt64),

    (:Oneseq, UInt16, :XSH_RR, UInt8),
    (:Oneseq, UInt32, :XSH_RR, UInt16),
    (:Oneseq, UInt64, :XSH_RR, UInt32),
    (:Oneseq, UInt128, :XSH_RR, UInt64),
    (:Unique, UInt16, :XSH_RR, UInt8),
    (:Unique, UInt32, :XSH_RR, UInt16),
    (:Unique, UInt64, :XSH_RR, UInt32),
    (:Unique, UInt128, :XSH_RR, UInt64),
    (:Setseq, UInt16, :XSH_RR, UInt8),
    (:Setseq, UInt32, :XSH_RR, UInt16),
    (:Setseq, UInt64, :XSH_RR, UInt32),
    (:Setseq, UInt128, :XSH_RR, UInt64),
    (:MCG, UInt16, :XSH_RR, UInt8),
    (:MCG, UInt32, :XSH_RR, UInt16),
    (:MCG, UInt64, :XSH_RR, UInt32),
    (:MCG, UInt128, :XSH_RR, UInt64),

    (:Oneseq, UInt8, :RXS_M_XS, UInt8),
    (:Oneseq, UInt16, :RXS_M_XS, UInt16),
    (:Oneseq, UInt32, :RXS_M_XS, UInt32),
    (:Oneseq, UInt64, :RXS_M_XS, UInt64),
    (:Oneseq, UInt128, :RXS_M_XS, UInt128),
    (:Unique, UInt16, :RXS_M_XS, UInt16),
    (:Unique, UInt32, :RXS_M_XS, UInt32),
    (:Unique, UInt64, :RXS_M_XS, UInt64),
    (:Unique, UInt128, :RXS_M_XS, UInt128),
    (:Setseq, UInt8, :RXS_M_XS, UInt8),
    (:Setseq, UInt16, :RXS_M_XS, UInt16),
    (:Setseq, UInt32, :RXS_M_XS, UInt32),
    (:Setseq, UInt64, :RXS_M_XS, UInt64),
    (:Setseq, UInt128, :RXS_M_XS, UInt128),

    (:Oneseq, UInt64, :XSL_RR, UInt32),
    (:Oneseq, UInt128, :XSL_RR, UInt64),
    (:Unique, UInt64, :XSL_RR, UInt32),
    (:Unique, UInt128, :XSL_RR, UInt64),
    (:Setseq, UInt64, :XSL_RR, UInt32),
    (:Setseq, UInt128, :XSL_RR, UInt64),
    (:MCG, UInt64, :XSL_RR, UInt32),
    (:MCG, UInt128, :XSL_RR, UInt64),

    (:Oneseq, UInt64, :XSL_RR_RR, UInt64),
    (:Oneseq, UInt128, :XSL_RR_RR, UInt128),
    (:Unique, UInt64, :XSL_RR_RR, UInt64),
    (:Unique, UInt128, :XSL_RR_RR, UInt128),
    (:Setseq, UInt64, :XSL_RR_RR, UInt64),
    (:Setseq, UInt128, :XSL_RR_RR, UInt128)
)

let p() = begin
        s = "The list of all the parameter combinations that can be used for PCG.\n\n"
        s *= "|Stream variation|State Type|Method Type|Output Type|\n"
        s *= "|---|---|---|---|\n"
        for (pcg_type, uint_type, method, output_type) in PCG_LIST
            s *= "|`PCGState$pcg_type`|`$uint_type`|`PCG_$method`|`$output_type`|\n"
        end
        s
    end
    @doc p() PCG_LIST
end
