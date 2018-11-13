using Documenter, RandomNumbers, DocumenterMarkdown
import Random

makedocs(
#    modules = [RandomNumbers],
    format = :markdown
)

deploydocs(
    repo   = "github.com/sunoru/RandomNumbers.jl.git",
    deps   = Deps.pip("pygments", "mkdocs", "python-markdown-math", "mkdocs-material"),
    make = () -> run(`mkdocs build`),
    target = "site"
)
