from re import TRegEx

from framework.http import Request, Response


type
    TView = proc (request: Request): Response {.cdecl.}
    TPattern* = tuple
        regex: TRegEx
        view: TView
    Patterns* = seq[TPattern]
