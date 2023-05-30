from django.urls import path
from reviewanalysis.views import (
    DashboardView,
    DouyinChina,
    DouyinGlobal,
    SummaryView,
    TmallChina,
    TmallGlobal,
    getReviewSummaryChatGpt,
)

app_name = 'reviewanalysis'

urlpatterns = [
    path('reviewanalysis', view=DashboardView.as_view(), name="dashboard"),
    path('summary', view=SummaryView.as_view(), name="summary"),
    path('tmallchina', view=TmallChina.as_view(), name="tmallchina"),
    path('tmallglobal', view=TmallGlobal.as_view(), name="tmallglobal"),
    path('douyinchina', view=DouyinChina.as_view(), name="douyinchina"),
    path('douyinglobal', view=DouyinGlobal.as_view(), name="douyinglobal"),
    path('getReviewSummaryChatGpt', view=getReviewSummaryChatGpt, name= "getReviewSummaryChatGpt")

]
