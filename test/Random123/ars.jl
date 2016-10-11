if R123_USE_AESNI
    key = rand(UInt128)
    r = ARS1x(key)
    r1 = ARS4x((unsafe_wrap(Array, Ptr{UInt32}(pointer_from_objref(key)), 4)...))
    @test seed_type(r) == UInt128
    @test seed_type(r1) == NTuple{4, UInt32}
    @test r.x == rand(r1, UInt128)
    @test rand(r, UInt128) == rand(r1, UInt128)
end
