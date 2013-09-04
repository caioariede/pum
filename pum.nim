from httpserver import run
from sockets import TSocket, TPort, send
from htmlgen import html, head, title, body, h1
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes


proc handleRequest(client: TSocket, path, query: string): bool {.procvar.} =
    client.send(
        html(
            head(
                title("Pum is a fast and light-weight URL shortener service"),
            ),
            body(
                h1("Pum!"),
            ),
        ),
    )
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
