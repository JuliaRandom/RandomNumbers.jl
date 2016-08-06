using RNGTest

function speed_test{T<:Number}(rng::AbstractRNG, ::Type{T}, n::Int)
    t = 0 % T
    elapsed = @elapsed for i = 1:n
        t += rand(rng, T)
    end
    @printf "Speed Test: %.3f ns/64 bits\n" elapsed * 1e9 / n * 8 / sizeof(T)
end

const TEST_NAME = "BaseMT19937"
fo = open("$TEST_NAME.log", "w")
redirect_stdout(fo)
println(TEST_NAME)

rng = MersenneTwister(123)

speed_test(rng, UInt64, 100_000_000)
flush(fo)

# Big Crush
p = RNGTest.wrap(rng, UInt64)
RNGTest.bigcrushTestU01(p)

close(fo)
