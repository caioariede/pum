from httpserver import run
from sockets import TSocket, TPort
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes
from os import getCurrentDir
from re import re, match

from framework/response import render
from framework/request import PRequest
from framework/urlpatterns import TPatterns

from views import home, put, serveStatic


var patterns: TPatterns = @[
    (re"^/put$", put),
    (re"^/$", home),
    (re"", serveStatic),
]


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    let request = PRequest(client: client, path: path, query: query,
                           documentRoot: getCurrentDir())

    for pattern in patterns:
        if match(path, pattern.regex):
            render(pattern.view(request), request)
            break

    return false


proc controlCHook() {.noconv.} =
    EraseLine() # Erase ^C
    writeln(stdout, "Bye!")
    resetAttributes()
    quit(QuitSuccess)


if isMainModule:
    # Quit gracefully
    setControlCHook(controlCHook)

    # Write a styled text on terminal
    setForegroundColor(fgGreen)
    writeln(stdout, "Pum is running on port 8888")

    # Pum!
    run(handleRequest, TPort(8888))
