using Documenter, RandomNumbers, DocumenterMarkdown
import Random123

makedocs(
    modules = [RandomNumbers],
    format = :markdown
)

deploydocs(
    repo   = "github.com/sunoru/RandomNumbers.jl.git",
    deps   = Deps.pip("pygments", "mkdocs==0.17.5", "python-markdown-math", "mkdocs-material==2.9.4"),
    make = () -> run(`mkdocs build`),
    target = "site"
)
