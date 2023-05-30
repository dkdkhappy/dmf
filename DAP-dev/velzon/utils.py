import math
import time
import pandas as pd
# from tabulate import tabulate
from django.http import Http404
import boto3
import io
import os
from datetime import datetime
from django.shortcuts import redirect
from dateutil.relativedelta import *
import psycopg2

from velzon.settings import DATABASES, DJANGO_SQL_STORAGE

BUCKET = 'derma-material-screening'
IAM_ID = "AKIAYRBXPIB6Y4K42NZR"
IAM_PW = "bOTOJRFDUpgmnGb8JD9PhfycjSZFdlh2A5mmMd8d"
REGION_NAME = "ap-northeast-2"

s3_client = boto3.client('s3',
                         aws_access_key_id=IAM_ID,
                         aws_secret_access_key=IAM_PW,
                         region_name=REGION_NAME
                         )


def call_csv(bucket_nm, key_nm, **kwargs):
    obj = s3_client.get_object(Bucket=bucket_nm, Key=key_nm)
    data = obj['Body'].read()

    data = pd.read_csv(io.BytesIO(data), **kwargs)

    return data


session = boto3.Session(aws_access_key_id=IAM_ID,
                        aws_secret_access_key=IAM_PW,
                        region_name=REGION_NAME)


def getPostgreSqlData(cur, query, params={}):
    """
    /**
    * 기능 : 쿼리 조회 후 dist 반환
    * @param {query} 조회 할 쿼리문
    * @param {dflist} 결과 레코드 dict

    */
    """
    try:
        start = time.time()
        query = query.format(**params)
        cur.execute(query)
        columns = [desc[0] for desc in cur.description]  # 컬럼명을 가져옴
        rows = cur.fetchall()
        # 컬럼명과 데이터 출력
        qr = []
        for row in rows:
            qr.append(dict(zip(columns, row)))

        end = time.time()
        # print(f"athena 쿼리 조회 소요 시간 : {end - start:.5f} sec")
        start = time.time()
        df = pd.DataFrame(qr)

        # print(tabulate(df, headers='keys', tablefmt='psql', showindex=True))

        end = time.time()
        # print(f"Query To DataFrame 형 변환 소요 시간 :  {end - start:.5f} sec")
        start = time.time()
        dflist = df.to_dict(orient='records')
        end = time.time()
        # print(f"DataFrame To Dist 형 변환 소요 시간 : {end - start:.5f} sec")
        return dflist
    except Exception as e:    # 모든 예외의 에러 메시지를 출력할 때는 Exception을 사용
        print(f'getPostgreSqlData 예외가 발생했습니다. : {e}')
        print(f'query : {query} \n params : {params}')

        pass


def delete_old_files(path_target, days_elapsed):
    """
    /**
    * 기능 : DataFrame 경과일 지난 파일 삭제
    * @param {path_target} 삭제할 파일이 있는 디렉토리
    * @param {days_elapsed} 경과일수

    */
    """
    for f in os.listdir(path_target):  # 디렉토리를 조회한다
        f = os.path.join(path_target, f)
        if os.path.isfile(f):  # 파일이면
            timestamp_now = datetime.now().timestamp()  # 타임스탬프(단위:초)
            # st_mtime(마지막으로 수정된 시간)기준 X일 경과 여부
            is_old = os.stat(f).st_mtime < timestamp_now - \
                (days_elapsed * 24 * 60 * 60)
            if is_old:  # X일 경과했다면
                try:
                    os.remove(f)  # 파일을 지운다
                    print(f, 'is deleted')  # 삭제완료 로깅
                except OSError:  # Device or resource busy (다른 프로세스가 사용 중)등의 이유
                    print(f, 'can not delete')  # 삭제불가 로깅


def serialize(obj):
    if isinstance(obj, pd.Series):
        return obj.to_dict()
    elif isinstance(obj, pd.DataFrame):
        return obj.to_dict(orient='records')
    elif isinstance(obj, list):
        return [serialize(item) for item in obj]
    elif isinstance(obj, pd.NA):
        return None
    return obj


def isNullChk(val):
    if (type(val) == str):
        return True if not val else False
    elif (type(val) == int):
        return True if not val else False
    elif (type(val) == None):
        return True
    elif (type(val) == float):
        return True if math.isnan(val) else False


def getSqlQueryString(sqlPath):
    sql = os.path.join(DJANGO_SQL_STORAGE, sqlPath)
    f = open(sql, 'r', encoding="UTF-8")
    query = ''
    while True:
        line = f.readline()
        if not line:
            break
        a = str(line)
        query = query + a
    return query


def getPageInitData(sqlPath):
    # PostgreSQL 데이터베이스 연결
    conn = psycopg2.connect(
        host=DATABASES["default"]["HOST"],
        database=DATABASES["default"]["NAME"],
        user=DATABASES["default"]["USER"],
        password=DATABASES["default"]["PASSWORD"],
    )
    # 커서 객체 생성
    cur = conn.cursor()
    query_file = sqlPath
    query = getSqlQueryString(query_file)
    results = getPostgreSqlData(cur, query)
    # 연결 객체 및 커서 객체 닫기
    cur.close()
    conn.close()
    if len(results) > 0:
        results = results[0]
    else:
        results = {}
    return results


def getTableTagName(url):
    result = {}
    if "tmallchina" in url:
        result["TAG"] = "DCT"
        result["TAG_ID"] = "'DCT'"
        result["CHNL_ID"] = "'Tmall China'"
        result["CHNL_L_ID"] = "TMALL"
    elif "tmallglobal" in url:
        result["TAG"] = "DGT"
        result["TAG_ID"] = "'DGT'"
        result["CHNL_ID"] = "'Tmall Global'"
        result["CHNL_L_ID"] = "TMALL"
    elif "douyinchina" in url:
        result["TAG"] = "DCD"
        result["TAG_ID"] = "'DCD'"
        result["CHNL_ID"] = "'Douyin China'"
        result["CHNL_L_ID"] = "DOUYIN"
    elif "douyinglobal" in url:
        result["TAG"] = "DGD"
        result["TAG_ID"] = "'DGD'"
        result["CHNL_ID"] = "'Douyin Global'"
        result["CHNL_L_ID"] = "DOUYIN"
    else:
        result["TAG"] = ""
        result["TAG_ID"] = "''"
        result["CHNL_ID"] = "''"
        result["CHNL_L_ID"] = ""
    return result


def check_user_able_to_see_page(*groups):
    def decorator(function):
        def wrapper(self, *args, **kwargs):
            if self.request.user.groups.filter(name__in=groups).exists():
                return function(self.request, *args, **kwargs)
            else:
                print('go 404')
                return redirect('/pages/pages/pages-hold-authentication')
        return wrapper
    return decorator