"Do one iteration and get the current value of a Xorshift RNG object."
xorshift_next

let doc_xorshift64(r) = """
```julia
$r <: AbstractXorshift64
$r([seed])
```

$r RNG. The `seed` can be an `UInt64`,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xorshift64("Xorshift64") Xorshift64
    @doc doc_xorshift64("Xorshift64Star") Xorshift64Star
end
@deprecate Xorshift64 Xoshiro256StarStar
@deprecate Xorshift64Star Xoshiro256StarStar

let doc_xorshift128(r) = """
```julia
$r <: AbstractXorshift128
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of two `UInt64`s,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xorshift128("Xorshift128") Xorshift128
    @doc doc_xorshift128("Xorshift128Star") Xorshift128Star
    @doc doc_xorshift128("Xorshift128Plus") Xorshift128Plus
end
@deprecate Xorshift128 Xoshiro256StarStar
@deprecate Xorshift128Star Xoshiro256StarStar
@deprecate Xorshift128Plus Xoshiro256StarStar

let doc_xorshift1024(r) = """
```julia
$r <: AbstractXorshift1024
$r([seed...])
```

$r RNG. The `seed` can be a `Tuple` of 16 `UInt64`s,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xorshift1024("Xorshift1024") Xorshift1024
    @doc doc_xorshift1024("Xorshift1024Star") Xorshift1024Star
    @doc doc_xorshift1024("Xorshift1024Plus") Xorshift1024Plus
end
@deprecate Xorshift1024 Xoshiro256StarStar
@deprecate Xorshift1024Star Xoshiro256StarStar
@deprecate Xorshift1024Plus Xoshiro256StarStar
# TODO: implement Xoroshiro1024Star / Xoroshiro1024StarStar and Xoroshiro512StarStar / Xoroshiro512Plus

let doc_xoroshiro64(r) = """
```julia
$r <: AbstractXoroshiro64
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of two `UInt32`s,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xoroshiro64("Xoroshiro64Star") Xoroshiro64Star
    @doc doc_xoroshiro64("Xoroshiro64StarStar") Xoroshiro64StarStar
end


let doc_xoroshiro128(r) = """
```julia
$r <: AbstractXoroshiro128
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of two `UInt64`s,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xoroshiro128("Xoroshiro128") Xoroshiro128
    @doc doc_xoroshiro128("Xoroshiro128Star") Xoroshiro128Star
    @doc doc_xoroshiro128("Xoroshiro128Plus") Xoroshiro128Plus
    @doc doc_xoroshiro128("Xoroshiro128StarStar") Xoroshiro128StarStar
end
@deprecate Xoroshiro128 Xoroshiro128Plus
@deprecate Xoroshiro128Star Xoroshiro128StarStar


let doc_xoshiro128(r) = """
```julia
$r <: AbstractXoshiro128
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of four `UInt32`s, a `Tuple` of two,
or an `Integer` which will be initialized with `SplitMix64`.
"""
    @doc doc_xoshiro128("Xoshiro128Plus") Xoshiro128Plus
    @doc doc_xoshiro128("Xoshiro128StarStar") Xoshiro128StarStar
end


let doc_xoshiro256(r) = """
```julia
$r <: AbstractXoshiro256
$r([seed])
```

$r RNG. The `seed` can be a `Tuple` of four `UInt64`s, or an `Integer` which will be automatically convert to
an `UInt64` number (and then is initialized with SplitMix64). Zero seeds are not acceptable.
"""
    @doc doc_xoshiro256("Xoshiro256Plus") Xoshiro256Plus
    @doc doc_xoshiro256("Xoshiro256StarStar") Xoshiro256StarStar
end
