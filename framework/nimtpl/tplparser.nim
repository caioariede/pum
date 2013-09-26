from strutils import strip

from framework/nimtpl/tpltokenizer import Token, BlockToken, VariableToken,
    CommentToken, TextToken

from framework/nimtpl/tplcontext import Context, getContextVariable


type
    RenderedTag* = tuple
        index: int
        content: string
    TParser = proc(index: int, tokens: seq[Token],
                   tags: seq[Tag], ctx: var Context): RenderedTag {.cdecl.}
    Tag* = tuple
        name: string
        fn: TParser


proc parseVariable(content: string, ctx: var Context): string =
    let variableName = strip(content[2..content.len-3])
    return getContextVariable(ctx, variableName).justStr


iterator parse*(tokens: seq[Token], tags: seq[Tag], ctx: var Context,
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


iterator parse*(tokens: seq[Token], tags: seq[Tag], ctx: var Context): string =
    for output in parse(tokens, tags, ctx, 0):
        yield output.content
