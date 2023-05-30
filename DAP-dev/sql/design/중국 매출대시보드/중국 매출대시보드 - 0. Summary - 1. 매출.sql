● 중국 매출대시보드 - 0. Summary - 1. 매출

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 대시보드 매출과 관련된 Summary
    * Comment : 할인일수 CARD에 숫자 두개 최근 30일 + 연누적


1. 중요정보 카드 - 매출 금액
    * 데이터 카드 제공 : 카드내용(Tmall 내륙 + Tmall 글로벌 + Douyin 내륙 + Douyin 글로벌)의 전일매출(환불),월별 누적매출(환불). 연간 누적 매출(환불)
2. 중요정보 카드 - 매출 비율
    * 올해 중국채널의 전체 TARGET 대비 누적 매출 비율
3. 중요정보 카드 - 브랜드 매출 순위
    * Tmall 내 브랜드 순위, 한국브랜드순위, (카테고리는 전체 기준) Douyin또한 브랜드 순위, 한국브랜드 순위(카테고리는 전체 기준)

/* 1. 중요정보 카드 - 매출 금액, 매출 비율, 브랜드 매출 순위 SQL */
WITH WT_SALE AS
    (
        SELECT SALE_AMT_RMB              /* 전일 매출                - 위안화 */
              ,SALE_RATE_DAY_YOY_RMB     /* 전일 매출 비율 YoY       - 위안화 */
              ,SALE_AMT_MNTH_RMB         /* 월별 누적 매출           - 위안화 */
              ,SALE_RATE_MNTH_MOM_RMB    /* 월별 누적 매출 비율 MoM  - 위안화 */
              ,SALE_RATE_MNTH_YOY_RMB    /* 월별 누적 매출 비율 YoY  - 위안화 */
              ,SALE_AMT_YEAR_RMB         /* 연간 누적 매출           - 위안화 */
              ,SALE_RATE_YEAR_YOY_RMB    /* 연간 누적 매출 비율 YoY  - 위안화 */
              ,SALE_AMT_KRW              /* 전일 매출                - 원화   */
              ,SALE_RATE_DAY_YOY_KRW     /* 전일 매출 비율 YoY       - 원화   */
              ,SALE_AMT_MNTH_KRW         /* 월별 누적 매출           - 원화   */
              ,SALE_RATE_MNTH_MOM_KRW    /* 월별 누적 매출 비율 MoM  - 원화   */
              ,SALE_RATE_MNTH_YOY_KRW    /* 월별 누적 매출 비율 YoY  - 원화   */
              ,SALE_AMT_YEAR_KRW         /* 연간 누적 매출           - 원화   */
              ,SALE_RATE_YEAR_YOY_KRW    /* 연간 누적 매출 비율 YoY  - 원화   */

              ,REFD_AMT_RMB              /* 전일 환불                - 위안화 */
              ,REFD_RATE_DAY_YOY_RMB     /* 전일 환불 비율 YoY       - 위안화 */
              ,REFD_AMT_MNTH_RMB         /* 월별 누적 환불           - 위안화 */
              ,REFD_RATE_MNTH_MOM_RMB    /* 월별 누적 환불 비율 MoM  - 위안화 */
              ,REFD_RATE_MNTH_YOY_RMB    /* 월별 누적 환불 비율 YoY  - 위안화 */
              ,REFD_AMT_YEAR_RMB         /* 연간 누적 환불           - 위안화 */
              ,REFD_RATE_YEAR_YOY_RMB    /* 연간 누적 환불 비율 YoY  - 위안화 */
              ,REFD_AMT_KRW              /* 전일 환불                - 원화   */
              ,REFD_RATE_DAY_YOY_KRW     /* 전일 환불 비율 YoY       - 원화   */
              ,REFD_AMT_MNTH_KRW         /* 월별 누적 환불           - 원화   */
              ,REFD_RATE_MNTH_MOM_KRW    /* 월별 누적 환불 비율 MoM  - 원화   */
              ,REFD_RATE_MNTH_YOY_KRW    /* 월별 누적 환불 비율 YoY  - 원화   */
              ,REFD_AMT_YEAR_KRW         /* 연간 누적 환불           - 원화   */
              ,REFD_RATE_YEAR_YOY_KRW    /* 연간 누적 환불 비율 YoY  - 원화   */
          FROM DASH.SUM_IMPCARDAMTDATA
    ), WT_RANK AS 
    (
        SELECT MAX(DCT_RANK_TOT     ) AS DCT_RANK_TOT       /* Tmall  내륙   매출 순위      */
              ,MAX(DGT_RANK_TOT     ) AS DGT_RANK_TOT       /* Tmall  글로벌 매출 순위      */
              ,MAX(DCD_RANK_TOT     ) AS DCD_RANK_TOT       /* Douyin 내륙   매출 순위      */
              ,MAX(DGD_RANK_TOT     ) AS DGD_RANK_TOT       /* Douyin 글로벌 매출 순위      */
              ,MAX(DCT_RANK_TOT_DIFF) AS DCT_RANK_TOT_DIFF  /* Tmall  내륙   매출 순위 변화 */
              ,MAX(DGT_RANK_TOT_DIFF) AS DGT_RANK_TOT_DIFF  /* Tmall  글로벌 매출 순위 변화 */
              ,MAX(DCD_RANK_TOT_DIFF) AS DCD_RANK_TOT_DIFF  /* Douyin 내륙   매출 순위 변화 */
              ,MAX(DGD_RANK_TOT_DIFF) AS DGD_RANK_TOT_DIFF  /* Douyin 글로벌 매출 순위 변화 */
          FROM DASH.SUM_RANKCARDDATA
    ), WT_REVN_TAGT AS
    (
        SELECT SUM("revenueTarget") * 1000000 AS REVN_TAGT_AMT  /* 한화로 백만원 단위 */
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN ('Tmall China', 'Tmall Global', 'Douyin China', 'Douyin Global')
    )
    SELECT CAST(SALE_AMT_RMB           AS DECIMAL(20,2)) AS SALE_AMT_RMB            /* 전일 매출                - 위안화 */
          ,CAST(SALE_RATE_DAY_YOY_RMB  AS DECIMAL(20,2)) AS SALE_RATE_DAY_YOY_RMB   /* 전일 매출 비율 YoY       - 위안화 */
          ,CAST(SALE_AMT_MNTH_RMB      AS DECIMAL(20,2)) AS SALE_AMT_MNTH_RMB       /* 월별 누적 매출           - 위안화 */
          ,CAST(SALE_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_MNTH_YOY_RMB  /* 월별 누적 매출 비율 YoY  - 위안화 */
          ,CAST(SALE_AMT_YEAR_RMB      AS DECIMAL(20,2)) AS SALE_AMT_YEAR_RMB       /* 연간 누적 매출           - 위안화 */
          ,CAST(SALE_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_RMB  /* 연간 누적 매출 비율 YoY  - 위안화 */
          ,CAST(SALE_AMT_KRW           AS DECIMAL(20,2)) AS SALE_AMT_KRW            /* 전일 매출                - 원화   */
          ,CAST(SALE_RATE_DAY_YOY_KRW  AS DECIMAL(20,2)) AS SALE_RATE_DAY_YOY_KRW   /* 전일 매출 비율 YoY       - 원화   */
          ,CAST(SALE_AMT_MNTH_KRW      AS DECIMAL(20,2)) AS SALE_AMT_MNTH_KRW       /* 월별 누적 매출           - 원화   */
          ,CAST(SALE_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_MNTH_YOY_KRW  /* 월별 누적 매출 비율 YoY  - 원화   */
          ,CAST(SALE_AMT_YEAR_KRW      AS DECIMAL(20,2)) AS SALE_AMT_YEAR_KRW       /* 연간 누적 매출           - 원화   */
          ,CAST(SALE_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_KRW  /* 연간 누적 매출 비율 YoY  - 원화   */

          ,CAST(REFD_AMT_RMB           AS DECIMAL(20,2)) AS REFD_AMT_RMB            /* 전일 환불                - 위안화 */
          ,CAST(REFD_RATE_DAY_YOY_RMB  AS DECIMAL(20,2)) AS REFD_RATE_DAY_YOY_RMB   /* 전일 환불 비율 YoY       - 위안화 */
          ,CAST(REFD_AMT_MNTH_RMB      AS DECIMAL(20,2)) AS REFD_AMT_MNTH_RMB       /* 월별 누적 환불           - 위안화 */
          ,CAST(REFD_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_MNTH_YOY_RMB  /* 월별 누적 환불 비율 YoY  - 위안화 */
          ,CAST(REFD_AMT_YEAR_RMB      AS DECIMAL(20,2)) AS REFD_AMT_YEAR_RMB       /* 연간 누적 환불           - 위안화 */
          ,CAST(REFD_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_RMB  /* 연간 누적 환불 비율 YoY  - 위안화 */
          ,CAST(REFD_AMT_KRW           AS DECIMAL(20,2)) AS REFD_AMT_KRW            /* 전일 환불                - 원화   */
          ,CAST(REFD_RATE_DAY_YOY_KRW  AS DECIMAL(20,2)) AS REFD_RATE_DAY_YOY_KRW   /* 전일 환불 비율 YoY       - 원화   */
          ,CAST(REFD_AMT_MNTH_KRW      AS DECIMAL(20,2)) AS REFD_AMT_MNTH_KRW       /* 월별 누적 환불           - 원화   */
          ,CAST(REFD_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_MNTH_YOY_KRW  /* 월별 누적 환불 비율 YoY  - 원화   */
          ,CAST(REFD_AMT_YEAR_KRW      AS DECIMAL(20,2)) AS REFD_AMT_YEAR_KRW       /* 연간 누적 환불           - 원화   */
          ,CAST(REFD_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_KRW  /* 연간 누적 환불 비율 YoY  - 원화   */

          ,DCT_RANK_TOT       /* Tmall  내륙   매출 순위      */
          ,DGT_RANK_TOT       /* Tmall  글로벌 매출 순위      */
          ,DCD_RANK_TOT       /* Douyin 내륙   매출 순위      */
          ,DGD_RANK_TOT       /* Douyin 글로벌 매출 순위      */
          ,DCT_RANK_TOT_DIFF  /* Tmall  내륙   매출 순위 변화 */
          ,DGT_RANK_TOT_DIFF  /* Tmall  글로벌 매출 순위 변화 */
          ,DCD_RANK_TOT_DIFF  /* Douyin 내륙   매출 순위 변화 */
          ,DGD_RANK_TOT_DIFF  /* Douyin 글로벌 매출 순위 변화 */

          ,REVN_TAGT_AMT                                                                    /* 당해 Target 대비 누적 매출 비용 - 원화 */
          ,CAST(SALE_AMT_YEAR_KRW / REVN_TAGT_AMT * 100 AS DECIMAL(20,2)) AS REVN_TAGT_RATE /* 당해 Target 대비 누적 매출 비용 - 원화 */
      FROM WT_SALE      A
          ,WT_RANK      B
          ,WT_REVN_TAGT C
;

/* 1. 중요정보 카드 - Chart SQL */
WITH WT_BASE AS
    (
        SELECT CHRT_KEY        /* 그래프 키 (DAY, MNTH, YEAR) */
              ,X_DT            /* 일자                      */
              ,Y_VAL_SALE_RMB  /* 매출 - 위안화             */
              ,Y_VAL_REFD_RMB  /* 환불 - 위안화             */
              ,Y_VAL_SALE_KRW  /* 매출 - 원화               */
              ,Y_VAL_REFD_KRW  /* 환불 - 원화               */
          FROM DASH.SUM_IMPCARDAMTCHART
    )
    SELECT CHRT_KEY                                                 /* 그래프 키 (DAY, MNTH, YEAR) */
          ,TO_CHAR(X_DT, 'YYYY-MM-DD')           AS X_DT
          ,CAST(Y_VAL_SALE_RMB AS DECIMAL(20,2)) AS Y_VAL_SALE_RMB  /* 매출 - 위안화 */
          ,CAST(Y_VAL_REFD_RMB AS DECIMAL(20,2)) AS Y_VAL_REFD_RMB  /* 환불 - 위안화 */
          ,CAST(Y_VAL_SALE_KRW AS DECIMAL(20,2)) AS Y_VAL_SALE_KRW  /* 매출 - 원화   */
          ,CAST(Y_VAL_REFD_KRW AS DECIMAL(20,2)) AS Y_VAL_REFD_KRW  /* 환불 - 원화   */
      FROM WT_BASE
;


4. 매출 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보
    * 기간선택시, 당해 누적금액, 전년도 누적금액, YOY기준 증감률( Tmall 내륙 + Tmall 글로벌 + Douyin 내특 + Douyin 글로벌)

/* 4. 매출 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_BASE AS
    (
        SELECT SALE_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
              ,SALE_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
              ,SALE_RATE_YEAR_YOY_RMB  /* 증감률           - 위안화  */
              ,SALE_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
              ,SALE_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
              ,SALE_RATE_YEAR_YOY_KRW  /* 증감률           - 원화    */
          FROM DASH.SUM_SALESTIMESERIESCARDDATA
    )
    SELECT CAST(SALE_AMT_YEAR_RMB      AS DECIMAL(20,2)) AS SALE_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
          ,CAST(SALE_AMT_YEAR_YOY_RMB  AS DECIMAL(20,2)) AS SALE_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
          ,CAST(SALE_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_RMB  /* 증감률           - 위안화  */
          ,CAST(SALE_AMT_YEAR_KRW      AS DECIMAL(20,2)) AS SALE_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
          ,CAST(SALE_AMT_YEAR_YOY_KRW  AS DECIMAL(20,2)) AS SALE_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
          ,CAST(SALE_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_KRW  /* 증감률           - 원화    */
      FROM WT_BASE
;

5. 매출 정보에 대한 시계열 / 데이터 뷰어 - 매출 시계열그래프
    * ( Tmall 내륙 + Tmall 글로벌 + Douyin 내륙 • Douyin 글로벌)값의 일별 그래프(주단위 Rolling, 쭳단위 Rolling)

/* 5. 매출 정보에 대한 시계열 / 데이터 뷰어 - 매출 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'SALE'       AS L_LGND_ID
              ,'일매출'     AS L_LGND_NM
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'SALE_WEEK'  AS L_LGND_ID
              ,'주매출'     AS L_LGND_NM
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'SALE_MNTH'  AS L_LGND_ID
              ,'월매출'     AS L_LGND_NM
    ), WT_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_RMB
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_rmb'
    ), WT_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_krw'
    ), WT_MOVE AS
    (
        SELECT A.STATISTICS_DATE
              ,    SUM(A.SALE_AMT_RMB)                                                                             AS SALE_AMT_RMB       /* 일매출                - 위안화 */
              ,AVG(SUM(A.SALE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출 이동평균( 5일) - 위안화 */
              ,AVG(SUM(A.SALE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출 이동평균(30일) - 위안화 */
              ,    SUM(B.SALE_AMT_KRW)                                                                             AS SALE_AMT_KRW       /* 일매출                - 원화   */
              ,AVG(SUM(B.SALE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 주매출 이동평균( 5일) - 원화   */
              ,AVG(SUM(B.SALE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 월매출 이동평균(30일) - 원화   */
          FROM WT_AMT_RMB A INNER JOIN WT_AMT_KRW B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
      GROUP BY A.STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,CAST(STATISTICS_DATE AS DATE) AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_RMB
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_RMB
               END AS Y_VAL_RMB  /* 매출금액 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_KRW
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* 매출금액 - 원화   */
          FROM WT_COPY A
              ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
;

6. 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단표
    * ( Tmall 내륙 + Tmall 글로벌 + Douyin 내륙 + Douyin 글로법)당해, 전년도 월별 금액 YOY, MoM 제시

/* 6. 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR            AS DATE) AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(BASE_YEAR    ||'-12-31' AS DATE) AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(FRST_DT_YEAR_YOY        AS DATE) AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(BASE_YEAR_YOY||'-12-31' AS DATE) AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,BASE_YEAR                             AS THIS_YEAR  /* 기준일의 연도            */
              ,BASE_YEAR_YOY                         AS LAST_YEAR  /* 기준일의 연도       -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                                              AS SORT_KEY
              ,'올해 '   ||  (SELECT THIS_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 2                                              AS SORT_KEY
              ,'전년도 ' ||  (SELECT LAST_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 3                                              AS SORT_KEY
              ,'YoY'                                          AS ROW_TITL
     UNION ALL
        SELECT 4                                              AS SORT_KEY
              ,'MoM'                                          AS ROW_TITL
    ), WT_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_RMB
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_rmb'
    ), WT_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_krw'
    ), WT_AMT_RMB_YOY AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_RMB
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_rmb'
    ), WT_AMT_KRW_YOY AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_krw'
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_RMB END) AS SALE_AMT_01_RMB /* 01월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_RMB END) AS SALE_AMT_02_RMB /* 02월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_RMB END) AS SALE_AMT_03_RMB /* 03월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_RMB END) AS SALE_AMT_04_RMB /* 04월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_RMB END) AS SALE_AMT_05_RMB /* 05월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_RMB END) AS SALE_AMT_06_RMB /* 06월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_RMB END) AS SALE_AMT_07_RMB /* 07월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_RMB END) AS SALE_AMT_08_RMB /* 08월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_RMB END) AS SALE_AMT_09_RMB /* 09월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_RMB END) AS SALE_AMT_10_RMB /* 10월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_RMB END) AS SALE_AMT_11_RMB /* 11월 매출 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_RMB END) AS SALE_AMT_12_RMB /* 12월 매출 - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_KRW END) AS SALE_AMT_01_KRW /* 01월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_KRW END) AS SALE_AMT_02_KRW /* 02월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_KRW END) AS SALE_AMT_03_KRW /* 03월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_KRW END) AS SALE_AMT_04_KRW /* 04월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_KRW END) AS SALE_AMT_05_KRW /* 05월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_KRW END) AS SALE_AMT_06_KRW /* 06월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_KRW END) AS SALE_AMT_07_KRW /* 07월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_KRW END) AS SALE_AMT_08_KRW /* 08월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_KRW END) AS SALE_AMT_09_KRW /* 09월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_KRW END) AS SALE_AMT_10_KRW /* 10월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_KRW END) AS SALE_AMT_11_KRW /* 11월 매출 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_KRW END) AS SALE_AMT_12_KRW /* 12월 매출 - 원화   */
          FROM WT_AMT_RMB A INNER JOIN WT_AMT_KRW B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_RMB END) AS SALE_AMT_01_RMB /* 01월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_RMB END) AS SALE_AMT_02_RMB /* 02월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_RMB END) AS SALE_AMT_03_RMB /* 03월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_RMB END) AS SALE_AMT_04_RMB /* 04월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_RMB END) AS SALE_AMT_05_RMB /* 05월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_RMB END) AS SALE_AMT_06_RMB /* 06월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_RMB END) AS SALE_AMT_07_RMB /* 07월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_RMB END) AS SALE_AMT_08_RMB /* 08월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_RMB END) AS SALE_AMT_09_RMB /* 09월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_RMB END) AS SALE_AMT_10_RMB /* 10월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_RMB END) AS SALE_AMT_11_RMB /* 11월 매출 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_RMB END) AS SALE_AMT_12_RMB /* 12월 매출 YoY - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_KRW END) AS SALE_AMT_01_KRW /* 01월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_KRW END) AS SALE_AMT_02_KRW /* 02월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_KRW END) AS SALE_AMT_03_KRW /* 03월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_KRW END) AS SALE_AMT_04_KRW /* 04월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_KRW END) AS SALE_AMT_05_KRW /* 05월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_KRW END) AS SALE_AMT_06_KRW /* 06월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_KRW END) AS SALE_AMT_07_KRW /* 07월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_KRW END) AS SALE_AMT_08_KRW /* 08월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_KRW END) AS SALE_AMT_09_KRW /* 09월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_KRW END) AS SALE_AMT_10_KRW /* 10월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_KRW END) AS SALE_AMT_11_KRW /* 11월 매출 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_KRW END) AS SALE_AMT_12_KRW /* 12월 매출 YoY - 원화   */
          FROM WT_AMT_RMB_YOY A INNER JOIN WT_AMT_KRW_YOY B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_01_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_01_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_01_RMB  /* 01월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_02_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_02_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_02_RMB  /* 02월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_03_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_03_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_03_RMB  /* 03월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_04_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_04_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_04_RMB  /* 04월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_05_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_05_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_05_RMB  /* 05월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_06_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_06_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_06_RMB  /* 06월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_07_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_07_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_07_RMB  /* 07월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_08_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_08_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_08_RMB  /* 08월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_09_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_09_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_09_RMB  /* 09월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_10_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_10_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_10_RMB  /* 10월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_11_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_11_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_11_RMB  /* 11월 매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_12_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_12_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_12_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_12_RMB  /* 12월 매출 - 위안화 */

               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_01_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_01_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_01_KRW  /* 01월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_02_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_02_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_02_KRW  /* 02월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_03_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_03_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_03_KRW  /* 03월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_04_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_04_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_04_KRW  /* 04월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_05_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_05_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_05_KRW  /* 05월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_06_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_06_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_06_KRW  /* 06월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_07_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_07_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_07_KRW  /* 07월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_08_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_08_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_08_KRW  /* 08월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_09_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_09_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_09_KRW  /* 09월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_10_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_10_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_10_KRW  /* 10월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_11_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_11_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_11_KRW  /* 11월 매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_12_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_12_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_12_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_12_KRW  /* 12월 매출 - 원화 */
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(SALE_AMT_01_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_01_RMB   /* 01월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_02_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_02_RMB   /* 02월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_03_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_03_RMB   /* 03월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_04_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_04_RMB   /* 04월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_05_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_05_RMB   /* 05월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_06_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_06_RMB   /* 06월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_07_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_07_RMB   /* 07월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_08_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_08_RMB   /* 08월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_09_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_09_RMB   /* 09월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_10_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_10_RMB   /* 10월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_11_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_11_RMB   /* 11월 매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_12_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_12_RMB   /* 12월 매출 - 위안화 */

          ,TO_CHAR(CAST(SALE_AMT_01_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_01_KRW  /* 01월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_02_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_02_KRW  /* 02월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_03_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_03_KRW  /* 03월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_04_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_04_KRW  /* 04월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_05_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_05_KRW  /* 05월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_06_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_06_KRW  /* 06월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_07_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_07_KRW  /* 07월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_08_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_08_KRW  /* 08월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_09_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_09_KRW  /* 09월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_10_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_10_KRW  /* 10월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_11_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_11_KRW  /* 11월 매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_12_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_12_KRW  /* 12월 매출 - 원화 */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

7. 채널별 매출 비중 Break Down
    * 4번에 선택한 기간에 따라, 연동되어 각 채널( Tmall 내륙, Tmall 글로벌, Douyin 내륙, Douyin 글로벌)의 값이 Break down되어 Stack그래프로 나오도록
    * 이때, 100% Stack바 그래프와 일반 bar 그래프 선택하도록
    * 우측에는 CAGR의 값(4번에서 선택한 기간에 따라) 표기되도특 
        CAGR “( 최종월(값)/최초월(값)) ^(1/월수) -1
        예시 2월 200, 5월 300
        (200/300)^(1/3) - 1

/* 7. 채널별 매출 비중 Break Down - CAGR SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_MNTH||'-01' AS DATE)                              AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(:FR_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,CAST(:TO_MNTH||'-01' AS DATE)                              AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */              
    ), WT_MNTH_DIFF AS
    (
        SELECT EXTRACT(MONTH FROM AGE((SELECT TO_MNTH_TO_DT FROM WT_WHERE), (SELECT FR_MNTH_FR_DT FROM WT_WHERE))) AS MNTH_DIFF
    ), WT_FR_AMT AS
    (
        SELECT SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_rmb'
                     THEN VALUE
                   END) AS FR_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_krw'
                     THEN VALUE
                   END) AS FR_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT FR_MNTH_TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('sale_amt_rmb', 'sale_amt_krw')
    ), WT_TO_AMT AS
    (
        SELECT SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_rmb'
                     THEN VALUE
                   END) AS TO_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_krw'
                     THEN VALUE
                   END) AS TO_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT TO_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('sale_amt_rmb', 'sale_amt_krw')
    ), WT_BASE AS
    (
        SELECT (((SELECT TO_AMT_RMB::DECIMAL FROM WT_TO_AMT) / (SELECT FR_AMT_RMB::DECIMAL FROM WT_FR_AMT)) ^ (1::DECIMAL / (SELECT MNTH_DIFF::DECIMAL FROM WT_MNTH_DIFF)) -1::DECIMAL) * 100 AS CAGR_AMT_RMB
              ,(((SELECT TO_AMT_KRW::DECIMAL FROM WT_TO_AMT) / (SELECT FR_AMT_KRW::DECIMAL FROM WT_FR_AMT)) ^ (1::DECIMAL / (SELECT MNTH_DIFF::DECIMAL FROM WT_MNTH_DIFF)) -1::DECIMAL) * 100 AS CAGR_AMT_KRW
          FROM WT_FR_AMT    A
              ,WT_TO_AMT    B
              ,WT_MNTH_DIFF C
    )
    SELECT CAST(CAGR_AMT_RMB AS DECIMAL(20,2)) AS CAGR_AMT_RMB
          ,CAST(CAGR_AMT_KRW AS DECIMAL(20,2)) AS CAGR_AMT_KRW
      FROM WT_BASE
;

/* 7. 채널별 매출 비중 Break Down - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_MNTH||'-01' AS DATE)                              AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:CHRT_TYPE                                                 AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_AMT AS
    (
        SELECT TO_CHAR(STATISTICS_DATE, 'YYYY-MM') AS MNTH_AMT
              ,CASE 
                 WHEN CHRT_KEY IN ('dct_sale_amt_rmb', 'dct_sale_amt_krw')
                 THEN 'DCT'
                 WHEN CHRT_KEY IN ('dgt_sale_amt_rmb', 'dgt_sale_amt_krw')
                 THEN 'DGT'
                 WHEN CHRT_KEY IN ('dcd_sale_amt_rmb', 'dcd_sale_amt_krw')
                 THEN 'DCD'
                 WHEN CHRT_KEY IN ('dgd_sale_amt_rmb', 'dgd_sale_amt_krw')
                 THEN 'DGD'
               END AS CHNL_ID
              ,MAX(CASE
                     WHEN CHRT_KEY IN ('dct_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_sale_amt_rmb')
                     THEN VALUE
                   END) AS SALE_AMT_RMB
              ,MAX(CASE
                     WHEN CHRT_KEY IN ('dct_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_sale_amt_krw')
                     THEN VALUE
                   END) AS SALE_AMT_KRW
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('dct_sale_amt_rmb', 'dgt_sale_amt_rmb', 'dcd_sale_amt_rmb', 'dgd_sale_amt_rmb',
                            'dct_sale_amt_krw', 'dgt_sale_amt_krw', 'dcd_sale_amt_krw', 'dgd_sale_amt_krw')
      GROUP BY TO_CHAR(STATISTICS_DATE, 'YYYY-MM')
              ,CHNL_ID
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CHNL_ID
              ,SALE_AMT_RMB
              ,SALE_AMT_KRW
              ,CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_AMT B ON (A.COPY_MNTH = B.MNTH_AMT)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID                       AS L_LGND_ID
              ,A.CHNL_NM                       AS L_LGND_NM
              ,B.X_DT
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN SALE_AMT_RMB
                 ELSE SALE_AMT_RMB / SUM(SALE_AMT_RMB) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_RMB
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN SALE_AMT_KRW
                 ELSE SALE_AMT_KRW / SUM(SALE_AMT_KRW) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_KRW
          FROM WT_CHNL A INNER JOIN WT_DATA B ON (A.CHNL_ID = B.CHNL_ID)
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;

8. 환불 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보
    * 8 번에서 기간을 선택하면, 9번에서 환불정보에 대한 시계열 그래프가 나와야함.
    * 카드에는 올해 1월 1 일부터 최근일(어제)까지 누적금액, 그리고 전년도 동기간 누적금액, 그 둘간의 증감률을 YOY로 표기

/* 8. 환불 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_BASE AS
    (
        SELECT REFD_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
              ,REFD_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
              ,REFD_RATE_YEAR_YOY_RMB  /* 증감률           - 위안화  */
              ,REFD_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
              ,REFD_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
              ,REFD_RATE_YEAR_YOY_KRW  /* 증감률           - 원화    */
          FROM DASH.SUM_SALESTIMESERIESCARDDATA
    )
    SELECT CAST(REFD_AMT_YEAR_RMB      AS DECIMAL(20,2)) AS REFD_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
          ,CAST(REFD_AMT_YEAR_YOY_RMB  AS DECIMAL(20,2)) AS REFD_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
          ,CAST(REFD_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_RMB  /* 증감률           - 위안화  */
          ,CAST(REFD_AMT_YEAR_KRW      AS DECIMAL(20,2)) AS REFD_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
          ,CAST(REFD_AMT_YEAR_YOY_KRW  AS DECIMAL(20,2)) AS REFD_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
          ,CAST(REFD_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_KRW  /* 증감률           - 원화    */
      FROM WT_BASE


9. 환불 정보에 대한 시계열 / 데이터 뷰어 - 환불 시계열그래프
    * 8 번에서 선택한 정보에 다른 환불시계열 그래프 y축 두개 좌측에는 환불금액, 우측에는 매출대비 환불 비중으로 그래프가 나와야 함.

/* 9. 환불 정보에 대한 시계열 / 데이터 뷰어 - 환불 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'REFD'       AS L_LGND_ID
              ,'일환불'     AS L_LGND_NM
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'REFD_WEEK'  AS L_LGND_ID
              ,'주환불'     AS L_LGND_NM
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'REFD_MNTH'  AS L_LGND_ID
              ,'월환불'     AS L_LGND_NM
    ), WT_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_RMB
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_rmb'
    ), WT_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_KRW
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_krw'
    ), WT_MOVE AS
    (
        SELECT A.STATISTICS_DATE
              ,    SUM(A.REFD_AMT_RMB)                                                                             AS REFD_AMT_RMB       /* 일환불                - 위안화 */
              ,AVG(SUM(A.REFD_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_RMB  /* 주환불 이동평균( 5일) - 위안화 */
              ,AVG(SUM(A.REFD_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_RMB  /* 월환불 이동평균(30일) - 위안화 */
              ,    SUM(B.REFD_AMT_KRW)                                                                             AS REFD_AMT_KRW       /* 일환불                - 원화   */
              ,AVG(SUM(B.REFD_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_KRW  /* 주환불 이동평균( 5일) - 원화   */
              ,AVG(SUM(B.REFD_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_KRW  /* 월환불 이동평균(30일) - 원화   */
          FROM WT_AMT_RMB A INNER JOIN WT_AMT_KRW B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
      GROUP BY A.STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,CAST(STATISTICS_DATE AS DATE) AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_RMB
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_RMB
               END AS Y_VAL_RMB  /* 환불금액 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_KRW
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* 환불금액 - 원화   */
          FROM WT_COPY A
              ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
;

10. 환불 정보에 대한 시계열 / 데이터 뷰어 - 하단표
    * 월별 테이블로 1월부터 12월까지, 올해, 전년도 정보 표기후 
    * YOY와 MOM산출 : YOY는 전 년도 대비 올해의 증감율, MOM은 이전달 대비 증감률

/* 10. 환불 정보에 대한 시계열 / 데이터 뷰어 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR            AS DATE) AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(BASE_YEAR    ||'-12-31' AS DATE) AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(FRST_DT_YEAR_YOY        AS DATE) AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(BASE_YEAR_YOY||'-12-31' AS DATE) AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,BASE_YEAR                             AS THIS_YEAR  /* 기준일의 연도            */
              ,BASE_YEAR_YOY                         AS LAST_YEAR  /* 기준일의 연도       -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                                              AS SORT_KEY
              ,'올해 '   ||  (SELECT THIS_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 2                                              AS SORT_KEY
              ,'전년도 ' ||  (SELECT LAST_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 3                                              AS SORT_KEY
              ,'YoY'                                          AS ROW_TITL
     UNION ALL
        SELECT 4                                              AS SORT_KEY
              ,'MoM'                                          AS ROW_TITL
    ), WT_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_RMB
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_rmb'
    ), WT_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_KRW
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_krw'
    ), WT_AMT_RMB_YOY AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_RMB
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_rmb'
    ), WT_AMT_KRW_YOY AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_KRW
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_krw'
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN REFD_AMT_RMB END) AS REFD_AMT_01_RMB /* 01월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN REFD_AMT_RMB END) AS REFD_AMT_02_RMB /* 02월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN REFD_AMT_RMB END) AS REFD_AMT_03_RMB /* 03월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN REFD_AMT_RMB END) AS REFD_AMT_04_RMB /* 04월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN REFD_AMT_RMB END) AS REFD_AMT_05_RMB /* 05월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN REFD_AMT_RMB END) AS REFD_AMT_06_RMB /* 06월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN REFD_AMT_RMB END) AS REFD_AMT_07_RMB /* 07월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN REFD_AMT_RMB END) AS REFD_AMT_08_RMB /* 08월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN REFD_AMT_RMB END) AS REFD_AMT_09_RMB /* 09월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN REFD_AMT_RMB END) AS REFD_AMT_10_RMB /* 10월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN REFD_AMT_RMB END) AS REFD_AMT_11_RMB /* 11월 환불 - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN REFD_AMT_RMB END) AS REFD_AMT_12_RMB /* 12월 환불 - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN REFD_AMT_KRW END) AS REFD_AMT_01_KRW /* 01월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN REFD_AMT_KRW END) AS REFD_AMT_02_KRW /* 02월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN REFD_AMT_KRW END) AS REFD_AMT_03_KRW /* 03월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN REFD_AMT_KRW END) AS REFD_AMT_04_KRW /* 04월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN REFD_AMT_KRW END) AS REFD_AMT_05_KRW /* 05월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN REFD_AMT_KRW END) AS REFD_AMT_06_KRW /* 06월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN REFD_AMT_KRW END) AS REFD_AMT_07_KRW /* 07월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN REFD_AMT_KRW END) AS REFD_AMT_08_KRW /* 08월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN REFD_AMT_KRW END) AS REFD_AMT_09_KRW /* 09월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN REFD_AMT_KRW END) AS REFD_AMT_10_KRW /* 10월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN REFD_AMT_KRW END) AS REFD_AMT_11_KRW /* 11월 환불 - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN REFD_AMT_KRW END) AS REFD_AMT_12_KRW /* 12월 환불 - 원화   */
          FROM WT_AMT_RMB A INNER JOIN WT_AMT_KRW B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN REFD_AMT_RMB END) AS REFD_AMT_01_RMB /* 01월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN REFD_AMT_RMB END) AS REFD_AMT_02_RMB /* 02월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN REFD_AMT_RMB END) AS REFD_AMT_03_RMB /* 03월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN REFD_AMT_RMB END) AS REFD_AMT_04_RMB /* 04월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN REFD_AMT_RMB END) AS REFD_AMT_05_RMB /* 05월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN REFD_AMT_RMB END) AS REFD_AMT_06_RMB /* 06월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN REFD_AMT_RMB END) AS REFD_AMT_07_RMB /* 07월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN REFD_AMT_RMB END) AS REFD_AMT_08_RMB /* 08월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN REFD_AMT_RMB END) AS REFD_AMT_09_RMB /* 09월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN REFD_AMT_RMB END) AS REFD_AMT_10_RMB /* 10월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN REFD_AMT_RMB END) AS REFD_AMT_11_RMB /* 11월 환불 YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN REFD_AMT_RMB END) AS REFD_AMT_12_RMB /* 12월 환불 YoY - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 01 THEN REFD_AMT_KRW END) AS REFD_AMT_01_KRW /* 01월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 02 THEN REFD_AMT_KRW END) AS REFD_AMT_02_KRW /* 02월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 03 THEN REFD_AMT_KRW END) AS REFD_AMT_03_KRW /* 03월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 04 THEN REFD_AMT_KRW END) AS REFD_AMT_04_KRW /* 04월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 05 THEN REFD_AMT_KRW END) AS REFD_AMT_05_KRW /* 05월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 06 THEN REFD_AMT_KRW END) AS REFD_AMT_06_KRW /* 06월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 07 THEN REFD_AMT_KRW END) AS REFD_AMT_07_KRW /* 07월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 08 THEN REFD_AMT_KRW END) AS REFD_AMT_08_KRW /* 08월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 09 THEN REFD_AMT_KRW END) AS REFD_AMT_09_KRW /* 09월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 10 THEN REFD_AMT_KRW END) AS REFD_AMT_10_KRW /* 10월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 11 THEN REFD_AMT_KRW END) AS REFD_AMT_11_KRW /* 11월 환불 YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(A.STATISTICS_DATE AS DATE)) = 12 THEN REFD_AMT_KRW END) AS REFD_AMT_12_KRW /* 12월 환불 YoY - 원화   */
          FROM WT_AMT_RMB_YOY A INNER JOIN WT_AMT_KRW_YOY B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_01_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_01_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_01_RMB  /* 01월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_02_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_02_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_02_RMB  /* 02월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_03_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_03_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_03_RMB  /* 03월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_04_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_04_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_04_RMB  /* 04월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_05_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_05_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_05_RMB  /* 05월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_06_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_06_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_06_RMB  /* 06월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_07_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_07_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_07_RMB  /* 07월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_08_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_08_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_08_RMB  /* 08월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_09_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_09_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_09_RMB  /* 09월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_10_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_10_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_10_RMB  /* 10월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_11_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_11_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_11_RMB  /* 11월 환불 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_12_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_12_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_12_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_12_RMB  /* 12월 환불 - 위안화 */

               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_01_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_01_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_01_KRW  /* 01월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_02_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_02_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_02_KRW  /* 02월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_03_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_03_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_03_KRW  /* 03월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_04_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_04_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_04_KRW  /* 04월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_05_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_05_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_05_KRW  /* 05월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_06_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_06_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_06_KRW  /* 06월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_07_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_07_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_07_KRW  /* 07월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_08_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_08_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_08_KRW  /* 08월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_09_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_09_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_09_KRW  /* 09월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_10_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_10_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_10_KRW  /* 10월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_11_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_11_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_11_KRW  /* 11월 환불 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN REFD_AMT_12_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(REFD_AMT_12_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(REFD_AMT_12_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(REFD_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(REFD_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS REFD_AMT_12_KRW  /* 12월 환불 - 원화 */
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(REFD_AMT_01_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_01_RMB   /* 01월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_02_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_02_RMB   /* 02월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_03_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_03_RMB   /* 03월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_04_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_04_RMB   /* 04월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_05_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_05_RMB   /* 05월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_06_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_06_RMB   /* 06월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_07_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_07_RMB   /* 07월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_08_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_08_RMB   /* 08월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_09_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_09_RMB   /* 09월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_10_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_10_RMB   /* 10월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_11_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_11_RMB   /* 11월 환불 - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_12_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_12_RMB   /* 12월 환불 - 위안화 */

          ,TO_CHAR(CAST(REFD_AMT_01_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_01_KRW  /* 01월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_02_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_02_KRW  /* 02월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_03_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_03_KRW  /* 03월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_04_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_04_KRW  /* 04월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_05_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_05_KRW  /* 05월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_06_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_06_KRW  /* 06월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_07_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_07_KRW  /* 07월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_08_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_08_KRW  /* 08월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_09_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_09_KRW  /* 09월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_10_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_10_KRW  /* 10월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_11_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_11_KRW  /* 11월 환불 - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_12_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS REFD_AMT_12_KRW  /* 12월 환불 - 원화 */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

11. 채널별 환불 비중 Break Down
    * 8 번에서 선택한 기간에 따라, 4개의 채널(Tmall 글로벌/내륙, Douyin 글로벌/내륙)에 대한 채널별 환불비중이 시계열로 나와야함

/* 11. 채널별 환불 비중 Break Down - 라인 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_MNTH||'-01' AS DATE)                              AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:CHRT_TYPE                                                 AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_AMT AS
    (
        SELECT TO_CHAR(STATISTICS_DATE, 'YYYY-MM') AS MNTH_AMT
              ,CASE 
                 WHEN CHRT_KEY IN ('dct_refd_amt_rmb', 'dct_refd_amt_krw')
                 THEN 'DCT'
                 WHEN CHRT_KEY IN ('dgt_refd_amt_rmb', 'dgt_refd_amt_krw')
                 THEN 'DGT'
                 WHEN CHRT_KEY IN ('dcd_refd_amt_rmb', 'dcd_refd_amt_krw')
                 THEN 'DCD'
                 WHEN CHRT_KEY IN ('dgd_refd_amt_rmb', 'dgd_refd_amt_krw')
                 THEN 'DGD'
               END AS CHNL_ID
              ,MAX(CASE
                     WHEN CHRT_KEY IN ('dct_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_refd_amt_rmb')
                     THEN VALUE
                   END) AS REFD_AMT_RMB
              ,MAX(CASE
                     WHEN CHRT_KEY IN ('dct_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_refd_amt_krw')
                     THEN VALUE
                   END) AS REFD_AMT_KRW
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('dct_refd_amt_rmb', 'dgt_refd_amt_rmb', 'dcd_refd_amt_rmb', 'dgd_refd_amt_rmb',
                            'dct_refd_amt_krw', 'dgt_refd_amt_krw', 'dcd_refd_amt_krw', 'dgd_refd_amt_krw')
      GROUP BY TO_CHAR(STATISTICS_DATE, 'YYYY-MM')
              ,CHNL_ID
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CHNL_ID
              ,REFD_AMT_RMB
              ,REFD_AMT_KRW
              ,CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_AMT B ON (A.COPY_MNTH = B.MNTH_AMT)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID                       AS L_LGND_ID
              ,A.CHNL_NM                       AS L_LGND_NM
              ,B.X_DT
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN REFD_AMT_RMB
                 ELSE REFD_AMT_RMB / SUM(REFD_AMT_RMB) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_RMB
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN REFD_AMT_KRW
                 ELSE REFD_AMT_KRW / SUM(REFD_AMT_KRW) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_KRW
          FROM WT_CHNL A INNER JOIN WT_DATA B ON (A.CHNL_ID = B.CHNL_ID)
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;

12. 채널 내 매출 순위
    * 채널(Tmall/Douyin), 카테고리, 국가, 더마여부 선택시 채널에 따라 브랜드 등수가 나오도록

/* 화면에서 맨 처음 조건인 채널 선택에 따라 아래 SQL 을 각각 사용한다. */
/* Tmall  선택 시 → "12. 채널 내 매출 순위 - Tmall  표 SQL"            */
/* Douyin 선택 시 → "12. 채널 내 매출 순위 - Douyin 표 SQL"            */

/* 12. 채널 내 매출 순위 - Tmall  표 SQL */
/* 조건은 KR_YN, DEMA_YN 만 적용하면 됨. MLTI_YN, SHOP_ID는 추후 필요 시 사용하도록 지우지 않음. */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}                 AS FR_MNTH           /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                 AS TO_MNTH           /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({MLTI_YN}, '%')  AS MLTI_YN           /* 사용자가 선택한 화장품전문몰 제외  ex) 전체:%, 화장품전문몰 제외:N  */
              ,COALESCE({KR_YN}  , '%')  AS KR_YN             /* 사용자가 선택한 국가               ex) 전체:%, 한국:Y               */
              ,COALESCE({DEMA_YN}, '%')  AS DEMA_YN           /* 사용자가 선택한 더마여부           ex) 전체:%, 더마:Y, 더마 외:N    */
    ), WT_SHOP_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY 
              ,TRIM(SHOP_ID)                         AS SHOP_ID
          FROM REGEXP_SPLIT_TO_TABLE({SHOP_ID}, ',') AS SHOP_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '67597230, 60637940, 492216636' */
         WHERE TRIM(SHOP_ID) <> ''
    ), WT_SHOP_RAW AS
    (
        SELECT CAST(SHOP_ID AS TEXT)                   AS SHOP_ID
              ,ARRAY_TO_STRING(ARRAY_AGG(COUNTRY),',') AS NATN_LIST
              ,COUNT(DISTINCT COUNTRY)                 AS NATN_CNT
              ,MAX(DERMA)                              AS DEMA_YN
          FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY
      GROUP BY SHOP_ID
    ), WT_SHOP AS
    (
        SELECT SHOP_ID
              ,NATN_LIST 
              ,NATN_CNT
              ,CASE WHEN NATN_CNT > 1                      THEN 'Y' ELSE 'N' END AS MLTI_YN
              ,CASE WHEN POSITION('한국' IN NATN_LIST) > 0 THEN 'Y' ELSE 'N' END AS KR_YN
              ,CASE WHEN DEMA_YN = 1                       THEN 'Y' ELSE 'N' END AS DEMA_YN
          FROM WT_SHOP_RAW
    ), WT_SALE AS
    (
        SELECT DISTINCT
               A.SHOP_ID                              AS SHOP_ID
              ,A.SHOP_NAME                            AS SHOP_NM
              ,A.SALE_AMT                             AS SALE_AMT
              ,B.NATN_LIST                            AS NATN_NM
              ,B.NATN_CNT                             AS NATN_CNT
              ,B.MLTI_YN                              AS MLTI_YN
              ,B.KR_YN                                AS KR_YN
              ,CASE WHEN B.DEMA_YN = 'Y' THEN '●' END AS DEMA_YN
              ,A.BASE_TIME
          FROM DASH.TMALL_STORE_RANK_DATA A INNER JOIN WT_SHOP B
            ON (A.SHOP_ID = B.SHOP_ID)
         WHERE A.BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
           AND B.MLTI_YN LIKE (SELECT MLTI_YN FROM WT_WHERE)
           AND B.KR_YN   LIKE (SELECT KR_YN   FROM WT_WHERE)
           AND B.DEMA_YN LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SHOP_ID        AS SHOP_ID
              ,SHOP_NM        AS SHOP_NM
              ,SUM(SALE_AMT)  AS SALE_AMT
              ,MAX(NATN_NM)   AS NATN_NM
              ,MAX(NATN_CNT)  AS NATN_CNT
              ,MAX(MLTI_YN)   AS MLTI_YN
              ,MAX(KR_YN)     AS KR_YN
              ,MAX(DEMA_YN)   AS DEMA_YN
          FROM WT_SALE
      GROUP BY SHOP_ID
              ,SHOP_NM
    ), WT_RATE AS
    (
        SELECT SHOP_ID
              ,SHOP_NM
              ,SALE_AMT / SUM(SALE_AMT) OVER() * 100 AS SALE_RATE
              ,SALE_AMT
              ,SUM(SALE_AMT) OVER()                  AS SALE_AMT_SUM
              ,NATN_NM
              ,NATN_CNT
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT --ROW_NUMBER() OVER(ORDER BY SALE_RATE DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
               ROW_NUMBER() OVER(ORDER BY SALE_AMT DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
              ,SHOP_ID
              ,SHOP_NM
              ,TO_CHAR(SALE_RATE, 'FM999,999,999,999,990.0000') AS SALE_RATE
              ,SALE_AMT
              ,SALE_AMT_SUM
              ,CASE WHEN NATN_CNT = 1 THEN NATN_NM ELSE '다국적' END AS NATN_NM
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_RATE
    )
    SELECT SHOP_RANK                                                /* 순위             */
          ,SHOP_ID                                                  /* 상점ID           */
          ,SHOP_NM                                                  /* 상점명           */
          ,TO_CHAR(SALE_AMT, 'FM999,999,999,999,999') AS SALE_RATE  /* 거래지수         */
          ,NATN_NM                                                  /* 국가             */
          ,MLTI_YN                                                  /* 화장품전문몰여부 */
          ,KR_YN                                                    /* 한국여부         */
          ,DEMA_YN                                                  /* 더마여부         */
      FROM WT_BASE
     WHERE ((SELECT COUNT(*) FROM WT_SHOP_WHERE) > 0 AND SHOP_ID IN (SELECT SHOP_ID FROM WT_SHOP_WHERE))
        OR ((SELECT COUNT(*) FROM WT_SHOP_WHERE) = 0 )
  ORDER BY SHOP_RANK
--     LIMIT 300
;

/* 12. 채널 내 매출 순위 - Douyin 표 SQL */
/* 조건은 KR_YN, DEMA_YN 만 적용하면 됨. MLTI_YN, SHOP_ID는 추후 필요 시 사용하도록 지우지 않음. */
WITH WT_WHERE AS
    (
        SELECT    CAST(CAST({FR_MNTH} || '-01' AS DATE) AS TEXT)                                               AS FR_DT /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,TO_CHAR(CAST({TO_MNTH} || '-01' AS DATE) + INTERVAL '1' MONTH - INTERVAL '1' DAY, 'YYYY-MM-DD') AS TO_DT /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({MLTI_YN}, '%')                                                                        AS MLTI_YN /* 사용자가 선택한 화장품전문몰 제외  ex) 전체:%, 화장품전문몰 제외:N  */
              ,COALESCE({KR_YN}  , '%')                                                                        AS KR_YN   /* 사용자가 선택한 국가               ex) 전체:%, 한국:Y               */
              ,COALESCE({DEMA_YN}, '%')                                                                        AS DEMA_YN /* 사용자가 선택한 더마여부           ex) 전체:%, 더마:Y, 더마 외:N    */
    ), WT_SHOP_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY 
              ,TRIM(SHOP_ID)                         AS SHOP_ID
          FROM REGEXP_SPLIT_TO_TABLE({SHOP_ID}, ',') AS SHOP_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '67597230, 60637940, 492216636' */
         WHERE TRIM(SHOP_ID) <> ''
    ), WT_SHOP_RAW AS
    (
        SELECT NICKNAME AS SHOP_NAME_CN
              ,''       AS NATN_LIST
              ,1        AS NATN_CNT
              ,0        AS DEMA_YN
          FROM DASH_RAW.OVER_DCD_LIVE_RANK_DATA
    ), WT_SHOP AS
    (
        SELECT SHOP_NAME_CN
              ,NATN_LIST
              ,NATN_CNT
              ,CASE WHEN NATN_CNT > 1                      THEN 'Y' ELSE 'N' END AS MLTI_YN
              ,CASE WHEN POSITION('한국' IN NATN_LIST) > 0 THEN 'Y' ELSE 'N' END AS KR_YN
              ,CASE WHEN DEMA_YN = 1                       THEN 'Y' ELSE 'N' END AS DEMA_YN
          FROM WT_SHOP_RAW
    ), WT_SALE AS
    (
        SELECT DISTINCT
               A.NICKNAME                             AS SHOP_ID
              ,A.NICKNAME                             AS SHOP_NM
              ,A.TRADE_INDEX                          AS SALE_AMT
              ,B.NATN_LIST                            AS NATN_NM
              ,B.NATN_CNT                             AS NATN_CNT
              ,B.MLTI_YN                              AS MLTI_YN
              ,B.KR_YN                                AS KR_YN
              ,CASE WHEN B.DEMA_YN = 'Y' THEN '●' END AS DEMA_YN
              ,A.DATE
              ,A.AUTHOR_ID
          FROM DASH_RAW.OVER_DCD_LIVE_RANK_DATA A INNER JOIN WT_SHOP B
            ON (A.NICKNAME = B.SHOP_NAME_CN)
         WHERE A.DATE BETWEEN (SELECT FR_DT   FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND A.CATEGORY = '20085'
           AND B.MLTI_YN LIKE (SELECT MLTI_YN FROM WT_WHERE)
           AND B.KR_YN   LIKE (SELECT KR_YN   FROM WT_WHERE)
           AND B.DEMA_YN LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SHOP_ID        AS SHOP_ID
              ,SHOP_NM        AS SHOP_NM
              ,SUM(SALE_AMT) / (CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - CAST((SELECT FR_DT FROM WT_WHERE) AS DATE))  AS SALE_AMT
              ,MAX(NATN_NM)   AS NATN_NM
              ,MAX(NATN_CNT)  AS NATN_CNT
              ,MAX(MLTI_YN)   AS MLTI_YN
              ,MAX(KR_YN)     AS KR_YN
              ,MAX(DEMA_YN)   AS DEMA_YN
              ,MAX(AUTHOR_ID) AS AUTHOR_ID
          FROM WT_SALE
      GROUP BY SHOP_ID
              ,SHOP_NM
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_AMT DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
              ,SHOP_ID
              ,SHOP_NM
              ,SALE_AMT
              ,CASE WHEN NATN_CNT = 1 THEN NATN_NM ELSE '다국적' END AS NATN_NM
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
              ,AUTHOR_ID
          FROM WT_SUM
    )
    SELECT SHOP_RANK                                       /* 순위            */
          ,SHOP_ID                                         /* 상점ID          */
          --,SHOP_NM                                       /* 상점명          */
          ,(
            SELECT MAX(X.LIVE_NAME_KR)
              FROM DASH_RAW.OVER_DOUYIN_LIVE_NAME X
             WHERE X.AUTHOR_ID     = A.AUTHOR_ID
               --AND X.LIVE_NAME_CN  = A.SHOP_NM
           ) AS SHOP_NM                                    /* 상점명           */
          ,CAST(SALE_AMT AS DECIMAL(20,2)) AS SALE_RATE    /* 거래지수         */
          ,NATN_NM                                         /* 국가             */
          ,MLTI_YN                                         /* 화장품전문몰여부 */
          ,KR_YN                                           /* 한국여부         */
          ,DEMA_YN                                         /* 더마여부         */
      FROM WT_BASE A
     WHERE ((SELECT COUNT(*) FROM WT_SHOP_WHERE) > 0 AND SHOP_ID IN (SELECT SHOP_ID FROM WT_SHOP_WHERE))
        OR ((SELECT COUNT(*) FROM WT_SHOP_WHERE) = 0 )
  ORDER BY SHOP_RANK
     --LIMIT 300
;

13. Top5 매출 제품
    * 선택기준없이 당해 연도 상위 매출 제품들 나오도록 하며, Tmall 매출비중은 Tmall전체(내륙/글로벌) 중 매출비중, 도우인 매출비중은 Douyin전체(내륙/글로벌) 중 매출비중을 의미함

/* 13. Top5 매출 제품 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR            AS DATE) AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(BASE_YEAR    ||'-12-31' AS DATE) AS TO_DT      /* 기준일의 12월 31일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_AMT_YEAR AS
    (
        SELECT COALESCE(MAX(A.SALE_AMT_YEAR_RMB), 0) + COALESCE(MAX(B.SALE_AMT_YEAR_RMB), 0) AS T_SALE_AMT_YEAR_RMB
              ,COALESCE(MAX(A.SALE_AMT_YEAR_KRW), 0) + COALESCE(MAX(B.SALE_AMT_YEAR_KRW), 0) AS T_SALE_AMT_YEAR_KRW
              ,0                                                                             AS D_SALE_AMT_YEAR_RMB
              ,0                                                                             AS D_SALE_AMT_YEAR_KRW
--              ,COALESCE(MAX(C.SALE_AMT_YEAR_RMB), 0) + COALESCE(MAX(D.SALE_AMT_YEAR_RMB), 0) AS D_SALE_AMT_YEAR_RMB
--              ,COALESCE(MAX(C.SALE_AMT_YEAR_KRW), 0) + COALESCE(MAX(D.SALE_AMT_YEAR_KRW), 0) AS D_SALE_AMT_YEAR_KRW
          FROM DASH.DCT_IMPCARDAMTDATA A
              ,DASH.DGT_IMPCARDAMTDATA B
--              ,DASH.DCD_IMPCARDAMTDATA C
--              ,DASH.DGD_IMPCARDAMTDATA D
    ), WT_PROD_DATA AS
    (
        SELECT 'DCT'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DCT_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
     UNION ALL
        SELECT 'DGT'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
     UNION ALL
        SELECT 'DCD'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DCD_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
--     UNION ALL
--        SELECT 'DGD'                         AS CHNL_ID
--              ,ITEM_CODE                     AS PROD_ID
--              ,MAX(ITEM_NAME)                AS PROD_NM
--              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
--              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
--          FROM DASH.DGD_PRICEANLAYSISITEMTIMESERIES A
--         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
--      GROUP BY ITEM_CODE
    ), WT_PROD AS
    (
        SELECT PROD_ID
              ,MAX(PROD_NM)      AS PROD_NM
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW
              ,SUM(CASE WHEN CHNL_ID IN ('DCT', 'DGT') THEN SALE_AMT_RMB END) AS T_SALE_AMT_RMB 
              ,SUM(CASE WHEN CHNL_ID IN ('DCT', 'DGT') THEN SALE_AMT_KRW END) AS T_SALE_AMT_KRW 
              ,SUM(CASE WHEN CHNL_ID IN ('DCD', 'DGD') THEN SALE_AMT_RMB END) AS D_SALE_AMT_RMB 
              ,SUM(CASE WHEN CHNL_ID IN ('DCD', 'DGD') THEN SALE_AMT_KRW END) AS D_SALE_AMT_KRW 
          FROM WT_PROD_DATA
      GROUP BY PROD_ID
    ), WT_PROD_AMT AS
    (
        SELECT PROD_ID
              ,PROD_NM
              ,ROW_NUMBER() OVER(ORDER BY SALE_AMT_RMB DESC, A.PROD_ID) AS SALE_RANK_RMB
              ,ROW_NUMBER() OVER(ORDER BY SALE_AMT_KRW DESC, A.PROD_ID) AS SALE_RANK_KRW
              ,SALE_AMT_RMB
              ,SALE_AMT_KRW
              ,CASE WHEN SUM(SALE_AMT_RMB) OVER() = 0 THEN 0 ELSE SALE_AMT_RMB   / SUM(SALE_AMT_RMB) OVER() * 100 END AS SALE_RATE_RMB
              ,CASE WHEN SUM(SALE_AMT_KRW) OVER() = 0 THEN 0 ELSE SALE_AMT_KRW   / SUM(SALE_AMT_KRW) OVER() * 100 END AS SALE_RATE_KRW
              ,CASE WHEN T_SALE_AMT_YEAR_RMB      = 0 THEN 0 ELSE T_SALE_AMT_RMB / T_SALE_AMT_YEAR_RMB      * 100 END AS T_SALE_RATE_RMB
              ,CASE WHEN T_SALE_AMT_YEAR_KRW      = 0 THEN 0 ELSE T_SALE_AMT_KRW / T_SALE_AMT_YEAR_KRW      * 100 END AS T_SALE_RATE_KRW
              ,CASE WHEN D_SALE_AMT_YEAR_RMB      = 0 THEN 0 ELSE D_SALE_AMT_RMB / D_SALE_AMT_YEAR_RMB      * 100 END AS D_SALE_RATE_RMB
              ,CASE WHEN D_SALE_AMT_YEAR_KRW      = 0 THEN 0 ELSE D_SALE_AMT_KRW / D_SALE_AMT_YEAR_KRW      * 100 END AS D_SALE_RATE_KRW
          FROM WT_PROD     A
              ,WT_AMT_YEAR B
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK
              ,B.PROD_ID         AS PROD_ID_RMB
              ,B.PROD_NM         AS PROD_NM_RMB
              ,B.SALE_AMT_RMB    AS SALE_AMT_RMB
              ,B.SALE_RATE_RMB   AS SALE_RATE_RMB
              ,B.T_SALE_RATE_RMB AS T_SALE_RATE_RMB
              ,B.D_SALE_RATE_RMB AS D_SALE_RATE_RMB
              ,C.PROD_ID         AS PROD_ID_KRW
              ,C.PROD_NM         AS PROD_NM_KRW
              ,C.SALE_AMT_KRW    AS SALE_AMT_KRW
              ,C.SALE_RATE_KRW   AS SALE_RATE_KRW
              ,C.T_SALE_RATE_KRW AS T_SALE_RATE_KRW
              ,C.D_SALE_RATE_KRW AS D_SALE_RATE_KRW
          FROM WT_COPY A LEFT OUTER JOIN WT_PROD_AMT B ON (A.SALE_RANK = B.SALE_RANK_RMB)
                         LEFT OUTER JOIN WT_PROD_AMT C ON (A.SALE_RANK = C.SALE_RANK_KRW)
    )
    SELECT SALE_RANK                                                                 /* 순위                      */
          ,PROD_ID_RMB                                                               /* 제품ID           - 위안화 */
          ,PROD_NM_RMB                                                               /* 제품명           - 위안화 */
          ,TO_CHAR(SALE_AMT_RMB   , 'FM999,999,999,999,990.00' ) AS SALE_AMT_RMB     /* 매출액           - 위안화 */
          ,TO_CHAR(SALE_RATE_RMB  , 'FM999,999,999,999,990.00%') AS SALE_RATE_RMB    /* 매출기여         - 위안화 */
          ,TO_CHAR(T_SALE_RATE_RMB, 'FM999,999,999,999,990.00%') AS T_SALE_RATE_RMB  /* Tmall  매출 비중 - 위안화 */
          ,TO_CHAR(D_SALE_RATE_RMB, 'FM999,999,999,999,990.00%') AS D_SALE_RATE_RMB  /* Douyin 매출 비중 - 위안화 */
          ,PROD_ID_KRW                                                               /* 제품ID           - 원화   */
          ,PROD_NM_KRW                                                               /* 제품명           - 원화   */
          ,TO_CHAR(SALE_AMT_KRW   , 'FM999,999,999,999,990.00' ) AS SALE_AMT_KRW     /* 매출액           - 원화   */
          ,TO_CHAR(SALE_RATE_KRW  , 'FM999,999,999,999,990.00%') AS SALE_RATE_KRW    /* 매출기여         - 원화   */
          ,TO_CHAR(T_SALE_RATE_KRW, 'FM999,999,999,999,990.00%') AS T_SALE_RATE_KRW  /* Tmall  매출 비중 - 원화   */
          ,TO_CHAR(D_SALE_RATE_KRW, 'FM999,999,999,999,990.00%') AS D_SALE_RATE_KRW  /* Douyin 매출 비중 - 원화   */
      FROM WT_BASE
  ORDER BY SALE_RANK
;

14. Top5 환불 제품 (환불 기준)
    * 선택기준없이 당해 연도 상위 환불(환불 금액 기준) 제품들 나오도록 하며, Tmall 매출비중은 Tmall전체(내륙/글로벌) 중 매출비중, 도우인 매출비중은 Douyin전체(내륙/글로벌) 중 매출비중을 의미함

/* 14. Top5 환불 제품 (환불 기준) - 표 SQL */


15. Top5 환불 제품 (매출 대비 환불 기준)
    * 선택기준없이 당해 연도 상위 환불(매출 대비 환불 기준) 제품들 나오도록 하며, Tmall 매출비중은 Tmall전체(내륙/글로벌) 중 매출비중, 도우인 매출비중은 Douyin전체(내륙/글로벌) 중 매출비중을 의미함

/* 15. Top5 환불 제품 (매출 대비 환불 기준) - 표 SQL */

