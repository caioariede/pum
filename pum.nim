from framework/server import runServer

from urls import patterns

if isMainModule:
    runServer(patterns)
