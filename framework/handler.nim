from sockets import TSocket, TPort
from os import getCurrentDir
from re import re, match

from framework/urlpatterns import Patterns
from framework/http import Request, render
from framework/exceptions/excviews import exceptionView


type
    handlerCallback = proc(client: TSocket,
                           path, query: string): bool {.closure.}


proc getHandler*(patterns: Patterns): handlerCallback =
    return proc(client: TSocket, path, query: string): bool {.closure.} =
        let request = Request(client: client, path: path, query: query,
                              documentRoot: getCurrentDir())

        for pattern in patterns:
            if match(path, pattern.regex):
                echo(path)
                try:
                    render(pattern.view(request), request)
                except:
                    render(exceptionView(request, getCurrentException()),
                           request)
                break

        return false
