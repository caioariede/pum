from os import existsFile, expandFileName, getCurrentDir
from strutils import startsWith


proc isPathSafe*(path: string, prefix: string): bool =
    var expandedPath: string

    try:
        expandedPath = expandFileName(path)
    except:
        return not existsFile(path)

    return expandedPath.startsWith(prefix)


if isMainModule:
    assert(not isPathSafe("../../../../../../../etc/passwd", getCurrentDir()))
    assert(isPathSafe("./security.nim", getCurrentDir()))
