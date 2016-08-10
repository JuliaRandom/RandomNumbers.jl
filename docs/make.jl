using Documenter, RNG

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math", "mkdocs-material"),
    repo   = "github.com/sunoru/RNG.jl.git",
    osname = "linux"
)
