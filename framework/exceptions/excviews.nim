from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse
from framework/nimtpl/tplcontext import addCtx, initContext
from framework/nimtpl/tplexceptions import ETemplateSyntaxError
from framework/nimtpl/tplutils import getTemplateLinesAround

from strutils import strip, splitLines


method exceptionView*(request: PRequest,
                      exc: ref E_Base): PResponse {.cdecl.} =
    var ctx = initContext()
    
    addCtx[string](ctx, "message", exc.msg)

    return PTemplateResponse(template_name: "framework/templates/error.html",
                             context: ctx)


method exceptionView*(request: PRequest,
                      exc: ref ETemplateSyntaxError): PResponse {.cdecl.} =
    let templateLinesAround = getTemplateLinesAround(exc.templateName,
                                                     exc.templateLine, 5)

    var stackTraceLines = getStackTrace(exc).strip().splitLines()
    var ctx = initContext()

    stackTraceLines = stackTraceLines[1..high(stackTraceLines)]

    add(stackTraceLines, exc.templateName & "(" & $exc.templateLine & ")")

    addCtx[string](ctx, "message", exc.msg)
    addCtx[string](ctx, "templateLine", $exc.templateLine)
    addCtx[seq[string]](ctx, "stacktrace", stackTraceLines)
    addCtx[seq[string]](ctx, "templateLinesAround", templateLinesAround)

    return PTemplateResponse(
        template_name: "framework/templates/template_error.html",
        context: ctx)
