from framework/nimtpl/tplcontext import Context
from framework/nimtpl/tpltokenizer import tokenize
from framework/nimtpl/tplparser import Tag, parse

from framework/nimtpl/tpltags/tpltag_for import tagFor
from framework/nimtpl/tplexceptions import ETemplateSyntaxError


proc renderTemplate*(content: string, templateName: string,
                     ctx: var Context): string =

    let tokens = tokenize(content)
    let tags: seq[Tag] = @[
        ("for", tagFor),
    ]

    result = ""

    try:
        for output in parse(tokens, tags, ctx):
            result = result & output
    except:
        var exc = cast[ref ETemplateSyntaxError](getCurrentException())
        exc.templateName = templateName
        raise exc


if isMainModule:
    let tokens = tokenize("""<ul>
        {% for x in list %}
            <li>{{ x }}</li>
        {% empty %}
            <li>empty</li>
        {% endfor %}
    </ul>""")

    let tags: seq[Tag] = @[
        ("for", tagFor),
    ]

    var ctx = Context()

    for output in parse(tokens, tags, ctx):
        echo(output)
