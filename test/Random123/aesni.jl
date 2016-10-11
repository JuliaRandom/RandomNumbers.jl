if R123_USE_AESNI
    key = rand(UInt128)
    r = AESNI1x(key)
    r1 = AESNI4x((unsafe_wrap(Array, Ptr{UInt32}(pointer_from_objref(key)), 4)...))
    @test seed_type(r) == UInt128
    @test seed_type(r1) == NTuple{4, UInt32}
    @test r.x == rand(r1, UInt128)
    @test rand(r, UInt128) == rand(r1, UInt128)
    set_counter!(r, 0)
    set_counter!(r1, 1)
    @test rand(r, Tuple{UInt128})[1] == rand(r1, UInt128)
end
