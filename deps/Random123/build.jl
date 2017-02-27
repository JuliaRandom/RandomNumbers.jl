function build()
    p = pwd()
    cd(dirname(@__FILE__))
    if is_windows()
        try
            run(`mingw32-make`)
        catch
            if sizeof(Int) == 4
                url = "https://github.com/sunoru/RandomNumbers.jl/releases/download/deplib-0.1/librandom123-32.dll"
            else
                url = "https://github.com/sunoru/RandomNumbers.jl/releases/download/deplib-0.1/librandom123.dll"
            end
            info("You don't have MinGW32 installed, so now downloading the library binary from github.")
            download(url, "librandom123.dll")
        end
    else
        run(`make`)
    end
    cd(p)
end

function have_aesni()
    if VERSION < v"0.5-" || sizeof(Int) != 8
        return false
    end
    @eval begin # use `@eval` to avoid errors while compiling (with julia 0.4)
        ecx = Base.llvmcall(
        """%1 = call { i32, i32, i32, i32 } asm "xchgq  %rbx,\${1:q}\\0A  cpuid\\0A  xchgq  %rbx,\${1:q}",
        "={ax},=r,={cx},={dx},0,~{dirflag},~{fpsr},~{flags}"(i32 1)
        %2 = extractvalue { i32, i32, i32, i32 } %1, 2
        ret i32 %2""", UInt32, Tuple{})
        (ecx >> 25) & 1 == 1
    end
end

check_compiler() = is_windows() ? true : success(`gcc --version`)

if have_aesni() && check_compiler()
    build()
else
    warn("AES-NI will not be compiled.")
end
