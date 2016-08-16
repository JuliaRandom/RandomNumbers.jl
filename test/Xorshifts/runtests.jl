import Base.Test: @test
using RNG.Xorshifts

stdout_ = STDOUT
pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Xorshifts"))
mkpath("./actual")

for (rng_name, rng) in (
        (:Xorshift64, :(Xorshift64(123))),
        (:Xorshift64Star, :(Xorshift64Star(123))),
        (:Xorshift128, :(Xorshift128(123))),
        (:Xorshift128Star, :(Xorshift128Star(123))),
        (:Xorshift128Plus, :(Xorshift128Plus(123))),
        (:Xorshift1024, :(Xorshift1024(123))),
        (:Xorshift1024Star, :(Xorshift1024Star(123))),
        (:Xorshift1024Plus, :(Xorshift1024Plus(123))),
        (:Xoroshiro128, :(Xoroshiro128(123))),
        (:Xoroshiro128Star, :(Xoroshiro128Star(123))),
        (:Xoroshiro128Plus, :(Xoroshiro128Plus(123))),
    )

    outfile = open(string(
        "./actual/check-$(lowercase("$rng_name")).out"
    ), "w")
    redirect_stdout(outfile)

    x = @eval $rng

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end
redirect_stdout(stdout_)

@test success(`diff -ru expected actual`)
cd(pwd_)
