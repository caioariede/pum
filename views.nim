from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse, PFileResponse


proc home*(request: PRequest): PResponse {.cdecl.} =
    return PTemplateResponse(template_name: "templates/home.html")


proc put*(request: PRequest): PResponse {.cdecl.} =
    return PTemplateResponse(template_name: "templates/put.html")


proc serveStatic*(request: PRequest): PResponse {.cdecl.} =
    return PFileResponse(
        filename: "assets/" & request.path[1..high(request.path)])
