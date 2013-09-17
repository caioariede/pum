from strutils import startsWith
from re import findBounds, re


type
    Token = ref object {.inheritable.}
        name: string
        content: string
        line: int
    TextToken = ref object of Token
    FilterToken = ref object of Token
    CommentToken = ref object of Token


iterator tokenize(content: string): Token =
    var matches: array[0..re.MaxSubpatterns-1, tuple[first, last: int]]

    discard findBounds(content, re"(\{[%#\{][^\}]+[\}#%]\})", matches, 0)

    for i in 0.. < len(matches):
        let first = matches[i].first
        let last = matches[i].last

        if last > 0:
            let subcontent = content.substr(first, last)
            var token: string

            if subcontent.startsWith("{{"):
                yield FilterToken(
                    name: "filter", content: subcontent, line: 0)
            elif subcontent.startsWith("{#"):
                yield CommentToken(
                    name: "comment", content: subcontent, line: 0)


method parse(token: Token) =
    quit("to override!")


method parse(token: TextToken) =
    echo("Text: " & token.content)


method parse(token: FilterToken) =
    echo("Filter: " & token.content)


method parse(token: CommentToken) =
    echo("Comment: " & token.content)


for token in tokenize("Hello {{ world }}"):
    parse(token)
