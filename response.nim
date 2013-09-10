from os import existsFile
from sockets import TSocket

from request import PRequest
from serve import safeServeFile


type
    PResponse* = ref object {.inheritable.}
    PTemplateResponse* = ref object of PResponse
        template_name*: string
    PFileResponse* = ref object of PResponse
        filename*: string


method render*(response: PResponse, request: PRequest) =
    quit "to override!"

method render*(response: PTemplateResponse, request: PRequest) =
    safeServeFile(request.client, response.template_name, request.documentRoot)

method render*(response: PFileResponse, request: PRequest) =
    safeServeFile(request.client, response.filename, request.documentRoot)
