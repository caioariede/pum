from strutils import startsWith, countLines, find, strip, `%`
from re import re, split, escapeRe, findBounds

from framework/nimtpl/tplcontext import Context, getContextVariable,
    setContextVariable, remContextVariable, TContextValue, ctxVal


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
    TParser = proc(index: int, tokens: seq[Token],
                   tags: seq[Tag], ctx: var Context): RenderedTag {.cdecl.}
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


proc parseVariable(content: string, ctx: var Context): string =
    let variableName = strip(content[2..content.len-3])
    return getContextVariable(ctx, variableName).justStr


proc getTokensUntil(tokens: seq[Token], start: int,
                    until: seq[string]): seq[Token] =
    var tokensUntil: seq[Token] = @[]
    block parsing:
        for token in tokens[start..high(tokens)]:
            add(tokensUntil, token)
            if token of BlockToken:
                let blockToken = cast[BlockToken](token)
                if blockToken.name in until:
                    break parsing
    return tokensUntil


iterator parse(tokens: seq[Token], tags: seq[Tag], ctx: var Context,
               start: int): RenderedTag =
    var
        output: RenderedTag
        token: Token
        index = start

    while index < tokens.len:
        token = tokens[index]
        inc(index)
        if token of BlockToken:
            let blockToken = cast[BlockToken](token)
            for tag in tags:
                if tag.name == blockToken.name:
                    output = tag.fn(index - 1, tokens, tags, ctx)
                    index = output.index
                    yield output
                    break
        elif token of VariableToken:
            yield (index: index + 1,
                   content: parseVariable(token.content, ctx))
        elif token of CommentToken:
            yield (index: index + 1, content: token.content)
        elif token of TextToken:
            yield (index: index + 1, content: token.content)


iterator parse(tokens: seq[Token], tags: seq[Tag], ctx: var Context): string =
    for output in parse(tokens, tags, ctx, 0):
        yield output.content


proc parseFor(content: string): tuple[counter: string, variable: string] =
    var
        forPos = content.find("for")
        afterFor = strip(content[forPos+3..content.len-3])
        inPos = afterFor.find(" in ")
        counterName = strip(afterFor[0..inPos])
        variableName = strip(afterFor[inPos+3..afterFor.len])

    return (counter: counterName, variable: variableName)


proc tagFor(index: int, tokens: seq[Token], tags: seq[Tag],
               ctx: var Context): RenderedTag {.cdecl.} =
    var
        newIndex = 0
        repeatedContent = ""
        nextTokens: seq[Token]

    let tagFor = parseFor(tokens[index].content)
    let counterName = tagFor.counter
    let variable = getContextVariable(ctx, tagFor.variable)
    let variableValue = variable.seqStr

    nextTokens = getTokensUntil(tokens, index + 1, @["endfor", "empty"])
    newIndex = index + nextTokens.len

    if variableValue.len > 0:
        # Consume the for contents until "endfor" or "empty"
        for value in variable.seqStr:
            setContextVariable[string](ctx, counterName, value)

            for output in parse(nextTokens, tags, ctx, 0):
                repeatedContent = repeatedContent & output.content

            remContextVariable(ctx, counterName)

    # nextToken must be "endfor" or "empty"
    var nextToken = tokens[newIndex]

    if nextToken of BlockToken:
        # In case next token is {% empty %}
        let nextBlockToken = cast[BlockToken](nextToken)
        if nextBlockToken.name == "empty":
            nextTokens = getTokensUntil(tokens, newIndex + 1, @["endfor"])
            newIndex = newIndex + nextTokens.len
            nextToken = tokens[newIndex]
            if variableValue.len == 0:
                for output in parse(nextTokens, tags, ctx, 0):
                    repeatedContent = repeatedContent & output.content

    var endForFound = false

    if nextToken of BlockToken:
        # Check if {% endfor %} is correctly placed
        let nextBlockToken = cast[BlockToken](nextToken)
        if nextBlockToken.name == "endfor":
            endForFound = true

    if not endForFound:
        quit "{% endfor %} expected"

    return (index: newIndex, content: repeatedContent)


proc renderTemplate*(content: string, ctx: var Context): string =
    let tokens = tokenize(content)
    let tags: seq[Tag] = @[
        ("for", tagFor),
    ]

    result = ""

    for output in parse(tokens, tags, ctx):
        result = result & output


if isMainModule:
    let tokens = tokenize("""<ul>
        {% for x in list %}
            <li>{{ x }}</li>
        {% empty %}
            <li>empty</li>
        {% endfor %}
    </ul>""")

    let tags: seq[Tag] = @[
        ("for", tagFor),
    ]

    var ctx = @[
        ctxVal[seq[string]]("list", @[]),
    ]

    for output in parse(tokens, tags, ctx):
        echo(output)
