type
    ETemplateSyntaxError* = object of E_Base
        templateLine*: int
        templateName*: string
