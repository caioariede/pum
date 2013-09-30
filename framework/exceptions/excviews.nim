from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse
from framework/nimtpl/tplcontext import ctxVal, Context
from framework/nimtpl/tplexceptions import ETemplateSyntaxError


method exceptionView*(request: PRequest,
                      exc: ref E_Base): PResponse {.cdecl.} =
    var ctx: Context = @[
        ctxVal[string]("message", exc.msg),
    ]

    return PTemplateResponse(template_name: "framework/templates/error.html",
                             context: ctx)


method exceptionView*(request: PRequest,
                      exc: ref ETemplateSyntaxError): PResponse {.cdecl.} =
    var ctx: Context = @[
        ctxVal[string]("message", exc.msg),
        ctxVal[string]("templateLine", $exc.templateLine),
    ]

    return PTemplateResponse(
        template_name: "framework/templates/template_error.html",
        context: ctx)
