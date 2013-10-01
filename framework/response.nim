from os import existsFile
from sockets import TSocket, send

from framework/request import PRequest
from framework/serve import safeServeFile

from framework/nimtpl/tplengine import renderTemplate
from framework/nimtpl/tplcontext import Context


type
    PResponse* = ref object {.inheritable.}
    PTemplateResponse* = ref object of PResponse
        template_name*: string
        context*: Context
    PFileResponse* = ref object of PResponse
        filename*: string


method render*(response: PResponse, request: PRequest) =
    quit "to override!"


method render*(response: PFileResponse, request: PRequest) =
    safeServeFile(request.client, response.filename, request.documentRoot)


method render*(response: PTemplateResponse, request: PRequest) =
    let templateString = readFile(response.template_name)
    let renderedTemplate = renderTemplate(templateString,
                                          response.template_name,
                                          response.context)

    request.client.send(renderedTemplate)
