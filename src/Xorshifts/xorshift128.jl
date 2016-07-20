import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift128", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name{T<:Union{UInt32, UInt64}} <: AbstractRNG{T}
            x::UInt64
            y::UInt64
            $((star || plus) ? :(result::UInt64) : nothing)
            flag::Bool
            function $rng_name(seed::UInt128)
                $((star || plus) ? :(r = new{T}(0, 0, 0, false)) : :(r = new{T}(0, 0, false)))
                srand(r, seed)
                r
            end
        end

        $rng_name{T<:Union{UInt32, UInt64}}(::Type{T},
            seed::Integer=gen_seed(UInt128)) = $rng_name{T}(seed % UInt128)

        $rng_name(seed::Integer=gen_seed(UInt128)) = $rng_name(UInt64, seed)

        @inline function xorshift_next(r::$rng_name)
            t = r.x $ r.x << 23
            r.x = r.y
            r.y = t $ (t >> 3) $ r.y $ (r.y >> 24)
            $(star ? :(r.result = r.y * 2685821657736338717) :
              plus ? :(r.result = r.y + r.x) : :(r.y))
        end

        @inline function srand(r::$rng_name, seed::Integer=gen_seed(UInt64))
            r.x = seed % UInt64
            r.y = (seed >> 64) % UInt64
            r.flag = false
            xorshift_next(r)
            r
        end

        @inline function rand(r::$rng_name{UInt64}, ::Type{UInt64})
            xorshift_next(r)
        end

        @inline function rand(r::$rng_name{UInt32}, ::Type{UInt32})
            if r.flag
                r.flag = false
                return ($((star || plus) ? :(r.result) : :(r.y)) >> 32) % UInt32
            else
                xorshift_next(r)
                r.flag = true
                return $((star || plus) ? :(r.result) : :(r.y)) % UInt32
            end
        end
    end
end
