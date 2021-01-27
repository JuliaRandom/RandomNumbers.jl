using RandomNumbers
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
    N = 100_000_000

    # Float64
    x = randfloat(N)
    @test maximum(x) > 0.999999
    @test minimum(x) < 1e-7

    # histogram for exponents
    H = fill(0,64)  
    for xi in x     # 0.5 is in H[1], 0.25 is in H[2] etc
        e = reinterpret(UInt64,xi) & Base.exponent_mask(Float64)
        H[Base.exponent_bias(Float64)-Int(e >> 52)] += 1
    end

    # test that the most frequent exponents occur at 50%, 25%, 12.5% etc.
    for i in 1:10   
        @test isapprox(H[i]/N,2.0^-i,atol=1e-4)
    end
    
    # FLOAT32
    x = randfloat(Float32,N)
    @test maximum(x) > prevfloat(1f0,5)
    @test minimum(x) < 1e-7

    # histogram for exponents
    H = fill(0,64)  
    for xi in x     # 0.5f0 is in H[1], 0.25f0 is in H[2] etc
        e = reinterpret(UInt32,xi) & Base.exponent_mask(Float32)
        H[Base.exponent_bias(Float32)-Int(e >> 23)] += 1
    end

    # test that the most frequent exponents occur at 50%, 25%, 12.5% etc.
    for i in 1:10   
        @test isapprox(H[i]/N,2.0^-i,atol=1e-4)
    end
end