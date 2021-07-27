using Test

if !@isdefined RandomNumbers
    include("../common.jl")
end

@testset "MersenneTwisters" begin

    using RandomNumbers.MersenneTwisters

    @info "Testing MersenneTwisters"
    stdout_ = stdout
    pwd_ = pwd()
    cd(dirname(@__FILE__))
    rm("./actual"; force=true, recursive=true)
    mkpath("./actual")

    @test seed_type(MT19937) == NTuple{RandomNumbers.MersenneTwisters.N, UInt32}

    for mt_name in (:MT19937, )

        outfile = open(string(
            "./actual/check-$(lowercase("$mt_name")).out"
        ), "w")
        redirect_stdout(outfile)

        @eval $mt_name()
        x = @eval $mt_name(123)
        @test copyto!(copy(x), x) == x

        for i in 1:100
            @printf "%.9f\n" rand(x)
        end

        close(outfile)
    end
    redirect_stdout(stdout_)

    compare_dirs("expected", "actual")

    # Package content should not be modified.
    rm("./actual"; force=true, recursive=true)

    cd(pwd_)

end
