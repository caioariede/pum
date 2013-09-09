from sockets import TSocket
from response import TTemplateResponse
from re import TRegEx

type
    TView = proc (client: TSocket): TTemplateResponse {.cdecl.}
    TPattern = object
        regex*: TRegEx
        view*: TView
    TPatterns* = seq[TPattern]
