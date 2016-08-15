"Do one iteration and get the current value of a Xorshift RNG object."
xorshift_next

# We'll define a new type to support UInt32 type, so no need for rand(T, seed) now.

# TODO: "not recommended", and remove the need of `T`.

let doc_xorshift64(r) = """
```julia
$r{T} <: AbstractXorshift64{T}
$r([seed])
```

$r RNG. The `seed` will be automatically convert to an `UInt64` number.
"""
    @doc doc_xorshift64("Xorshift64") Xorshift64
    @doc doc_xorshift64("Xorshift64Star") Xorshift64Star
end

let doc_xorshift128(r) = """
```julia
$r{T} <: AbstractXorshift128{T}
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of two `UInt64`s, or an `Integer` which will be automatically convert to
an `UInt128` number.
"""
    @doc doc_xorshift128("Xorshift128") Xorshift128
    @doc doc_xorshift128("Xorshift128Star") Xorshift128Star
    @doc doc_xorshift128("Xorshift128Plus") Xorshift128Plus
end

let doc_xorshift1024(r) = """
```julia
$r{T} <: AbstractXorshift1024{T}
$r([seed...])
```

$r RNG. The `seed` can be a `Tuple` of 16 `UInt64`s, or several (no more than 16) `Integer`s which will all
be automatically converted to `UInt64` numbers.
"""
    @doc doc_xorshift1024("Xorshift1024") Xorshift1024
    @doc doc_xorshift1024("Xorshift1024Star") Xorshift1024Star
    @doc doc_xorshift1024("Xorshift1024Plus") Xorshift1024Plus
end

let doc_xoroshiro128(r) = """
```julia
$r{T} <: AbstractXoroshiro128{T}
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of two `UInt64`s, or an `Integer` which will be automatically convert to
an `UInt128` number.
"""
    @doc doc_xoroshiro128("Xoroshiro128") Xoroshiro128
    @doc doc_xoroshiro128("Xoroshiro128Star") Xoroshiro128Star
    @doc doc_xoroshiro128("Xoroshiro128Plus") Xoroshiro128Plus
end
