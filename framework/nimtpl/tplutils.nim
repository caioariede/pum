from cgi import XMLencode


proc getTemplateLinesAround*(templateName: string, templateLine: int,
                             around: int): seq[string] =
    var
        f: TFile
        linesAround: seq[string] = @[]
        currentLine = 1
    
    let
        minLine = (templateLine - around) - 1
        maxLine = (templateLine + around) + 1

    for line in lines(templateName):
        if currentLine > minLine and currentLine < maxLine:
            if currentLine != templateLine:
                add(linesAround, XMLencode(line))
            else:
                add(linesAround, "<b>" & XMLencode(line) & "</b>")
        currentLine += 1

    return linesAround
