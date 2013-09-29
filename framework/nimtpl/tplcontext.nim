type
    TContextKind = enum
        justString
        sequenceOfStrings
    TContextValue* = object
        key: string
        case kind: TContextKind
        of justString:
            justStr*: string
        of sequenceOfStrings:
            seqStr*: seq[string]
    PContextValue = ref TContextValue
    Context* = seq[PContextValue]


proc setContextVariable*[T](ctx: var Context, key: string, value: T) =
    add(ctx, PContextValue(key: key, kind: justString, justStr: value))


proc getContextVariable*(ctx: var Context, key: string): PContextValue =
    for item in items(ctx):
        if item.key == key:
            return item
    return nil


proc remContextVariable*(ctx: var Context, key: string) =
    for i in 0..high(ctx):
        if ctx[i].key == key:
            del(ctx, i)
            break


proc ctxVal*[T](key: string, val: T): PContextValue =
    when T is seq[string]:
        return PContextValue(key: key, kind: sequenceOfStrings, seqStr: val)
    elif T is string:
        return PContextValue(key: key, kind: justString, justStr: val)
