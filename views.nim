from framework/http import Request, Response, TemplateResponse
from framework/nimtpl/tplcontext import initContext, addCtx


proc home*(request: Request): Response {.cdecl.} =
    var ctx = initContext()

    addCtx[seq[string]](ctx, "letters", @["a", "b", "c"])

    return TemplateResponse(template_name: "templates/home.html", context: ctx)


proc put*(request: Request): Response {.cdecl.} =
    return TemplateResponse(template_name: "templates/put.html")
