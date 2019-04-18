using RandomNumbers.MersenneTwisters
import Random123
using RandomNumbers.Random123
using RandomNumbers.PCG
using RandomNumbers.Xorshifts
import Random: rand
import Printf: @printf, @sprintf

include("common.jl")

function rank_timing_results(results)
    sort!(results, by = last)
    mtidx = findfirst(t -> endswith(t[1], "MersenneTwister"), results)
    timemt = results[mtidx][2]
    println("\n\nRanked:")
    for i in 1:length(results)
        rngstr, timetaken = results[i]
        @printf "%4d. %s: %6.3f ns/64 bits" i rngstr timetaken
        p = 100.0 * (timetaken-timemt)/timemt
        c = (p < 0.0 ? :green : (p > 0.0 ? :red : :normal))
        if p != 0.0
            signstr = (p > 0.0 ? "+" : "")
            printstyled("  ", signstr, @sprintf("%.2f%%", p); color=c)
        end
        println("")
    end
end

macro rngtest(rngs...)
    results = []
    for rng in rngs
        if rng.head == :call
            r = @eval $rng
            name = rng.args[1]
        else
            r = @eval $(rng.args[1])
            name = rng.args[2]
        end
        timetaken = speed_test(r)
        @printf "%20s: %6.3f ns/64 bits\n" name timetaken
        push!(results, (@sprintf("%20s", name), timetaken))
    end
    rank_timing_results(results)
end

@rngtest(
Xorshift64(123),
Xorshift64Star(123),
Xorshift128Star(123),
Xorshift128Plus(123),
Xorshift1024Star(123),
Xorshift1024Plus(123),
Xoroshiro128Plus(123),
Xoroshiro128Star(123),

MersenneTwister(123),
MT19937(123),

(Threefry2x(UInt64, (123, 321)), Threefry2x64),
(Threefry4x(UInt64, (123, 321, 456, 654)), Threefry4x64),
(Threefry2x(UInt32, (123, 321)), Threefry2x32),
(Threefry4x(UInt32, (123, 321, 456, 654)), Threefry4x32),
(Philox2x(UInt64, 123), Philox2x64),
(Philox4x(UInt64, (123, 321)), Philox4x64),
(Philox2x(UInt32, 123), Philox2x32),
(Philox4x(UInt32, (123, 321)), Philox4x32),
(AESNI1x(123), AESNI1x128),
(ARS1x(123), ARS1x128),
(AESNI4x((123, 321, 456, 654)), AESNI4x32),
(ARS4x((123, 321, 456, 654)), ARS4x32),

(PCGStateOneseq(UInt64, PCG_XSH_RS, 123), PCG_XSH_RS_128),
(PCGStateOneseq(UInt64, PCG_XSH_RR, 123), PCG_XSH_RR_128),
(PCGStateOneseq(UInt64, PCG_RXS_M_XS, 123), PCG_RXS_M_XS_64),
(PCGStateOneseq(UInt64, PCG_XSL_RR, 123), PCG_XSL_RR_128),
(PCGStateOneseq(UInt64, PCG_XSL_RR_RR, 123), PCG_XSL_RR_RR_64),

(PCGStateOneseq(UInt32, PCG_XSH_RS, 123), PCG_XSH_RS_64),
(PCGStateOneseq(UInt32, PCG_XSH_RR, 123), PCG_XSH_RR_64),
(PCGStateOneseq(UInt32, PCG_RXS_M_XS, 123), PCG_RXS_M_XS_32),
(PCGStateOneseq(UInt32, PCG_XSL_RR, 123), PCG_XSL_RR_64),

(PCGStateOneseq(UInt128, PCG_RXS_M_XS, 123), PCG_RXS_M_XS_128),
(PCGStateOneseq(UInt128, PCG_XSL_RR_RR, 123), PCG_XSL_RR_RR_128),
)
