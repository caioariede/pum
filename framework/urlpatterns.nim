from re import TRegEx

from framework/request import PRequest
from framework/response import PResponse


type
    TView = proc (request: PRequest): PResponse {.cdecl.}
    TPattern* = tuple
        regex: TRegEx
        view: TView
    TPatterns* = seq[TPattern]
