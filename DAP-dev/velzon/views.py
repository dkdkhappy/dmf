import json
import time
import importlib
import os
from django.contrib.auth.mixins import LoginRequiredMixin
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse_lazy
from allauth.account.views import PasswordChangeView, PasswordSetView
from django.views.decorators.http import require_GET, require_POST
from django.core import serializers
import psycopg2
import urllib.parse
import dashboards
from velzon.settings import DATABASES, DJANGO_SQL_STORAGE
from velzon.utils import getPostgreSqlData, getSqlQueryString, getTableTagName
from django.apps import apps
import requests

class MyPasswordChangeView(PasswordChangeView):
    success_url = reverse_lazy("dashboards:dashboard")


class MyPasswordSetView(PasswordSetView):
    success_url = reverse_lazy("dashboards:dashboard")


def getData(request):
    """
    {
        "params": {
            "FR_DT": "2023-02-01",
            "TO_DT": "2023-02-01"
        },
        "menu": "dashboards",
        "tab": "sales",
        "dataList": ["refundTimeSeriesByProduct", "refundTimeSeriesByProduct"]
    }
    """
    results = {}
    all_start_time = time.time()
    if request.method == 'POST':
        try:
            # 채널별 분기를 위해 referer 을 조회 후 Global, China url 추출
            referer = request.META.get('HTTP_REFERER') or request.headers.get('referer')
            if referer:
                url_path = urllib.parse.urlparse(referer).path
            payment_data = json.loads(request.body)
            # PostgreSQL 데이터베이스 연결
            conn = psycopg2.connect(
                host=DATABASES["default"]["HOST"],
                database=DATABASES["default"]["NAME"],
                user=DATABASES["default"]["USER"],
                password=DATABASES["default"]["PASSWORD"],
            )
            # 커서 객체 생성
            cur = conn.cursor()
            for name in payment_data["dataList"]:
                start_time = time.time()
                # 모듈 경로와 함수 이름 분리
                menuNm = payment_data["menu"].split('/')[0]
                module_path = f'{menuNm}.views'
                function_name = name
                # 모듈 가져오기
                module = importlib.import_module(module_path)
                if hasattr(module, function_name):
                    # 함수가 존재함
                    function = getattr(module, function_name)
                    result = function()
                    results[name] = result
                else:
                    # 함수가 존재하지 않음
                    query_file = "postgre" + "/" + payment_data["menu"] + "/" + name + ".sql"

                    if "tab" in payment_data:
                        query_file = "postgre" + "/" + url_path + "/" + payment_data["tab"] + "/" + name + ".sql"
                        if not os.path.exists(os.path.join(DJANGO_SQL_STORAGE, query_file)):
                            query_file = "postgre" + "/" + payment_data["menu"] + "/" + payment_data["tab"] + "/" + name + ".sql"

                    tableConfig = getTableTagName(url_path)
                    payment_data["params"]["TAG"] = tableConfig["TAG"]
                    payment_data["params"]["TAG_ID"] = tableConfig["TAG_ID"]
                    if "CHNL_ID" not in payment_data["params"]:
                        payment_data["params"]["CHNL_ID"] = tableConfig["CHNL_ID"]
                    payment_data["params"]["CHNL_L_ID"] = tableConfig["CHNL_L_ID"]
                    
                    query = getSqlQueryString(query_file)                    
                    results[name] = getPostgreSqlData(cur, query, params=payment_data["params"])
                print(f"{name} - {getTableTagName(url_path)} 조회 소요 시간: {time.time() - start_time:.5f} sec")
            # 연결 객체 및 커서 객체 닫기
            cur.close()
            conn.close()
            # Print total query time
            print(f"총 조회 소요 시간: {time.time() - all_start_time:.5f} sec")
        except (ValueError, KeyError, TypeError) as e:
            print(f"Error: {e}")
            pass
    return JsonResponse(results)

def getTranslate(request):
    results = {}
    try:
        data = json.loads(request.body)
        if not data:
            return JsonResponse(results)  # request.body가 비어있는 경우 처리
        text_list = [row['word_item'] for row in data]
        api_url = "https://on5r04vd0g.execute-api.ap-northeast-2.amazonaws.com/beta/translate/"
        headers = {"Content-Type": "application/json;charset=UTF-8"}
        api_data = [{"text": text, "lang_from": "auto", "lang_to": "en","index": "0"} for text in text_list]
        #api_data = [{"text": text, "lang_from": "auto", "lang_to": "ko", "index": str(row['word_cnt'])} for row, text in zip(data, text_list)]
        response = requests.post(api_url, headers=headers, data=json.dumps(api_data))
        translated_rows = response.json()
        for i, row in enumerate(data):
            row['word_item'] = translated_rows[i]['translate']
        results['data'] = data
    except (ValueError, KeyError, TypeError) as e:
        print(f"Error: {e}")
    return JsonResponse(results)