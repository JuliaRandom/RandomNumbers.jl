using RandomNumbers
using StatsBase
using Test

@testset "Check types" begin
    @test typeof(randfloat()) == Float64
    @test typeof(randfloat(Float32)) == Float32
    @test typeof(randfloat(Float64)) == Float64
    
    # arrays
    @test typeof(randfloat(Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(Float64,2,3)) <: Matrix{Float64}
end

@testset "Non-default RNG" begin
    import RandomNumbers.Xorshifts.Xorshift64
    rng = Xorshift64()
    @test typeof(randfloat(rng)) == Float64
    @test typeof(randfloat(rng,Float32)) == Float32
    @test typeof(randfloat(rng,Float64)) == Float64
    
    # arrays
    @test typeof(randfloat(rng,Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(rng,Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(rng,Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(rng,Float64,2,3)) <: Matrix{Float64}

    import RandomNumbers.MersenneTwisters.MT19937
    rng = MT19937()
    @test typeof(randfloat(rng)) == Float64
    @test typeof(randfloat(rng,Float32)) == Float32
    @test typeof(randfloat(rng,Float64)) == Float64
    
    # arrays
    @test typeof(randfloat(rng,Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(rng,Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(rng,Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(rng,Float64,2,3)) <: Matrix{Float64}
end

@testset "Distribution is uniform [0,1)" begin
    # Float64
    x = randfloat(10_000_000)
    @test maximum(x) > 0.999999
    @test minimum(x) < 5e-7

    H = fit(Histogram,x,nbins=100).weights
    @test minimum(H) > 98000
    @test maximum(H) < 10200
    
    # Float32
    x = randfloat(Float32,10_000_000)
    @test maximum(x) > prevfloat(1f0,5)
    @test minimum(x) < 5e-7

    H = fit(Histogram,x,nbins=100).weights
    @test minimum(H) > 98000
    @test maximum(H) < 10200
end