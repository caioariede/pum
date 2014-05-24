from os import existsFile
from sockets import TSocket, send

from framework/serve import safeServeFile

from framework/nimtpl/tplengine import renderTemplate
from framework/nimtpl/tplcontext import Context


type
    Request* = ref object
        client*: TSocket
        path*, query*, documentRoot*: string


type
    Response* = ref object {.inheritable.}
    TemplateResponse* = ref object of Response
        template_name*: string
        context*: Context
    FileResponse* = ref object of Response
        filename*: string


method render*(response: Response, request: Request) =
    quit "to override!"


method render*(response: FileResponse, request: Request) =
    safeServeFile(request.client, response.filename, request.documentRoot)


method render*(response: TemplateResponse, request: Request) =
    let templateString = readFile(response.template_name)
    let renderedTemplate = renderTemplate(templateString,
                                          response.template_name,
                                          response.context)

    request.client.send(renderedTemplate)
