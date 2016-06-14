import Base.Random: rand
abstract AbstractRNG{T<:Number} <: Base.Random.AbstractRNG

for (output_type, scale) in (
    (UInt8, 3.906250000000000000000000000000e-03),
    (UInt16, 1.525878906250000000000000000000e-05),
    (UInt32, 2.328306436538696289062500000000e-10),
    (UInt64, 5.421010862427522170037264004350e-20),
    (UInt128, 2.938735877055718769921841343056e-39)
)
    @eval @inline function rand(rng::AbstractRNG{$output_type})
        (rand(rng, $output_type)::$output_type * $scale)::Float64
    end
end
