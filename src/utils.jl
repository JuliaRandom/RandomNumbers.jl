
"""
```julia
gen_seed(T[, n])
```

Generate a tuple of `n` truly random numbers in type `T`. If `n` is missing, return only one number.
The "truly" random numbers are provided by the random device of system. See
[`Base.Random.RandomDevice`](https://github.com/JuliaLang/julia/blob/master/base/random.jl#L29).

# Examples
```julia
julia> gen_seed(UInt64, 2)  # The output should probably be different on different computers.
(0x26aa3fe5e306f725,0x7b9dc3c227d8acc9)

julia> gen_seed(UInt32)
0x9ba60fdc
```
"""
gen_seed{T<:Number}(::Type{T}) = rand(RandomDevice(), T)
gen_seed{T<:Number}(::Type{T}, n) = tuple(rand(RandomDevice(), T, n)...)
