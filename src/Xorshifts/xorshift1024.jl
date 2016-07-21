import Base.Random: rand, srand
import RNG: AbstractRNG, gen_seed

for (star, plus) in (
        (false, false),
        (false, true),
        (true, false),
    )
    rng_name = Symbol(string("Xorshift1024", star ? "Star" : plus ? "Plus" :""))
    @eval begin
        type $rng_name{T<:Union{UInt32, UInt64}} <: AbstractRNG{T}
            s0::UInt64
            s1::UInt64
            s2::UInt64
            s3::UInt64
            s4::UInt64
            s5::UInt64
            s6::UInt64
            s7::UInt64
            s8::UInt64
            s9::UInt64
            s10::UInt64
            s11::UInt64
            s12::UInt64
            s13::UInt64
            s14::UInt64
            s15::UInt64
            p::Int
            $((star || plus) ? :(result::UInt64) : nothing)
            flag::Bool
            function $rng_name(seed::Tuple{[UInt64 for i in 1:16]...}=gen_seed(UInt64, 16))
                $((star || plus) ? :(r = new{T}(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)) :
                    :(r = new{T}(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)))
                srand(r, seed)
                r
            end
        end
    end # if no another @eval there's a weird error: type definition not allowed inside a local scope
    @eval begin
        $rng_name{T<:Union{UInt32, UInt64}}(::Type{T},
            seed::Tuple{[Integer for i in 1:16]...}=gen_seed(UInt64, 16)) = $rng_name{T}(map(x->x % UInt64, seed))

        function $rng_name{T<:Union{UInt32, UInt64}}(::Type{T}, seed::Integer...)
            l = length(seed)
            @assert 0 ≤ l ≤ 16
            if l == 0
                return $rng_name(T, gen_seed(UInt64, 16))
            end
            $rng_name(T, (seed..., [i for i in l+1:16]...))
        end

        $rng_name(seed::Tuple{[Integer for i in 1:16]...}) = $rng_name(UInt64, seed)

        $rng_name(seed::Integer...) = $rng_name(UInt64, seed...)

        @inline function xorshift_next(r::$rng_name)
            p = r.p
            s0 = getfield(r, p + 1)
            p = (p + 1) % 16
            s1 = getfield(r, p + 1)
            s1 $= s1 << 31
            s1 $= s1 >> 11
            s1 $= s0 >> 30
            s1 $= s0
            unsafe_store!(Ptr{UInt64}(pointer_from_objref(r)), s1, p + 1)
            r.p = p
            $(star ? :(r.result = s1 * 2685821657736338717) :
              plus ? :(r.result = s1 + s0) : :s1)
        end

        @inline function srand(r::$rng_name, seed::Tuple{[Integer for i in 1:16]...})
            for i in 1:16
                unsafe_store!(Ptr{UInt64}(pointer_from_objref(r)), seed[i], i)
            end
            r.p = 0
            r.flag = false
            for i in 1:16
                xorshift_next(r)
            end
            r
        end

        @inline function srand(r::$rng_name, seed::Integer...)
            l = length(seed)
            @assert 0 ≤ l ≤ 16 
            if l == 0
                srand(r, gen_seed(UInt64, 16))
            end
            srand(r, (seed..., [i for i in l+1:16]...))
        end

        @inline function rand(r::$rng_name{UInt64}, ::Type{UInt64})
            xorshift_next(r)
        end

        @inline function rand(r::$rng_name{UInt32}, ::Type{UInt32})
            if r.flag
                r.flag = false
                return ($((star || plus) ? :(r.result) : :(getfield(r, r.p + 1))) >> 32) % UInt32
            else
                xorshift_next(r)
                r.flag = true
                return $((star || plus) ? :(r.result) : :(getfield(r, r.p + 1))) % UInt32
            end
        end
    end
end
