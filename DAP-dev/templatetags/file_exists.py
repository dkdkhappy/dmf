from django import template
import os
from django.conf import settings
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
@stringfilter
def file_exists(path):
    print("-----------------------------------------------------------------------")
    isFilePath = os.path.join("templates", path)
    print(isFilePath)
    print(os.path.isfile(isFilePath))
    # templates\dashboards\tmallglobal\tabs\sale.html
    return os.path.isfile(isFilePath)

@register.filter
@stringfilter
def static_file_exists(path):
    print("---------------------------------static_file_exists--------------------------------------")
    print(path) 
    isFile = False
    for static_dir in settings.STATICFILES_DIRS:
        if os.path.exists(os.path.join(static_dir, path)):
            isFile = True
            break
    print(isFile) 
    return isFile
