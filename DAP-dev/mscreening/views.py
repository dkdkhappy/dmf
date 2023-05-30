import shutil
import os
import json
import pandas as pd
import numpy as np

from django.views.decorators.http import require_GET, require_POST
from django.shortcuts import render
from django.views.generic import TemplateView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.http import JsonResponse, HttpResponse, Http404
import psycopg2
from mscreening.services import Full_code_fin, Box_file_output
from datetime import datetime
import psycopg2
from velzon.settings import DJANGO_DRF_FILEPOND_FILE_STORE_PATH, DJANGO_DRF_FILEPOND_UPLOAD_TMP,DATABASES
from django_drf_filepond.api import store_upload
from django_drf_filepond.api import get_stored_upload
from django_drf_filepond.api import get_stored_upload_file_data

from velzon.utils import getPostgreSqlData, getSqlQueryString, check_user_able_to_see_page
from dashboards.models import OverallTooltip


# Create your views here.


class MscreeningView(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN', 'ms')
    def get(self, request):
        # PostgreSQL 데이터베이스 연결
        conn = psycopg2.connect(
            host=DATABASES["default"]["HOST"],
            database=DATABASES["default"]["NAME"],
            user=DATABASES["default"]["USER"],
            password=DATABASES["default"]["PASSWORD"],
        )
        # 커서 객체 생성
        cur = conn.cursor()
        query_file = "postgre/mscreening/mscreeningUpdate.sql"
        query = getSqlQueryString(query_file)
        results = getPostgreSqlData(cur, query)
        # 연결 객체 및 커서 객체 닫기
        cur.close()
        conn.close()
        if len(results) > 0:
            results = results[0]
        else:
            results = {}

        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='MATERIAL_SCREENING').values())
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context']  + str('"')      
        results['toolTips'] =  tool_dict
        return render(request, 'mscreening/index.html', results)


class DBSearchView(LoginRequiredMixin, TemplateView):
   def get(self, request):
        # PostgreSQL 데이터베이스 연결
        conn = psycopg2.connect(
            host=DATABASES["default"]["HOST"],
            database=DATABASES["default"]["NAME"],
            user=DATABASES["default"]["USER"],
            password=DATABASES["default"]["PASSWORD"],
        )
        # 커서 객체 생성
        cur = conn.cursor()
        query_file = "postgre/mscreening/mscreeningUpdate.sql"
        query = getSqlQueryString(query_file)
        results = getPostgreSqlData(cur, query)
        # 연결 객체 및 커서 객체 닫기
        cur.close()
        conn.close()
        if len(results) > 0:
            results = results[0]
        else:
            results = {}

        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(tab='DB_FINDER').values())
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context']  + str('"')    
        results['toolTips'] =  tool_dict
        print(results)            
        return render(request, 'mscreening/dbsearch.html', results)


class msBoxView(LoginRequiredMixin, TemplateView):
    def get(self, request):
        result = {}
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(tab='BOX_INGREDIENT').values())
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context']  + str('"')    

        
        return render(request, 'mscreening/ms_box.html', result)


mscreening_view = MscreeningView.as_view()
dbsearch_view = DBSearchView.as_view(template_name="mscreening/dbsearch.html")
ms_box_view = msBoxView.as_view(template_name="mscreening/ms_box.html")


@require_POST  # 해당 뷰는 POST method 만 받는다.
def getExcelParse(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        result = {}
        files = os.listdir(os.path.join(
            DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"]))
        for file in files:
            filename = os.path.join(os.path.join(
                DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"]), file)
            dirPath = os.path.join(DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"])

            os.rename(filename, filename + '.xlsx')
            result = Full_code_fin(filename + '.xlsx')
            shutil.rmtree(dirPath)

            # try:
            #     os.rename(filename, filename + '.xlsx')
            #     result = Full_code_fin(filename + '.xlsx')
            #     shutil.rmtree(dirPath)
            # except:
            #     print('error')
            #     pass

            result["file_id"] = os.path.basename(filename)
        return JsonResponse(result)

# @require_POST # 해당 뷰는 POST method 만 받는다.


def excelDownload(request):
    file = request.GET.get('filename') + ".xlsx"
    filename = os.path.join(DJANGO_DRF_FILEPOND_FILE_STORE_PATH, file)
    if os.path.exists(filename):
        f = open(filename, 'rb')
        response = HttpResponse(
            f.read(), content_type="application/vnd.ms-excel")
        downName = "screening_file - " + datetime.today().strftime("%Y%m%d%H%M%S") + ".xlsx"
        response['Content-Disposition'] = 'inline; filename=' + downName
        f.close()
        # os.remove(filename)
        return response
    raise Http404


def getDbSearch(request):
    search = request.GET.get('search')
    results = {}
    # PostgreSQL 데이터베이스 연결
    conn = psycopg2.connect(
        host=DATABASES["default"]["HOST"],
        database=DATABASES["default"]["NAME"],
        user=DATABASES["default"]["USER"],
        password=DATABASES["default"]["PASSWORD"],
    )
    # 커서 객체 생성
    cur = conn.cursor()
    query_file = "postgre/mscreening/dbsearch.sql"
    query = getSqlQueryString(query_file)
    pg_data = getPostgreSqlData(cur, query, {"KEY_WORD": f'\'{search}\''})
    # 연결 객체 및 커서 객체 닫기
    cur.close()
    conn.close()
    results["results"] = pg_data
    results["count"] = len(pg_data)
    return JsonResponse(results)


def ms_box(request):
    results = {}
    return JsonResponse(results)


@require_POST  # 해당 뷰는 POST method 만 받는다.
def getExcelParseBox(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        result = {}
        files = os.listdir(os.path.join(
            DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"]))
        print(data)
        for file in files:
            filename = os.path.join(os.path.join(
                DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"]), file)
            dirPath = os.path.join(DJANGO_DRF_FILEPOND_UPLOAD_TMP, data["key"])

            os.rename(filename, filename + '.xlsx')
            print(filename)
            fn = Box_file_output(filename + '.xlsx')
            shutil.rmtree(dirPath)
            print('저장위치:', fn)

            # try:
            #     os.rename(filename, filename + '.xlsx')
            #     result = Full_code_fin(filename + '.xlsx')
            #     shutil.rmtree(dirPath)
            # except:
            #     print('error')
            #     pass

            result["file_id"] = os.path.basename(filename)
        return JsonResponse(result)

