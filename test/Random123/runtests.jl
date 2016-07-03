import Base.Test: @test
using RNG.Random123

pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Random123"))
mkpath("./actual")

for (rng_name, stype, seed) in (
    (:Threefry2x, UInt32, (123, 321)),
    (:Threefry2x, UInt64, (123, 321)),
    (:Threefry4x, UInt32, (123, 321, 456, 654)),
    (:Threefry4x, UInt64, (123, 321, 456, 654)),
    (:Philox2x, UInt32, 123),
    (:Philox2x, UInt64, 123),
    (:Philox4x, UInt32, (123, 321)),
    (:Philox4x, UInt64, (123, 321))
)
    outfile = open(string(
        "./actual/check-$(string(lowercase("$rng_name"), sizeof(stype)<<3)).out"
    ), "w")
    redirect_stdout(outfile)

    x = @eval $rng_name($stype, $seed)

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end

@test success(`diff -ru expected actual`)
cd(pwd_)
