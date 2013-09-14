from httpserver import run
from sockets import TPort
from terminal import EraseLine, setForegroundColor, fgGreen, resetAttributes

from framework/handler import getHandler
from framework/urlpatterns import TPatterns


proc controlCHook() {.noconv.} =
    EraseLine() # Erase ^C
    writeln(stdout, "Bye!")
    resetAttributes()
    quit(QuitSuccess)


proc runServer*(patterns: TPatterns) =
    # Quit gracefully
    setControlCHook(controlCHook)

    # Write a styled text on terminal
    setForegroundColor(fgGreen)
    writeln(stdout, "Pum is running on port 8888")

    # Pum!
    run(getHandler(patterns), TPort(8888))
