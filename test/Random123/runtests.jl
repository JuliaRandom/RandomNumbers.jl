import Base.Test: @test
using RandomNumbers.Random123

stdout_ = STDOUT
pwd_ = pwd()
cd(dirname(@__FILE__))
rm("./actual"; force=true, recursive=true)
mkpath("./actual")

for (rng_name, seed_t, stype, seed, args) in (
    (:Threefry2x, NTuple{2, UInt32}, UInt32, (123, 321), (32,)),
    (:Threefry2x, NTuple{2, UInt64}, UInt64, (123, 321), (32,)),
    (:Threefry4x, NTuple{4, UInt32}, UInt32, (123, 321, 456, 654), (72,)),
    (:Threefry4x, NTuple{4, UInt64}, UInt64, (123, 321, 456, 654), (72,)),
    (:Philox2x,   UInt32, UInt32, 123, (16,)),
    (:Philox2x,   UInt64, UInt64, 123, (16,)),
    (:Philox4x,   NTuple{2, UInt32}, UInt32, (123, 321), (16,)),
    (:Philox4x,   NTuple{2, UInt64}, UInt64, (123, 321), (16,))
)
    outfile = open(string(
        "./actual/check-$(string(lowercase("$rng_name"), sizeof(stype)<<3)).out"
    ), "w")
    redirect_stdout(outfile)

    @eval $rng_name($stype)
    x = @eval $rng_name($stype, $seed, $(args...))
    @test seed_type(x) == seed_t
    @test copy!(copy(x), x) == x

    x.p = 1
    rand(x, UInt64)
    x.p = 1
    rand(x, UInt128)
    @eval rand(x, NTuple{$(string(rng_name)[end-1]-'0'), $stype})

    set_counter!(x, 0)
    for i in 1:100
        @printf "%.9f\n" rand(x)
    end


    close(outfile)
end
redirect_stdout(stdout_)

@test_diff "expected" "actual"
cd(pwd_)

include("aesni.jl")
include("ars.jl")
