from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse
from framework/nimtpl/tplcontext import initContext, addCtx


proc home*(request: PRequest): PResponse {.cdecl.} =
    var ctx = initContext()

    addCtx[seq[string]](ctx, "letters", @["a", "b", "c"])

    return PTemplateResponse(template_name: "templates/home.html",
                             context: ctx)


proc put*(request: PRequest): PResponse {.cdecl.} =
    return PTemplateResponse(template_name: "templates/put.html")
