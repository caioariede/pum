from httpserver import run
from sockets import TSocket, TPort
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes
from os import getCurrentDir

from serve import safeServeFile
from response import render

from views import home, put


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    var
        path = path
        documentRoot = getCurrentDir()

    if path == "/":
        render(home(client), documentRoot)
    elif path == "/put":
        render(put(client), documentRoot)
    else:
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
