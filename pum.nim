from httpserver import run
from sockets import TSocket, TPort
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes
from os import getCurrentDir
from re import re, match

from serve import safeServeFile
from response import render
from urlpatterns import TPatterns

from views import home, put


var patterns = cast[TPatterns](@[
    (re"^/put$", put),
    (re"^/$", home)
])


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    var
        path = path
        documentRoot = getCurrentDir()
        found = False

    for pattern in patterns:
        if not found and match(path, pattern.regex):
            found = True
            render(pattern.view(client), documentRoot)

    if not found:
        safeServeFile(client, "assets/" & path[1..high(path)], documentRoot)

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
