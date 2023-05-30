import json
from django.http import JsonResponse
from django.shortcuts import render
from django.views.generic import TemplateView
from django.views.decorators.http import require_GET, require_POST
from django.contrib.auth.mixins import LoginRequiredMixin
import psycopg2
from keywordprod.network_bert import network_json
from keywordprod.sankey import make_sankey_db
from velzon.settings import DATABASES
from velzon.argparse_helpers import str2bool
from velzon.utils import getPostgreSqlData, getSqlQueryString, check_user_able_to_see_page
from dashboards.models import OverallTooltip
from .openai_api import call_chatgpt, call_chatgpt_intention
import pandas as pd 

class KeywordprodView(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN', 'keywordprod')
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
        query_file = "postgre/keywordprod/initData.sql"
        query = getSqlQueryString(query_file)
        results = getPostgreSqlData(cur, query)
        # 연결 객체 및 커서 객체 닫기
        cur.close()
        conn.close()
        if len(results) > 0:
            results = results[0]
        else:
            results = {}

        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='KEYWORD').values())
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context']  + str('"')      
        results['toolTips'] =  tool_dict
            
            
            
        return render(request, 'keywordprod/index.html', results)


# Create your views here.
keywordprod_view = KeywordprodView.as_view()

@require_POST  # 해당 뷰는 POST method 만 받는다.
def getMakeSankeyData(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        result = make_sankey_db(keyword=data["keyword"], steps=data["steps"], direction=data["direction"], fr_mnth=data["fr_mnth"], to_mnth=data["to_mnth"], gender=data["gender"], cutoff=data["cutoff"], google_search=str2bool(data["google_search"]), google_trend=str2bool(data["google_trend"]), naver_search=str2bool(data["naver_search"]))
        return JsonResponse(result)

@require_POST  # 해당 뷰는 POST method 만 받는다.
def getNetworkJson(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        result = network_json(keyword=data["keyword"], steps=data["steps"], direction=data["direction"], gender=data["gender"], cutoff=data["cutoff"], google_search=str2bool(data["google_search"]), google_trend=str2bool(data["google_trend"]), naver_search=str2bool(data["naver_search"]))
        return JsonResponse(result)
    
@require_POST  # 해당 뷰는 POST method 만 받는다.
def getNetworkChatGpt(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        print('go')
        print(data["keyword"])
        keywords2 = network_json(keyword=data["keyword"], steps=data["steps"], direction=data["direction"], gender=data["gender"], cutoff=data["cutoff"], google_search=str2bool(data["google_search"]), google_trend=str2bool(data["google_trend"]), naver_search=str2bool(data["naver_search"]))
        print(keywords2['nodes'])
        keywords2_list = []  
        for keys in keywords2['nodes']: 
            keywords2_list.append(keys['name'])
        result = call_chatgpt(keywords2_list)
        # result = '<table>\n  <tr>\n    <th>카테고리</th>\n    <th>검색 키워드</th>\n  </tr>\n  <tr>\n    <td>피부타입</td>\n    <td>예민한피부</td>\n  </tr>\n  <tr>\n    <td>성분</td>\n    <td>피부장벽강화, 판테놀, 나이아신아마이드, 유리드, 히알루론산</td>\n  </tr>\n  <tr>\n    <td>브랜드</td>\n    <td>더랩바이블랑두, 올리고</td>\n  </tr>\n  <tr>\n    <td>문제 해결</td>\n    <td>속건조</td>\n  </tr>\n</table>\n\n- 예민한 피부를 가진 소비자들은 보다 자극이 적은 제품을 선호할 것으로 예상되며, 피부타입에 맞는 성분이 함유된 제품을 추천해주는 마케팅 전략이 필요하다.\n- 피부장벽강화 성분이 함유된 제품은 피 부보호 기능을 강화해주어 피부건강에 도움을 줄 수 있으며, 이러한 성분을 활용한 제품을 개발하는 것이 좋다.\n- 판테놀, 나이아신아마이드, 유리드, 히알루론산 등의 성분은 피부 보습에 도움을 주는 성분으로, 이러한 성분을 함유한 제품들은 보다 건강한 피부를 유지하기 위해 사용될 수 있다.\n- 더랩바이블랑두와 올리고는 예민한 피부를 가진 소비자들에게 인기 있는 브랜드 중 하나이며, 이러한 브랜드들과의 협력 을 통해 보다 안정적인 제품을 제공할 수 있다.\n- 속건조는 낮은 습도와 냉난방으로 인해 겨울철에 더 심해지는 문제이다. 이러한 소비자들을 대상으로 보습 효과가 높은 제품을 마케팅 전략으로 활용할 수 있다.'
        return JsonResponse({"gptResponse": result})
        # return render(request, 'keywordprod/network.html', {"gptResponse": result} )
    

@require_POST  # 해당 뷰는 POST method 만 받는다.
def getIntentionChatGpt(request):
    # POST 요청일 때
    if request.method == 'POST':
        data = json.loads(request.body)
        print('go')
        print(data) 
        # naver_words = []
        # google_words = []
        # for dat in  data['data'] :
        #      if dat['node_key'] == 'GOOGLE' : 
        #          google_words.append()
            
        
        # # keywords_naver = data["naverSuggestedKeywords"]
        keywords_json = data['data']
        kwrd = data['kwrd']
        result = call_chatgpt_intention(keywords_json, kwrd)
        # result = '<table>\n  <tr>\n    <th>카테고리</th>\n    <th>검색 키워드</th>\n  </tr>\n  <tr>\n    <td>피부타입</td>\n    <td>예민한피부</td>\n  </tr>\n  <tr>\n    <td>성분</td>\n    <td>피부장벽강화, 판테놀, 나이아신아마이드, 유리드, 히알루론산</td>\n  </tr>\n  <tr>\n    <td>브랜드</td>\n    <td>더랩바이블랑두, 올리고</td>\n  </tr>\n  <tr>\n    <td>문제 해결</td>\n    <td>속건조</td>\n  </tr>\n</table>\n\n- 예민한 피부를 가진 소비자들은 보다 자극이 적은 제품을 선호할 것으로 예상되며, 피부타입에 맞는 성분이 함유된 제품을 추천해주는 마케팅 전략이 필요하다.\n- 피부장벽강화 성분이 함유된 제품은 피 부보호 기능을 강화해주어 피부건강에 도움을 줄 수 있으며, 이러한 성분을 활용한 제품을 개발하는 것이 좋다.\n- 판테놀, 나이아신아마이드, 유리드, 히알루론산 등의 성분은 피부 보습에 도움을 주는 성분으로, 이러한 성분을 함유한 제품들은 보다 건강한 피부를 유지하기 위해 사용될 수 있다.\n- 더랩바이블랑두와 올리고는 예민한 피부를 가진 소비자들에게 인기 있는 브랜드 중 하나이며, 이러한 브랜드들과의 협력 을 통해 보다 안정적인 제품을 제공할 수 있다.\n- 속건조는 낮은 습도와 냉난방으로 인해 겨울철에 더 심해지는 문제이다. 이러한 소비자들을 대상으로 보습 효과가 높은 제품을 마케팅 전략으로 활용할 수 있다.'
        return JsonResponse({"gptResponse": result})
        # return render(request, 'keywordprod/network.html', {"gptResponse": result} )
    
