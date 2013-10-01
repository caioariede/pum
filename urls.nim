from re import re

from framework/urlpatterns import TPatterns
from framework/staticviews import serveStatic

from views import home, put


var patterns*: TPatterns = @[
    (re"^/put$", put),
    (re"^/$", home),
    (re".*", serveStatic),
]
