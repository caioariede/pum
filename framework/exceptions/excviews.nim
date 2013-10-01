from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse
from framework/nimtpl/tplcontext import ctxVal, Context
from framework/nimtpl/tplexceptions import ETemplateSyntaxError
from framework/nimtpl/tplutils import getTemplateLinesAround

from strutils import strip, splitLines


method exceptionView*(request: PRequest,
                      exc: ref E_Base): PResponse {.cdecl.} =
    var ctx: Context = @[
        ctxVal[string]("message", exc.msg),
    ]

    return PTemplateResponse(template_name: "framework/templates/error.html",
                             context: ctx)


method exceptionView*(request: PRequest,
                      exc: ref ETemplateSyntaxError): PResponse {.cdecl.} =
    let templateLinesAround = getTemplateLinesAround(exc.templateName,
                                                     exc.templateLine, 5)

    var stackTraceLines = getStackTrace(exc).strip().splitLines()

    stackTraceLines = stackTraceLines[1..high(stackTraceLines)]

    add(stackTraceLines, exc.templateName & "(" & $exc.templateLine & ")")

    var ctx: Context = @[
        ctxVal[string]("message", exc.msg),
        ctxVal[string]("templateLine", $exc.templateLine),
        ctxVal[seq[string]]("stacktrace", stackTraceLines),
        ctxVal[seq[string]]("templateLinesAround", templateLinesAround),
    ]

    return PTemplateResponse(
        template_name: "framework/templates/template_error.html",
        context: ctx)
