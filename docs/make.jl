using Documenter, RandomNumbers

makedocs()

deploydocs(
    deps   = Deps.pip("pygments", "mkdocs", "python-markdown-math", "mkdocs-material"),
    repo   = "github.com/sunoru/RandomNumbers.jl.git",
    osname = "linux"
)
