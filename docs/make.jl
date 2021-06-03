using Documenter, RandomNumbers, DocumenterMarkdown
import Random123

DocMeta.setdocmeta!(RandomNumbers, :DocTestSetup, quote
    using RandomNumbers
    using RandomNumbers.PCG
    using RandomNumbers.Xorshifts
    using RandomNumbers.MersenneTwisters
    using Random123
    using Test
end; recursive=true)

makedocs(
    modules = [RandomNumbers],
    format = Markdown()
)

deploydocs(
    repo   = "github.com/JuliaRandom/RandomNumbers.jl.git",
    deps   = Deps.pip("pygments", "mkdocs", "python-markdown-math", "mkdocs-material"),
    make = () -> run(`mkdocs build`),
    target = "site"
)
