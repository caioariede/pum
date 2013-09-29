from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse
from framework/nimtpl/tplcontext import ctxVal, Context


proc exceptionView*(request: PRequest, exc: ref E_Base): PResponse {.cdecl.} =
    var ctx: Context = @[
        ctxVal[string]("message", exc.msg),
    ]

    return PTemplateResponse(template_name: "framework/templates/error.html",
                             context: ctx)
