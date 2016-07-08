import Base.Test: @test
using RNG.Random123

pwd_ = pwd()
cd(joinpath(Pkg.dir("RNG"), "test/Random123"))
mkpath("./actual")

for (rng_name, stype, seed, args) in (
    (:Threefry2x, UInt32, (123, 321), (32,)),
    (:Threefry2x, UInt64, (123, 321), (32,)),
    (:Threefry4x, UInt32, (123, 321, 456, 654), (72,)),
    (:Threefry4x, UInt64, (123, 321, 456, 654), (72,)),
    (:Philox2x, UInt32, 123, (16,)),
    (:Philox2x, UInt64, 123, (16,)),
    (:Philox4x, UInt32, (123, 321), (16,)),
    (:Philox4x, UInt64, (123, 321), (16,))
)
    outfile = open(string(
        "./actual/check-$(string(lowercase("$rng_name"), sizeof(stype)<<3)).out"
    ), "w")
    redirect_stdout(outfile)

    @eval $rng_name($stype)
    x = @eval $rng_name($stype, $seed, $(args...))

    for i in 1:100
        @printf "%.9f\n" rand(x)
    end

    close(outfile)
end

@test success(`diff -ru expected actual`)
cd(pwd_)
