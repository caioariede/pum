from os import existsFile
from sockets import TSocket, send
from httpserver import run, serveFile

from framework.security import isPathSafe


proc safeServeFile*(client: TSocket, filename: string, documentRoot: string) =
    echo(filename, documentRoot)
    if isPathSafe(filename, documentRoot) and existsFile(filename):
        serveFile(client, filename)
    else:
        client.send("File not found\n")
