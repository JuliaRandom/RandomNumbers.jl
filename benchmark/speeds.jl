using RandomNumbers.MersenneTwisters
using RandomNumbers.Random123
using RandomNumbers.PCG
using RandomNumbers.Xorshifts
import Random: rand
import Printf: @printf

include("common.jl")

macro rngtest(rngs...)
    for rng in rngs
        if rng.head == :call
            r = @eval $rng
            name = rng.args[1]
        else
            r = @eval $(rng.args[1])
            name = rng.args[2]
        end
        @printf "%20s: %6.3f ns/64 bits\n" name speed_test(r)
    end
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
