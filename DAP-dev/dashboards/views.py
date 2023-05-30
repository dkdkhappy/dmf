from django.shortcuts import render, redirect
from django.views.generic import TemplateView
from django.contrib.auth.mixins import LoginRequiredMixin
from velzon.utils import getPageInitData, check_user_able_to_see_page
from .models import OverallTooltip
import pandas as pd 
# Create your views here.


class DashboardView(LoginRequiredMixin, TemplateView):
    def get(self, request):
        pageInfo = {
            "title": "DASHBOARD",
            "basePath": "dashboards/index"
        }
        results = getPageInitData("postgre/dashboards/initData.sql")
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SALE_DASHBOARD').values())
        results['chnm_nm'] = '대시보드 전체'
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"')     
        
        return render(request, 'dashboards/dashboards.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})


class SummaryView(LoginRequiredMixin, TemplateView):
    def get(self, request):
        group_list = [group[1] for group in list(self.request.user.groups.all().values_list())]
        
        if 'ADMIN' not in group_list:
            if 'ms' in group_list: 
                return redirect('/mscreening/')
            elif 'review' in group_list : 
                return redirect('/reviewanalysis/summary')
            elif 'keywordprod' in group_list : 
                return redirect('/keywordprod/')            
            else : 
                return redirect('/pages/pages/pages-hold-authentication')
        else:
            pageInfo = {
                "title": "Summary",
                "basePath": "dashboards/summary"
            }
            results = getPageInitData("postgre/dashboards/initData.sql")
            results['chnm_nm'] = '서머리'
            
            tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SUMMARY').values())
            
            tool_dict = {}
            for i in range(0, len(tooltips_data)) :
                tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"')     
            
            return render(request, 'dashboards/summary.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})
            
            

class TmallChina(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN')
    def get(self, request):
        pageInfo = {
            "title": "Tmall 내륙",
            "basePath": "dashboards/tmallchina"
        }
        results = getPageInitData("postgre/dashboards/initData.sql")
        results['chnm_nm'] = 'Tmall 내륙'
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SALE_DASHBOARD').values())
        
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            if tooltips_data.loc[i,'tab'] != 'FUNNEL':
                tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"')     
        return render(request, 'dashboards/dashboards.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})


class TmallGlobal(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN')
    def get(self, request):
        pageInfo = {
            "title": "Tmall 글로벌",
            "basePath": "dashboards/tmallglobal"
        }
        results = getPageInitData("postgre/dashboards/initData.sql")
        results['chnm_nm'] = 'Tmall 글로벌'
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SALE_DASHBOARD').values())
        
        tool_dict = {}
        for i in range(0, len(tooltips_data)) :
            if tooltips_data.loc[i,'tab'] != 'FUNNEL':
                tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"')      
        
        return render(request, 'dashboards/dashboards.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})


class DouyinChina(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN')
    def get(self, request):
        pageInfo = {
            "title": "Douyin 내륙",
            "basePath": "dashboards/douyinchina"
        }
        results = getPageInitData("postgre/dashboards/initData.sql")
        results['chnm_nm'] = 'Douyin 내륙'
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SALE_DASHBOARD').values())
        tool_dict = {}
        
        for i in range(0, len(tooltips_data)) :
            if tooltips_data.loc[i,'tab'] != 'FUNNEL':
                tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"')
        return render(request, 'dashboards/dashboards.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})


class DouyinGlobal(LoginRequiredMixin, TemplateView):
    @check_user_able_to_see_page('ADMIN')
    def get(self, request):
        pageInfo = {
            "title": "Douyin 글로벌",
            "basePath": "dashboards/douyinglobal"
        }
        results = getPageInitData("postgre/dashboards/initData.sql")
        results['chnm_nm'] = 'Douyin 글로벌'
        tooltips_data = pd.DataFrame(OverallTooltip.objects.using('dash').filter(section='SALE_DASHBOARD').values())
        tool_dict = {}
        
        for i in range(0, len(tooltips_data)) :
            if tooltips_data.loc[i,'tab'] != 'FUNNEL':
                tool_dict[tooltips_data.loc[i,'item']] = str('"') + tooltips_data.loc[i,'context'].format(**results)  + str('"') 
        
        return render(request, 'dashboards/dashboards.html', {"pageInfo": pageInfo, "initData": results, "toolTips" : tool_dict})
