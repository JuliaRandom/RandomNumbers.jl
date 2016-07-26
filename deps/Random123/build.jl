function build()
    p = pwd()
    cd(Pkg.dir("RNG/deps/Random123"))
    run(`make`)
    cd(p)
end

function have_aesni()
    if VERSION < v"0.5-"
        return false
    end
    ecx = Base.llvmcall(
        """%1 = call { i32, i32, i32, i32 } asm "xchgq  %rbx,\${1:q}\\0A  cpuid\\0A  xchgq  %rbx,\${1:q}",
        "={ax},=r,={cx},={dx},0,~{dirflag},~{fpsr},~{flags}"(i32 1)
        %2 = extractvalue { i32, i32, i32, i32 } %1, 2
        ret i32 %2""", UInt32, Tuple{})
    (ecx >> 25) & 1 == 1
end

check_compiler() = success(`gcc --version`)

if have_aesni() && check_compiler()
    build()
else
    warn("AES-NI will not be compiled.")
end
