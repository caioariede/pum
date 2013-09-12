from framework/request import PRequest
from framework/response import PResponse, PFileResponse


proc serveStatic*(request: PRequest): PResponse {.cdecl.} =
    return PFileResponse(
        filename: "assets/" & request.path[1..high(request.path)])
