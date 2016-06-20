using RNGTest
using RNG

function bigcrush{T<:Number}(rng::RNG.AbstractRNG{T})
    p = RNGTest.wrap(r, T)
    RNGTest.bigcrushTestU01(p)
end

function speed_test{T<:Number}(rng::RNG.AbstractRNG{T}, n::Int64)
    start_time = time()
    for i = 1:n
        rand(rng, T)
    end
    elapsed = time() - start_time
    @printf "Speed Test: %.3f ns/64 bits\n" elapsed * 1e9 / n * 8 / sizeof(T)
end

function test_all{T<:Number}(rng::RNG.AbstractRNG{T}, n::Int64=10_000_000)
    fo = open(TEST_NAME, "w")
    redirect_stdout(fo)
    bigcrush(rng)
    speed_test(rng, n)
    close(fo)
end
