from framework/http import Request, Response, TemplateResponse
from framework/nimtpl/tplcontext import addCtx, initContext
from framework/nimtpl/tplexceptions import ETemplateSyntaxError
from framework/nimtpl/tplutils import getTemplateLinesAround

from strutils import strip, splitLines


method exceptionView*(request: Request,
                      exc: ref E_Base): Response {.cdecl.} =
    var ctx = initContext()
    
    addCtx[string](ctx, "message", exc.msg)

    return TemplateResponse(template_name: "framework/templates/error.html",
                             context: ctx)


method exceptionView*(request: Request,
                      exc: ref ETemplateSyntaxError): Response {.cdecl.} =
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

    return TemplateResponse(
        template_name: "framework/templates/template_error.html",
        context: ctx)
