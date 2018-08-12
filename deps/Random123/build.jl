function build()
    p = pwd()
    cd(dirname(@__FILE__))
    if Sys.iswindows()
        try
            run(`mingw32-make`)
        catch
            if Sys.WORD_SIZE == 32
                url = "https://github.com/sunoru/RandomNumbers.jl/releases/download/deplib-0.1/librandom123-32.dll"
            else
                url = "https://github.com/sunoru/RandomNumbers.jl/releases/download/deplib-0.1/librandom123.dll"
            end
            info("You don't have MinGW32 installed, so now downloading the library binary from github.")
            download(url, "librandom123.dll")
        end
    elseif Sys.isbsd() && !Sys.isapple()  # e.g. FreeBSD
        run(`gmake`)
    else
        run(`make`)
    end
    cd(p)
end

function have_aesni()
    @static if VERSION < v"0.5-" || Sys.WORD_SIZE != 64
        return false
    else
        ecx = Base.llvmcall(
            """%1 = call { i32, i32, i32, i32 } asm "xchgq  %rbx,\${1:q}\\0A  cpuid\\0A  xchgq  %rbx,\${1:q}",
            "={ax},=r,={cx},={dx},0,~{dirflag},~{fpsr},~{flags}"(i32 1)
            %2 = extractvalue { i32, i32, i32, i32 } %1, 2
            ret i32 %2""", UInt32, Tuple{})
        return (ecx >> 25) & 1 == 1
    end
end

check_compiler() = Sys.iswindows() ? true : success(`gcc --version`)

if have_aesni() && check_compiler()
    build()
else
    warn("AES-NI will not be compiled.")
end
