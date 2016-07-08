import Base.Test: @test
using RNG.Xorshifts

pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Xorshifts"))
mkpath("./actual")

for rng_name in (:Xorshift64, )

    outfile = open(string(
        "./actual/check-$(lowercase("$rng_name")).out"
    ), "w")
    redirect_stdout(outfile)

    x = @eval $rng_name(123)

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end

@test success(`diff -ru expected actual`)
cd(pwd_)
