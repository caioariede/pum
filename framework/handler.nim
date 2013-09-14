from sockets import TSocket, TPort
from os import getCurrentDir
from re import re, match

from framework/urlpatterns import TPatterns
from framework/request import PRequest
from framework/response import render


type
    handlerCallback = proc(client: TSocket,
                           path, query: string): bool {.closure.}


proc getHandler*(patterns: TPatterns): handlerCallback =
    return proc(client: TSocket, path, query: string): bool {.closure.} =
        let request = PRequest(client: client, path: path, query: query,
                               documentRoot: getCurrentDir())

        for pattern in patterns:
            if match(path, pattern.regex):
                render(pattern.view(request), request)
                break

        return false
