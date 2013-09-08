from os import existsFile
from sockets import TSocket

from serve import safeServeFile


type
    TResponse* {.inheritable.} = object
        client*: TSocket
    ## TTemplateResponse* = object of TResponse
    # Not able to use inheritance:
    # SIGSEGV: Illegal storage access. (Attempt to read from nil?)
    TTemplateResponse* = object
        client*: TSocket
        template_name*: string


proc render*(response: TTemplateResponse, documentRoot: string) =
    safeServeFile(response.client, response.template_name, documentRoot)
