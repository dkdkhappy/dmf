let sale = {};
let currency = "rmb"; // 화면 적용 화폐 test

sale.impCardAmtData = {}; // # 1. 중요정보 카드 - 금액 SQL
sale.impCardAmtChart = {}; // # 1. 중요정보 카드 - Chart SQL
sale.salesTimeSeriesGraphData = {}; // # 2. 매출정보에 대한 시계열 그래프 - 그래프상단 정보 SQL
sale.salesTimeSeriesGraphChart = {}; // # 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL
sale.salesTimeSeriesGraphBottom = {}; // # 2. 매출정보에 대한 시계열 그래프 - 하단표 SQL
sale.salesHeatmapData = {}; // # 3. 일별 / 시간별 매출 히트맵
sale.salesRefundTimeSeriesAllData = {}; // # 4. 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 SQL
sale.salesRefundTimeSeriesAllGraph = {}; // # 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL
sale.refundAmountYoY = {}; // # 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 SQL
sale.refundDataByMonth = {}; // # 5. 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 SQL
sale.productSalesMast = {}; // # 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 SQL
sale.productSalesTimeSeries = {}; // # 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL
sale.salesComparisonLastYear = {}; // # 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 SQL
sale.salesRankingLYMoM = {}; // # 9. 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 SQL
sale.topSalesLastMonth = {}; // # 9. 제품별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 SQL
sale.productRefundMast = {}; // # 10. 제품별 환불 정보 시계열 그래프 - 제품별 선택 SQL
sale.refundTimeSeriesByProduct = {}; // # 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL
sale.refundComparisonLastYear = {}; // # 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 SQL
sale.refundRankingLYMoM = {}; // # 11. 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 SQL
sale.topRefundLastMonth = {}; // # 11. 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 SQL
sale.onloadStatus = false; // 화면 로딩 상태
sale.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
  {
    type: "inside",
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

// 매출 정보에 대한 시계열
sale.charLineSalesOption = {
  tooltip: {
    trigger: "axis",
    sort: "ascending",
  },
  legend: {
    data: ["결제 금액", "환불 제외 금액"],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: sale.zoomSales,
  grid: {
    left: "2.5%",
    right: "5%",
    containLabel: !0,
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  textStyle: {
    fontFamily: "Poppins, sans-serif",
  },
  xAxis: {
    type: "category",
    boundaryGap: !1,
    data: [],
    axisLine: {
      lineStyle: {
        color: "#858d98",
      },
    },
  },
  yAxis: {
    type: "value",
    axisLine: {
      lineStyle: {
        color: "#858d98",
      },
    },
    splitLine: {
      lineStyle: {
        color: "rgba(133, 141, 152, 0.1)",
      },
    },
  },
  series: [
    {
      // name: "결제 금액",
      type: "line",
      data: [],
    },
    {
      // name: "환불 제외 금액",
      type: "line",
      data: [],
    },
  ],
  graphic: {
    elements: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },
};

if (document.getElementById("chart-line-sales")) {
  sale.chartLineSales = echarts.init(document.getElementById("chart-line-sales"));
  sale.chartLineSales.setOption(sale.charLineSalesOption);
}

sale.setDataBinding = function () {
  /* currency dom */
  let currencyDom = document.getElementById("selected-currency-img");
  currency = currencyDom.getAttribute("data-currency");
  currency = currency == "cny" ? "rmb" : currency;
  if (currency == "rmb") {
    // debugger;
    let bxYenAll = document.querySelectorAll(".bx-won");
    bxYenAll.forEach(function (bxYen) {
      if (!bxYen.classList.contains("fix-won")) {
        bxYen.classList.add("bx-yen");
        bxYen.classList.remove("bx-won");
      }
    });
  } else {
    let bxYenAll = document.querySelectorAll(".bx-yen");
    bxYenAll.forEach(function (bxYen) {
      if (!bxYen.classList.contains("fix-won")) {
        bxYen.classList.add("bx-won");
        bxYen.classList.remove("bx-yen");
      }
    });
  }

  /* 중요정보 카드 */
  if (Object.keys(sale.impCardAmtData).length > 0) {
    sale.impCardAmtUpdate();
  }
  /* 중요정보 카드 - 그래프 */
  if (Object.keys(sale.impCardAmtChart).length > 0) {
    sale.impCardAmtChartUpdate();
  }
  /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 */
  if (Object.keys(sale.salesTimeSeriesGraphData).length > 0) {
    sale.salesTimeSeriesUpdate();
  }
  /* 매출 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */
  if (Object.keys(sale.salesTimeSeriesGraphChart).length > 0) {
    // console.table(sale.salesTimeSeriesGraphChart);
    sale.chartLineSalesUpdate(); //
  }
  /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */
  if (Object.keys(sale.salesTimeSeriesGraphBottom).length > 0) {
    sale.chartLineSalesBottomUpdate();
  }
  /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */
  if (Object.keys(sale.salesHeatmapData).length > 0) {
    sale.salesHeatmapDataUpdate();
  }
  /* 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 */
  if (Object.keys(sale.salesRefundTimeSeriesAllData).length > 0) {
    sale.salesRefundTimeSeriesUpdate();
  }
  /* 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
  if (Object.keys(sale.salesRefundTimeSeriesAllGraph).length > 0) {
    // console.table(sale.salesRefundTimeSeriesAllGraph);
    sale.salesRefundTimeSeriesAllGraphUpdate();
  }
  /* # 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 */
  if (Object.keys(sale.refundAmountYoY).length > 0) {
    // console.table(sale.refundAmountYoY);
    sale.refundAmountYoYUpdate();
  }
  /* # 5. 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 */
  if (Object.keys(sale.refundDataByMonth).length > 0) {
    // console.table(sale.refundDataByMonth);
    sale.refundDataByMonthUpdate();
  }
  /* 6. 채널 내 매출 순위 300위 - 상점명 선택 SQL */
  if (Object.keys(sale.storeName).length > 0) {
    // console.table(sale.storeName);
    sale.storeNameUpdate();
  }
  /* 7. 카테고리별 매출 순위 - 1차 카테고리 선택 SQL */
  if (Object.keys(sale.categorySalesRank1).length > 0) {
    // console.table(sale.categorySalesRank1);
    sale.categorySalesRank1Update();
  }
  /* # 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 */
  if (Object.keys(sale.productSalesMast).length > 0) {
    // console.table(sale.productSalesMast);
    sale.productSalesMastUpdate();
  }
  /* # 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 */
  if (Object.keys(sale.productSalesTimeSeries).length > 0) {
    // sale.productSalesTimeSeriesUpdate();
  }
  /* # 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 */
  if (Object.keys(sale.salesComparisonLastYear).length > 0) {
    sale.productSalesDataViewer("yoy");
  }
  /* # 10. 제품별 환불 정보 시계열 그래프 - 제품별 선택 */
  if (Object.keys(sale.productRefundMast).length > 0) {
    // console.table(sale.productRefundMast);
    sale.productRefundMastUpdate();
  }
  /* # 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 */
  if (Object.keys(sale.refundTimeSeriesByProduct).length > 0) {
    //sale.refundTimeSeriesByProductUpdate();
  }
  /* # 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 */
  if (Object.keys(sale.refundComparisonLastYear).length > 0) {
    sale.productRefudDataViewer("yoy");
  }
  /* number counting 처리 */
  counter();
};

/**
 * 매출 상단 카드 - 카드 내 data
 */
sale.impCardAmtUpdate = function () {
  let rawData = sale.impCardAmtData[0];
  // 상단 중요정보 카드
  //  sale_amt      : 일매출금액,       sale_amt_mnth      : 월매출금액(누적),        sale_amt_year      : 연매출금액(누적)
  //  sale_rate_dod : 일매출금액 증감률, sale_rate_mnth_yoy : 월매출금액(누적) 증감률, sale_rate_year_yoy : 연매출금액(누적) 증감률
  // refd_amt       : 일환불금액,        refd_amt_mnth     : 월매환불액(누적),        refd_amt_year      : 연환불금액(누적)
  // refd_rate_dod  : 일환불금액 증감률, refd_rate_mnth_yoy : 월환불금액(누적) 증감률, refd_rate_year_yoy : 연환불금액(누적) 증감률

  let cardAreaList = [
    "sale_amt",
    "sale_rate_dod",
    "sale_amt_mnth",
    "sale_rate_mnth_yoy",
    "sale_amt_year",
    "sale_rate_year_yoy",
    "refd_amt",
    "refd_rate_dod",
    "refd_amt_mnth",
    "refd_rate_mnth_yoy",
    "refd_amt_year",
    "refd_rate_year_yoy",
  ];

  cardAreaList.forEach((cardArea) => {
    let el = document.getElementById(`${cardArea}`);
    if (el) {
      if (cardArea.indexOf("_dod") > -1 || cardArea.indexOf("_yoy") > -1) {
        let elArrow = document.getElementById(`${cardArea}_arrow`);
        if (elArrow) {
          if (Number(rawData[`${cardArea}_${currency}`]) > 0) {
            el.classList.add("text-success");
            elArrow.classList.add("ri-arrow-up-line", "text-success");
          } else if (Number(rawData[`${cardArea}_${currency}`]) < 0) {
            el.classList.add("text-danger");
            elArrow.classList.add("ri-arrow-down-line", "text-danger");
          } else {
            el.classList.add("text-muted");
            elArrow.classList.add("text-muted");
          }
          el.innerText = rawData[`${cardArea}_${currency}`] + "%";
        }
      } else {
        el.innerText = 0;
        el.setAttribute("data-target", rawData[`${cardArea}_${currency}`]);
      }
    }
  });

  if (sale.radialChart) {
    sale.radialChart.updateOptions({
      series: [rawData["revn_tagt_rate"]],
    });
  }

  const brnd_rank_el = document.getElementById("brnd_rank");
  const top_sales_rank_el = document.getElementById("top_sales_rank");
  const top_sales_rank_arrow_el = document.getElementById("top_sales_rank_arrow");

  if (brnd_rank_el && top_sales_rank_el && top_sales_rank_arrow_el) {
    brnd_rank_el.innerText = rawData["brnd_rank"];
    top_sales_rank_el.innerText = Math.abs(Number(rawData["brnd_rank_mom"]));

    if (Number(rawData["brnd_rank_mom"]) > 0) {
      top_sales_rank_el.classList.add("plus_mark", "text-success");
      top_sales_rank_arrow_el.classList.add("ri-arrow-up-line", "text-success");
    } else if (Number(rawData["brnd_rank_mom"]) < 0) {
      top_sales_rank_el.classList.add("minus_mark", "text-danger");
      top_sales_rank_arrow_el.classList.add("ri-arrow-down-line", "text-danger");
    } else {
      top_sales_rank_el.classList.add("text-muted");
      top_sales_rank_arrow_el.classList.add("text-muted");
    }
  }

  const brnd_rank_kr_el = document.getElementById("brnd_rank_kr");
  const kor_brand_sales_rank_el = document.getElementById("kor_brand_sales_rank");
  const kor_brand_sales_rank_arrow_el = document.getElementById("kor_brand_sales_rank_arrow");

  if (brnd_rank_kr_el && kor_brand_sales_rank_el && kor_brand_sales_rank_arrow_el) {
    brnd_rank_kr_el.innerText = rawData["brnd_rank_kr"];
    kor_brand_sales_rank_el.innerText = Math.abs(Number(rawData["brnd_rank_kr_mom"]));

    if (Number(rawData["brnd_rank_kr_mom"]) > 0) {
      kor_brand_sales_rank_el.classList.add("plus_mark", "text-success");
      kor_brand_sales_rank_arrow_el.classList.add("ri-arrow-up-line", "text-success");
    } else if (Number(rawData["brnd_rank_kr_mom"]) < 0) {
      kor_brand_sales_rank_el.classList.add("minus_mark", "text-danger");
      kor_brand_sales_rank_arrow_el.classList.add("ri-arrow-down-line", "text-danger");
    } else {
      kor_brand_sales_rank_el.classList.add("text-muted");
      kor_brand_sales_rank_arrow_el.classList.add("text-muted");
    }
    const revn_tagt_amt = document.getElementById("revn_tagt_amt");
    revn_tagt_amt.innerText = 0;
    revn_tagt_amt.setAttribute("data-target", rawData["revn_tagt_amt"]);
  }
};

/**
 * 매출 상단 카드 - apex chart
 */
sale.impCardAmtChartUpdate = function () {
  // 상단 중요정보 카드 - 그래프

  let {
    DAY = [],
    MNTH = [],
    YEAR = [],
  } = sale.impCardAmtChart.reduce((arr, chart) => {
    arr[chart["chrt_key"]] ? arr[chart["chrt_key"]].push(chart) : (arr[chart["chrt_key"]] = [chart]);
    return arr;
  }, {});

  let daySaleData = DAY.map((d) => ({
    x: d["x_dt"],
    y: Number(d[`y_val_sale_${currency}`]),
  })),
    dayRefdData = DAY.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_refd_${currency}`]),
    })),
    mnthSaleData = MNTH.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_sale_${currency}`]),
    })),
    mnthRefdData = MNTH.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_refd_${currency}`]),
    })),
    yearSaleData = YEAR.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_sale_${currency}`]),
    })),
    yearRefdData = YEAR.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_refd_${currency}`]),
    }));

  // 전일 매출 그래프 데이터 업데이트
  if (sale.areaChart1) {
    sale.areaChart1.updateSeries([
      {
        name: "금액",
        data: daySaleData,
      },
    ]);
  }
  // 당월 누적 매출 그래프 데이터 업데이트
  if (sale.areaChart2) {
    sale.areaChart2.updateSeries([
      {
        name: "금액",
        data: mnthSaleData,
      },
    ]);
  }
  // 당해 누적 매출 그래프 데이터 업데이트
  if (sale.areaChart3) {
    sale.areaChart3.updateSeries([
      {
        name: "금액",
        data: yearSaleData,
      },
    ]);
  }
  // 전일 환불 금액 그래프 데이터 업데이트
  if (sale.areaChart4) {
    sale.areaChart4.updateSeries([
      {
        name: "금액",
        data: dayRefdData,
      },
    ]);
  }
  // 당월 누적 환불 그래프 데이터 업데이트
  if (sale.areaChart5) {
    sale.areaChart5.updateSeries([
      {
        name: "금액",
        data: mnthRefdData,
      },
    ]);
  }
  // 당해 누적 환불 그래프 데이터 업데이트
  if (sale.areaChart6) {
    sale.areaChart6.updateSeries([
      {
        name: "금액",
        data: yearRefdData,
      },
    ]);
  }
};

/**
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - 상단 카드
 */
sale.salesTimeSeriesUpdate = function () {
  let rawData = sale.salesTimeSeriesGraphData;
  if (document.getElementById("time_series_sale_amt")) {
    document.getElementById("time_series_sale_amt").innerText = 0;
    document.getElementById("time_series_sale_amt").setAttribute("data-target", rawData[0][`exre_amt_${currency}`]);
  }

  if (document.getElementById("time_series_sale_amt_yoy")) {
    document.getElementById("time_series_sale_amt_yoy").innerText = 0;
    document.getElementById("time_series_sale_amt_yoy").setAttribute("data-target", rawData[0][`exre_amt_yoy_${currency}`]);
  }

  if (document.getElementById("time_series_sale_rate")) {
    document.getElementById("time_series_sale_rate").innerText = 0;
    document.getElementById("time_series_sale_rate").setAttribute("data-target", rawData[0][`exre_rate_${currency}`]);
  }
};

/**
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 Gridjs
 */

sale.chartLineSalesBottomUpdate = function () {
  if (sale.saleInfoListGrid) {
    let keysToExtract = [
      "row_titl",
      `exre_amt_01_${currency}`,
      `exre_amt_02_${currency}`,
      `exre_amt_03_${currency}`,
      `exre_amt_04_${currency}`,
      `exre_amt_05_${currency}`,
      `exre_amt_06_${currency}`,
      `exre_amt_07_${currency}`,
      `exre_amt_08_${currency}`,
      `exre_amt_09_${currency}`,
      `exre_amt_10_${currency}`,
      `exre_amt_11_${currency}`,
      `exre_amt_12_${currency}`,
      `sale_amt_01_${currency}`,
      `sale_amt_02_${currency}`,
      `sale_amt_03_${currency}`,
      `sale_amt_04_${currency}`,
      `sale_amt_05_${currency}`,
      `sale_amt_06_${currency}`,
      `sale_amt_07_${currency}`,
      `sale_amt_08_${currency}`,
      `sale_amt_09_${currency}`,
      `sale_amt_10_${currency}`,
      `sale_amt_11_${currency}`,
      `sale_amt_12_${currency}`,
    ];
    let filterData = [];
    for (var i = 0; i < sale.salesTimeSeriesGraphBottom.length; i++) {
      filterData.push(keysToExtract.map((key) => sale.salesTimeSeriesGraphBottom[i][key]));
    }
    sale.saleInfoListGrid.updateConfig({ data: filterData }).forceRender();
  }
};

/**
 * 일별 / 시간별 매출 히트맵
 */
sale.salesHeatmapDataUpdate = function () {
  if (sale.heatMapSales) {
    sale.heatMapSales.setOption(sale.heatMapSalesOption, true);
    let rawData = sale.salesHeatmapData;
    if (rawData.length > 0) {
      // 전일 매출 그래프 데이터 업데이트
      let salesHeatmapData = [];
      let maxVal = 0;
      switch (currency) {
        case "rmb":
          salesHeatmapData = rawData.map(({ week_no, hour_no, sale_amt_rmb }) => [Number(week_no), Number(hour_no), Number(sale_amt_rmb)]);
          maxVal = rawData.reduce(function (prev, current) {
            return Number(prev.sale_amt_rmb) > Number(current.sale_amt_rmb) ? prev : current;
          }).sale_amt_rmb;
          break;
        case "krw":
          salesHeatmapData = rawData.map(({ week_no, hour_no, sale_amt_krw }) => [Number(week_no), Number(hour_no), Number(sale_amt_krw)]);
          maxVal = rawData.reduce(function (prev, current) {
            return Number(prev.sale_amt_krw) > Number(current.sale_amt_krw) ? prev : current;
          }).sale_amt_krw;
          break;
      }
      sale.data = salesHeatmapData.map(function (item) {
        return [item[1], item[0], item[2] || "-"];
      });
      sale.heatMapSales.setOption({
        visualMap: {
          min: 0,
          max: maxVal,
        },
        series: [
          {
            data: sale.data,
          },
        ],
      });
    }
  }
};

/**
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - echart
 */
sale.chartLineSalesUpdate = function () {
  if (sale.chartLineSales) {
    sale.chartLineSales.setOption(sale.charLineSalesOption, true);
    let rawData = sale.salesTimeSeriesGraphChart;
    if (rawData.length > 0) {
      // 상단 중요정보 카드 - 그래프
      let dataArr = rawData.reduce((arr, chart) => {
        (arr[chart["l_lgnd_id"]] = arr[chart["l_lgnd_id"]] || []).push(chart);
        return arr;
      }, {});

      let uniqueLegends = rawData.reduce((result, item) => {
        const { l_lgnd_id, l_lgnd_nm } = item;
        if (!result[l_lgnd_id]) result[l_lgnd_id] = { id: l_lgnd_id, name: l_lgnd_nm };
        return result;
      }, {});

      const lgnd = [...new Set(rawData.map((item) => item.l_lgnd_id))];

      const lgnd_nm = [...new Set(rawData.map((item) => item.l_lgnd_nm))];

      const dates = [...new Set([...dataArr["SALE"].map(({ x_dt }) => x_dt), ...dataArr["EXRE"].map(({ x_dt }) => x_dt)])];

      let dayValues = [[], [], [], [], [], []],
        series = [];
      for (let i = 0; i < lgnd.length; i++) {
        for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
          dayValues[i][j] = Number(dataArr[lgnd[i]][j][`y_val_${currency}`]);
        }
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          data: dayValues[i],
        });
      }
      let dataSum = dayValues[0].length + dayValues[1].length + dayValues[2].length + dayValues[3].length + dayValues[4].length + dayValues[5].length;

      sale.chartLineSales.setOption({
        legend: {
          data: lgnd_nm,
          selected: {
            "결제금액 - 주매출": false,
            "결제금액 - 월매출": false,
            "환불제외금액 - 주매출": false,
            "환불제외금액 - 월매출": false,
          },
          textStyle: {
            color: "#858d98",
          },
        },
        dataZoom: sale.zoomSales,
        xAxis: {
          type: "category",
          data: dates,
        },
        yAxis: {
          type: "value",
        },
        series: series,
        graphic: {
          elements: [
            {
              style: {
                text: dataSum == 0 ? "데이터가 없습니다" : "",
              },
            },
          ],
        },
      });
    }
  }
};

/**
 * 환불 정보에 대한 시계열 - 상단 카드
 */
sale.salesRefundTimeSeriesUpdate = function () {
  let rawData = sale.salesRefundTimeSeriesAllData;
  /* 당해 */
  if (document.getElementById("refd_amt_time")) {
    document.getElementById("refd_amt_time").innerText = 0;
    document.getElementById("refd_amt_time").setAttribute("data-target", rawData[0][`refd_amt_${currency}`]);
  }
  if (document.getElementById("refd_amt_yoy_time")) {
    document.getElementById("refd_amt_yoy_time").innerText = 0;
    document.getElementById("refd_amt_yoy_time").setAttribute("data-target", rawData[0][`refd_amt_yoy_${currency}`]);
  }
  if (document.getElementById("refd_rate_time")) {
    document.getElementById("refd_rate_time").innerText = 0;
    document.getElementById("refd_rate_time").setAttribute("data-target", rawData[0][`refd_rate_${currency}`]);
  }

  /* 전해 */
  if (document.getElementById("pcnt_amt_time")) {
    document.getElementById("pcnt_amt_time").innerText = 0;
    document.getElementById("pcnt_amt_time").setAttribute("data-target", rawData[0][`pcnt_amt_${currency}`]);
  }
  if (document.getElementById("pcnt_amt_yoy_time")) {
    document.getElementById("pcnt_amt_yoy_time").innerText = 0;
    document.getElementById("pcnt_amt_yoy_time").setAttribute("data-target", rawData[0][`pcnt_amt_yoy_${currency}`]);
  }
  if (document.getElementById("pcnt_rate_time")) {
    document.getElementById("pcnt_rate_time").innerText = 0;
    document.getElementById("pcnt_rate_time").setAttribute("data-target", rawData[0][`pcnt_rate_${currency}`]);
  }
};

/**
 * 환불 정보에 대한 시계열 - echart
 */
sale.salesRefundTimeSeriesAllGraphUpdate = function () {
  if (sale.chartLineRefuned) {
    sale.chartLineRefuned.setOption(sale.charLineRefunedOption, true);
    // 상단 중요정보 카드 - 그래프
    let dataArr = sale.salesRefundTimeSeriesAllGraph.reduce((arr, chart) => {
      (arr[chart["l_lgnd_id"]] = arr[chart["l_lgnd_id"]] || []).push(chart);
      return arr;
    }, {});

    let uniqueLegends = sale.salesRefundTimeSeriesAllGraph.reduce((result, item) => {
      const { l_lgnd_id, l_lgnd_nm } = item;
      if (!result[l_lgnd_id]) result[l_lgnd_id] = { id: l_lgnd_id, name: l_lgnd_nm };
      return result;
    }, {});

    const lgnd = [...new Set(sale.salesRefundTimeSeriesAllGraph.map((item) => item.l_lgnd_id))];
    const lgnd_nm = [...new Set(sale.salesRefundTimeSeriesAllGraph.map((item) => item.l_lgnd_nm))];
    const dates = [...new Set([...dataArr["SALE"].map(({ x_dt }) => x_dt), ...dataArr["REFD"].map(({ x_dt }) => x_dt)])];
    let dayValues = [[], [], [], [], [], [], [], [], []],
      series = [];
    for (let i = 0; i < lgnd.length; i++) {
      for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
        dayValues[i][j] = Number(dataArr[lgnd[i]][j][`y_val_${currency}`]);
      }
      if (lgnd[i].substring(0, 4) === "RATE") {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          yAxisIndex: 1,
          data: dayValues[i],
        });
      } else {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          yAxisIndex: 0,
          data: dayValues[i],
        });
      }
    }
    let dataSum = dayValues[0].length + dayValues[1].length + dayValues[2].length + dayValues[3].length + dayValues[4].length + dayValues[5].length;

    sale.chartLineRefuned.setOption({
      legend: {
        data: lgnd_nm,
        selected: {
          주매출: false,
          월매출: false,
          주환불: false,
          월환불: false,
          주환불비중: false,
          월환불비중: false,
        },
        textStyle: {
          color: "#858d98",
        },
      },
      xAxis: {
        type: "category",
        data: dates,
      },
      yAxis: [
        {
          type: "value",
        },
        {
          type: "value",
        },
      ],
      series: series,
      graphic: {
        elements: [
          {
            style: {
              text: dataSum == 0 ? "데이터가 없습니다" : "",
            },
          },
        ],
      },
    });
  }
};

/**
 * 전년 동월 대비 환불 금액 및 환불 비중
 */
sale.refundAmountYoYUpdate = function (month) {
  if (sale.lastYearRefunedListGrid) {
    let keysToExtract = ["row_titl", `refd_yoy_${currency}`, `refd_${currency}`];
    let filterData = [];
    for (var i = 0; i < sale.refundAmountYoY.length; i++) {
      filterData.push(keysToExtract.map((key) => sale.refundAmountYoY[i][key]));
    }
    if (!month) {
      month = sale.initData.base_mnth.split("-")[1];
    }
    sale.lastYearRefunedListGrid
      .updateConfig({
        columns: [
          {
            name: "구분",
          },
          {
            name: `전년 ${Number(month)}월`,
          },
          {
            name: `올해 ${Number(month)}월`,
          },
        ],
        data: filterData,
      })
      .forceRender();
  }
};

/**
 * 월별 환불 금액 및 환불 비중
 */
sale.refundDataByMonthUpdate = function () {
  if (sale.monthRefunedList) {
    let keysToExtract = [
      "row_titl",
      `refd_01_${currency}`,
      `refd_02_${currency}`,
      `refd_03_${currency}`,
      `refd_04_${currency}`,
      `refd_05_${currency}`,
      `refd_06_${currency}`,
      `refd_07_${currency}`,
      `refd_08_${currency}`,
      `refd_09_${currency}`,
      `refd_10_${currency}`,
      `refd_11_${currency}`,
      `refd_12_${currency}`,
    ];
    let filterData = [];
    for (var i = 0; i < sale.refundDataByMonth.length; i++) {
      filterData.push(keysToExtract.map((key) => sale.refundDataByMonth[i][key]));
    }
    sale.monthRefunedList.updateConfig({ data: filterData }).forceRender();
  }
};

/**
 * 제품별 매출 정보 시계열 그래프 - 제품 선택 Select Box
 */
sale.productSalesMastUpdate = function () {
  prodList = [];
  sale.productSalesMast.forEach((product) => {
    prodList.push({ value: product.prod_id, label: product.prod_nm });
  });
  if (document.getElementById("choices-multiple-product1")) {
    const choicesMultipleProduct = document.getElementById("choices-multiple-product1");
    if (!sale.selProductSales) {
      sale.selProductSales = new Choices(choicesMultipleProduct, {
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
    sale.selProductSales.setChoices(prodList, "value", "label", true);
  }
};

/**
 * 제품별 매출 정보 시계열 그래프 - chart update
 */
sale.productSalesTimeSeriesUpdate = function () {
  const rawData = sale.productSalesTimeSeries;

  const filteredData1 = rawData.filter((item) => item.l_lgnd_id === 9999999999999);
  const lgnd = [...new Set(rawData.map((item) => item.l_lgnd_id))].sort((a, b) => a - b);

  let uniqueLegends = rawData.reduce((result, item) => {
    const { l_lgnd_id, l_lgnd_nm } = item;
    if (!result[l_lgnd_id]) result[l_lgnd_id] = { id: l_lgnd_id, name: l_lgnd_nm };
    return result;
  }, {});

  const dates1 = filteredData1.map((item) => item.x_dt);
  const sales1 = filteredData1.map((item) => parseFloat(item.y_val_sale_rmb));

  let yAxis = [];

  yAxis.push({
    type: "value",
    name: "전체 매출",
    position: "right",
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      formatter: "{value}",
    },
  });

  yAxis.push({
    type: "value",
    name: "제품 매출",
    position: "left",
    min: 0,
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      formatter: "{value}",
    },
  });

  let series = [];
  series.push({
    name: "전체 매출",
    type: "line",
    data: sales1,
  });

  let idx = 1;
  let dataSum = 0;
  lgnd.forEach((id) => {
    if (id !== 9999999999999) {
      // 기존 일매출, 일매출(환불제외) 2개의 legend로 되어있던 금액 중 일매출(환불제외)만 사용하고 이름을 제품명만 표시하도록 변경
      filteredData2 = rawData.filter((item) => item.l_lgnd_id == id);
      keysToExtract = ["x_dt", `y_val_exre_${currency}`];
      filterData = [];
      dataSum += filteredData2.length;
      for (var i = 0; i < filteredData2.length; i++) {
        filterData.push(keysToExtract.map((key) => filteredData2[i][key]));
      }
      series.push({
        name: `${uniqueLegends[id]["name"]}`,
        type: "line",
        yAxisIndex: idx,
        data: filterData,
      });
    }
  });

  let selProductSales = sale.selProductSales.getValue();
  let legend = selProductSales.map((item) => item.label);
  legend.unshift("전체 매출");

  sale.chartSalesProductInfo.setOption({
    xAxis: [
      {
        type: "category",
        axisTick: {
          alignWithLabel: true,
        },
        // prettier-ignore
        data: dates1,
      },
    ],
    legend: {
      data: legend,
      textStyle: {
        color: "#858d98",
      },
    },
    yAxis: yAxis,
    series: series,
    graphic: {
      elements: [
        {
          type: "text",
          left: "center",
          top: "middle",
          style: {
            text: dataSum == 0 ? "데이터가 없습니다" : "",
            fill: "#999",
            font: "14px Microsoft YaHei",
          },
        },
      ],
    },
  });
};

/**
 * 제품별 환불 시계열 그래프 - chart update
 */
sale.refundTimeSeriesByProductUpdate = function () {
  let rawData = sale.refundTimeSeriesByProduct;

  rawData = rawData.sort(function (a, b) {
    if (a.x_dt === "") return -1;
    return new Date(a.x_dt) - new Date(b.x_dt);
  });

  // const l_lgnd_id_arr = rawData.map((obj) => obj.l_lgnd_id);
  // const x_dt_arr = rawData.map((obj) => obj.x_dt);
  // const y_val_sale_rmb_arr = rawData.map((obj) => obj.y_val_sale_rmb);

  let uniqueLegends = rawData.reduce((result, item) => {
    const { l_lgnd_id, l_lgnd_nm } = item;
    if (!result[l_lgnd_id]) result[l_lgnd_id] = { id: l_lgnd_id, name: l_lgnd_nm };
    return result;
  }, {});

  const lgnd = [...new Set(rawData.map((item) => item.l_lgnd_id))].sort((a, b) => a - b);
  const dates = [...new Set(rawData.map((item) => item.x_dt))];
  // const dates1 = filteredData1.map((item) => item.x_dt);
  // const sales1 = filteredData1.map((item) => parseFloat(item.y_val_sale_rmb));

  let yAxis = [];

  yAxis.push({
    type: "value",
    name: "환불금액",
    position: "left",
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      formatter: "{value}",
    },
  });

  yAxis.push({
    type: "value",
    name: "환불비중",
    position: "right",
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      formatter: "{value}",
    },
  });

  let series = [];
  let dataSum = 0;
  lgnd.forEach((id) => {
    let filteredData2 = rawData.filter((item) => item.l_lgnd_id == id);
    let keysToExtract = ["x_dt", `y_val_rate_${currency}`];
    let filterData = [];
    dataSum += filteredData2.length;
    for (var i = 0; i < filteredData2.length; i++) {
      filterData.push(keysToExtract.map((key) => filteredData2[i][key]));
    }
    series.push({
      name: `${uniqueLegends[id]["name"]}-환불비중`,
      type: "line",
      yAxisIndex: 0,
      data: filterData,
    });
    filteredData2 = rawData.filter((item) => item.l_lgnd_id == id);
    keysToExtract = ["x_dt", `y_val_refd_${currency}`];
    filterData = [];
    dataSum += filteredData2.length;
    for (var i = 0; i < filteredData2.length; i++) {
      filterData.push(keysToExtract.map((key) => filteredData2[i][key]));
    }
    series.push({
      name: `${uniqueLegends[id]["name"]}-환불금액`,
      type: "line",
      yAxisIndex: 1,
      data: filterData,
    });
  });

  let selProductRefund = sale.selProductRefund.getValue();
  let refundArr = selProductRefund.map((item) => item.label);
  let legend = [];
  refundArr.forEach(function (refundArr) {
    legend.push(`${refundArr}-환불금액`);
    legend.push(`${refundArr}-환불비중`);
  });

  sale.chartRefundProductInfo.setOption({
    xAxis: [
      {
        type: "category",
        axisTick: {
          alignWithLabel: true,
        },
        // prettier-ignore
        data: dates,
      },
    ],
    legend: {
      data: legend,
      textStyle: {
        color: "#858d98",
      },
    },
    yAxis: yAxis,
    series: series,
    graphic: {
      elements: [
        {
          type: "text",
          left: "center",
          top: "middle",
          style: {
            text: dataSum == 0 ? "데이터가 없습니다" : "",
            fill: "#999",
            font: "14px Microsoft YaHei",
          },
        },
      ],
    },
  });
};

/**
 * 제품별 환불 시계열 그래프 - 제품 선택 Select Box
 */
sale.productRefundMastUpdate = function () {
  if (document.getElementById("choices-multiple-product2")) {
    prodList = [];
    sale.productRefundMast.forEach((product) => {
      prodList.push({ value: product.prod_id, label: product.prod_nm });
    });
    const choicesMultipleProduct = document.getElementById("choices-multiple-product2");
    if (!sale.selProductRefund) {
      sale.selProductRefund = new Choices(choicesMultipleProduct, {
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
    sale.selProductRefund.setChoices(prodList, "value", "label", true);
  }
};

/**
 * 제품별 매출 정보 데이터 뷰어
 */
sale.productSalesDataViewer = function (opt) {
  if (sale.salesProdList) {
    let keysToExtract = [];
    let filterData = [];
    let lastYearMonth1 = document.getElementById("last_year_month1");
    switch (opt) {
      case "yoy":
        keysToExtract = ["sale_rank", `prod_nm_yoy_${currency}`, `sale_amt_yoy_${currency}`, `sale_rate_yoy_${currency}`, `prod_nm_${currency}`, `sale_amt_${currency}`, `sale_rate_${currency}`];
        filterData = [];
        for (var i = 0; i < sale.salesComparisonLastYear.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.salesComparisonLastYear[i][key]));
        }
        lastYearMonth1.style.display = "none";
        sale.salesProdList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "100px",
              },
              {
                name: "전년도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "매출액",
                  },
                  {
                    name: "매출 비중",
                  },
                ],
              },
              {
                name: "당해 연도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "매출액",
                  },
                  {
                    name: "매출 비중",
                  },
                ],
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      case "mom":
        keysToExtract = ["sale_rank", `prod_nm_yoy_${currency}`, `sale_amt_yoy_${currency}`, `sale_rate_yoy_${currency}`, `prod_nm_${currency}`, `sale_amt_${currency}`, `sale_rate_${currency}`];
        filterData = [];
        for (var i = 0; i < sale.salesRankingLYMoM.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.salesRankingLYMoM[i][key]));
        }
        lastYearMonth1.style.display = "block";
        sale.salesProdList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "100px",
              },
              {
                name: "전년도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "매출액",
                  },
                  {
                    name: "매출 비중",
                  },
                ],
              },
              {
                name: "당해 연도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "매출액",
                  },
                  {
                    name: "매출 비중",
                  },
                ],
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      case "mon":
        keysToExtract = [
          "sale_rank",
          `prod_nm_01_${currency}`,
          `prod_nm_02_${currency}`,
          `prod_nm_03_${currency}`,
          `prod_nm_04_${currency}`,
          `prod_nm_05_${currency}`,
          `prod_nm_06_${currency}`,
          `prod_nm_07_${currency}`,
          `prod_nm_08_${currency}`,
          `prod_nm_09_${currency}`,
          `prod_nm_10_${currency}`,
          `prod_nm_11_${currency}`,
          `prod_nm_12_${currency}`,
        ];
        filterData = [];
        for (var i = 0; i < sale.topSalesLastMonth.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.topSalesLastMonth[i][key]));
        }
        lastYearMonth1.style.display = "none";
        sale.salesProdList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "60px",
              },
              {
                name: "1월",
                width: "250px",
              },
              {
                name: "2월",
                width: "250px",
              },
              {
                name: "3월",
                width: "250px",
              },
              {
                name: "4월",
                width: "250px",
              },
              {
                name: "5월",
                width: "250px",
              },
              {
                name: "6월",
                width: "250px",
              },
              {
                name: "7월",
                width: "250px",
              },
              {
                name: "8월",
                width: "250px",
              },
              {
                name: "9월",
                width: "250px",
              },
              {
                name: "10월",
                width: "250px",
              },
              {
                name: "11월",
                width: "250px",
              },
              {
                name: "12월",
                width: "250px",
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      default:
        // Do nothing
        break;
    }
  }
};

/**
 * 채널 내 매출 순위 300위 - 상점명 선택
 */
sale.storeNameUpdate = function () {
  if (document.getElementById("channelSalesRankingTop300Brand")) {
    storeList = [];
    sale.storeName.forEach((store) => {
      storeList.push({ value: store.shop_id, label: store.shop_nm });
    });
    const choicesMultipleStore = document.getElementById("channelSalesRankingTop300Brand");
    if (!sale.selStore) {
      sale.selStore = new Choices(choicesMultipleStore, {
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "상점명을 선택하세요.  ",
      });
    }
    sale.selStore.setChoices(storeList, "value", "label", true);
  }
};

/**
 * 카테고리별 매출 순위 - 1차 카테고리
 */
sale.categorySalesRank1Update = function () {
  if (sale.selCategorySalesRankingName1) {
    categorySalesRank1List = [];
    sale.categorySalesRank1.forEach((category) => {
      categorySalesRank1List.push({ value: category.cate_1, label: category.cate_1 });
    });
    sale.selCategorySalesRankingName1.setChoices(categorySalesRank1List, "value", "label", true);
  }
};

/**
 * 카테고리별 매출 순위 - 2차 카테고리
 */
sale.categorySalesRank2Update = function () {
  categorySalesRank2List = [];
  categorySalesRank2List.push({ value: "", label: "2차 카테고리를 선택하세요." });
  sale.categorySalesRank2.forEach((category) => {
    categorySalesRank2List.push({ value: category.cate_2, label: category.cate_2 });
  });
  sale.selCategorySalesRankingName2.setChoices(categorySalesRank2List, "value", "label", true);
  sale.selCategorySalesRankingName2.setChoiceByValue("");
};

/**
 * 제품별 환불 정보 데이터 뷰어
 */
sale.productRefudDataViewer = function (opt) {
  if (sale.refundInfoList) {
    let keysToExtract = [];
    let filterData = [];
    let lastYearMonth2 = document.getElementById("last_year_month2");
    switch (opt) {
      case "yoy":
        keysToExtract = ["refd_rank", `prod_nm_yoy_${currency}`, `refd_amt_yoy_${currency}`, `refd_rate_yoy_${currency}`, `prod_nm_${currency}`, `refd_amt_${currency}`, `refd_rate_${currency}`];
        filterData = [];
        for (var i = 0; i < sale.refundComparisonLastYear.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.refundComparisonLastYear[i][key]));
        }
        lastYearMonth2.style.display = "none";
        sale.refundInfoList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "100px",
              },
              {
                name: "전년도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "환불 금액",
                  },
                  {
                    name: "환불 비중",
                  },
                ],
              },
              {
                name: "당해 연도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "환불 금액",
                  },
                  {
                    name: "환불 비중",
                  },
                ],
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      case "mom":
        keysToExtract = ["refd_rank", `prod_nm_yoy_${currency}`, `refd_amt_yoy_${currency}`, `refd_rate_yoy_${currency}`, `prod_nm_${currency}`, `refd_amt_${currency}`, `refd_rate_${currency}`];
        filterData = [];
        for (var i = 0; i < sale.refundRankingLYMoM.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.refundRankingLYMoM[i][key]));
        }
        lastYearMonth2.style.display = "block";
        sale.refundInfoList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "100px",
              },
              {
                name: "전년도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "환불 금액",
                  },
                  {
                    name: "환불 비중",
                  },
                ],
              },
              {
                name: "당해 연도 동기 누적",
                width: "600px",
                columns: [
                  {
                    name: "제품명",
                  },
                  {
                    name: "환불 금액",
                  },
                  {
                    name: "환불 비중",
                  },
                ],
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      case "mon":
        keysToExtract = [
          "refd_rank",
          `prod_nm_01_${currency}`,
          `prod_nm_02_${currency}`,
          `prod_nm_03_${currency}`,
          `prod_nm_04_${currency}`,
          `prod_nm_05_${currency}`,
          `prod_nm_06_${currency}`,
          `prod_nm_07_${currency}`,
          `prod_nm_08_${currency}`,
          `prod_nm_09_${currency}`,
          `prod_nm_10_${currency}`,
          `prod_nm_11_${currency}`,
          `prod_nm_12_${currency}`,
        ];
        filterData = [];
        for (var i = 0; i < sale.topRefundLastMonth.length; i++) {
          filterData.push(keysToExtract.map((key) => sale.topRefundLastMonth[i][key]));
        }
        lastYearMonth2.style.display = "none";
        sale.refundInfoList
          .updateConfig({
            columns: [
              {
                name: "등수",
                width: "100px",
              },
              {
                name: "1월",
                width: "250px",
              },
              {
                name: "2월",
                width: "250px",
              },
              {
                name: "3월",
                width: "250px",
              },
              {
                name: "4월",
                width: "250px",
              },
              {
                name: "5월",
                width: "250px",
              },
              {
                name: "6월",
                width: "250px",
              },
              {
                name: "7월",
                width: "250px",
              },
              {
                name: "8월",
                width: "250px",
              },
              {
                name: "9월",
                width: "250px",
              },
              {
                name: "10월",
                width: "250px",
              },
              {
                name: "11월",
                width: "250px",
              },
              {
                name: "12월",
                width: "250px",
              },
            ],
            data: function () {
              return new Promise(function (resolve) {
                setTimeout(function () {
                  resolve(filterData);
                }, 2000);
              });
            },
          })
          .forceRender();
        break;
      default:
        // Do nothing
        break;
    }
  }
};

/**
 * 채널 내 매출 순위 300위
 */
sale.channelSalesRank300GridUpdate = function () {
  let rawData = sale.channelSalesRank300Grid;
  let keysToExtract = ["shop_rank", "shop_nm", "sale_rate", "natn_nm", "dema_yn"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  sale.channelList.updateConfig({ data: filterData }).forceRender();
};

/**
 * 카테고리별 매출 순위
 */
sale.categorySalesRankGridUpdate = function () {
  let rawData = sale.categorySalesRankGrid;
  let keysToExtract = ["prod_rank", "cate_1", "cate_2", "prod_url", "prod_nm", "sale_rate", "natn_nm", "dema_yn"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  sale.categoryList
    .updateConfig({
      columns: [
        {
          name: "순위",
          width: "60px",
        },
        {
          name: "1차 카테고리",
          width: "120px",
        },
        {
          name: "2차 카테고리",
          width: "140px",
        },
        {
          name: "제품 이미지",
          width: "55px",
          formatter: (cell, row) => {
            // debugger;
            return gridjs.html(`<img style='width: 100%;' src='${row.cells[3].data}' />`);
          },
        },
        {
          name: "제품명",
          width: "340px",
        },
        {
          name: "거래 지수",
          width: "140px",
        },
        {
          name: "국가",
          width: "100px",
        },
        {
          name: "더마 여부",
          width: "60px",
        },
      ],
      data: filterData,
    })
    .forceRender();
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

sale.options = {
  series: [
    {
      name: "매출",
      data: [],
    },
  ],
  graphic: {
    elements: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },
  chart: {
    width: 130,
    height: 110,
    type: "area",
    sparkline: {
      enabled: !0,
    },
    toolbar: {
      show: !1,
    },
  },
  dataLabels: {
    enabled: !1,
  },
  stroke: {
    curve: "smooth",
    width: 1.5,
  },
  fill: {
    type: "gradient",
    gradient: {
      shadeIntensity: 1,
      inverseColors: !1,
      opacityFrom: 0.45,
      opacityTo: 0.05,
      stops: [50, 100, 100, 100],
    },
  },
  tooltip: {
    y: {
      formatter: function (val) {
        return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      },
    },
  },
  colors: getChartColorsArray("areaChart1"),
};

if (document.querySelector("#areaChart1")) {
  sale.areaChart1 = new ApexCharts(document.querySelector("#areaChart1"), sale.options);
  sale.areaChart1.render();
}
if (document.querySelector("#areaChart2")) {
  sale.areaChart2 = new ApexCharts(document.querySelector("#areaChart2"), sale.options);
  sale.areaChart2.render();
}
if (document.querySelector("#areaChart3")) {
  sale.areaChart3 = new ApexCharts(document.querySelector("#areaChart3"), sale.options);
  sale.areaChart3.render();
}
if (document.querySelector("#areaChart4")) {
  sale.areaChart4 = new ApexCharts(document.querySelector("#areaChart4"), sale.options);
  sale.areaChart4.render();
}
if (document.querySelector("#areaChart5")) {
  sale.areaChart5 = new ApexCharts(document.querySelector("#areaChart5"), sale.options);
  sale.areaChart5.render();
}
if (document.querySelector("#areaChart6")) {
  sale.areaChart6 = new ApexCharts(document.querySelector("#areaChart6"), sale.options);
  sale.areaChart6.render();
}

sale.radialbarOptions = {
  series: [0],
  chart: {
    type: "radialBar",
    width: 93,
    sparkline: {
      enabled: !0,
    },
  },
  dataLabels: {
    enabled: !1,
  },
  plotOptions: {
    radialBar: {
      hollow: {
        margin: 0,
        size: "70%",
      },
      track: {
        margin: 1,
      },
      dataLabels: {
        show: !0,
        name: {
          show: !1,
        },
        value: {
          show: !0,
          fontSize: "16px",
          fontWeight: 600,
          offsetY: 8,
        },
      },
    },
  },
  colors: getChartColorsArray("progress_radial"),
};

if (document.querySelector("#progress_radial")) {
  sale.radialChart = new ApexCharts(document.querySelector("#progress_radial"), sale.radialbarOptions);
  sale.radialChart.render();
}

// prettier-ignore
sale.hours = [
  '12am', '1am', '2am', '3am', '4am', '5am', '6am',
  '7am', '8am', '9am', '10am', '11am',
  '12pm', '1pm', '2pm', '3pm', '4pm', '5pm',
  '6pm', '7pm', '8pm', '9pm', '10pm', '11pm'
];
// prettier-ignore
sale.days = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun'
];
// 1 = days
// 2 = hours
// 3 = values
// prettier-ignore
sale.data = [
  [0, 0, 0]
].map(function (item) {
  return [
    item[1], item[0], item[2] || '-'
  ];
});
sale.heatMapSalesOption = {
  tooltip: {
    position: "top",
  },
  grid: {
    top: "0%",
    right: "5%",
    left: "10%",
  },
  xAxis: {
    type: "category",
    data: sale.hours,
    splitArea: {
      show: true,
    },
  },
  yAxis: {
    type: "category",
    data: sale.days,
    splitArea: {
      show: true,
    },
  },
  visualMap: {
    min: 0,
    max: 20000,
    calculable: true,
    orient: "horizontal",
    left: "center",
  },
  series: [
    {
      name: "매출",
      type: "heatmap",
      data: sale.data,
      label: {
        show: false,
      },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowColor: "rgba(0, 0, 0, 0.5)",
        },
      },
    },
  ],
};

if (document.getElementById("heat-map-sales")) {
  sale.heatMapSales = echarts.init(document.getElementById("heat-map-sales"));
  sale.heatMapSales.setOption(sale.heatMapSalesOption);
}

// 매출 정보에 대한 데이터 뷰어
if (document.getElementById("saleInfoList")) {
  sale.saleInfoListGrid = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "100px",
      },
      {
        name: "1월",
        width: "120px",
      },
      {
        name: "2월",
        width: "120px",
      },
      {
        name: "3월",
        width: "120px",
      },
      {
        name: "4월",
        width: "120px",
      },
      {
        name: "5월",
        width: "120px",
      },
      {
        name: "6월",
        width: "120px",
      },
      {
        name: "7월",
        width: "120px",
      },
      {
        name: "8월",
        width: "120px",
      },
      {
        name: "9월",
        width: "120px",
      },
      {
        name: "10월",
        width: "120px",
      },
      {
        name: "11월",
        width: "120px",
      },
      {
        name: "12월",
        width: "120px",
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    data: function () {
      return new Promise(function (resolve) {
        setTimeout(function () {
          resolve([]);
        }, 2000);
      });
    },
  }).render(document.getElementById("saleInfoList"));
}

// 환불 정보에 대한 시계열
sale.charLineRefunedOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["환불 금액", "환불 비중"],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: sale.zoomSales,
  grid: {
    left: "2.5%",
    right: "5%",
    containLabel: !0,
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  textStyle: {
    fontFamily: "Poppins, sans-serif",
  },
  xAxis: {
    type: "category",
    boundaryGap: !1,
    data: [],
    axisLine: {
      lineStyle: {
        color: "#858d98",
      },
    },
  },
  yAxis: [
    {
      type: "value",
      name: "금액",
      axisLine: {
        show: true,
      },
    },
    {
      type: "value",
      name: "비중",
      min: 0,
      max: 100,
      axisLine: {
        show: true,
      },
    },
  ],
  series: [
    {
      type: "line",
      data: [],
    },
    {
      type: "line",
      data: [],
    },
  ],
  graphic: {
    elements: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },

  color: getChartColorsArray("chart-line-refuned"),
};

if (document.getElementById("chart-line-refuned")) {
  sale.chartLineRefuned = echarts.init(document.getElementById("chart-line-refuned"));
  sale.chartLineRefuned.setOption(sale.charLineRefunedOption);
}

// 환불 정보 데이터 뷰어 : 전년 동월 대비 환불 금액 및 환불 비중
if (document.getElementById("lastYearRefunedList")) {
  sale.lastYearRefunedListGrid = new gridjs.Grid({
    columns: [
      {
        name: "구분",
      },
      {
        name: "전년 1월",
      },
      {
        name: "올해 1월",
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    data: function () {
      return new Promise(function (resolve) {
        setTimeout(function () {
          resolve([
            ["환불 금액($)", "1,100", "2,120"],
            ["환불 비중(%)", "32%", "25%"],
          ]);
        }, 2000);
      });
    },
  }).render(document.getElementById("lastYearRefunedList"));
}

// 환불 정보 데이터 뷰어 : 월별 환불 금액 및 환불 비중
if (document.getElementById("monthRefunedList")) {
  sale.monthRefunedList = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "100px",
      },
      {
        name: "1월",
        width: "120px",
      },
      {
        name: "2월",
        width: "120px",
      },
      {
        name: "3월",
        width: "120px",
      },
      {
        name: "4월",
        width: "120px",
      },
      {
        name: "5월",
        width: "120px",
      },
      {
        name: "6월",
        width: "120px",
      },
      {
        name: "7월",
        width: "120px",
      },
      {
        name: "8월",
        width: "120px",
      },
      {
        name: "9월",
        width: "120px",
      },
      {
        name: "10월",
        width: "120px",
      },
      {
        name: "11월",
        width: "120px",
      },
      {
        name: "12월",
        width: "120px",
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    data: function () {
      return new Promise(function (resolve) {
        setTimeout(function () {
          resolve([
            ["환불 금액($)", "1,123", "1,234", "1,345", "2,456", "2,567", "2,678", "2,789", "2,890", "1,901", "1,109", "1,987", "1,876"],
            ["환불 비중(%)", "11%", "20%", "39%", "48%", "57%", "66%", "74%", "32%", "28%", "41%", "17%", "34%"],
          ]);
        }, 2000);
      });
    },
  }).render(document.getElementById("monthRefunedList"));
}

// 채널 내 매출 순위 300위
if (document.getElementById("channelList")) {
  sale.channelList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "80px",
      },
      {
        name: "상점명",
        width: "340px",
      },
      {
        name: "거래 지수",
        width: "150px",
      },
      {
        name: "국가",
        width: "100px",
      },
      {
        name: "더마 여부",
        width: "100px",
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    pagination: {
      limit: 10,
    },
    data: [],
  }).render(document.getElementById("channelList"));
}

// 카테고리별 매출 순위
if (document.getElementById("categoryList")) {
  sale.categoryList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "80px",
      },
      {
        name: "1차 카테고리",
        width: "170px",
      },
      {
        name: "2차 카테고리",
        width: "200px",
      },
      {
        name: "제품 이미지",
        width: "100px",
      },
      {
        name: "제품명",
        width: "340px",
      },
      {
        name: "거래 지수",
        width: "150px",
      },
      {
        name: "국가",
        width: "100px",
      },
      {
        name: "더마 여부",
        width: "100px",
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    pagination: {
      limit: 5,
    },
    data: [],
  }).render(document.getElementById("categoryList"));
}

// 제품별 매출 정보 시계열 그래프
sale.chartSalesProductInfoOption = {
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "cross",
    },
  },
  dataZoom: sale.zoomSales,
  grid: {
    left: "3%",
    right: "5%",
    containLabel: !0,
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  legend: {
    data: ["전체 매출", "매출"],
  },
  xAxis: [
    {
      type: "category",
      axisTick: {
        alignWithLabel: true,
      },
      // prettier-ignore
      data: [],
    },
  ],
  yAxis: [
    {
      type: "value",
      name: "전체 매출",
      position: "right",
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: "#858d98",
        },
      },
      axisLabel: {
        formatter: "{value}",
      },
    },
    {
      type: "value",
      name: "매출",
      position: "left",
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: "#858d98",
        },
      },
      axisLabel: {
        formatter: "{value}",
      },
    },
  ],
  series: [
    {
      type: "line",
      data: [],
    },
    {
      type: "line",
      yAxisIndex: 1,
      data: [],
    },
  ],
  graphic: {
    elements: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },
  color: getChartColorsArray("chart-sales-product-info"),
};

if (document.getElementById("chart-sales-product-info")) {
  sale.chartSalesProductInfo = echarts.init(document.getElementById("chart-sales-product-info"));
  sale.chartSalesProductInfo.setOption(sale.chartSalesProductInfoOption);
}

// 제품별 매출 정보 데이터 뷰어
if (document.getElementById("salesProdList")) {
  sale.salesProdList = new gridjs.Grid({
    columns: [
      {
        name: "등수",
        width: "100px",
      },
      {
        name: "전년도 동기 누적",
        width: "400px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "매출액",
          },
          {
            name: "매출 비중",
          },
        ],
      },
      {
        name: "당해 연도 동기 누적",
        width: "400px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "매출액",
          },
          {
            name: "매출 비중",
          },
        ],
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    data: [],
  }).render(document.getElementById("salesProdList"));
}

// 제품별 환불 시계열 그래프
sale.chartRefundProductInfoOption = {
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "cross",
    },
  },
  dataZoom: sale.zoomSales,
  grid: {
    left: "3%",
    right: "5%",
    containLabel: !0,
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  legend: {
    data: ["환불비중", "환불금액"],
  },
  xAxis: [
    {
      type: "category",
      axisTick: {
        alignWithLabel: true,
      },
      // prettier-ignore
      data: [],
    },
  ],
  yAxis: [
    {
      type: "value",
      name: "환불비중",
      position: "right",
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: "#858d98",
        },
      },
      axisLabel: {
        formatter: "{value}",
      },
    },
    {
      type: "value",
      name: "환불금액",
      position: "left",
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: "#858d98",
        },
      },
      axisLabel: {
        formatter: "{value}",
      },
    },
  ],
  series: [
    {
      type: "line",
      data: [],
    },
    {
      type: "line",
      yAxisIndex: 1,
      data: [],
    },
  ],
  graphic: {
    elements: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },
  color: getChartColorsArray("chart-sales-product-info"),
};

if (document.getElementById("chart-refund-product-info")) {
  sale.chartRefundProductInfo = echarts.init(document.getElementById("chart-refund-product-info"));
  sale.chartRefundProductInfo.setOption(sale.chartRefundProductInfoOption);
}

// 제품별 환불 정보 데이터 뷰어
if (document.getElementById("refundInfoList")) {
  sale.refundInfoList = new gridjs.Grid({
    columns: [
      {
        name: "등수",
        width: "100px",
      },
      {
        name: "전년도 동기 누적",
        width: "600px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "환불 금액",
          },
          {
            name: "환불 비중",
          },
        ],
      },
      {
        name: "당해 연도 동기 누적",
        width: "600px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "환불 금액",
          },
          {
            name: "환불 비중",
          },
        ],
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
      },
    },
    data: [],
  }).render(document.getElementById("refundInfoList"));
}

// 이벤트 핸들러 함수를 배열로 정의합니다.
sale.resizeHandlers = [sale.chartLineSales, sale.heatMapSales, sale.chartLineRefuned, sale.chartSalesProductInfo, sale.chartRefundProductInfo];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
sale.resizeHandlers.forEach((handler) => {
  if (handler != undefined) {
    window.addEventListener("resize", eval(handler).resize);
  }
});

/**
 * ch : 채널 내 매출 순위 300위 - filter 버튼 이벤트
 * ct : 카테고리별 매출 순위 - filter 버튼 이벤트
 * pd_sa : 제품별 매출 정보 시계열 그래프 - 검색 버튼 이벤트
 * pd_re : 제품별 환불 시계열 그래프 - 검색 버튼 이벤트
 */
sale.searchData = function (opt) {
  if (opt == "ch") {
    let selStore = sale.selStore.getValue();
    let storeArr = [];
    if (selStore.length > 0) {
      storeArr = sale.selStore.getValue().map((item) => item.value);
    }
    let datePicker = document.getElementById("channelSalesRankingTop300Month");
    let channelSalesRankingTop300IsMulti = document.getElementById("channelSalesRankingTop300IsMulti");
    let channelSalesRankingTop300CountryName = document.getElementById("channelSalesRankingTop300CountryName");
    let channelSalesRankingTop300IsDerma = document.getElementById("channelSalesRankingTop300IsDerma");

    let params = {
      params: {
        FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
        TO_MNTH: `'${datePicker.value.slice(-7)}'`,
        MLTI_YN: `'${channelSalesRankingTop300IsMulti.value}'`,
        KR_YN: `'${channelSalesRankingTop300CountryName.value}'`,
        DEMA_YN: `'${channelSalesRankingTop300IsDerma.value}'`,
        SHOP_ID: `'${storeArr.join(",")}'`,
      },
      menu: "dashboards/common",
      tab: "sales",
      dataList: ["channelSalesRank300Grid"],
    };

    getData(params, function (data) {
      sale.channelSalesRank300Grid = {};
      /* 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 */
      if (data["channelSalesRank300Grid"] != undefined) {
        sale.channelSalesRank300Grid = data["channelSalesRank300Grid"];
        // console.table(sale.channelSalesRank300Grid);
        sale.channelSalesRank300GridUpdate();
      }
    });
  } else if (opt == "ct") {
    let categorySalesRankingName1 = document.getElementById("categorySalesRankingName1");
    let categorySalesRankingName2 = document.getElementById("categorySalesRankingName2");
    let datePicker = document.getElementById("categorySalesRankingMonth");
    let categorySalesRankingCountryName = document.getElementById("categorySalesRankingCountryName");
    let categorySalesRankingisDerma = document.getElementById("categorySalesRankingisDerma");
    let categorySalesRankingisOwn = document.getElementById("categorySalesRankingisOwn");

    if (!categorySalesRankingName1.value) {
      dapAlert("1차 카테고리를 선택해 주세요.");
      return false;
    }

    if (!categorySalesRankingName2.value) {
      dapAlert("2차 카테고리를 선택해 주세요.");
      return false;
    }

    let params = {
      params: {
        FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
        TO_MNTH: `'${datePicker.value.slice(-7)}'`,
        KR_YN: `'${categorySalesRankingCountryName.value}'`,
        DEMA_YN: `'${categorySalesRankingisDerma.value}'`,
        OWN_YN: `'${categorySalesRankingisOwn.value}'`,
        CATE_1: `'${categorySalesRankingName1.value}'`,
        CATE_2: `'${categorySalesRankingName2.value}'`,
      },
      menu: "dashboards/common",
      tab: "sales",
      dataList: ["categorySalesRankGrid"],
    };

    getData(params, function (data) {
      sale.categorySalesRankGrid = {};
      /* 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 */
      if (data["categorySalesRankGrid"] != undefined) {
        sale.categorySalesRankGrid = data["categorySalesRankGrid"];
        // console.table(sale.categorySalesRankGrid);
        sale.categorySalesRankGridUpdate();
      }
    });
  } else if (opt == "pd_sa") {
    let selProductSales = sale.selProductSales.getValue();
    let datePicker = document.getElementById("productSalesDatepicker");
    let productArr = selProductSales.map((item) => item.value);
    if (!datePicker.value) {
      dapAlert("조회 기간을 선택해 주세요.");
      return false;
    }
    if (productArr.length == 0) {
      dapAlert("제품을 선택해 주세요.");
      return false;
    }

    let params = {
      params: {
        PROD_ID: `'${productArr.join(",")}'`,
        FR_DT: `'${datePicker.value.substring(0, 10)}'`,
        TO_DT: `'${datePicker.value.slice(-10)}'`,
      },
      menu: "dashboards/common",
      tab: "sales",
      dataList: ["productSalesTimeSeries"],
    };

    getData(params, function (data) {
      sale.productSalesTimeSeries = {};
      /* 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 */
      if (data["productSalesTimeSeries"] != undefined) {
        sale.productSalesTimeSeries = data["productSalesTimeSeries"];
        // console.table(sale.productSalesTimeSeries);
        sale.productSalesTimeSeriesUpdate();
      }
    });
  } else if (opt == "pd_re") {
    let selProductRefund = sale.selProductRefund.getValue();
    let datePicker = document.getElementById("productRefundDatepicker");
    let productArr = selProductRefund.map((item) => item.value);
    if (!datePicker.value) {
      dapAlert("조회 기간을 선택해 주세요.");
      return false;
    }
    if (productArr.length == 0) {
      dapAlert("제품을 선택해 주세요.");
      return false;
    }

    let params = {
      params: {
        PROD_ID: `'${productArr.join(",")}'`,
        FR_DT: `'${datePicker.value.substring(0, 10)}'`,
        TO_DT: `'${datePicker.value.slice(-10)}'`,
      },
      menu: "dashboards/common",
      tab: "sales",
      dataList: ["refundTimeSeriesByProduct"],
    };

    getData(params, function (data) {
      sale.refundTimeSeriesByProduct = {};
      /* 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 */
      if (data["refundTimeSeriesByProduct"] != undefined) {
        sale.refundTimeSeriesByProduct = data["refundTimeSeriesByProduct"];
        // console.table(sale.refundTimeSeriesByProduct);
        sale.refundTimeSeriesByProductUpdate();
      }
    });
  }
};

sale.onLoadEvent = function (initData) {
  sale.initData = initData;
  /*
   * 상단 카드 init
   */
  let counterValue = document.getElementsByClassName("counter-value");
  let badgePar, badgeStyle;
  for (let i = 0; i < counterValue.length; i++) {
    badgePar = counterValue[i].parentNode.nextElementSibling;
    if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
      badgePar.firstElementChild.style.display = "none";
    }
  }

  /* 년도 선택 박스 생성 */
  // 현재 년도 가져오기
  let currentYear = new Date().getFullYear();

  // select 엘리먼트 가져오기

  if (document.getElementById("experienceYear")) {
    let selectElement = document.getElementById("experienceYear");

    // 새로운 Choices 인스턴스 생성
    const choices = new Choices(selectElement, {
      searchEnabled: false,
      shouldSort: false,
    });

    // 초기화를 위해 선택 항목 초기화 (선택 해제)
    choices.clearChoices();

    // option 엘리먼트 생성 및 추가
    let yearList = [];
    for (let year = 2001; year <= currentYear + 1; year++) {
      yearList.push({
        value: year,
        label: year.toString(),
      });
    }
    yearList = yearList.reverse();

    // 선택 항목 추가
    choices.setChoices(yearList, "value", "label", true);

    // 현재 년도 선택
    choices.setChoiceByValue(currentYear);

    // 월별 환불 금액 및 환불 비중 - 년도 선택 이벤트
    selectElement.addEventListener("change", function (e) {
      let params = {
        params: {
          BASE_YEAR: `'${e.target.value}'`,
        },
        menu: "dashboards/common",
        tab: "sales",
        dataList: ["refundDataByMonth"],
      };
      getData(params, function (data) {
        sale.refundDataByMonth = data["refundDataByMonth"];
        /* # 5. 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 */
        // console.table(sale.refundDataByMonth);
        sale.refundDataByMonthUpdate();
      });
    });
  }

  flatpickr("#channelSalesRankingTop300Month, #categorySalesRankingMonth", {
    disableMobile: "true",
    locale: "ko", // locale for this instance only
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
    mode: "range",
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
  });

  flatpickr("#productSalesDatepicker, #productRefundDatepicker", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
  });

  // 매출 정보에 대한 시계열 / 데이터 뷰어 - flatpickr 이벤트
  let salesTimeSeriesFlatpickr = flatpickr("#salesTimeSeriesViewer, #salesDayTimeHeattmapViewer", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        salesTimeSeriesFlatpickr[0].setDate([fromDate, toDate]);
        salesTimeSeriesFlatpickr[1].setDate([fromDate, toDate]);
        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
          },
          menu: "dashboards/common",
          tab: "sales",
          dataList: ["salesTimeSeriesGraphChart", "salesHeatmapData"],
        };
        getData(params, function (data) {
          sale.salesTimeSeriesGraphChart = {};
          sale.salesHeatmapData = {};
          /* 4. 매출 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */
          if (data["salesTimeSeriesGraphChart"] != undefined) {
            sale.salesTimeSeriesGraphChart = data["salesTimeSeriesGraphChart"];
            sale.chartLineSalesUpdate(); //
          }
          /* 5. 일별 / 시간별 매출 히트맵 */
          if (data["salesHeatmapData"] != undefined) {
            sale.salesHeatmapData = data["salesHeatmapData"];
            sale.salesHeatmapDataUpdate(); //
          }
        });
      }
    },
  });

  // 환불 정보에 대한 시계열 - flatpickr 이벤트
  flatpickr("#refundTimeSeriesViewer", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
          },
          menu: "dashboards/common",
          tab: "sales",
          dataList: ["salesRefundTimeSeriesAllGraph"],
        };
        getData(params, function (data) {
          sale.salesRefundTimeSeriesAllGraph = {};
          /* 7. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
          if (data["salesRefundTimeSeriesAllGraph"] != undefined) {
            sale.salesRefundTimeSeriesAllGraph = data["salesRefundTimeSeriesAllGraph"];
            sale.salesRefundTimeSeriesAllGraphUpdate();
          }
        });
      }
    },
  });

  // 환불 정보에 대한 시계열 - flatpickr 이벤트
  flatpickr("#refundAmountLastYear", {
    disableMobile: "true",
    locale: "ko", // locale for this instance only
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
    defaultDate: `${initData.base_mnth}`,
    onChange: function (selectedDates, dateStr, instance) {
      const fromDate = selectedDates[0];
      const month = (fromDate.getMonth() + 1).toString().padStart(2, "0");
      let params = {
        params: {
          BASE_MNTH: `'${getMonthFormatter(fromDate)}'`,
        },
        menu: "dashboards/common",
        tab: "sales",
        dataList: ["refundAmountYoY"],
      };
      getData(params, function (data) {
        sale.refundAmountYoY = {};
        /* 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 */
        if (data["refundAmountYoY"] != undefined) {
          sale.refundAmountYoY = data["refundAmountYoY"];
          // console.table(sale.refundAmountYoY);
          sale.refundAmountYoYUpdate(month);
        }
      });
    },
  });

  // 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 - flatpickr 이벤트
  flatpickr("#lastMonthSalesFlatpickr", {
    disableMobile: "true",
    locale: "ko", // locale for this instance only
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
    defaultDate: `${initData.base_mnth}`,
    onChange: function (selectedDates, dateStr, instance) {
      const fromDate = selectedDates[0];
      let params = {
        params: {
          BASE_MNTH: `'${getMonthFormatter(fromDate)}'`,
        },
        menu: "dashboards/common",
        tab: "sales",
        dataList: ["salesRankingLYMoM"],
      };
      getData(params, function (data) {
        sale.salesRankingLYMoM = {};
        if (data["salesRankingLYMoM"] != undefined) {
          sale.salesRankingLYMoM = data["salesRankingLYMoM"];
          sale.productSalesDataViewer("mom");
        }
      });
    },
  });

  // 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 - flatpickr 이벤트
  flatpickr("#lastMonthRefundFlatpickr", {
    disableMobile: "true",
    locale: "ko", // locale for this instance only
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
    defaultDate: `${initData.base_mnth}`,
    onChange: function (selectedDates, dateStr, instance) {
      const fromDate = selectedDates[0];
      let params = {
        params: {
          BASE_MNTH: `'${getMonthFormatter(fromDate)}'`,
        },
        menu: "dashboards/common",
        tab: "sales",
        dataList: ["refundRankingLYMoM"],
      };
      getData(params, function (data) {
        sale.refundRankingLYMoM = {};
        if (data["refundRankingLYMoM"] != undefined) {
          sale.refundRankingLYMoM = data["refundRankingLYMoM"];
          sale.productRefudDataViewer("mom");
        }
      });
    },
  });

  /**
   * 제품별 매출 정보 시계열 그래프 - 제품 선택 Select Box
   */
  if (document.getElementById("choices-multiple-product1")) {
    const choicesMultipleProduct1 = document.getElementById("choices-multiple-product1");
    if (!sale.selProductSales) {
      sale.selProductSales = new Choices(choicesMultipleProduct1, {
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
  }

  /**
   * 제품별 환불 시계열 그래프 - 제품 선택 Select Box
   */
  if (document.getElementById("choices-multiple-product2")) {
    const choicesMultipleProduct2 = document.getElementById("choices-multiple-product2");
    if (!sale.selProductRefund) {
      sale.selProductRefund = new Choices(choicesMultipleProduct2, {
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
  }

  // 제품별 매출 정보 데이터 뷰어 - 콤보 박스
  if (document.getElementById("productsSalesInfo")) {
    let productsSalesInfo = document.getElementById("productsSalesInfo");
    const cProductsSalesInfo = new Choices(productsSalesInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cProductsSalesInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let productsSalesInfoList = [
      { value: "yoy", label: "누적 매출 기준 전년도 vs 당해 연도 매출 TOP5" },
      { value: "mom", label: "전년 동월 대비 매출 TOP5" },
      { value: "mon", label: "당해 연도 월별 매출 TOP5" },
    ];
    cProductsSalesInfo.setChoices(productsSalesInfoList, "value", "label", true);
    cProductsSalesInfo.setChoiceByValue("yoy");

    productsSalesInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["salesComparisonLastYear" /* 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 */],
        mom: ["salesRankingLYMoM" /* 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 */],
        mon: ["topSalesLastMonth" /* 제품별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 */],
      };
      let params = {
        params: { FR_DT: `'${getMonthStartAndToday()["monthStart"]}'`, TO_DT: `'${getMonthStartAndToday()["today"]}'`, BASE_MNTH: `'${getMonthFormatter(new Date())}'` },
        menu: "dashboards/common",
        tab: "sales",
        dataList: dataList[type],
      };
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          sale[key] = data[key];
        });
        sale.productSalesDataViewer(type);
      });
    });
  }

  // 채널 내 매출 순위 300위, 카테고리별 매출 순위 콤보박스
  const config = {
    searchEnabled: false,
    shouldSort: false,
  };
  if (document.getElementById("channelSalesRankingTop300IsMulti")) {
    const channelSalesRankingTop300IsMulti = document.getElementById("channelSalesRankingTop300IsMulti");
    new Choices(channelSalesRankingTop300IsMulti, config);
  }
  if (document.getElementById("channelSalesRankingTop300IsDerma")) {
    const channelSalesRankingTop300IsDerma = document.getElementById("channelSalesRankingTop300IsDerma");
    new Choices(channelSalesRankingTop300IsDerma, config);
  }
  if (document.getElementById("categorySalesRankingisDerma")) {
    const categorySalesRankingisDerma = document.getElementById("categorySalesRankingisDerma");
    new Choices(categorySalesRankingisDerma, config);
  }
  if (document.getElementById("categorySalesRankingisOwn")) {
    const categorySalesRankingisOwn = document.getElementById("categorySalesRankingisOwn");
    new Choices(categorySalesRankingisOwn, config);
  }

  if (document.getElementById("categorySalesRankingName1")) {
    const categorySalesRankingName1 = document.getElementById("categorySalesRankingName1");
    sale.selCategorySalesRankingName1 = new Choices(categorySalesRankingName1, {
      searchEnabled: false,
    });
    categorySalesRankingName1.addEventListener("change", function (val) {
      let cate1 = this.value;
      let params = {
        params: {
          CATE_1: `'${cate1}'`,
        },
        menu: "dashboards/common",
        tab: "sales",
        dataList: ["categorySalesRank2"],
      };
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          sale[key] = data[key];
        });
        sale.categorySalesRank2Update();
      });
    });
  }
  if (document.getElementById("categorySalesRankingName2")) {
    const categorySalesRankingName2 = document.getElementById("categorySalesRankingName2");
    sale.selCategorySalesRankingName2 = new Choices(categorySalesRankingName2, {
      searchEnabled: false,
      placeholder: true,
      placeholderValue: "2차 카테고리를 선택하세요.  ",
    });
  }

  // 제품별 매출 정보 데이터 뷰어 - 콤보 박스
  if (document.getElementById("productsRefudInfo")) {
    let productsRefudInfo = document.getElementById("productsRefudInfo");

    const cproductsRefudInfo = new Choices(productsRefudInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cproductsRefudInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let productsRefudInfoList = [
      { value: "yoy", label: "누적 환불액 기준 전년도 vs 당해 연도 매출 TOP5" },
      { value: "mom", label: "전년 동월 대비 환불 TOP5" },
      { value: "mon", label: "당해 연도 월별 환불 TOP5" },
    ];
    cproductsRefudInfo.setChoices(productsRefudInfoList, "value", "label", true);
    cproductsRefudInfo.setChoiceByValue("yoy");

    productsRefudInfo.addEventListener("change", function (val) {
      let type = this.value;

      let dataList = {
        yoy: ["refundComparisonLastYear" /* 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 */],
        mom: ["refundRankingLYMoM" /* 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 */],
        mon: ["topRefundLastMonth" /* 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 */],
      };

      let params = {
        params: { FR_DT: `'${getMonthStartAndToday()["monthStart"]}'`, TO_DT: `'${getMonthStartAndToday()["today"]}'`, BASE_MNTH: `'${getMonthFormatter(new Date())}'` },
        menu: "dashboards/common",
        tab: "sales",
        dataList: dataList[type],
      };
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          sale[key] = data[key];
        });
        sale.productRefudDataViewer(type);
      });
    });
  }

  let dataList = [
    "impCardAmtData" /* 중요정보 카드 Data 조회 */,
    "impCardAmtChart" /* 중요정보 그래프 Data 조회 */,
    "salesTimeSeriesGraphData" /* 중요정보 그래프 Data 조회 */,
    "salesTimeSeriesGraphChart" /* 매출 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */,
    "salesTimeSeriesGraphBottom" /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */,
    "salesHeatmapData" /* 일별 시간별 매출 히트맵 */,
    "salesRefundTimeSeriesAllData" /* 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 */,
    "salesRefundTimeSeriesAllGraph" /* 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */,
    "refundAmountYoY" /* 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 */,
    "refundDataByMonth" /* 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 */,
    "productSalesMast" /* 제품별 매출 정보 시계열 그래프 - 제품별 선택 */,
    "productRefundMast" /* 제품별 환불 정보 시계열 그래프 - 제품별 선택 */,
    "storeName" /* 채널 내 매출 순위 300위 - 상점명 선택 SQL */,
    "categorySalesRank1" /* 카테고리별 매출 순위 - 1차 카테고리 선택 SQL */,
    "salesComparisonLastYear" /* 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 */,
    "refundComparisonLastYear" /* 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 */,
  ];
  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, BASE_YEAR: `'${initData.base_year}'` },
    menu: "dashboards/common",
    tab: "sales",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      sale[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    sale.setDataBinding();
  });

  sale.onloadStatus = true; // 화면 로딩 상태
};
