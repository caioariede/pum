from re import re

from framework.urlpatterns import Patterns
from framework.staticviews import serveStatic

from views import home, put


var patterns*: Patterns = @[
    (re"^/put$", put),
    (re"^/$", home),
    (re".*", serveStatic),
]
