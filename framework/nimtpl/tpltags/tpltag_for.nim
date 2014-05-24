from strutils import find, strip

from framework.nimtpl.tpltokenizer import Token, BlockToken, getTokensUntil
from framework.nimtpl.tplparser import Tag, RenderedTag, parse
from framework.nimtpl.tplcontext import Context, getContextVariable,
    setContextVariable, remContextVariable
from framework.nimtpl.tplexceptions import ETemplateSyntaxError


proc parseFor(content: string): tuple[counter: string, variable: string] =
    var
        forPos = content.find("for")
        afterFor = strip(content[forPos+3..content.len-3])
        inPos = afterFor.find(" in ")
        counterName = strip(afterFor[0..inPos])
        variableName = strip(afterFor[inPos+3..afterFor.len])

    return (counter: counterName, variable: variableName)


proc tagFor*(index: int, tokens: seq[Token], tags: seq[Tag],
               ctx: var Context): RenderedTag {.cdecl.} =
    var
        newIndex = 0
        repeatedContent = ""
        nextTokens: seq[Token]

    let forToken = cast[BlockToken](tokens[index])
    let tagFor = parseFor(forToken.content)
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
        var exc: ref ETemplateSyntaxError = newException(
            ETemplateSyntaxError,
            "Expected {% endfor %} not found.")
        exc.templateLine = forToken.line
        raise exc

    return (index: newIndex, content: repeatedContent)
