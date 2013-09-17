from strutils import startsWith
from pegs import parsePeg, findAll, TPeg


type
    Token = ref object {.inheritable.}
        name: string
        content: string
        line: int
    TextToken = ref object of Token
    TagToken = ref object of Token
    FilterToken = ref object of Token
    CommentToken = ref object of Token


iterator tokenize(content: string): Token =
    let grammar = parsePeg("""
        grammar <- tag
        tag <- "{%" @ "%}" / comment
        comment <- "{#" @ "#}" / filter
        filter <- "{{" @ "}}" / text
        text <- [^{]+ &"{" / .+
""", "template.html", line=1, col=0)

    for match in findAll(content, grammar, start=0):
        if match.startsWith("{%"):
            yield TagToken(name: "tag", content: match, line: 0)
        elif match.startsWith("{#"):
            yield CommentToken(name: "comment", content: match, line: 0)
        elif match.startsWith("{{"):
            yield FilterToken(name: "filter", content: match, line: 0)
        else:
            yield TextToken(name: "text", content: match, line: 0)


method parse(token: Token) =
    quit("to override!")


method parse(token: TextToken) =
    echo("Text: " & token.content)


method parse(token: TagToken) =
    echo("Tag: " & token.content)


method parse(token: FilterToken) =
    echo("Filter: " & token.content)


method parse(token: CommentToken) =
    echo("Comment: " & token.content)


for token in tokenize("""<ul>
    {% for x in list %}
        <li>{{ x }}</li>
    {% endfor %
</ul>"""):
    parse(token)
