from framework/nimtpl/tplcontext import Context, ctxVal
from framework/nimtpl/tpltokenizer import tokenize
from framework/nimtpl/tplparser import Tag, parse

from framework/nimtpl/tpltags/tpltag_for import tagFor


proc renderTemplate*(content: string, ctx: var Context): string =
    let tokens = tokenize(content)
    let tags: seq[Tag] = @[
        ("for", tagFor),
    ]

    result = ""

    for output in parse(tokens, tags, ctx):
        result = result & output


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

    var ctx = @[
        ctxVal[seq[string]]("list", @[]),
    ]

    for output in parse(tokens, tags, ctx):
        echo(output)
