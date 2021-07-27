using Test

if !@isdefined RandomNumbers
    include("../common.jl")
end

@testset "PCG" begin

    using RandomNumbers.PCG

    @info "Testing PCG"
    stdout_ = stdout
    pwd_ = pwd()
    cd(dirname(@__FILE__))
    rm("./actual"; force=true, recursive=true)
    mkpath("./actual")

    numbers = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K']
    suit = ['h', 'c', 'd', 's'];

    PCGStateOneseq()
    PCGStateOneseq(UInt32)
    PCGStateMCG()
    PCGStateMCG(UInt32)
    PCGStateSetseq()
    PCGStateSetseq(UInt32)
    PCGStateUnique()
    PCGStateUnique(UInt32)

    for (state_type_t, uint_type, method_symbol, return_type) in PCG_LIST
        state_type = eval(Symbol("PCGState$state_type_t"))
        method = Val{method_symbol}

        state_type(method)
        state_type(return_type, method)

        if state_type_t == :Setseq
            r = state_type(return_type, method, (42, 54))
            @test seed_type(r) == NTuple{2, uint_type}
        else
            r = state_type(return_type, method, 42)
            @test seed_type(r) == uint_type
        end
        @test copyto!(copy(r), r) == r

        # Unique state won't produce the same sequence every time.
        if state_type_t == :Unique
            t = rand(r, return_type)
            advance!(r, -1)
            @test t == rand(r, return_type)
            bounded_rand(r, 200701281 % return_type)
            continue
        end
        outfile = open(string(
            "./actual/check-$(lowercase("$state_type_t"))-$(sizeof(uint_type) << 3)-",
            "$(replace(lowercase("$method_symbol"), "_" => "-"))-$(sizeof(return_type) << 3).out"
        ), "w")
        redirect_stdout(outfile)
        for round in 1:5
            @printf "Round %d:\n" round
            @printf "%4dbit:" (sizeof(return_type) << 3)
            values = 10
            wrap = 10
            printstr = " 0x%04x"
            if return_type == UInt8
                values, wrap, printstr = 14, 14, " 0x%02x"
            elseif return_type == UInt32
                values, wrap, printstr = 6, 6, " 0x%08x"
            elseif return_type == UInt64
                values, wrap, printstr = 6, 3, " 0x%016llx"
            elseif return_type == UInt128
                values, wrap, printstr = 6, 2, " 0x%032llx"
            end

            for i in 1:values
                if i > 1 && (i - 1) % wrap == 0
                    @printf "\n\t"
                end
                value = rand(r, return_type)
                @eval @printf $printstr $value
            end
            @printf "\n"

            @printf "  Again:"
            advance!(r, -(values % uint_type))
            for i in 1:values
                if i > 1 && (i - 1) % wrap == 0
                    @printf "\n\t"
                end
                value = rand(r, return_type)
                @eval @printf $printstr $value
            end
            @printf "\n"

            @printf "  Coins: "
            for i in 1:65
                @printf "%c" (bounded_rand(r, 2 % return_type) == 1 ? 'H' : 'T')
            end
            @printf "\n"

            @printf "  Rolls:"
            for i in 1:33
                @printf " %d" (UInt32(bounded_rand(r, 6 % return_type)) + 1);
            end
            @printf "\n"

            cards = collect(0:51)
            for i = 52:-1:2
                chosen = bounded_rand(r, i % return_type)
                card = cards[chosen+1]
                cards[chosen+1] = cards[i]
                cards[i] = card
            end

            @printf "  Cards:"
            for i = 0:51
                @printf " %c%c" numbers[(cards[i+1] ÷ 4)+1] suit[(cards[i+1] % 4)+1]
                if (i+1) % 22 == 0
                    @printf "\n\t"
                end
            end
            @printf "\n"

            @printf "\n"
        end
        close(outfile)
    end
    redirect_stdout(stdout_)

    compare_dirs("expected", "actual")

    # Package content should not be modified.
    rm("./actual"; force=true, recursive=true)

    cd(pwd_)

end
