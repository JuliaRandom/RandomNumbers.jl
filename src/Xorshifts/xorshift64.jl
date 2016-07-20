import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

for star in (false, true)
    rng_name = Symbol(string("Xorshift64", star ? "Star" : ""))
    @eval begin
        type $rng_name{T<:Union{UInt32, UInt64}} <: AbstractRNG{T}
            x::UInt64
            $(star ? :(result::UInt64) : nothing)
            flag::Bool
            function $rng_name(seed::UInt64)
                $(star ? :(r = new{T}(0, 0, false)) : :(r = new{T}(0, false)))
                srand(r, seed)
                r
            end
        end

        $rng_name{T<:Union{UInt32, UInt64}}(::Type{T},
            seed::Integer=gen_seed(UInt64)) = $rng_name{T}(seed % UInt64)

        $rng_name(seed::Integer=gen_seed(UInt64)) = $rng_name(UInt64, seed)

        @inline function xorshift_next(r::$rng_name)
            r.x $= r.x << 18
            r.x $= r.x >> 31
            r.x $= r.x << 11
            $(star ? :(r.result = r.x * 2685821657736338717) : :(r.x))
        end

        @inline function srand(r::$rng_name, seed::Integer=gen_seed(UInt64))
            r.x = seed % UInt64
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
                return ($(star ? :(r.result) : :(r.x)) >> 32) % UInt32
            else
                xorshift_next(r)
                r.flag = true
                return $(star ? :(r.result) : :(r.x)) % UInt32
            end
        end
    end
end
