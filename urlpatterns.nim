from request import PRequest
from response import PResponse
from re import TRegEx

type
    TView = proc (request: PRequest): PResponse {.cdecl.}
    TPattern* = tuple
        regex: TRegEx
        view: TView
    TPatterns* = seq[TPattern]
