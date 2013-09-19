from strutils import startsWith, countLines, find, `%`
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
        name: string
    CommentToken = ref object of Token
    VariableToken = ref object of Token


type
    RenderedTag = tuple
        index: int
        content: string
    TParser = proc(index: int, tokens: seq[Token], tags: seq[Tag]): RenderedTag {.closure.}
    Tag = tuple
        name: string
        fn: TParser


proc getBlockToken(slice: string, currentLine: int): BlockToken =
    var name = slice[3..slice.find({' '}, 3) - 1]
    return BlockToken(name: name, content: slice, line: currentLine)


proc getTextToken(slice: string, currentLine: int): TextToken =
    return TextToken(content: slice, line: currentLine)


proc getCommentToken(slice: string, currentLine: int): CommentToken =
    return CommentToken(content: slice, line: currentLine)


proc getVariableToken(slice: string, currentLine: int): VariableToken =
    return VariableToken(content: slice, line: currentLine)


proc tokenize(templateString: string): seq[Token] =
    discard """
    Returns a list of tokens from a given templateString
    """
    var
        matches: array[0..1, tuple[first, last: int]]
        start: int
        slice: string
        currentLine = 1
        tokens: seq[Token] = @[]
        templateSize = high(templateString)

    while True:
        if findBounds(templateString, regexTag, matches, start).first < 0:
            break
        else:
            for match in matches:
                if match.last > 0:
                    if match.first > 0:
                        # Match text before token found
                        slice = templateString[start..match.first - 1]
                        add(tokens, getTextToken(slice, currentLine))
                        currentLine += countLines(slice)
                    # Identify matched token
                    start = match.last + 1
                    slice = templateString[match.first..match.last]
                    currentLine += countLines(slice)
                    if slice.startsWith(blockTagStart):
                        add(tokens, getBlockToken(slice, currentLine))
                    elif slice.startsWith(commentTagStart):
                        add(tokens, getCommentToken(slice, currentLine))
                    elif slice.startsWith(variableTagStart):
                        add(tokens, getVariableToken(slice, currentLine))
                    else:
                        add(tokens, getTextToken(slice, currentLine))

    if start < templateSize:
        slice = templateString[start..templateSize]
        currentLine += countLines(slice)
        add(tokens, getTextToken(slice, currentLine))

    return tokens


iterator parse(tokens: seq[Token], tags: seq[Tag], start: int, until: seq[string]): RenderedTag =
    var
        output: RenderedTag
        token: Token
        index = start

    block parsing:
        while index < tokens.len:
            token = tokens[index]
            inc(index)
            if token of BlockToken:
                let blockToken = cast[BlockToken](token)
                for tag in tags:
                    if tag.name == blockToken.name:
                        output = tag.fn(index - 1, tokens, tags)
                        index = output.index
                        yield output
                        break
                # stops if needed
                if blockToken.name in until:
                    yield (index: index, content: "")
                    break parsing
            elif token of VariableToken:
                yield (index: index + 1, content: token.content)
            elif token of CommentToken:
                yield (index: index + 1, content: token.content)
            elif token of TextToken:
                yield (index: index + 1, content: token.content)


iterator parse(tokens: seq[Token], tags: seq[Tag]): string =
    for output in parse(tokens, tags, 0, @[]):
        yield output.content


proc parse_for(index: int, tokens: seq[Token], tags: seq[Tag]): RenderedTag {.closure.} =
    var
        newIndex = index + 1
        content = ""
        repeatedContent = ""

    for output in parse(tokens, tags, newIndex, @["endfor", "empty"]):
        content = content & output.content
        newIndex = output.index

    for i in [1, 2, 3]:
        repeatedContent = repeatedContent & content

    return (index: newIndex, content: repeatedContent)


let tokens = tokenize("""<ul>
    {% for x in list %}
        <li>{{ x }}</li>
    {% endfor %}
</ul>""")

let tags: seq[Tag] = @[
    ("for", parse_for),
]

for output in parse(tokens, tags):
    echo(output)
