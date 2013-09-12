from framework/request import PRequest
from framework/response import PResponse, PTemplateResponse


proc home*(request: PRequest): PResponse {.cdecl.} =
    return PTemplateResponse(template_name: "templates/home.html")


proc put*(request: PRequest): PResponse {.cdecl.} =
    return PTemplateResponse(template_name: "templates/put.html")
