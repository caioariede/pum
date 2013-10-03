from framework/utils/tables2 import TTable, del, add, `[]`


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
    Context* = TTable[string, PContextValue]


proc setContextVariable*[T](ctx: var Context, key: string, value: T) =
    add(ctx, key, PContextValue(key: key, kind: justString, justStr: value))


proc getContextVariable*(ctx: var Context, key: string): PContextValue =
    return ctx[key]


proc remContextVariable*(ctx: var Context, key: string) =
    del(ctx, key)


proc ctxVal*[T](ctx: var Context, key: string, val: T) =
    when T is seq[string]:
        add(ctx, key, PContextValue(
            key: key, kind: sequenceOfStrings, seqStr: val))
    elif T is string:
        add(ctx, key, PContextValue(
            key: key, kind: justString, justStr: val))


proc getContext*(): Context =
    result.counter = 0
    newSeq(result.data, 64)
