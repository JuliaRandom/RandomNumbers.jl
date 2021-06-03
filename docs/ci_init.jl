using Pkg
Pkg.instantiate()
Pkg.develop(PackageSpec(path=pwd()))
Pkg.develop(PackageSpec(url="https://github.com/JuliaRandom/Random123.jl"))
Pkg.build("Random123")
Pkg.build("RandomNumbers")
