using RandomNumbers
using Test

@testset "Check types" begin
    @test typeof(randfloat()) == Float64
    @test typeof(randfloat(Float32)) == Float32
    @test typeof(randfloat(Float64)) == Float64
    @test typeof(randfloat(Float16)) == Float16
    
    # arrays
    @test typeof(randfloat(Float16,2)) <: Vector{Float16}
    @test typeof(randfloat(Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(Float16,2,3)) <: Matrix{Float16}
    @test typeof(randfloat(Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(Float64,2,3)) <: Matrix{Float64}
end

@testset "Non-default RNG" begin
    import RandomNumbers.Xorshifts.Xorshift64
    rng = Xorshift64()
    @test typeof(randfloat(rng)) == Float64
    @test typeof(randfloat(rng,Float16)) == Float16
    @test typeof(randfloat(rng,Float32)) == Float32
    @test typeof(randfloat(rng,Float64)) == Float64
    
    # arrays
    @test typeof(randfloat(rng,Float16,2)) <: Vector{Float16}
    @test typeof(randfloat(rng,Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(rng,Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(rng,Float16,2,3)) <: Matrix{Float16}
    @test typeof(randfloat(rng,Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(rng,Float64,2,3)) <: Matrix{Float64}

    import RandomNumbers.MersenneTwisters.MT19937
    rng = MT19937()
    @test typeof(randfloat(rng)) == Float64
    @test typeof(randfloat(rng,Float16)) == Float16
    @test typeof(randfloat(rng,Float32)) == Float32
    @test typeof(randfloat(rng,Float64)) == Float64
    
    # arrays
    @test typeof(randfloat(rng,Float16,2)) <: Vector{Float16}
    @test typeof(randfloat(rng,Float32,2)) <: Vector{Float32}
    @test typeof(randfloat(rng,Float64,2)) <: Vector{Float64}

    @test typeof(randfloat(rng,Float16,2,3)) <: Matrix{Float16}
    @test typeof(randfloat(rng,Float32,2,3)) <: Matrix{Float32}
    @test typeof(randfloat(rng,Float64,2,3)) <: Matrix{Float64}
end

@testset "Distribution is uniform [0,1) Float64" begin
    N = 100_000_000

    x = randfloat(N)
    @test maximum(x) > 0.999999
    @test minimum(x) < 1e-7

    exponent_mask = 0x7ff0000000000000
    exponent_bias = 1023

    # histogram for exponents
    H = fill(0,64)  
    for xi in x     # 0.5 is in H[1], 0.25 is in H[2] etc
        e = reinterpret(UInt64,xi) & exponent_mask
        H[exponent_bias-Int(e >> 52)] += 1
    end

    # test that the most frequent exponents occur at 50%, 25%, 12.5% etc.
    for i in 1:10   
        @test isapprox(H[i]/N,2.0^-i,atol=5e-4)
    end
end

@testset "Distribution is uniform [0,1) Float32" begin
    N = 100_000_000

    x = randfloat(Float32,N)
    @test maximum(x) > prevfloat(1f0,5)
    @test minimum(x) < 1e-7

    exponent_mask = 0x7f800000
    exponent_bias = 127

    # histogram for exponents
    H = fill(0,64)  
    for xi in x     # 0.5f0 is in H[1], 0.25f0 is in H[2] etc
        e = reinterpret(UInt32,xi) & exponent_mask
        H[exponent_bias-Int(e >> 23)] += 1
    end

    # test that the most frequent exponents occur at 50%, 25%, 12.5% etc.
    for i in 1:10   
        @test isapprox(H[i]/N,2.0^-i,atol=5e-4)
    end
end

@testset "Distribution is uniform [0,1) Float16" begin
    N = 100_000_000

    x = randfloat(Float16,N)
    @test maximum(x) == prevfloat(one(Float16))
    @test minimum(x) == zero(Float16)               # zero can be produced

    exponent_mask = 0x7c00
    exponent_bias = 15

    # histogram for exponents
    H = fill(0,16)  
    for xi in x     # 0.5f0 is in H[1], 0.25f0 is in H[2] etc
        e = reinterpret(UInt16,xi) & exponent_mask
        H[exponent_bias-Int(e >> 10)] += 1
    end

    # test that the most frequent exponents occur at 50%, 25%, 12.5% etc.
    for i in 1:10   
        @test isapprox(H[i]/N,2.0^-i,atol=5e-4)
    end
end