using RNGTest
using RNG

function bigcrush{T<:Number}(rng::RNG.AbstractRNG{T})
    p = RNGTest.wrap(r, T)
    RNGTest.bigcrushTestU01(p)
end

function speed_test{T<:Number}(rng::RNG.AbstractRNG{T}, n)
    t = 0 % T
    elapsed = @elapsed for i = 1:n
        t += rand(rng, T)
    end
    @printf "Speed Test: %.3f ns/64 bits\n" elapsed * 1e9 / n * 8 / sizeof(T)
end

function test_all{T<:Number}(rng::RNG.AbstractRNG{T}, n=10_000_000)
    fo = open("$TEST_NAME.log", "w")
    redirect_stdout(fo)
    println(TEST_NAME)
    speed_test(rng, n)
    flush(fo)
    bigcrush(rng)
    close(fo)
end
