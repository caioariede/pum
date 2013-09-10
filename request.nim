from sockets import TSocket


type
    PRequest* = ref object
        client*: TSocket
        path*, query*, documentRoot*: string
