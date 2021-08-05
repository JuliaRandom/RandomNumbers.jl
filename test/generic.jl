using Test
@testset "Generic functions" begin
    import Random: randn, randexp, bitrand, randstring, randsubseq, shuffle, randperm, randcycle

    @info "Testing Generic functions"
    r = PCG.PCGStateOneseq(123)
    @test randn(r) == -0.4957408739873887
    @test randn(r, Float64, 8) == [
        -0.38659391873108484, -0.12391575881839223, 0.305709506865529, 1.0234147128314572,
        1.1925044460767074, 0.8448640519165571, -0.2982275988025108, 0.9615482011555472
    ]
    @test randexp(r) == 1.0279939998988223
    @test bitrand(r, 3, 3) == [false false false; false true false; false true true]
    # randstring method changed after a julia release
    randstringres = ""
    if VERSION >= v"1.5"
        randstringres = "6j22eD3r"
    else
        randstringres = "KuSFMMEc"
    end
    @test randstring(r) == randstringres
    a = 1:100
    @test randsubseq(r, a, 0.1) == [1, 11, 12, 17, 19, 21, 27, 38, 44, 54, 58, 78, 80]
    a = 1:10
    @test shuffle(r, a) == [3, 7, 5, 10, 2, 6, 1, 4, 9, 8]
    @test randperm(r, 10) == [2, 10, 1, 6, 4, 3, 7, 8, 9, 5]
    @test randcycle(r, 10) == [8, 4, 5, 1, 10, 2, 3, 9, 7, 6]
    @test rand(r, ComplexF64) == 0.9500729643158807 + 0.9280185794620359im
end
