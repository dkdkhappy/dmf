from django.urls import path
from mscreening.views import (
    getExcelParse,
    getExcelParseBox,
    excelDownload,
    getDbSearch,
    mscreening_view,
    dbsearch_view,
    ms_box_view,
)

app_name = 'mscreening'

urlpatterns = [
    path('',view =mscreening_view,name="mscreening"),
    path('dbsearch',view =dbsearch_view,name="dbsearch"),
    path('ms_box',view =ms_box_view,name="ms_box"),
    path('getDbSearch',view =getDbSearch,name="getDbSearch"),
    path('getExcelParse',view =getExcelParse,name="getExcelParse"),
    path('getExcelParseBox',view =getExcelParseBox,name="getExcelParseBox"),
    path('excelDownload',view =excelDownload,name="excelDownload"),
]


