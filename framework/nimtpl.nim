from strutils import startsWith, `%`
from re import re, split, escapeRe, findBounds


const
    blockTagStart = "{%"
    blockTagEnd = "%}"
    commentTagStart = "{#"
    commentTagEnd = "#}"
    variableTagStart = "{{"
    variableTagEnd = "}}"


let regexTag = re("($1.*?$2|$3.*?$4|$5.*?$6)" % [
        escapeRe(blockTagStart), escapeRe(blockTagEnd),
        escapeRe(commentTagStart), escapeRe(commentTagEnd),
        escapeRe(variableTagStart), escapeRe(variableTagEnd)])


type
    Token = ref object {.inheritable.}
        content: string
        line: int
    TextToken = ref object of Token
    BlockToken = ref object of Token
    CommentToken = ref object of Token
    VariableToken = ref object of Token


iterator tokenize(templateString: string): Token =
    discard """
    Returns a list of tokens from a given templateString
    """
    var
        matches: array[0..1, tuple[first, last: int]]
        start: int
        slice: string

    while True:
        if findBounds(templateString, regexTag, matches, start).first < 0:
            break
        else:
            for match in matches:
                if match.last > 0:
                    if match.first > 0:
                        slice = templateString[start..match.first - 1]
                        yield TextToken(content: slice, line: 0)
                    slice = templateString[match.first..match.last]
                    if slice.startsWith("{%"):
                        yield BlockToken(content: slice, line: 0)
                    elif slice.startsWith("{#"):
                        yield CommentToken(content: slice, line: 0)
                    else:
                        yield VariableToken(content: slice, line: 0)
                    start = match.last + 1


method parse(token: Token) =
    quit("to override!")


method parse(token: TextToken) =
    echo("Text: " & token.content)


method parse(token: BlockToken) =
    echo("Block: " & token.content)


method parse(token: VariableToken) =
    echo("Variable: " & token.content)


method parse(token: CommentToken) =
    echo("Comment: " & token.content)


for token in tokenize("""<ul>
    {% for x in list %}
        <li>{{ x }}</li>
    {% endfor %}
</ul>"""):
    parse(token)
