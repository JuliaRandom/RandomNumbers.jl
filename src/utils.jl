# import Random
import Random: RandomDevice
import RandomNumbers: AbstractRNG

"""
```julia
gen_seed(T[, n])
```

Generate a tuple of `n` truly random numbers in type `T`. If `n` is missing, return only one number.
The "truly" random numbers are provided by the random device of system. See
[`Random.RandomDevice`](https://github.com/JuliaLang/julia/blob/master/base/random.jl#L29).

# Examples
```julia
julia> RandomNumbers.gen_seed(UInt64, 2)  # The output should probably be different on different computers.
(0x26aa3fe5e306f725,0x7b9dc3c227d8acc9)

julia> RandomNumbers.gen_seed(UInt32)
0x9ba60fdc
```
"""
gen_seed(::Type{T}) where {T<:Number} = rand(RandomDevice(), T)
gen_seed(::Type{T}, n) where {T<:Number} = Tuple(rand(RandomDevice(), T, n))

"Get the original output type of a RNG."
@inline output_type(::AbstractRNG{T}) where {T} = T

# For 1.0
# Random.gentype(::Type{T}) where {T<:AbstractRNG} = output_type(T)

"Get the default seed type of a RNG."
@inline seed_type(r::AbstractRNG) = seed_type(typeof(r))

@inline split_uint(x::UInt128, ::Type{UInt64}=UInt64) = (x % UInt64, (x >> 64) % UInt64)
@inline split_uint(x::UInt128, ::Type{UInt32}) = (x % UInt32, (x >> 32) % UInt32,
    (x >> 64) % UInt32, (x >> 96) % UInt32)
@inline split_uint(x::UInt64, ::Type{UInt32}=UInt32) = (x % UInt32, (x >> 32) % UInt32)
@inline union_uint(x::NTuple{2, UInt32}) = unsafe_load(Ptr{UInt64}(pointer(collect(x))), 1)
@inline union_uint(x::NTuple{2, UInt64}) = unsafe_load(Ptr{UInt128}(pointer(collect(x))), 1)
@inline union_uint(x::NTuple{4, UInt32}) = unsafe_load(Ptr{UInt128}(pointer(collect(x))), 1)

@inline function unsafe_copyto!(r1::R, r2::R, ::Type{T}, len) where {R, T}
    arr1 = Ptr{T}(pointer_from_objref(r1))
    arr2 = Ptr{T}(pointer_from_objref(r2))
    for i = 1:len
        unsafe_store!(arr1, unsafe_load(arr2, i), i)
    end
    r1
end

@inline function unsafe_compare(r1::R, r2::R, ::Type{T}, len) where {R, T}
    arr1 = Ptr{T}(pointer_from_objref(r1))
    arr2 = Ptr{T}(pointer_from_objref(r2))
    all(unsafe_load(arr1, i) == unsafe_load(arr2, i) for i in 1:len)
end
