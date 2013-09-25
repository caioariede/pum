from os import existsFile
from sockets import TSocket, send

from framework/request import PRequest
from framework/serve import safeServeFile

from framework/nimtpl/tplengine import renderTemplate
from framework/nimtpl/tplcontext import Context, ctxVal


type
    PResponse* = ref object {.inheritable.}
    PTemplateResponse* = ref object of PResponse
        template_name*: string
    PFileResponse* = ref object of PResponse
        filename*: string


method render*(response: PResponse, request: PRequest) =
    quit "to override!"


method render*(response: PFileResponse, request: PRequest) =
    safeServeFile(request.client, response.filename, request.documentRoot)


method render*(response: PTemplateResponse, request: PRequest) =
    var ctx: Context = @[
        ctxVal[seq[string]]("letters", @["a", "b", "c"]),
    ]

    let templateString = readFile(response.template_name)
    let renderedTemplate = renderTemplate(templateString, ctx)

    request.client.send(renderedTemplate)
