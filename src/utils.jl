gen_seed{T<:Number}(seed_type::Type{T}) = rand(RandomDevice(), seed_type)
gen_seed{T<:Number}(seed_type::Type{T}, n) = tuple(rand(RandomDevice(), seed_type, n)...)
