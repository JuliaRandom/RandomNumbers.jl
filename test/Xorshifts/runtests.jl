import Base.Test: @test
using RNG.Xorshifts

pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Xorshifts"))
mkpath("./actual")

for (rng_name, rng) in (
        (:Xorshift64_64, :(Xorshift64(UInt64, 123))),
        (:Xorshift64_32, :(Xorshift64(UInt32, 123))),
        (:Xorshift64Star_64, :(Xorshift64Star(UInt64, 123))),
        (:Xorshift64Star_32, :(Xorshift64Star(UInt32, 123))),
        (:Xorshift128_64, :(Xorshift128(UInt64, 123))),
        (:Xorshift128_32, :(Xorshift128(UInt32, 123))),
        (:Xorshift128Star_64, :(Xorshift128Star(UInt64, 123))),
        (:Xorshift128Star_32, :(Xorshift128Star(UInt32, 123))),
        (:Xorshift128Plus_64, :(Xorshift128Plus(UInt64, 123))),
        (:Xorshift128Plus_32, :(Xorshift128Plus(UInt32, 123))),
        (:Xorshift1024_64, :(Xorshift1024(UInt64, 123))),
        (:Xorshift1024_32, :(Xorshift1024(UInt32, 123))),
        (:Xorshift1024Star_64, :(Xorshift1024Star(UInt64, 123))),
        (:Xorshift1024Star_32, :(Xorshift1024Star(UInt32, 123))),
        (:Xorshift1024Plus_64, :(Xorshift1024Plus(UInt64, 123))),
        (:Xorshift1024Plus_32, :(Xorshift1024Plus(UInt32, 123))),
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

@test success(`diff -ru expected actual`)
cd(pwd_)
