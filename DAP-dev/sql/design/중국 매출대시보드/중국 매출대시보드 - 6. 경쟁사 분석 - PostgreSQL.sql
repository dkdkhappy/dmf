● 중국 매출대시보드 - 6. 경쟁사 분석

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 리뷰분석 경쟁사를 확인할 수 있는 경쟁사 분석 페이지
    ※ 조회기간은 초기 셋팅을 최근 3개월


1. 분석기간을 선택하는 기능(Calendar) 월단위 몇월 며칠 ~ 몇월 며칠까지
    ==> 월 달력, 기간 선택 기능

2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창


/* product.sql */
/* 2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창 - 제품선택 SQL */
/*    제품 Select Box 에서 사용, 여기에서는 제품ID가 아닌 제품명을 사용한다. */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
    ), WT_PROD AS
    (
        SELECT DISTINCT
               OWN_PROD_NAME AS PROD_NM
          FROM DASH.DGT_COMP_COMPETE A
         /* WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE) */
         WHERE COALESCE(OWN_PROD_NAME, '') != ''
    )
    SELECT PROD_NM
      FROM WT_PROD
  ORDER BY PROD_NM COLLATE "ko_KR.utf8"
;


3. 채널선택 (채널은 Tmall-Global, 내륙, 전체)
    ==> 기존 기획에서는 별도의 탭으로 기획을 했었는데 매출대시보드 내의 각 채널별 화면으로 기획이 변경되면서 채널선택 없이 각 채널별로 table 화면 디스플레이 해야 합니다.

4. 경쟁제품분석
    * Stack 바 그래프 : y축은 거래지수 기준(선택한 기간의 누적으로 계산한다) 마우스오버시 통합으로 보이는건 %단위로 (거래지수/전체거래지수), 쌓이는 것은 각 제품의 거래지수 기준,
                      x축은 선택한 제품 명들로 나와야함 (제품 1개 선택하면 바그래프1개, 2개선택하면 2개)
                      툴팁에서 타사제품명이 길경우 "[-]" 제외, 한글기준 15자리내 나오도록

    <로직 추가 설명>
    # 여러기간의 trade index를 합산하여 횡단면적 경쟁자 분석 진행
    1. 자사제품 (복수) 및 기간 선택 (캘린더는 월기준)
    2. 해당 기간 및 자사제품에 대한 데이터를 필터링
    3. 타사 제품의 trade index를 compete id 기준 groupby로 합산
    4. 합산된 trade index 기준으로 상위 5개 경쟁사 제품 trade index 디스플레이 (5개가 안나올수도 있음 그러니 최대 5개)
    ※. y축 거래지수 : trade_index
       조회기간 동안의 모든 데이터 sum 입니다. 만약 합산된 거래지수 기준으로 보았을 때 동점인 경우 선택된 기간 내의 출현빈도 
       (예를 들어 2023년 1월 ~ 3월을 선택하였을 때 1월과 3월에 데이터가 존재하는 경우 출현빈도는 2)를 기준으로 순위를 결정합니다.
       타사 제품 상위 5개만 보여주고 해당 기간 trade_index의 나머지는 기타 처리 부탁드립니다.

/* competingProductAnalysis.sql */
/* 4. 경쟁제품분석 - Stack Bar Chart SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_NM)        AS PROD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_NM, '★') AS PROD_NM  /* 입력된 제품명을 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) 'M4 토너 에멀전 세트, 더마펌 모이스트베리어워터선밀크 M4 본품 50ml 공통' */
    ), WT_DATA AS
    (
        SELECT OWN_PROD_NAME     AS PROD_NM
              ,COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.DGT_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME IN (SELECT PROD_NM FROM WT_PROD_WHERE)
      GROUP BY OWN_PROD_NAME
              ,COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT PROD_NM
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,CMPT_MNTH_MAX
              ,ROW_NUMBER() OVER(PARTITION BY PROD_NM ORDER BY TRDE_IDX DESC, CMPT_MNTH_MAX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_SUM AS
    (
        SELECT PROD_NM
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END AS CMPT_RANK
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END AS CMPT_ID
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END AS CMPT_NM
              ,SUM(TRDE_IDX)                                                         AS TRDE_IDX
          FROM WT_RANK A
      GROUP BY PROD_NM
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END
    ), WT_BASE AS
    (
        SELECT (SELECT SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_NM = A.PROD_NM) AS SORT_KEY
              ,A.PROD_NM
              ,CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,TRDE_IDX / SUM(TRDE_IDX) OVER(PARTITION BY A.PROD_NM) * 100 AS TRDE_RATE
          FROM WT_PROD_WHERE A LEFT OUTER JOIN WT_SUM B ON (A.PROD_NM = B.PROD_NM)
    )
    SELECT SORT_KEY                                        /* 정렬순서      */
          ,SUBSTRING(PROD_NM, 1, 30) AS PROD_NM            /* 자사 제품명   */
          ,CMPT_RANK                                       /* 경쟁제품 순위 */
          ,CMPT_ID                                         /* 경쟁제품 ID   */
          ,SUBSTRING(CMPT_NM, 1, 30) AS CMPT_NM            /* 경쟁제품 명   */
          ,TRDE_IDX                                        /* 거래지수      */
          ,CAST(TRDE_RATE AS DECIMAL(20,2)) AS TRDE_RATE   /* 거래지수 비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,CMPT_RANK COLLATE "ko_KR.utf8"


5. 제품선택 창이나, 단수선택만 가능하도록 (왜나하면 아래의 바그래프는 시간단위로 볼것)

6. 그래프선택창 (일반 barchart, 100% barchar)로 구분하여 보여주기

7. 경쟁제품 시계열 그래프
    * 기본 Stackbar그래프이되, X축은 선택한 기간에 대한 월별(1월부터 5월선택하면 1~5월나열) Y축은 거래지수 6번의 그래프선택이 100%바그래프일경우 100%기준 bar그래프로 보여주길 바람

/* competitorProductTimeSeriesGraph.sql */
/* 7. 경쟁제품 시계열 그래프 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:PROD_NM                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_DATA AS
    (
        SELECT TO_CHAR(CAST(DATE AS DATE), 'YYYY-MM') AS CMPT_MNTH
              ,COMPETE_ID                             AS CMPT_ID
              ,KOR_NAME                               AS CMPT_NM
              ,SUM(TRADE_INDEX)                       AS TRDE_IDX
          FROM DASH.DGT_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(DATE AS DATE), 'YYYY-MM')
              ,COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT CMPT_MNTH
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,ROW_NUMBER() OVER(PARTITION BY CMPT_MNTH ORDER BY TRDE_IDX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_SUM AS
    (
        SELECT CMPT_MNTH
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END AS CMPT_RANK
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END AS CMPT_ID
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END AS CMPT_NM
              ,SUM(TRDE_IDX)                                                         AS TRDE_IDX
          FROM WT_RANK A
      GROUP BY CMPT_MNTH
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END
    ), WT_BASE AS
    (
        SELECT CMPT_MNTH
              ,CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,TRDE_IDX / SUM(TRDE_IDX) OVER(PARTITION BY CMPT_MNTH) * 100 AS TRDE_RATE
          FROM WT_SUM A
    )
    SELECT CMPT_MNTH                                      /* 기준월        */
          ,CMPT_RANK                                      /* 경쟁제품 순위 */
          ,CMPT_ID                                        /* 경쟁제품 ID   */
          ,SUBSTRING(CMPT_NM, 1, 30) AS CMPT_NM           /* 경쟁제품 명   */
          ,TRDE_IDX                                       /* 거래지수      */
          ,CAST(TRDE_RATE AS DECIMAL(20,2)) AS TRDE_RATE  /* 거래지수 비율 */
      FROM WT_BASE
  ORDER BY CMPT_MNTH
          ,CMPT_RANK COLLATE "ko_KR.utf8"


8. 경쟁제품 등수변화
    * 평행그래프로, 각 라이벌 제품의 등수변화 보여주기 (상위 10개)

/* competitionProductRankingShiftMonth.sql */
/* 8. 경쟁제품 등수변화 - 월 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
    )
    SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS AMT_MNTH


/* competitionProductRankingShiftChart.sql */
/* 8. 경쟁제품 등수변화 - 평행그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:FR_MNTH                                                                           AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                           AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:PROD_NM                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_DATA_AMT AS
    (
        SELECT BASE_TIME
              ,PROD_ID
              ,SUM(CAST(SALE_AMT AS DECIMAL(20,0))) AS SALE_AMT
          FROM DASH.TMALL_ITEM_RANK_DATA
         WHERE BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY BASE_TIME
              ,PROD_ID
    ), WT_AMT_RANK AS
    (
        SELECT BASE_TIME AS AMT_MNTH
              ,PROD_ID   AS PROD_ID
              ,SALE_AMT  AS SALE_AMT
              ,ROW_NUMBER() OVER(PARTITION BY BASE_TIME ORDER BY SALE_AMT DESC, PROD_ID) AS AMT_RANK
          FROM WT_DATA_AMT
    ), WT_DATA AS
    (
        SELECT OWN_PROD_NAME     AS PROD_NM
              ,COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.DGT_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY OWN_PROD_NAME
              ,COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT PROD_NM
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,CMPT_MNTH_MAX
              ,ROW_NUMBER() OVER(PARTITION BY PROD_NM ORDER BY TRDE_IDX DESC, CMPT_MNTH_MAX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_RANK_MNTH AS
    (
        SELECT A.COPY_MNTH
              ,B.PROD_NM
              ,B.CMPT_ID
              ,B.CMPT_NM
              ,B.TRDE_IDX
              ,B.CMPT_RANK
          FROM WT_COPY_MNTH A
              ,WT_RANK      B
        WHERE B.CMPT_RANK <= 5
    ), WT_RANK_AMT_JOIN AS
    (
        SELECT A.PROD_NM
              ,A.CMPT_ID
              ,A.CMPT_NM
              ,A.TRDE_IDX
              ,A.CMPT_RANK
              ,A.COPY_MNTH
              ,COALESCE(CAST(B.AMT_RANK AS TEXT), '') AS AMT_RANK
          FROM WT_RANK_MNTH A LEFT OUTER JOIN WT_AMT_RANK B ON (A.COPY_MNTH = B.AMT_MNTH AND A.CMPT_ID = B.PROD_ID)
    ), WT_BASE AS 
    (
        SELECT CMPT_RANK
              ,CMPT_NM
              ,ARRAY_TO_STRING(ARRAY_AGG(COPY_MNTH ORDER BY COPY_MNTH),',') AS AMT_MNTH_LIST
              ,ARRAY_TO_STRING(ARRAY_AGG(AMT_RANK  ORDER BY COPY_MNTH),',') AS AMT_RANK_LIST
          FROM WT_RANK_AMT_JOIN
      GROUP BY CMPT_RANK
              ,CMPT_NM
    )
    SELECT CMPT_RANK                                                                  /* 경쟁제품 지수 등수 */
          ,SUBSTRING(CMPT_NM, 1, 15)                                   AS P_CATE_VAL  /* 경쟁제품 명        */
          ,AMT_RANK_LIST || ',''' || SUBSTRING(CMPT_NM, 1, 30) || '''' AS S_DATA      /* 경쟁제품 AMT 등수  */
      FROM WT_BASE
  ORDER BY CMPT_RANK



9. 경쟁 제품 TOP 5
    * 7번에서 선택한 기준을 이용하여 그 기간 동안 누적 1~5등까지 테이블로 보여주기 칼럼(등수, 제품명, 누적 거래지수, 링크)

/* topFiveCompetingProducts.sql */
/* 9. 경쟁 제품 TOP 5 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:PROD_NM                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_DATA AS
    (
        SELECT COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.DGT_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,CMPT_MNTH_MAX
              ,ROW_NUMBER() OVER(ORDER BY TRDE_IDX DESC, CMPT_MNTH_MAX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_BASE AS
    (
        SELECT CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,(SELECT MAX(ITEM_PIC)
                  FROM DASH.DGT_COMP_COMPETE X
                 WHERE X.COMPETE_ID    = A.CMPT_ID
                   AND X.DATE          = A.CMPT_MNTH_MAX
                   AND X.OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
               ) AS PROD_IMG
          FROM WT_RANK A
         WHERE CMPT_RANK <= 5
    )
    SELECT CMPT_RANK                                               /* 등수          */
          ,CMPT_ID                                                 /* 제품ID        */
          ,SUBSTRING(CMPT_NM, 1, 30)                  AS CMPT_NM   /* 제품명        */
          ,TO_CHAR(TRDE_IDX, 'FM999,999,999,999,990') AS TRDE_IDX  /* 누적 거래지수 */
          ,PROD_IMG                                                /* 제품 이미지   */
      FROM WT_BASE
  ORDER BY CMPT_RANK
  