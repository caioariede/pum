from framework/http import Request, Response, FileResponse


proc serveStatic*(request: Request): Response {.cdecl.} =
    echo("assets/" & request.path[1..high(request.path)])
    return FileResponse(
        filename: "assets/" & request.path[1..high(request.path)])
