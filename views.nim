from sockets import TSocket
from response import TTemplateResponse


proc home*(client: TSocket): TTemplateResponse {.procvar.} =
    return TTemplateResponse(template_name: "templates/home.html",
                             client: client)


proc put*(client: TSocket): TTemplateResponse {.procvar.} =
    return TTemplateResponse(template_name: "templates/put.html",
                             client: client)
