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
    repo   = "github.com/sunoru/RandomNumbers.jl.git",
    deps   = Deps.pip("pygments", "mkdocs==0.17.5", "python-markdown-math", "mkdocs-material==2.9.4"),
    make = () -> run(`mkdocs build`),
    target = "site"
)
