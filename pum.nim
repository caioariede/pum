from httpserver import run, serveFile
from sockets import TSocket, TPort, send
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes
from os import existsFile, getCurrentDir

from security import isPathSafe


proc renderTemplate(client: TSocket, tpl: string) =
    var filename: string = "templates/" & tpl
    if existsFile(filename):
        serveFile(client, filename)
    else:
        client.send("Template " & tpl & " not found\n")


proc home(client: TSocket) =
    renderTemplate(client, "home.html")


proc put(client: TSocket) =
    renderTemplate(client, "put.html")


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    var
        path = path
        documentRoot = getCurrentDir()

    if path == "/":
        home(client)
    elif path == "/put":
        put(client)
    else:
        var filename: string = "assets/" & path[1..high(path)]
        if isPathSafe(filename, documentRoot) and existsFile(filename):
            serveFile(client, filename)
        client.send("File not found\n")
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
