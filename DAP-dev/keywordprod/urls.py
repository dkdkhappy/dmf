from django.urls import path
from keywordprod.views import (
    getMakeSankeyData,
    getNetworkJson,
    keywordprod_view,
    getNetworkChatGpt,
    getIntentionChatGpt,
)

app_name = 'keywordprod'

urlpatterns = [
    path('',view =keywordprod_view,name="keywordprod"),
    path('getMakeSankeyData',view =getMakeSankeyData,name="getMakeSankeyData"),
    path('getNetworkJson',view =getNetworkJson,name="getNetworkJson"),
    path('getNetworkChatGpt',view =getNetworkChatGpt,name="getNetworkChatGpt"),
    path('getIntentionChatGpt',view =getIntentionChatGpt,name="getIntentionChatGpt"),
]


