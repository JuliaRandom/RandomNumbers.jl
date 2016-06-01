using RNG.PCG

let pcg_list = include("pcg_list.jl")
    for (state_type_t, uint_type, method_symbol, return_type, rand_value, rand_bounded_value) in pcg_list
        state_type = eval(Symbol("PCGState$state_type_t"))
        method = Val{method_symbol}
        r = PermutedCongruentialGenerator(state_type, method, uint_type)
        if state_type_t == :Setseq
            srand(r, (12345 % uint_type, 54321 % uint_type))
        else
            srand(r, 123456 % uint_type)
        end

        # Unique state won't produce the same sequence every time.
        if state_type_t != :Unique
            @test rand_value == rand(r)
            @test rand_bounded_value == rand_bounded(r, 200701281 % return_type)
        else
            rand(r)
            rand_bounded(r, 200701281 % return_type)
        end
    end
end
