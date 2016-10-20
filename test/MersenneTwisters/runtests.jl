import Base.Test: @test
using RNG.MersenneTwisters

stdout_ = STDOUT
pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/MersenneTwisters"))
rm("./actual"; force=true, recursive=true)
mkpath("./actual")

@test seed_type(MT19937) == NTuple{RNG.MersenneTwisters.N, UInt32}

for mt_name in (:MT19937, )

    outfile = open(string(
        "./actual/check-$(lowercase("$mt_name")).out"
    ), "w")
    redirect_stdout(outfile)

    @eval $mt_name()
    x = @eval $mt_name(123)
    @test copy!(copy(x), x) == x

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end
redirect_stdout(stdout_)

@test success(`diff -ru expected actual`)
cd(pwd_)
