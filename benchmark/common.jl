try
    using RNGTest
catch
    @warn "No RNGTest package found. Only speed benchmarks can be run."
end
using RandomNumbers
import Printf: @printf
using Random

function bigcrush(rng::RandomNumbers.AbstractRNG{T}) where {T<:Number}
    p = RNGTest.wrap(r, T)
    RNGTest.bigcrushTestU01(p)
end

function speed_test(rng::RandomNumbers.AbstractRNG{T}, n=100_000_000) where {T<:Number}
    A = Array{T}(undef, n)
    rand!(rng, A)
    elapsed = @elapsed rand!(rng, A)
    elapsed * 1e9 / n * 8 / sizeof(T)
end

function bigcrush(rng::MersenneTwister)
    p = RNGTest.wrap(r, UInt64)
    RNGTest.bigcrushTestU01(p)
end

function speed_test(rng::MersenneTwister, n=100_000_000)
    T = UInt64
    A = Array{T}(undef, n)
    rand!(rng, A)
    elapsed = @elapsed rand!(rng, A)
    elapsed * 1e9 / n * 8 / sizeof(T)
end

function test_all(rng::Random.AbstractRNG, n=100_000_000)
    fo = open("$TEST_NAME.log", "w")
    redirect_stdout(fo)
    println(TEST_NAME)
    speed = speed_test(rng, n)
    @printf "Speed Test: %.3f ns/64 bits\n" speed
    flush(fo)
    bigcrush(rng)
    close(fo)
end
