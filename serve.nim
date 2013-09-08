from os import existsFile
from sockets import TSocket, send
from httpserver import run, serveFile

from security import isPathSafe


proc safeServeFile*(client: TSocket, filename: string, documentRoot: string) =
    if isPathSafe(filename, documentRoot) and existsFile(filename):
        serveFile(client, filename)
    else:
        client.send("File not found\n")
