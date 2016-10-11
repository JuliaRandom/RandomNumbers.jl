import Base.Test: @test
using RNG.Xorshifts

stdout_ = STDOUT
pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Xorshifts"))
rm("./actual"; force=true, recursive=true)
mkpath("./actual")

for (rng_name, rng, seed_t) in (
        (:Xorshift64,       :(Xorshift64(123))      , UInt64),
        (:Xorshift64Star,   :(Xorshift64Star(123))  , UInt64),
        (:Xorshift128,      :(Xorshift128(123))     , NTuple{2, UInt64}),
        (:Xorshift128Star,  :(Xorshift128Star(123)) , NTuple{2, UInt64}),
        (:Xorshift128Plus,  :(Xorshift128Plus(123)) , NTuple{2, UInt64}),
        (:Xorshift1024,     :(Xorshift1024(123))    , NTuple{16, UInt64}),
        (:Xorshift1024Star, :(Xorshift1024Star(123)), NTuple{16, UInt64}),
        (:Xorshift1024Plus, :(Xorshift1024Plus(123)), NTuple{16, UInt64}),
        (:Xoroshiro128,     :(Xoroshiro128(123))    , NTuple{2, UInt64}),
        (:Xoroshiro128Star, :(Xoroshiro128Star(123)), NTuple{2, UInt64}),
        (:Xoroshiro128Plus, :(Xoroshiro128Plus(123)), NTuple{2, UInt64}),
    )

    outfile = open(string(
        "./actual/check-$(lowercase("$rng_name")).out"
    ), "w")
    redirect_stdout(outfile)

    @eval x = $rng_name()
    srand(x)
    srand(x, 1)
    @test seed_type(x) == seed_t
    @eval x = $rng

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end
redirect_stdout(stdout_)

@test success(`diff -ru expected actual`)
cd(pwd_)
