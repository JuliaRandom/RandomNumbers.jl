if R123_USE_AESNI
    import RandomNumbers: split_uint
    key = rand(UInt128)
    r = ARS1x(key)
    r1 = ARS4x(split_uint(key, UInt32))
    @test seed_type(r) == UInt128
    @test seed_type(r1) == NTuple{4, UInt32}
    @test copyto!(copy(r), r) == r
    @test copyto!(copy(r1), r1) == r1
    @test r.x == rand(r1, UInt128)
    @test rand(r, UInt128) == rand(r1, UInt128)
    set_counter!(r, 0)
    set_counter!(r1, 1)
    @test rand(r, Tuple{UInt128})[1] == rand(r1, UInt128)
end
