with WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT     /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'    */
              ,CAST({TO_DT} AS DATE) AS TO_DT     /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'    */
    ), wt_barcode as (
	select 
	item_code																								as item_code
	,statistics_date																						as date
	,all_sales_item_qty * sale_tag_item_price_rmb 															as sale_tag_item_price_rmb 
	,all_sales_item_qty * sale_tag_item_price_krw 															as sale_tag_item_price_krw
	,all_sales_item_qty																						as qty
	,all_sale_item_amount_rmb 																				as sale_item_price_rmb 
	,all_sale_item_amount_krw 																				as sale_item_price_krw 
	from DASH.{TAG}_PRICEANLAYSISITEMTIMESERIES
    where STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE) 
	), wt_sum as(
	select 
	CAST(date AS DATE)																			            as X_DT 
	,case when coalesce(sum(sale_tag_item_price_rmb), 0 ) = 0 then 0  
	else round(((sum(sale_item_price_rmb )/sum(sale_tag_item_price_rmb ))::Numeric) * 100, 2) end			as disc_rate_rmb
	,case when coalesce(sum(sale_tag_item_price_krw), 0 ) = 0 then 0  
	else round(((sum(sale_item_price_krw )/sum(sale_tag_item_price_krw ))::numeric) * 100, 2) end			as disc_rate_krw
	,case when coalesce(sum(sale_tag_item_price_krw), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_krw )/sum(qty))::numeric),2)   end									as tag_krw
	,case when coalesce(sum(sale_tag_item_price_rmb), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_rmb )/sum(qty))::numeric),2)   end									as tag_rmb
	,case when coalesce(sum(sale_item_price_krw ), 0 ) = 0 then 0  
	else round(((sum(sale_item_price_krw  )/sum(qty))::numeric),2)   end									as amt_krw
	,case when coalesce(sum(sale_item_price_rmb ), 0 ) = 0 then 0  
	else round(((sum(sale_item_price_rmb  )/sum(qty))::numeric),2)   end									as amt_rmb
	,case when coalesce(sum(sale_tag_item_price_krw), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_krw )/sum(qty)*0.7)::numeric),2)   end								as d30_krw
	,case when coalesce(sum(sale_tag_item_price_rmb), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_rmb )/sum(qty)*0.7)::numeric),2)   end								as d30_rmb
	,case when coalesce(sum(sale_tag_item_price_krw), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_krw )/sum(qty)*0.5)::numeric),2)   end								as d50_krw
	,case when coalesce(sum(sale_tag_item_price_rmb), 0 ) = 0 then 0  
	else round(((sum(sale_tag_item_price_rmb )/sum(qty)*0.5)::numeric),2)   end								as d50_rmb

	from wt_barcode 
	where sale_item_price_rmb  > 0 and sale_tag_item_price_rmb  > 0 
	group by X_DT
	order by X_DT
	
	), wt_sum_pie as (

	select case when 100 - disc_rate_rmb <= 30 then 1 
			else 0 	 end																						as D00_CNT_RMB
		  ,case when 100 - disc_rate_krw <= 30  then 1 
			else 0 		end																					as D00_CNT_KRW
		  ,case when 100 - disc_rate_rmb > 30 and 100 - disc_rate_rmb <= 50  then 1 
			else 0 		end	    																			as D30_CNT_RMB
		  ,case when 100 - disc_rate_krw > 30 and 100 - disc_rate_krw <= 50  then 1 
			else 0 		end																					as D30_CNT_KRW
		  ,case when 100 - disc_rate_rmb > 50  then 1 
			else 0 		end																					as D50_CNT_RMB
		  ,case when 100 - disc_rate_krw > 50  then 1 
			else 0 		end																					as D50_CNT_KRW
	
	from wt_sum
	) select 
		sum(D00_CNT_RMB) as D00_CNT_RMB   /*   ~30%   할인율 발생일수 - 위안화 */
		,sum(D00_CNT_KRW) as D00_CNT_KRW   /*   ~30%   할인율 발생일수 - 원화   */
		,sum(D30_CNT_RMB) as D30_CNT_RMB   /* 30~50%   할인율 발생일수 - 위안화 */	
		,sum(D30_CNT_KRW) as D30_CNT_KRW   	/* 30~50%   할인율 발생일수 - 원화   */
		,sum(D50_CNT_RMB) as D50_CNT_RMB   /* 50% 이상 할인율 발생일수 - 위안화 */
		,sum(D50_CNT_KRW) as D50_CNT_KRW   /* 50% 이상 할인율 발생일수 - 원화   */
	from wt_sum_pie
	
	
	