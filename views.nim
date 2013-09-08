from sockets import TSocket
from response import TResponse, TTemplateResponse


proc home*(client: TSocket): TTemplateResponse =
    return TTemplateResponse(template_name: "templates/home.html",
                             client: client)


proc put*(client: TSocket): TTemplateResponse =
    return TTemplateResponse(template_name: "templates/put.html",
                             client: client)
