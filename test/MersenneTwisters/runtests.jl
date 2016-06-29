import Base.Test: @test
using RNG.MersenneTwisters

pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/MersenneTwisters"))
mkpath("./actual")

for mt_name in (:MT19937, )

    outfile = open(string(
        "./actual/check-$(lowercase("$mt_name")).out"
    ), "w")
    redirect_stdout(outfile)

    x = @eval $mt_name(123)

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end

@test success(`diff -ru expected actual`)
cd(pwd_)
