"""velzon URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path,include,re_path
from django.conf.urls.static import static
from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.views.static import serve
from dashboards.views import SummaryView
from .views import MyPasswordChangeView, MyPasswordSetView, getData, getTranslate

urlpatterns = [
    path('admin/', admin.site.urls),
    # post 타입 데이터 조회
    path('getData', view=getData, name="getData"),
    # post 타입 데이터 조회
    path('getTranslate', view=getTranslate, name="getTranslate"),
    # Dashboard
    path('',view=SummaryView.as_view(), name="dashboard"),
    path('dashboards/',include('dashboards.urls')),
    # Dashboard
    path('reviewanalysis/',include('reviewanalysis.urls')),
    # Mscreening
    path('mscreening/',include('mscreening.urls')),
    # keywordprod
    path('keywordprod/',include('keywordprod.urls')),
    # Layouts
    path('layouts/',include('layouts.urls')),
    # Pages
    path('pages/',include('pages.urls')),
    #account
    path(
        "account/password/change/",
        login_required(MyPasswordChangeView.as_view()),
        name="account_change_password",
    ),
    path(
        "account/password/set/",
        login_required(MyPasswordSetView.as_view()),
        name="account_set_password",
    ),
    # All Auth
    path('account/', include('allauth.urls')),
    path('social-auth/',include('social_django.urls', namespace='social')),

    # file upload
    re_path(r'^fp/', include('django_drf_filepond.urls')),
    # staticRoot update (for debug is False)
    re_path(r'^static/(?P<path>.*)$', serve,{'document_root': settings.STATIC_ROOT}),
]
urlpatterns += static(settings.STATIC_URL, document_root = settings.STATIC_ROOT)