# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class DgtSalestimeseriesgraphdata(models.Model):
    sale_amt_rmb = models.FloatField(blank=True, null=True)
    exre_amt_rmb = models.FloatField(blank=True, null=True)
    sale_amt_krw = models.FloatField(blank=True, null=True)
    exre_amt_krw = models.FloatField(blank=True, null=True)
    sale_amt_yoy_rmb = models.TextField(blank=True, null=True)
    exre_amt_yoy_rmb = models.TextField(blank=True, null=True)
    sale_amt_yoy_krw = models.TextField(blank=True, null=True)
    exre_amt_yoy_krw = models.TextField(blank=True, null=True)
    sale_rate_rmb = models.TextField(blank=True, null=True)
    exre_rate_rmb = models.TextField(blank=True, null=True)
    sale_rate_krw = models.TextField(blank=True, null=True)
    exre_rate_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salestimeseriesgraphdata'


class DgtAveragerevenuepercustomergraph(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_rmb = models.TextField(blank=True, null=True)
    y_val_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_averagerevenuepercustomergraph'


class DgtImpcardamtdata(models.Model):
    sale_amt_rmb = models.FloatField(blank=True, null=True)
    refd_amt_rmb = models.FloatField(blank=True, null=True)
    sale_amt_krw = models.FloatField(blank=True, null=True)
    refd_amt_krw = models.FloatField(blank=True, null=True)
    sale_rate_dod_rmb = models.FloatField(blank=True, null=True)
    refd_rate_dod_rmb = models.FloatField(blank=True, null=True)
    sale_rate_dod_krw = models.FloatField(blank=True, null=True)
    refd_rate_dod_krw = models.FloatField(blank=True, null=True)
    sale_amt_mnth_rmb = models.FloatField(blank=True, null=True)
    refd_amt_mnth_rmb = models.FloatField(blank=True, null=True)
    sale_amt_mnth_krw = models.FloatField(blank=True, null=True)
    refd_amt_mnth_krw = models.FloatField(blank=True, null=True)
    sale_rate_mnth_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rate_mnth_yoy_rmb = models.TextField(blank=True, null=True)
    sale_rate_mnth_yoy_krw = models.TextField(blank=True, null=True)
    refd_rate_mnth_yoy_krw = models.TextField(blank=True, null=True)
    sale_amt_year_rmb = models.FloatField(blank=True, null=True)
    refd_amt_year_rmb = models.FloatField(blank=True, null=True)
    sale_amt_year_krw = models.FloatField(blank=True, null=True)
    refd_amt_year_krw = models.FloatField(blank=True, null=True)
    sale_rate_year_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rate_year_yoy_rmb = models.TextField(blank=True, null=True)
    sale_rate_year_yoy_krw = models.TextField(blank=True, null=True)
    refd_rate_year_yoy_krw = models.TextField(blank=True, null=True)
    sale_amt_dod_rmb = models.FloatField(blank=True, null=True)
    refd_amt_dod_rmb = models.FloatField(blank=True, null=True)
    sale_amt_dod_krw = models.FloatField(blank=True, null=True)
    refd_amt_dod_krw = models.FloatField(blank=True, null=True)
    sale_amt_mnth_yoy_rmb = models.TextField(blank=True, null=True)
    refd_amt_mnth_yoy_rmb = models.TextField(blank=True, null=True)
    sale_amt_mnth_yoy_krw = models.TextField(blank=True, null=True)
    refd_amt_mnth_yoy_krw = models.TextField(blank=True, null=True)
    sale_amt_year_yoy_rmb = models.TextField(blank=True, null=True)
    refd_amt_year_yoy_rmb = models.TextField(blank=True, null=True)
    sale_amt_year_yoy_krw = models.TextField(blank=True, null=True)
    refd_amt_year_yoy_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_impcardamtdata'


class DgtLastyearcumulativerefundranking(models.Model):
    refd_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_yoy_rmb = models.TextField(blank=True, null=True)
    prod_nm_yoy_rmb = models.TextField(blank=True, null=True)
    refd_amt_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rate_yoy_rmb = models.TextField(blank=True, null=True)
    prod_id_rmb = models.BigIntegerField(blank=True, null=True)
    prod_nm_rmb = models.TextField(blank=True, null=True)
    refd_amt_rmb = models.FloatField(blank=True, null=True)
    refd_rate_rmb = models.FloatField(blank=True, null=True)
    prod_id_yoy_krw = models.TextField(blank=True, null=True)
    prod_nm_yoy_krw = models.TextField(blank=True, null=True)
    refd_amt_yoy_krw = models.TextField(blank=True, null=True)
    refd_rate_yoy_krw = models.TextField(blank=True, null=True)
    prod_id_krw = models.BigIntegerField(blank=True, null=True)
    prod_nm_krw = models.TextField(blank=True, null=True)
    refd_amt_krw = models.FloatField(blank=True, null=True)
    refd_rate_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_lastyearcumulativerefundranking'


class DgtSalesrefundtimeseriesallgraph(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_rmb = models.FloatField(blank=True, null=True)
    y_val_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salesrefundtimeseriesallgraph'


class DgtVisitdurationgraph(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitdurationgraph'


class DgtSalestimeseriesgraphbottom(models.Model):
    row_titl = models.TextField(blank=True, null=True)
    sale_amt_01_rmb = models.FloatField(blank=True, null=True)
    sale_amt_02_rmb = models.FloatField(blank=True, null=True)
    sale_amt_03_rmb = models.FloatField(blank=True, null=True)
    sale_amt_04_rmb = models.TextField(blank=True, null=True)
    sale_amt_05_rmb = models.FloatField(blank=True, null=True)
    sale_amt_06_rmb = models.FloatField(blank=True, null=True)
    sale_amt_07_rmb = models.FloatField(blank=True, null=True)
    sale_amt_08_rmb = models.FloatField(blank=True, null=True)
    sale_amt_09_rmb = models.FloatField(blank=True, null=True)
    sale_amt_10_rmb = models.FloatField(blank=True, null=True)
    sale_amt_11_rmb = models.FloatField(blank=True, null=True)
    sale_amt_12_rmb = models.FloatField(blank=True, null=True)
    exre_amt_01_rmb = models.FloatField(blank=True, null=True)
    exre_amt_02_rmb = models.FloatField(blank=True, null=True)
    exre_amt_03_rmb = models.FloatField(blank=True, null=True)
    exre_amt_04_rmb = models.TextField(blank=True, null=True)
    exre_amt_05_rmb = models.FloatField(blank=True, null=True)
    exre_amt_06_rmb = models.FloatField(blank=True, null=True)
    exre_amt_07_rmb = models.FloatField(blank=True, null=True)
    exre_amt_08_rmb = models.FloatField(blank=True, null=True)
    exre_amt_09_rmb = models.FloatField(blank=True, null=True)
    exre_amt_10_rmb = models.FloatField(blank=True, null=True)
    exre_amt_11_rmb = models.FloatField(blank=True, null=True)
    exre_amt_12_rmb = models.FloatField(blank=True, null=True)
    sale_amt_01_krw = models.FloatField(blank=True, null=True)
    sale_amt_02_krw = models.FloatField(blank=True, null=True)
    sale_amt_03_krw = models.FloatField(blank=True, null=True)
    sale_amt_04_krw = models.TextField(blank=True, null=True)
    sale_amt_05_krw = models.TextField(blank=True, null=True)
    sale_amt_06_krw = models.TextField(blank=True, null=True)
    sale_amt_07_krw = models.TextField(blank=True, null=True)
    sale_amt_08_krw = models.TextField(blank=True, null=True)
    sale_amt_09_krw = models.TextField(blank=True, null=True)
    sale_amt_10_krw = models.TextField(blank=True, null=True)
    sale_amt_11_krw = models.TextField(blank=True, null=True)
    sale_amt_12_krw = models.TextField(blank=True, null=True)
    exre_amt_01_krw = models.FloatField(blank=True, null=True)
    exre_amt_02_krw = models.FloatField(blank=True, null=True)
    exre_amt_03_krw = models.FloatField(blank=True, null=True)
    exre_amt_04_krw = models.TextField(blank=True, null=True)
    exre_amt_05_krw = models.TextField(blank=True, null=True)
    exre_amt_06_krw = models.TextField(blank=True, null=True)
    exre_amt_07_krw = models.TextField(blank=True, null=True)
    exre_amt_08_krw = models.TextField(blank=True, null=True)
    exre_amt_09_krw = models.TextField(blank=True, null=True)
    exre_amt_10_krw = models.TextField(blank=True, null=True)
    exre_amt_11_krw = models.TextField(blank=True, null=True)
    exre_amt_12_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salestimeseriesgraphbottom'


class DgtRegionaldistributionmapchart(models.Model):
    city_nm = models.TextField(blank=True, null=True)
    vist_cnt = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_regionaldistributionmapchart'


class DgtVisitoranalyticschart(models.Model):
    chrt_key = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_vist = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitoranalyticschart'


class DgtRefundamountyoy(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    row_titl = models.TextField(blank=True, null=True)
    refd_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rmb = models.FloatField(blank=True, null=True)
    refd_yoy_krw = models.TextField(blank=True, null=True)
    refd_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_refundamountyoy'


class DgtSalesrefundtimeseriesalldata(models.Model):
    refd_amt_rmb = models.FloatField(blank=True, null=True)
    refd_amt_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rate_rmb = models.TextField(blank=True, null=True)
    pcnt_amt_rmb = models.FloatField(blank=True, null=True)
    pcnt_amt_yoy_rmb = models.TextField(blank=True, null=True)
    pcnt_rate_rmb = models.FloatField(blank=True, null=True)
    refd_amt_krw = models.FloatField(blank=True, null=True)
    refd_amt_yoy_krw = models.TextField(blank=True, null=True)
    refd_rate_krw = models.TextField(blank=True, null=True)
    pcnt_amt_krw = models.FloatField(blank=True, null=True)
    pcnt_amt_yoy_krw = models.TextField(blank=True, null=True)
    pcnt_rate_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salesrefundtimeseriesalldata'


class DgtToprefundlastmonth(models.Model):
    refd_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_01_rmb = models.TextField(blank=True, null=True)
    prod_id_02_rmb = models.TextField(blank=True, null=True)
    prod_id_03_rmb = models.TextField(blank=True, null=True)
    prod_id_04_rmb = models.TextField(blank=True, null=True)
    prod_id_05_rmb = models.TextField(blank=True, null=True)
    prod_id_06_rmb = models.TextField(blank=True, null=True)
    prod_id_07_rmb = models.TextField(blank=True, null=True)
    prod_id_08_rmb = models.TextField(blank=True, null=True)
    prod_id_09_rmb = models.TextField(blank=True, null=True)
    prod_id_10_rmb = models.TextField(blank=True, null=True)
    prod_id_11_rmb = models.TextField(blank=True, null=True)
    prod_id_12_rmb = models.TextField(blank=True, null=True)
    prod_nm_01_rmb = models.TextField(blank=True, null=True)
    prod_nm_02_rmb = models.TextField(blank=True, null=True)
    prod_nm_03_rmb = models.TextField(blank=True, null=True)
    prod_nm_04_rmb = models.TextField(blank=True, null=True)
    prod_nm_05_rmb = models.TextField(blank=True, null=True)
    prod_nm_06_rmb = models.TextField(blank=True, null=True)
    prod_nm_07_rmb = models.TextField(blank=True, null=True)
    prod_nm_08_rmb = models.TextField(blank=True, null=True)
    prod_nm_09_rmb = models.TextField(blank=True, null=True)
    prod_nm_10_rmb = models.TextField(blank=True, null=True)
    prod_nm_11_rmb = models.TextField(blank=True, null=True)
    prod_nm_12_rmb = models.TextField(blank=True, null=True)
    refd_amt_01_rmb = models.FloatField(blank=True, null=True)
    refd_amt_02_rmb = models.FloatField(blank=True, null=True)
    refd_amt_03_rmb = models.FloatField(blank=True, null=True)
    refd_amt_04_rmb = models.TextField(blank=True, null=True)
    refd_amt_05_rmb = models.TextField(blank=True, null=True)
    refd_amt_06_rmb = models.TextField(blank=True, null=True)
    refd_amt_07_rmb = models.TextField(blank=True, null=True)
    refd_amt_08_rmb = models.TextField(blank=True, null=True)
    refd_amt_09_rmb = models.TextField(blank=True, null=True)
    refd_amt_10_rmb = models.TextField(blank=True, null=True)
    refd_amt_11_rmb = models.TextField(blank=True, null=True)
    refd_amt_12_rmb = models.TextField(blank=True, null=True)
    prod_id_01_krw = models.TextField(blank=True, null=True)
    prod_id_02_krw = models.TextField(blank=True, null=True)
    prod_id_03_krw = models.TextField(blank=True, null=True)
    prod_id_04_krw = models.TextField(blank=True, null=True)
    prod_id_05_krw = models.TextField(blank=True, null=True)
    prod_id_06_krw = models.TextField(blank=True, null=True)
    prod_id_07_krw = models.TextField(blank=True, null=True)
    prod_id_08_krw = models.TextField(blank=True, null=True)
    prod_id_09_krw = models.TextField(blank=True, null=True)
    prod_id_10_krw = models.TextField(blank=True, null=True)
    prod_id_11_krw = models.TextField(blank=True, null=True)
    prod_id_12_krw = models.TextField(blank=True, null=True)
    prod_nm_01_krw = models.TextField(blank=True, null=True)
    prod_nm_02_krw = models.TextField(blank=True, null=True)
    prod_nm_03_krw = models.TextField(blank=True, null=True)
    prod_nm_04_krw = models.TextField(blank=True, null=True)
    prod_nm_05_krw = models.TextField(blank=True, null=True)
    prod_nm_06_krw = models.TextField(blank=True, null=True)
    prod_nm_07_krw = models.TextField(blank=True, null=True)
    prod_nm_08_krw = models.TextField(blank=True, null=True)
    prod_nm_09_krw = models.TextField(blank=True, null=True)
    prod_nm_10_krw = models.TextField(blank=True, null=True)
    prod_nm_11_krw = models.TextField(blank=True, null=True)
    prod_nm_12_krw = models.TextField(blank=True, null=True)
    refd_amt_01_krw = models.FloatField(blank=True, null=True)
    refd_amt_02_krw = models.FloatField(blank=True, null=True)
    refd_amt_03_krw = models.FloatField(blank=True, null=True)
    refd_amt_04_krw = models.TextField(blank=True, null=True)
    refd_amt_05_krw = models.TextField(blank=True, null=True)
    refd_amt_06_krw = models.TextField(blank=True, null=True)
    refd_amt_07_krw = models.TextField(blank=True, null=True)
    refd_amt_08_krw = models.TextField(blank=True, null=True)
    refd_amt_09_krw = models.TextField(blank=True, null=True)
    refd_amt_10_krw = models.TextField(blank=True, null=True)
    refd_amt_11_krw = models.TextField(blank=True, null=True)
    refd_amt_12_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_toprefundlastmonth'


class DgtDayofweekvisitorcounttimeseries(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_dayofweekvisitorcounttimeseries'


class DgtProductrefundmast(models.Model):
    prod_id = models.TextField(blank=True, null=True)
    prod_nm = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_productrefundmast'


class DgtSalesrankinglymom(models.Model):
    sale_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_yoy_rmb = models.TextField(blank=True, null=True)
    prod_nm_yoy_rmb = models.TextField(blank=True, null=True)
    sale_amt_yoy_rmb = models.FloatField(blank=True, null=True)
    prod_id_rmb = models.TextField(blank=True, null=True)
    prod_nm_rmb = models.TextField(blank=True, null=True)
    sale_amt_rmb = models.FloatField(blank=True, null=True)
    prod_id_yoy_krw = models.TextField(blank=True, null=True)
    prod_nm_yoy_krw = models.TextField(blank=True, null=True)
    sale_amt_yoy_krw = models.FloatField(blank=True, null=True)
    prod_id_krw = models.TextField(blank=True, null=True)
    prod_nm_krw = models.TextField(blank=True, null=True)
    sale_amt_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salesrankinglymom'


class DgtSalestimeseriesgraphchart(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_rmb = models.FloatField(blank=True, null=True)
    y_val_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salestimeseriesgraphchart'


class DgtWeekdaynewbuyerratiotornado(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    y_week = models.TextField(blank=True, null=True)
    x_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_weekdaynewbuyerratiotornado'


class DgtGenderdistributionbarchart(models.Model):
    x_val = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_genderdistributionbarchart'


class DgtVisitoranalyticscard(models.Model):
    vist_cnt = models.FloatField(blank=True, null=True)
    vist_cnt_mnth = models.FloatField(blank=True, null=True)
    vist_cnt_year = models.FloatField(blank=True, null=True)
    cust_amt_rmb = models.FloatField(blank=True, null=True)
    cust_amt_krw = models.FloatField(blank=True, null=True)
    stay_time = models.FloatField(blank=True, null=True)
    frst_cnt = models.FloatField(blank=True, null=True)
    frst_rate = models.FloatField(blank=True, null=True)
    paid_cnt = models.FloatField(blank=True, null=True)
    paid_rate = models.FloatField(blank=True, null=True)
    vist_rate = models.FloatField(blank=True, null=True)
    vist_rate_mnth = models.TextField(blank=True, null=True)
    vist_rate_year = models.TextField(blank=True, null=True)
    cust_rate_rmb = models.TextField(blank=True, null=True)
    cust_rate_krw = models.TextField(blank=True, null=True)
    stay_rate = models.TextField(blank=True, null=True)
    vist_cnt_mom = models.FloatField(blank=True, null=True)
    vist_cnt_mnth_yoy = models.TextField(blank=True, null=True)
    vist_cnt_year_yoy = models.TextField(blank=True, null=True)
    cust_amt_yoy_rmb = models.TextField(blank=True, null=True)
    cust_amt_yoy_krw = models.TextField(blank=True, null=True)
    stay_time_yoy = models.TextField(blank=True, null=True)
    frst_cnt_yoy = models.TextField(blank=True, null=True)
    frst_rate_yoy = models.FloatField(blank=True, null=True)
    paid_cnt_yoy = models.TextField(blank=True, null=True)
    paid_rate_yoy = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitoranalyticscard'


class DgtProductsalesmast(models.Model):
    prod_id = models.TextField(blank=True, null=True)
    prod_nm = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_productsalesmast'


class DgtRefunddatabymonth(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    row_titl = models.TextField(blank=True, null=True)
    refd_01_rmb = models.FloatField(blank=True, null=True)
    refd_02_rmb = models.FloatField(blank=True, null=True)
    refd_03_rmb = models.FloatField(blank=True, null=True)
    refd_04_rmb = models.TextField(blank=True, null=True)
    refd_05_rmb = models.TextField(blank=True, null=True)
    refd_06_rmb = models.TextField(blank=True, null=True)
    refd_07_rmb = models.TextField(blank=True, null=True)
    refd_08_rmb = models.TextField(blank=True, null=True)
    refd_09_rmb = models.TextField(blank=True, null=True)
    refd_10_rmb = models.TextField(blank=True, null=True)
    refd_11_rmb = models.TextField(blank=True, null=True)
    refd_12_rmb = models.TextField(blank=True, null=True)
    refd_01_krw = models.FloatField(blank=True, null=True)
    refd_02_krw = models.FloatField(blank=True, null=True)
    refd_03_krw = models.FloatField(blank=True, null=True)
    refd_04_krw = models.TextField(blank=True, null=True)
    refd_05_krw = models.TextField(blank=True, null=True)
    refd_06_krw = models.TextField(blank=True, null=True)
    refd_07_krw = models.TextField(blank=True, null=True)
    refd_08_krw = models.TextField(blank=True, null=True)
    refd_09_krw = models.TextField(blank=True, null=True)
    refd_10_krw = models.TextField(blank=True, null=True)
    refd_11_krw = models.TextField(blank=True, null=True)
    refd_12_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_refunddatabymonth'


class DgtRefundtimeseriesbyproduct(models.Model):
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_refd_rmb = models.FloatField(blank=True, null=True)
    y_val_rate_rmb = models.FloatField(blank=True, null=True)
    y_val_refd_krw = models.FloatField(blank=True, null=True)
    y_val_rate_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_refundtimeseriesbyproduct'


class DgtRegionaldistributionbarchart(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    x_val = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_regionaldistributionbarchart'


class DgtVisitortimeserieschart(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    l_lgnd_id = models.TextField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitortimeserieschart'


class DgtRefundcomparisonlastyear(models.Model):
    refd_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_yoy_rmb = models.TextField(blank=True, null=True)
    prod_nm_yoy_rmb = models.TextField(blank=True, null=True)
    refd_amt_yoy_rmb = models.TextField(blank=True, null=True)
    refd_rate_yoy_rmb = models.TextField(blank=True, null=True)
    prod_id_rmb = models.TextField(blank=True, null=True)
    prod_nm_rmb = models.TextField(blank=True, null=True)
    refd_amt_rmb = models.FloatField(blank=True, null=True)
    refd_rate_rmb = models.FloatField(blank=True, null=True)
    prod_id_yoy_krw = models.TextField(blank=True, null=True)
    prod_nm_yoy_krw = models.TextField(blank=True, null=True)
    refd_amt_yoy_krw = models.TextField(blank=True, null=True)
    refd_rate_yoy_krw = models.TextField(blank=True, null=True)
    prod_id_krw = models.TextField(blank=True, null=True)
    prod_nm_krw = models.TextField(blank=True, null=True)
    refd_amt_krw = models.FloatField(blank=True, null=True)
    refd_rate_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_refundcomparisonlastyear'


class DgtProductsalestimeseries(models.Model):
    l_lgnd_id = models.BigIntegerField(blank=True, null=True)
    l_lgnd_nm = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_sale_rmb = models.FloatField(blank=True, null=True)
    y_val_exre_rmb = models.FloatField(blank=True, null=True)
    y_val_sale_krw = models.FloatField(blank=True, null=True)
    y_val_exre_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_productsalestimeseries'


class DgtAveragedwelltimebydayofweek(models.Model):
    sort_key = models.BigIntegerField(blank=True, null=True)
    x_week = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_averagedwelltimebydayofweek'


class DgtVisitortimeseriescard(models.Model):
    vist_cnt = models.FloatField(blank=True, null=True)
    vist_cnt_yoy = models.TextField(blank=True, null=True)
    vist_rate = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitortimeseriescard'


class DgtAgedistributionbarchart(models.Model):
    x_val = models.TextField(blank=True, null=True)
    y_val = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_agedistributionbarchart'


class DgtVisitortimeseriesbottom(models.Model):
    row_titl = models.TextField(blank=True, null=True)
    vist_cnt_01 = models.TextField(blank=True, null=True)
    vist_cnt_02 = models.TextField(blank=True, null=True)
    vist_cnt_03 = models.TextField(blank=True, null=True)
    vist_cnt_04 = models.TextField(blank=True, null=True)
    vist_cnt_05 = models.TextField(blank=True, null=True)
    vist_cnt_06 = models.TextField(blank=True, null=True)
    vist_cnt_07 = models.TextField(blank=True, null=True)
    vist_cnt_08 = models.TextField(blank=True, null=True)
    vist_cnt_09 = models.TextField(blank=True, null=True)
    vist_cnt_10 = models.TextField(blank=True, null=True)
    vist_cnt_11 = models.TextField(blank=True, null=True)
    vist_cnt_12 = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_visitortimeseriesbottom'


class DgtRefundrankinglymom(models.Model):
    refd_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_yoy_rmb = models.TextField(blank=True, null=True)
    prod_nm_yoy_rmb = models.TextField(blank=True, null=True)
    refd_amt_yoy_rmb = models.FloatField(blank=True, null=True)
    prod_id_rmb = models.TextField(blank=True, null=True)
    prod_nm_rmb = models.TextField(blank=True, null=True)
    refd_amt_rmb = models.FloatField(blank=True, null=True)
    prod_id_yoy_krw = models.TextField(blank=True, null=True)
    prod_nm_yoy_krw = models.TextField(blank=True, null=True)
    refd_amt_yoy_krw = models.FloatField(blank=True, null=True)
    prod_id_krw = models.TextField(blank=True, null=True)
    prod_nm_krw = models.TextField(blank=True, null=True)
    refd_amt_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_refundrankinglymom'


class DgtTopsaleslastmonth(models.Model):
    sale_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_01_rmb = models.TextField(blank=True, null=True)
    prod_id_02_rmb = models.TextField(blank=True, null=True)
    prod_id_03_rmb = models.TextField(blank=True, null=True)
    prod_id_04_rmb = models.TextField(blank=True, null=True)
    prod_id_05_rmb = models.TextField(blank=True, null=True)
    prod_id_06_rmb = models.TextField(blank=True, null=True)
    prod_id_07_rmb = models.TextField(blank=True, null=True)
    prod_id_08_rmb = models.TextField(blank=True, null=True)
    prod_id_09_rmb = models.TextField(blank=True, null=True)
    prod_id_10_rmb = models.TextField(blank=True, null=True)
    prod_id_11_rmb = models.TextField(blank=True, null=True)
    prod_id_12_rmb = models.TextField(blank=True, null=True)
    prod_nm_01_rmb = models.TextField(blank=True, null=True)
    prod_nm_02_rmb = models.TextField(blank=True, null=True)
    prod_nm_03_rmb = models.TextField(blank=True, null=True)
    prod_nm_04_rmb = models.TextField(blank=True, null=True)
    prod_nm_05_rmb = models.TextField(blank=True, null=True)
    prod_nm_06_rmb = models.TextField(blank=True, null=True)
    prod_nm_07_rmb = models.TextField(blank=True, null=True)
    prod_nm_08_rmb = models.TextField(blank=True, null=True)
    prod_nm_09_rmb = models.TextField(blank=True, null=True)
    prod_nm_10_rmb = models.TextField(blank=True, null=True)
    prod_nm_11_rmb = models.TextField(blank=True, null=True)
    prod_nm_12_rmb = models.TextField(blank=True, null=True)
    sale_amt_01_rmb = models.FloatField(blank=True, null=True)
    sale_amt_02_rmb = models.FloatField(blank=True, null=True)
    sale_amt_03_rmb = models.FloatField(blank=True, null=True)
    sale_amt_04_rmb = models.TextField(blank=True, null=True)
    sale_amt_05_rmb = models.TextField(blank=True, null=True)
    sale_amt_06_rmb = models.TextField(blank=True, null=True)
    sale_amt_07_rmb = models.TextField(blank=True, null=True)
    sale_amt_08_rmb = models.TextField(blank=True, null=True)
    sale_amt_09_rmb = models.TextField(blank=True, null=True)
    sale_amt_10_rmb = models.TextField(blank=True, null=True)
    sale_amt_11_rmb = models.TextField(blank=True, null=True)
    sale_amt_12_rmb = models.TextField(blank=True, null=True)
    prod_id_01_krw = models.TextField(blank=True, null=True)
    prod_id_02_krw = models.TextField(blank=True, null=True)
    prod_id_03_krw = models.TextField(blank=True, null=True)
    prod_id_04_krw = models.TextField(blank=True, null=True)
    prod_id_05_krw = models.TextField(blank=True, null=True)
    prod_id_06_krw = models.TextField(blank=True, null=True)
    prod_id_07_krw = models.TextField(blank=True, null=True)
    prod_id_08_krw = models.TextField(blank=True, null=True)
    prod_id_09_krw = models.TextField(blank=True, null=True)
    prod_id_10_krw = models.TextField(blank=True, null=True)
    prod_id_11_krw = models.TextField(blank=True, null=True)
    prod_id_12_krw = models.TextField(blank=True, null=True)
    prod_nm_01_krw = models.TextField(blank=True, null=True)
    prod_nm_02_krw = models.TextField(blank=True, null=True)
    prod_nm_03_krw = models.TextField(blank=True, null=True)
    prod_nm_04_krw = models.TextField(blank=True, null=True)
    prod_nm_05_krw = models.TextField(blank=True, null=True)
    prod_nm_06_krw = models.TextField(blank=True, null=True)
    prod_nm_07_krw = models.TextField(blank=True, null=True)
    prod_nm_08_krw = models.TextField(blank=True, null=True)
    prod_nm_09_krw = models.TextField(blank=True, null=True)
    prod_nm_10_krw = models.TextField(blank=True, null=True)
    prod_nm_11_krw = models.TextField(blank=True, null=True)
    prod_nm_12_krw = models.TextField(blank=True, null=True)
    sale_amt_01_krw = models.FloatField(blank=True, null=True)
    sale_amt_02_krw = models.FloatField(blank=True, null=True)
    sale_amt_03_krw = models.FloatField(blank=True, null=True)
    sale_amt_04_krw = models.TextField(blank=True, null=True)
    sale_amt_05_krw = models.TextField(blank=True, null=True)
    sale_amt_06_krw = models.TextField(blank=True, null=True)
    sale_amt_07_krw = models.TextField(blank=True, null=True)
    sale_amt_08_krw = models.TextField(blank=True, null=True)
    sale_amt_09_krw = models.TextField(blank=True, null=True)
    sale_amt_10_krw = models.TextField(blank=True, null=True)
    sale_amt_11_krw = models.TextField(blank=True, null=True)
    sale_amt_12_krw = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_topsaleslastmonth'


class DgtImpcardamtchart(models.Model):
    chrt_key = models.TextField(blank=True, null=True)
    x_dt = models.TextField(blank=True, null=True)
    y_val_sale_rmb = models.FloatField(blank=True, null=True)
    y_val_refd_rmb = models.FloatField(blank=True, null=True)
    y_val_sale_krw = models.FloatField(blank=True, null=True)
    y_val_refd_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_impcardamtchart'


class DgtDayofweekvisitorcountbottom(models.Model):
    row_titl = models.TextField(blank=True, null=True)
    col_val_01 = models.FloatField(blank=True, null=True)
    col_val_02 = models.FloatField(blank=True, null=True)
    col_val_03 = models.FloatField(blank=True, null=True)
    col_val_04 = models.TextField(blank=True, null=True)
    col_val_05 = models.TextField(blank=True, null=True)
    col_val_06 = models.TextField(blank=True, null=True)
    col_val_07 = models.TextField(blank=True, null=True)
    col_val_08 = models.TextField(blank=True, null=True)
    col_val_09 = models.TextField(blank=True, null=True)
    col_val_10 = models.TextField(blank=True, null=True)
    col_val_11 = models.TextField(blank=True, null=True)
    col_val_12 = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_dayofweekvisitorcountbottom'


class DgtSalescomparisonlastyear(models.Model):
    sale_rank = models.BigIntegerField(blank=True, null=True)
    prod_id_yoy_rmb = models.TextField(blank=True, null=True)
    prod_nm_yoy_rmb = models.TextField(blank=True, null=True)
    sale_amt_yoy_rmb = models.TextField(blank=True, null=True)
    sale_rate_yoy_rmb = models.TextField(blank=True, null=True)
    prod_id_rmb = models.TextField(blank=True, null=True)
    prod_nm_rmb = models.TextField(blank=True, null=True)
    sale_amt_rmb = models.FloatField(blank=True, null=True)
    sale_rate_rmb = models.FloatField(blank=True, null=True)
    prod_id_yoy_krw = models.TextField(blank=True, null=True)
    prod_nm_yoy_krw = models.TextField(blank=True, null=True)
    sale_amt_yoy_krw = models.TextField(blank=True, null=True)
    sale_rate_yoy_krw = models.TextField(blank=True, null=True)
    prod_id_krw = models.TextField(blank=True, null=True)
    prod_nm_krw = models.TextField(blank=True, null=True)
    sale_amt_krw = models.FloatField(blank=True, null=True)
    sale_rate_krw = models.FloatField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dgt_salescomparisonlastyear'

class OverallTooltip(models.Model):
    section = models.TextField(db_column='SECTION', blank=True, null=True)  # Field name made lowercase.
    tab = models.TextField(db_column='TAB', blank=True, null=False, primary_key= True)  # Field name made lowercase.
    item = models.TextField(db_column='ITEM', blank=True, null=True)  # Field name made lowercase.
    context = models.TextField(db_column='CONTEXT', blank=True, null=True)  # Field name made lowercase.
    position = models.TextField(db_column='POSITION', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'overall_tooltip'
