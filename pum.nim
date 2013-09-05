from httpserver import run, serveFile
from sockets import TSocket, TPort, send
from htmlgen import html, head, title, body, h1
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes
from strutils import replace
from os import existsFile


proc renderTemplate(client: TSocket, tpl: string) =
    var filename: string = "templates/" & tpl
    if existsFile(filename):
        serveFile(client, filename)
    else:
        client.send("File not found")


proc home(client: TSocket) =
    renderTemplate(client, "home.html")


proc put(client: TSocket) =
    renderTemplate(client, "put.html")


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    var path = path

    if path == "/":
        home(client)
    elif path == "/put":
        put(client)
    else:
        path = path.replace("..", "")
        var filename: string = "assets/" & path[1..high(path)]
        if existsFile(filename):
            serveFile(client, filename)
    return false


proc controlCHook() {.noconv.} =
    EraseLine() # Erase ^C
    writeln(stdout, "Bye!")
    quit(QuitSuccess)


if isMainModule:
    # Quit gracefully
    setControlCHook(controlCHook)

    # Write a styled text on terminal
    setForegroundColor(fgGreen)
    writeln(stdout, "Pum is running on port 8888")

    # Reset styled terminal
    addQuitProc(resetAttributes)

    # Pum!
    run(handleRequest, TPort(8888))
