let cust = {};
chan.CHNL_NM = "Douyin China";
cust.visitorAnalyticsCard = {}; // # 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL ,
cust.visitorAnalyticsChart = {}; // # 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL,
cust.visitorTimeSeriesCard = {}; /* 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL*/
cust.visitorTimeSeriesChart = {}; /* 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
cust.visitorTimeSeriesBottom = {}; /* 2. 방문자수 시계열 그래프 - 하단표 SQL     visitorTimeSeriesViewer */
cust.weekdayVisitorChart = {}; /* [도우인] 3. 요일 방문자 수 그래프 - 시계열 그래프 SQL */
cust.clickConversionRate = {}; /* [도우인] 4. 클릭 전환율 - 시계열 그래프 SQL */
cust.weekdayClickConversionRate = {}; /* [도우인] 5. 요일별 클릭 전환율 - 시계열 그래프 SQL */
cust.buyerTimeSeriesCard = {} /* 8. 구매자수 시계열 그래프 - 그래프상단 정보 SQL */
cust.buyerTimeSeriesChart = {} /* 8. 구매자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
cust.buyerTimeSeriesBottom = {} /* 8. 구매자수 시계열 그래프 - 하단 정보 SQL */
cust.buyerFirstBuyRebuyChart = {} /* 9. 구매자 첫구매/재구매 그래프 - 방문자 시계열 그래프 SQL */
cust.buyerFirstBuyRebuyBottom = {} /* 9. 구매자 첫구매/재구매 그래프 - 하단표 SQL */
cust.buyerProfitGraph = {} /* 9. 구매자당 수익 그래프 - 바 그래프 SQL */
cust.averageRevenuePerCustomerGraph = {}; /* 10. 구매자 객단가 그래프 - 그래프 SQL */
cust.regionalDistributionBarChart = {}; /* 11. 지역분포 그래프 - 바 그래프 SQL */
cust.regionalDistributionMapChart = {}; /* 11. 지역분포 그래프 - 지도 그래프 SQL */
cust.genderDistributionBarChart = {}; /* 12. 성별분포 그래프 - 바 그래프 SQL */
cust.ageDistributionBarChart = {}; /* 13. 연령분포 - 바 그래프 SQL */
cust.onloadStatus = false; // 화면 로딩 상태

cust.zoomSales = [
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

// prettier-ignore
cust.hours = [
  '12am', '1am', '2am', '3am', '4am', '5am', '6am',
  '7am', '8am', '9am', '10am', '11am',
  '12pm', '1pm', '2pm', '3pm', '4pm', '5pm',
  '6pm', '7pm', '8pm', '9pm', '10pm', '11pm'];

// prettier-ignore
cust.days = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun'
];

cust.data = [[0, 0, 0]].map(function (item) {
  return [item[1], item[0], item[2] || "-"];
});

cust.setDataBinding = function () {
  /* currency dom */
  let currencyDom = document.getElementById("selected-currency-img");
  currency = currencyDom.getAttribute("data-currency");
  currency = currency == "cny" ? "rmb" : currency;
  if (currency == "rmb") {
    let bxYenAll = document.querySelectorAll(".bx-won");
    bxYenAll.forEach(function (bxYen) {
      bxYen.classList.add("bx-yen");
      bxYen.classList.remove("bx-won");
    });
  } else {
    let bxYenAll = document.querySelectorAll(".bx-yen");
    bxYenAll.forEach(function (bxYen) {
      bxYen.classList.add("bx-won");
      bxYen.classList.remove("bx-yen");
    });
  }

  /* 1 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL  */
  if (Object.keys(cust.visitorAnalyticsCard).length > 0) {
    cust.visitorAnalyticsCardUpdate();
  }
  /* 1 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL */
  if (Object.keys(cust.visitorAnalyticsChart).length > 0) {
    cust.visitorAnalyticsChartUpdate();
  }
  /* 2 방문자수 시계열 그래프 - 그래프상단 정보 SQL */
  if (Object.keys(cust.visitorTimeSeriesCard).length > 0) {
    cust.visitorTimeSeriesCardUpdate();
  }
  /* 2 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
  if (Object.keys(cust.visitorTimeSeriesChart).length > 0) {
    cust.visitorTimeSeriesChartUpdate();
  }
  /* 2 방문자수 시계열 그래프 - 하단 정보 SQL */
  if (Object.keys(cust.visitorTimeSeriesBottom).length > 0) {
    cust.visitorTimeSeriesBottomUpdate();
  }
  /* [도우인] 3. 요일 방문자 수 그래프 - 시계열 그래프 SQL */
  if (Object.keys(cust.weekdayVisitorChart).length > 0) {
    cust.weekdayVisitorChartUpdate();
  }
  /* [도우인] 4. 클릭 전환율 - 시계열 그래프 SQL */
  if (Object.keys(cust.clickConversionRate).length > 0) {
    cust.clickConversionRateUpdate();
  }
  /* [도우인] 5. 요일별 클릭 전환율 - 시계열 그래프 SQL */
  if (Object.keys(cust.weekdayClickConversionRate).length > 0) {
    cust.weekdayClickConversionRateUpdate();
  }
  /* 8. 구매자수 시계열 그래프 - 그래프상단 정보 SQL */
  if (Object.keys(cust.buyerTimeSeriesCard).length > 0) {
    cust.buyerTimeSeriesCardUpdate();
  }
  /* 8. 구매자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
  if (Object.keys(cust.buyerTimeSeriesChart).length > 0) {
    cust.buyerTimeSeriesChartUpdate();
  }
  /* 8. 구매자수 시계열 그래프 - 하단 정보 SQL */
  if (Object.keys(cust.buyerTimeSeriesBottom).length > 0) {
    cust.buyerTimeSeriesBottomUpdate();
  }
  /* 9. 구매자 첫구매/재구매 그래프 - 방문자 시계열 그래프 SQL */
  if (Object.keys(cust.buyerFirstBuyRebuyChart).length > 0) {
    cust.buyerFirstBuyRebuyChartUpdate();
  }
  /* 9. 구매자 첫구매/재구매 그래프 - 하단표 SQL */
  if (Object.keys(cust.buyerFirstBuyRebuyBottom).length > 0) {
    cust.buyerFirstBuyRebuyBottomUpdate();
  }
  /* 9. 구매자당 수익 그래프 - 바 그래프 SQL */
  if (Object.keys(cust.buyerProfitGraph).length > 0) {
    cust.buyerProfitGraphUpdate();
  }
  /* 10. 구매자 객단가 그래프 - 그래프 SQL */
  if (Object.keys(cust.averageRevenuePerCustomerGraph).length > 0) {
    cust.averageRevenuePerCustomerGraphUpdate(); //
  }
  /* 11. 지역분포 그래프 - 바 그래프 SQL */
  if (Object.keys(cust.regionalDistributionBarChart).length > 0) {
    cust.regionalDistributionBarChartUpdate();
  }
  /* 11. 지역분포 그래프 - 지도 그래프 SQL */
  if (Object.keys(cust.regionalDistributionMapChart).length > 0) {
    cust.regionalDistributionMapChartUpdate();
  }
  /* 12. 성별분포 그래프 - 바 그래프 SQL */
  if (Object.keys(cust.genderDistributionBarChart).length > 0) {
    cust.genderDistributionBarChartUpdate();
  }
  /* 13. 연령분포 - 바 그래프 SQL */
  if (Object.keys(cust.ageDistributionBarChart).length > 0) {
    cust.ageDistributionBarChartUpdate();
  }
  /* number counting 처리 */
  counter();
};

// 클릭 전환율 게이지 그래프
cust.redialClickOptions = {
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
  colors: getChartColorsArray("redial_click"),
};
if (document.querySelector("#redial_click")) {
  cust.redialClickChart = new ApexCharts(document.querySelector("#redial_click"), cust.redialClickOptions);
  cust.redialClickChart.render();
}

// 첫 방문자 게이지 그래프
cust.redialRebuyOptions = {
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
  colors: getChartColorsArray("redial_rebuy"),
};
if (document.querySelector("#redial_rebuy")) {
  cust.redialRebuyChart = new ApexCharts(document.querySelector("#redial_rebuy"), cust.redialRebuyOptions);
  cust.redialRebuyChart.render();
}

// 구매자 게이지 그래프
cust.radialCustomerOptions = {
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
  colors: getChartColorsArray("redial_customer"),
};
if (document.querySelector("#redial_customer")) {
  cust.radialCustomerChart = new ApexCharts(document.querySelector("#redial_customer"), cust.radialCustomerOptions);
  cust.radialCustomerChart.render();
}

/********************************************** 1. 중요정보 카드 **********************************************/
/**
 *  중요정보 카드 - 방문자수/객단가/평균체류시간 SQL
 */
cust.visitorAnalyticsCardUpdate = function () {
  let rawData = cust.visitorAnalyticsCard[0];
  // 상단 중요정보 카드

  const cardAreaList = [
    "vist_cnt" /* 전일 방문자 수         */,
    "vist_cnt_mnth" /* 당월 방문자 수         */,
    "vist_cnt_year" /* 당해 방문자 수         */,
    "cust_amt" /* 객단가 */,
    "clck_cnt" /* 클릭 수                */,
    "clck_rate" /* 클릭전환율             */,
    "paid_cnt" /* 구매자 수              */,
    "paid_rate" /* 구매자 비율            */,
    "repd_cnt" /* 재구매자 수            */,
    "repd_rate" /* 재구매자 비율          */,
    "vist_rate" /* 전일 방문자 수 증감률  */,
    "vist_rate_mnth" /* 전일 방문자 수 증감률  */,
    "vist_rate_year" /* 당해 방문자 수 증감률  */,
    "cust_rate" /* 객단가 증감률 */,
    // "vist_cnt_mom" /* 전일 방문자 수 - MoM */,
    // "vist_cnt_yoy" /* 전일 방문자 수 - YoY */,
    // "vist_cnt_mnth_yoy" /* 당월 방문자 수 - YoY */,
    // "vist_cnt_year_yoy" /* 당해 방문자 수 - YoY */,
    // "cust_amt_yoy_rmb" /* 객단가 YoY  - 위안화 */,
    // "cust_amt_yoy_krw" /* 객단가 YoY  - 원화   */,
    // "clck_cnt_yoy" /* 클릭 수    YoY       */,
    // "clck_rate_yoy" /* 클릭전환율 YoY       */,
    // "paid_cnt_yoy" /* 구매자 수   YoY      */,
    // "paid_rate_yoy" /* 구매자 비율 YoY      */,
    // "repd_cnt_yoy" /* 재구매자 수   YoY    */,
    // "repd_rate_yoy" /* 재구매자 비율 YoY    */,
  ];
  cardAreaList.forEach((cardArea) => {
    const el = document.getElementById(`${cardArea}`);
    if (el) {
      if (cardArea.indexOf("vist_rate") > -1 || cardArea.indexOf("cust_rate") > -1 || cardArea.indexOf("stay_rate") > -1) {
        let elArrow = document.getElementById(`${cardArea}_arrow`);
        const recentData = rawData[`${cardArea}`];
        if (elArrow) {
          if (Number(recentData) > 0) {
            el.classList.add("text-success");
            elArrow.classList.add("ri-arrow-up-line", "text-success");
          } else if (Number(recentData) < 0) {
            el.classList.add("text-danger");
            elArrow.classList.add("ri-arrow-down-line", "text-danger");
          } else {
            el.classList.add("text-muted");
            elArrow.classList.add("text-muted");
          }
          if (cardArea.indexOf("cust") > -1) {
            el.innerText = rawData[`${cardArea}_${currency}`] + "%";
          } else {
            el.innerText = rawData[`${cardArea}`] + "%";
          }
        }
      } else if (cardArea.indexOf("cust") > -1) {
        const dataTarget = rawData[`${cardArea}_${currency}`];
        el.innerText = 0;
        el.setAttribute("data-target", dataTarget);
      } else {
        const dataTarget = rawData[`${cardArea}`];
        el.innerText = 0;
        el.setAttribute("data-target", dataTarget);
      }
    }
  });

  if (cust.redialClickChart) {
    cust.redialClickChart.updateOptions({
      series: [rawData["clck_rate"]],
    });
  }
  if (cust.redialRebuyChart) {
    cust.redialRebuyChart.updateOptions({
      series: [rawData["repd_rate"]],
    });
  }
  if (cust.radialCustomerChart) {
    cust.radialCustomerChart.updateOptions({
      series: [rawData["paid_rate"]],
    });
  }
};

/**
 * 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL
 */
cust.visitorAnalyticsChartUpdate = function () {
  // 상단 중요정보 카드 - 그래프
  let {
    DAY = [],
    MNTH = [],
    YEAR = [],
  } = cust.visitorAnalyticsChart.reduce((arr, chart) => {
    arr[chart["chrt_key"]] ? arr[chart["chrt_key"]].push(chart) : (arr[chart["chrt_key"]] = [chart]);
    return arr;
  }, {});

  let daySaleData = DAY.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_vist`]),
    })),
    mnthSaleData = MNTH.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_vist`]),
    })),
    yearSaleData = YEAR.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_vist`]),
    }));

  // 전일 매출 그래프 데이터 업데이트
  if (cust.areaChart7) {
    cust.areaChart7.updateSeries([
      {
        name: "방문자 수",
        data: daySaleData,
      },
    ]);
  }
  // 당월 누적 매출 그래프 데이터 업데이트
  if (cust.areaChart8) {
    cust.areaChart8.updateSeries([
      {
        name: "방문자 수",
        data: mnthSaleData,
      },
    ]);
  }
  // 당해 누적 매출 그래프 데이터 업데이트
  if (cust.areaChart9) {
    cust.areaChart9.updateSeries([
      {
        name: "방문자 수",
        data: yearSaleData,
      },
    ]);
  }
};

cust.options = {
  series: [
    {
      name: "방문자 수",
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
  colors: getChartColorsArray("areaChart7"),
};

if (document.querySelector("#areaChart7")) {
  cust.areaChart7 = new ApexCharts(document.querySelector("#areaChart7"), cust.options);
  cust.areaChart7.render();
}
if (document.querySelector("#areaChart8")) {
  cust.areaChart8 = new ApexCharts(document.querySelector("#areaChart8"), cust.options);
  cust.areaChart8.render();
}
if (document.querySelector("#areaChart9")) {
  cust.areaChart9 = new ApexCharts(document.querySelector("#areaChart9"), cust.options);
  cust.areaChart9.render();
}

/******************************************************************************************************************************/

/********************************************** 2. 방문자수 시계열 그래프 *********************************************************/
/*
 * 2. 방문자수 시계열 그래프 / 데이터 뷰어 - 상단 카드
 */
cust.visitorTimeSeriesCardUpdate = function () {
  if (document.getElementById("time_series_vist_cnt")) {
    document.getElementById("time_series_vist_cnt").setAttribute("data-target", cust.visitorTimeSeriesCard[0]["vist_cnt"]);
    document.getElementById("time_series_vist_cnt").innerText = 0;
  }

  if (document.getElementById("time_series_vist_cnt_yoy")) {
    document.getElementById("time_series_vist_cnt_yoy").setAttribute("data-target", cust.visitorTimeSeriesCard[0]["vist_cnt_yoy"]);
    document.getElementById("time_series_vist_cnt_yoy").innerText = 0;
  }

  if (document.getElementById("time_series_visit_rate")) {
    document.getElementById("time_series_visit_rate").innerText = cust.visitorTimeSeriesCard[0]["vist_rate"] + "%";
    if (Number(cust.visitorTimeSeriesCard[0]["vist_rate"]) > 0) {
      document.getElementById("time_series_visit_arrow").classList.add("ri-arrow-up-line", "text-success");
    } else if (Number(cust.visitorTimeSeriesCard[0]["vist_rate"]) < 0) {
      document.getElementById("time_series_visit_arrow").classList.add("ri-arrow-down-line", "text-danger");
    } else {
      document.getElementById("time_series_visit_arrow").classList.add("text-muted");
    }
  }
  
};

// 2. 방문자수 시계열 그래프 / chart.js
cust.visitorTimeSeriesChartUpdate = function () {
  if (cust.chartLineVisit) {
    let rawData = cust.visitorTimeSeriesChart;
    cust.chartLineVisit.setOption(cust.charLineVisitOption, true);
    if (rawData.length > 0) {
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
      const dates = [...new Set([...dataArr["VIST"].map(({ x_dt }) => x_dt)])];

      let dayValues = [[], [], []],
        series = [];
      for (let i = 0; i < lgnd.length; i++) {
        for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
          dayValues[i][j] = Number(dataArr[lgnd[i]][j][`y_val`]);
        }
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          data: dayValues[i],
        });
      }
      let dataSum = dayValues[0].length + dayValues[1].length + dayValues[2].length;

      cust.chartLineVisit.setOption({
        legend: {
          data: lgnd_nm,
          textStyle: {
            color: "#858d98",
          },
        },
        dataZoom: cust.zoomSales,
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

cust.charLineVisitOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["방문자 수"],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: cust.zoomSales,
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
    data: [], //"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
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
      //name: "방문자 수",
      type: "line",
      stack: "Total",
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

if (document.getElementById("chart_line_visit")) {
  cust.chartLineVisit = echarts.init(document.getElementById("chart_line_visit"));
  cust.chartLineVisit.setOption(cust.charLineVisitOption);
}

//방문자수 시계열 그래프 / 데이터 뷰어 - 하단 Gridjs
cust.visitorTimeSeriesBottomUpdate = function () {
  if (cust.visitCountListGrid) {
    let filterData = [];
    for (var i = 0; i < cust.visitorTimeSeriesBottom.length; i++) {
      filterData.push(Object.values(cust.visitorTimeSeriesBottom[i]));
    }
    cust.visitCountListGrid.updateConfig({ data: filterData }).forceRender();
  }
};

if (document.getElementById("visitCountList")) {
  cust.visitCountListGrid = new gridjs.Grid({
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
  }).render(document.getElementById("visitCountList"));
}

/******************************************************************************************************************************/

/******************************************************** 3. 요일 **********************************************************************/
cust.weekdayVisitorChartUpdate = function () {
  let rawData = cust.weekdayVisitorChart;
  if (cust.chartLineTimeSale) {
    cust.chartLineTimeSale.setOption(cust.chartLineTimeSaleOption, true);
    if (rawData.length > 0) {
      const x_week = [...new Set(rawData.map((item) => item.x_week))];
      cust.chartLineTimeSale.setOption({
        xAxis: {
          type: "category",
          data: x_week,
        },
        series: [
          {
            name: "방문자수",
            data: rawData.map((item) => item.y_val),
            type: "line",
          },
        ],
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData.length == 0 ? "데이터가 없습니다" : "",
                fill: "#999",
                font: "14px Microsoft YaHei",
              },
            },
          ],
        },
      });
    }
  }
};
// 요일 방문자 수 그래프
cust.chartLineTimeSaleOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: cust.days,
  },
  yAxis: {
    type: "value",
  },
  series: [
    {
      name: "방문자수",
      data: [],
      type: "line",
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

if (document.getElementById("chart-line-time-custs")) {
  cust.chartLineTimeSale = echarts.init(document.getElementById("chart-line-time-custs"));
  cust.chartLineTimeSale.setOption(cust.chartLineTimeSaleOption);
}

/******************************************************************************************************************************/
cust.clickConversionRateUpdate = function () {
  let rawData = cust.clickConversionRate;
  if (cust.charLineClickChange) {
    cust.charLineClickChange.setOption(cust.charLineClickChangeOption, true);
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];
      cust.charLineClickChange.setOption({
        xAxis: {
          data: x_dt,
        },
        legend: {
          data: rawData.map((item) => item.l_lgnd_nm),
          textStyle: {
            color: "#858d98",
          }
        },
        series: [
          {
            name: "올해",
            data: rawData.filter((item) => item.l_lgnd_id === "VIST").map((item) => item.y_val),
            type: "line",
          },
          {
            name: "작년",
            data: rawData.filter((item) => item.l_lgnd_id === "VIST_YOY").map((item) => item.y_val),
            type: "line",
          },
        ],
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData.length == 0 ? "데이터가 없습니다" : "",
                fill: "#999",
                font: "14px Microsoft YaHei",
              },
            },
          ],
        },
      });
    }
  }
};

cust.charLineClickChangeOption = {
  tooltip: {
    trigger: "axis",
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  xAxis: {
    type: "category",
    boundaryGap: false,
    data: [],
  },
  yAxis: {
    type: "value",
  },
  series: [],
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

if (document.getElementById("chart-line-click-change")) {
  cust.charLineClickChange = echarts.init(document.getElementById("chart-line-click-change"));
  cust.charLineClickChange.setOption(cust.charLineClickChangeOption);
}

/***********************************************************************************************************/
cust.weekdayClickConversionRateUpdate = function () {
  let rawData = cust.weekdayClickConversionRate;
  if (cust.charLineDayClickChange) {
    cust.charLineDayClickChange.setOption(cust.charLineDayClickChangeOption, true);
    if (rawData.length > 0) {
      const x_week = [...new Set(rawData.map((item) => item.x_week))];
      cust.charLineDayClickChange.setOption({
        xAxis: {
          data: x_week,
        },
        series: [
          {
            name: "전환율",
            data: rawData.map((item) => item.y_val),
            type: "line",
          },
        ],
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData.length == 0 ? "데이터가 없습니다" : "",
                fill: "#999",
                font: "14px Microsoft YaHei",
              },
            },
          ],
        },
      });
    }
  }
};

cust.charLineDayClickChangeOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: cust.days,
  },
  yAxis: {
    type: "value",
  },
  series: [],
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

if (document.getElementById("chart-line-day-click-change")) {
  cust.charLineDayClickChange = echarts.init(document.getElementById("chart-line-day-click-change"));
  cust.charLineDayClickChange.setOption(cust.charLineDayClickChangeOption);
}

/************************************************************************* */
/*
 * 8. 방문자수 시계열 그래프 / 데이터 뷰어 - 상단 카드
 */
cust.buyerTimeSeriesCardUpdate = function () {
  if (document.getElementById("time_series_buyer_cnt")) {
    document.getElementById("time_series_buyer_cnt").setAttribute("data-target", cust.buyerTimeSeriesCard[0]["paid_cnt"]);
    document.getElementById("time_series_buyer_cnt").innerText = 0;
  }

  if (document.getElementById("time_series_buyer_cnt_yoy")) {
    document.getElementById("time_series_buyer_cnt_yoy").setAttribute("data-target", cust.buyerTimeSeriesCard[0]["paid_cnt_yoy"]);
    document.getElementById("time_series_buyer_cnt_yoy").innerText = 0;
  }

  if (document.getElementById("time_series_buyer_rate")) {
    document.getElementById("time_series_buyer_rate").innerText = cust.buyerTimeSeriesCard[0]["paid_rate"] + "%";
    if (Number(cust.buyerTimeSeriesCard[0]["paid_rate"]) > 0) {
      document.getElementById("time_series_buyer_arrow").classList.add("ri-arrow-up-line", "text-success");
    } else if (Number(cust.buyerTimeSeriesCard[0]["paid_rate"]) < 0) {
      document.getElementById("time_series_buyer_arrow").classList.add("ri-arrow-down-line", "text-danger");
    } else {
      document.getElementById("time_series_buyer_arrow").classList.add("text-muted");
    }
  }
};

// 8. 방문자수 시계열 그래프 / chart.js
cust.buyerTimeSeriesChartUpdate = function () {
  if (cust.chartLineBuyer) {
    let rawData = cust.buyerTimeSeriesChart;
    cust.chartLineBuyer.setOption(cust.chartLineBuyerOption, true);
    if (rawData.length > 0) {
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
      const dates = [...new Set([...dataArr["PAID"].map(({ x_dt }) => x_dt)])];

      let dayValues = [[], [], []],
        series = [];
      for (let i = 0; i < lgnd.length; i++) {
        for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
          dayValues[i][j] = Number(dataArr[lgnd[i]][j][`y_val`]);
        }
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          data: dayValues[i],
        });
      }
      let dataSum = dayValues[0].length + dayValues[1].length + dayValues[2].length;

      cust.chartLineBuyer.setOption({
        legend: {
          data: lgnd_nm,
          textStyle: {
            color: "#858d98",
          },
        },
        dataZoom: cust.zoomSales,
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
// 8. 구매자 수 시계열 그래프
cust.chartLineBuyerOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["구매자 수"],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: cust.zoomSales,
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
    data: [], //"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
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
      //name: "구매자 수",
      type: "line",
      stack: "Total",
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

if (document.getElementById("chart-line-buyer")) {
  cust.chartLineBuyer = echarts.init(document.getElementById("chart-line-buyer"));
  cust.chartLineBuyer.setOption(cust.chartLineBuyerOption);
}

// 8. 방문자수 시계열 그래프 / 데이터 뷰어 - 하단 Gridjs
cust.buyerTimeSeriesBottomUpdate = function () {
  if (cust.buyerCountListGrid) {
    let filterData = [];
    for (var i = 0; i < cust.buyerTimeSeriesBottom.length; i++) {
      filterData.push(Object.values(cust.buyerTimeSeriesBottom[i]));
    }
    cust.buyerCountListGrid.updateConfig({ data: filterData }).forceRender();
  }
};

// 하단 grid js
if (document.getElementById("buyerCountList")) {
  cust.buyerCountListGrid = new gridjs.Grid({
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
  }).render(document.getElementById("buyerCountList"));
}

/************************************************************************* */
cust.buyerFirstBuyRebuyChartUpdate = function () {
  if (cust.charMixBuyRebuy) {
    let rawData = cust.buyerFirstBuyRebuyChart;
    let buyerData = [];
    let buyerWeekData = [];
    let buyerMnthData = [];
    let repdData = [];

    const lgnd_id = [...new Set(rawData.map((item) => item.l_lgnd_id))].sort((a, b) => a - b);
    let uniqueLegends = rawData.reduce((result, item) => {
      const { l_lgnd_id, l_lgnd_nm } = item;
      if (!result[l_lgnd_id]) result[l_lgnd_id] = { id: l_lgnd_id, name: l_lgnd_nm };
      return result;
    }, {});

    const date = [...new Set(rawData.map((item) => item.x_dt))].sort((a, b) => a - b);

    for (const data of cust.buyerFirstBuyRebuyChart) {
      if (data.l_lgnd_id === "PAID") {
        buyerData.push(data);
      } else if (data.l_lgnd_id === "PAID_WEEK") {
        buyerWeekData.push(data);
      } else if (data.l_lgnd_id === "PAID_MNTH") {
        buyerMnthData.push(data);
      } else if (data.l_lgnd_id === "REPD") {
        repdData.push(data);
      }
    }

    let series = [];
    let legend = [];
    let dataSum = 0;
    lgnd_id.forEach((id) => {
      legend.push(`${uniqueLegends[id]["name"]}`);
      let filteredData2 = rawData.filter((item) => item.l_lgnd_id == id);
      let keysToExtract = ["x_dt", "y_val"];
      let filterData = [];
      dataSum += filteredData2.length;
      for (var i = 0; i < filteredData2.length; i++) {
        filterData.push(keysToExtract.map((key) => filteredData2[i][key]));
      }
      if (id === "REPD") {
        series.push({
          name: `${uniqueLegends[id]["name"]}`,
          type: "line",
          yAxisIndex: 0,
          data: filterData,
        });
      } else {
        series.push({
          name: `${uniqueLegends[id]["name"]}`,
          type: "bar",
          yAxisIndex: 1,
          data: filterData,
        });
      }
    });
    cust.charMixBuyRebuyOption = {
      legend: {
        data: legend,
        selected: {
          "주 구매자수": false,
          "월 구매자수": false
        },
        textStyle: {
          color: "#858d98",
        }
      },
      xAxis: [
        {
          type: "category",
          data: date,
        },
      ],
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
    };
    cust.charMixBuyRebuy.setOption(cust.charMixBuyRebuyOption);
  }
};
/* 10. 구매자 첫 구매 / 재 구매 비율 */
cust.charMixBuyRebuyOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  grid: {
    left: "1%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  legend: {
    data: [],
  },
  xAxis: [
    {
      type: "category",
      data: [],
    },
  ],
  yAxis: [
    {
      type: "value",
    },
    {
      type: "value",
    },
  ],
  series: [],
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

if (document.getElementById("chart-mix-buy-rebuy")) {
  cust.charMixBuyRebuy = echarts.init(document.getElementById("chart-mix-buy-rebuy"));
  cust.charMixBuyRebuy.setOption(cust.charMixBuyRebuyOption);
}

/* 9. 구매자 첫구매/재구매 비율 - 하단 표 SQL */
cust.buyerFirstBuyRebuyBottomUpdate = function () {
  if (cust.firstBuyRebuyListGrid) {
    let filterData = [];
    for (var i = 0; i < cust.buyerFirstBuyRebuyBottom.length; i++) {
      filterData.push(Object.values(cust.buyerFirstBuyRebuyBottom[i]));
    }
    cust.firstBuyRebuyListGrid.updateConfig({ data: filterData }).forceRender();
  }
};

// 하단 grid js
if (document.getElementById("firstBuyRebuyList")) {
  cust.firstBuyRebuyListGrid = new gridjs.Grid({
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
  }).render(document.getElementById("firstBuyRebuyList"));
}

/************************************************************************* */
/* 8. 구매자 객단가 그래프 - 그래프 SQL */
cust.averageRevenuePerCustomerGraphUpdate = function () {
  if (cust.charMixCustPrice) {
    let rawData = cust.averageRevenuePerCustomerGraph;

    cust.charMixCustPrice.setOption(cust.charMixCustPriceOption, true);
    if (rawData.length > 0) {
      rawData = rawData.sort(function (a, b) {
        if (a === 0) return -1; // 0을 가장 첫번째로 배치
        return new Date(a.x_dt) - new Date(b.x_dt);
      });

      let dataArr = rawData.reduce((arr, chart) => {
        (arr[chart["l_lgnd_id"]] = arr[chart["l_lgnd_id"]] || []).push(chart);
        return arr;
      }, {});

      const lgnd = [...new Set(rawData.map((item) => item.l_lgnd_id))];
      const lgnd_nm = [...new Set(rawData.map((item) => item.l_lgnd_nm))];
      let dayValues = [[], [], [], []];
      let dates = [
        ...new Set([
          ...dataArr["PAID"].map(({ x_dt }) => x_dt),
          ...dataArr["CUST"].map(({ x_dt }) => x_dt),
          ...dataArr["CUST_WEEK"].map(({ x_dt }) => x_dt),
          ...dataArr["CUST_MNTH"].map(({ x_dt }) => x_dt),
        ]),
      ];

      if ("PAID_YOY" in dataArr) {
        dayValues = [[], [], [], [], [], [], [], []];
        dates = [
          ...new Set([
            ...dataArr["PAID"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST_WEEK"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST_MNTH"].map(({ x_dt }) => x_dt),
            ...dataArr["PAID_YOY"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST_YOY"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST_WEEK_YOY"].map(({ x_dt }) => x_dt),
            ...dataArr["CUST_MNTH_YOY"].map(({ x_dt }) => x_dt),
          ]),
        ];
      }

      dates = dates.sort(function (a, b) {
        if (a === 0) return -1; // 0을 가장 첫번째로 배치
        return new Date(a) - new Date(b);
      });

      let series = [];
      let seriesLgndData = [];
      let xdtVal;
      lgnd.forEach((lg) => {
        seriesLgndData = [];
        dates.forEach((date) => {
          xdtVal = rawData.find((obj) => {
            return obj.x_dt == date && obj.l_lgnd_id == lg;
          });
          if (xdtVal && xdtVal[`y_val_${currency}`]) {
            seriesLgndData.push(Number(xdtVal[`y_val_${currency}`]));
          } else {
            seriesLgndData.push(0);
          }
        });
        if (lg === "PAID" || lg === "PAID_YOY") {
          series.push({
            name: [...new Set(rawData.filter((rawData) => lg === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "bar",
            yAxisIndex: 1,
            data: seriesLgndData,
          });
        } else {
          series.push({
            name: [...new Set(rawData.filter((rawData) => lg === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            yAxisIndex: 0,
            data: seriesLgndData,
          });
        }
      });

      cust.charMixCustPrice.setOption({
        legend: {
          data: lgnd_nm,
          selected: {
            "주 객단가": false,
            "월 객단가": false
          },
          textStyle: {
            color: "#858d98",
          }
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
                text: rawData.length == 0 ? "데이터가 없습니다" : "",
              },
            },
          ],
        },
      });
    }
  }
};

// 구매자 객단가 그래프
cust.charMixCustPriceOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  grid: {
    left: "1%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  legend: {
    data: [],
  },
  xAxis: [
    {
      type: "category",
      data: [],
    },
  ],
  yAxis: [
    {
      type: "value",
    },
    {
      type: "value",
    },
  ],
  series: [],
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
if (document.getElementById("chart-mix-cust-price")) {
  cust.charMixCustPrice = echarts.init(document.getElementById("chart-mix-cust-price"));
  cust.charMixCustPrice.setOption(cust.charMixCustPriceOption);
}

/************************************************************************************************** */
/* 10. 지역분포 그래프 - 지도 그래프 SQL */
cust.regionalDistributionMapChartUpdate = function () {
  var rawData = cust.regionalDistributionMapChart;
  // 데이터 변환
  var convertedData = rawData.map(function (item) {
    return {
      name: item.city_nm,
      value: item.vist_cnt,
    };
  });

  var vistCnts = rawData.map(function (item) {
    return item.vist_cnt;
  });

  var minVistCnt = Math.min(...vistCnts);
  var maxVistCnt = Math.max(...vistCnts);

  convertedData.sort(function (a, b) {
    return a.value - b.value;
  });
  cust.mapOption = {
    tooltip: {
      trigger: "item",
      formatter: function (params) {
        var value = params.value;
        if (!value) {
          value = 0;
        }
        var color = params.color;
        if (!color) {
          color = "rgba(150, 150, 150, 1)";
        }
        return (
          `${params.name}` +
          '<br /><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:' +
          color +
          ';margin-right:5px;"></span>' +
          '<span style="font-weight:900;float:right;margin-left:10px;font-size:14px;color:#666;">' +
          `${value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}` +
          "</span>"
        );
      },
    },
    visualMap: {
      left: "left",
      min: minVistCnt,
      max: maxVistCnt,
      inRange: {
        // prettier-ignore
        color: ['lightskyblue', 'yellow', 'orangered'],
      },
      text: ["High", "Low"],
      calculable: true,
      dimension: 0,
    },
    toolbox: {
      left: "right",
      top: "center",
      orient: "vertical",
      feature: {
        saveAsImage: {},
        dataView: {},
        myCustomButton: {
          // 커스텀 버튼 추가
          show: true, // 버튼을 표시합니다.
          title: "전국지도로 이동", // 버튼의 툴팁 제목을 설정합니다.
          icon: "path://M575.8 255.5c0 18-15 32.1-32 32.1h-32l.7 160.2c0 2.7-.2 5.4-.5 8.1V472c0 22.1-17.9 40-40 40H456c-1.1 0-2.2 0-3.3-.1c-1.4 .1-2.8 .1-4.2 .1H416 392c-22.1 0-40-17.9-40-40V448 384c0-17.7-14.3-32-32-32H256c-17.7 0-32 14.3-32 32v64 24c0 22.1-17.9 40-40 40H160 128.1c-1.5 0-3-.1-4.5-.2c-1.2 .1-2.4 .2-3.6 .2H104c-22.1 0-40-17.9-40-40V360c0-.9 0-1.9 .1-2.8V287.6H32c-18 0-32-14-32-32.1c0-9 3-17 10-24L266.4 8c7-7 15-8 22-8s15 2 21 7L564.8 231.5c8 7 12 15 11 24z", // 버튼 아이콘을 설정합니다.
          onclick: function (params) {
            echarts.registerMap("CHN", cust.initMapData);
            cust.chartMap.setOption(cust.mapOption, true);
          },
        },
      },
    },
    series: [
      {
        id: "population",
        type: "map",
        roam: true,
        map: "CHN",
        animationDurationUpdate: 1000,
        universalTransition: true,
        data: convertedData,
        label: {
          show: true, // 항상 레이블 표시
          formatter: "{b}", // 레이블의 포맷 지정
        },
        emphasis: {
          itemStyle: {
            areaColor: "#FFFCCC",
          },
          label: {
            show: true,
          },
        },
      },
    ],
  };
  cust.chartMap.setOption(cust.mapOption, true);
  // setInterval(function () {
  //   currentOption = currentOption === cust.mapOption ? cust.barOption : cust.mapOption;
  //   cust.chartMap.setOption(currentOption, true);
  // }, 10000);
};
/************************************************************************************************** */
/* 10. 지역분포 그래프 - 바 그래프 SQL */
cust.regionalDistributionBarChartUpdate = function () {
  if (cust.charBarRegiGrade) {
    let rawData = cust.regionalDistributionBarChart;

    let charBarRegiGradeData = [];
    rawData.forEach(function (item) {
      charBarRegiGradeData.push({
        value: item.y_val,
        rate: item.y_rate,
      });
    });

    cust.labelSetting3 = {
      show: true,
      position: "top",
      offset: [0, -20],
      formatter: function (param) {
        return Number(param.data.rate).toFixed(0) + "%";
      },
      fontSize: 17,
      fontFamily: "Arial",
    };

    cust.charBarRegiGrade.setOption({
      tooltip: {
        trigger: "axis",
      },
      xAxis: {
        type: "category",
        data: rawData.map((item) => item.x_val),
      },
      series: [
        {
          name: "지역 등급별 분포",
          label: cust.labelSetting3,
          data: charBarRegiGradeData,
          type: "bar",
        },
      ],
      graphic: {
        elements: [
          {
            type: "text",
            left: "center",
            top: "middle",
            style: {
              text: rawData.length == 0 ? "데이터가 없습니다" : "",
              fill: "#999",
              font: "14px Microsoft YaHei",
            },
          },
        ],
      },
    });
  }
};

cust.charBarRegiGradeOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: "bar", // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: [],
  },
  yAxis: {
    type: "value",
  },
  series: [
    {
      data: [],
      type: "bar",
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
if (document.getElementById("chart-bar-regi-grade")) {
  cust.charBarRegiGrade = echarts.init(document.getElementById("chart-bar-regi-grade"));
  cust.charBarRegiGrade.setOption(cust.charBarRegiGradeOption);
}

/************************************************************************************************** */
/* 11. 성별분포 그래프 - 바 그래프 SQL */
cust.labels = ["여성", "미상", "남성"];
cust.bodyMax = 100;
cust.labelSetting = {
  show: true,
  position: "top",
  offset: [0, -20],
  formatter: function (param) {
    return ((param.value / cust.bodyMax) * 100).toFixed(0) + "%";
  },
  fontSize: 17,
  fontFamily: "Arial",
};
// 성별 분포 그래프
const symbols = [
  'path://M1240 8986 c0 -15 -21 -26 -49 -26 -21 0 -110 -46 -171 -88 -45 -31 -111 -101 -136 -144 -44 -77 -84 -191 -84 -238 0 -19 -7 -57 -15 -84 -8 -27 -15 -68 -15 -91 0 -23 -7 -64 -15 -91 -8 -27 -15 -65 -15 -84 0 -19 -7 -60 -15 -90 -8 -30 -15 -71 -15 -90 0 -19 -7 -57 -15 -84 -8 -27 -15 -69 -15 -93 0 -24 -6 -69 -14 -101 -14 -56 -31 -154 -45 -262 -4 -30 -13 -68 -22 -85 l-14 -30 -185 -6 c-195 -6 -242 -13 -261 -35 -6 -8 -17 -14 -23 -14 -19 0 -62 -50 -90 -103 -22 -41 -26 -61 -26 -132 0 -46 5 -87 10 -90 6 -3 10 -15 10 -25 0 -11 6 -34 14 -52 22 -53 37 -101 45 -138 4 -19 12 -44 18 -55 12 -23 31 -76 43 -120 5 -16 14 -46 21 -65 6 -19 17 -51 24 -70 7 -19 18 -51 24 -70 7 -19 16 -48 21 -65 11 -39 29 -91 46 -133 8 -18 14 -42 14 -53 0 -12 6 -33 14 -47 15 -30 33 -81 46 -127 5 -16 14 -46 21 -65 6 -19 17 -51 24 -70 7 -19 18 -51 25 -70 25 -71 24 -79 -5 -90 -14 -5 -73 -10 -130 -10 -87 0 -111 -4 -145 -21 -44 -23 -120 -105 -120 -129 0 -9 -5 -21 -11 -27 -21 -21 13 -431 56 -668 9 -44 15 -105 15 -135 0 -30 7 -82 15 -115 8 -33 14 -81 15 -106 0 -26 5 -71 11 -100 6 -30 15 -92 20 -139 12 -121 28 -245 40 -315 5 -33 14 -111 19 -173 5 -62 12 -117 16 -123 3 -6 10 -50 14 -97 11 -111 34 -235 54 -290 18 -47 71 -131 108 -172 35 -39 145 -120 161 -120 8 0 20 -7 27 -15 7 -8 24 -15 39 -15 14 -1 37 -7 51 -15 37 -21 1993 -21 2030 0 14 8 37 14 51 15 15 0 32 7 39 15 7 8 19 15 27 15 18 0 117 76 164 127 46 50 99 134 99 159 0 11 5 25 11 31 13 13 37 142 49 265 4 47 11 91 14 97 4 6 11 61 16 123 5 62 14 140 19 173 12 72 28 198 40 315 5 47 14 105 20 130 6 25 11 70 11 100 0 30 7 82 15 115 8 33 15 85 15 115 0 30 6 91 15 135 18 99 37 249 42 335 5 88 11 110 28 110 12 0 15 19 15 109 0 100 -2 109 -20 114 -11 3 -20 13 -20 23 0 26 -64 99 -114 128 -40 24 -54 26 -150 26 -153 0 -172 11 -142 82 20 49 37 98 47 141 5 21 13 45 18 55 10 21 30 77 41 117 5 17 14 46 21 65 6 19 17 51 24 70 7 19 18 51 24 70 7 19 16 49 21 65 5 17 14 46 21 65 6 19 17 51 24 70 7 19 18 51 24 70 7 19 16 49 21 65 11 40 31 96 41 117 5 10 13 34 18 55 10 43 27 92 47 141 8 18 14 41 14 52 0 11 9 25 20 32 17 11 20 24 20 89 0 58 -4 78 -15 82 -8 4 -21 21 -28 40 -17 40 -74 107 -92 107 -7 0 -18 6 -24 14 -19 22 -66 29 -261 35 l-185 6 -14 30 c-9 17 -18 55 -22 85 -14 108 -31 206 -45 262 -8 32 -14 74 -14 94 0 20 -6 66 -14 103 -8 36 -22 111 -31 166 -9 55 -23 130 -31 166 -8 37 -14 85 -14 107 0 23 -5 53 -11 69 -6 15 -15 57 -19 93 -14 122 -60 223 -152 332 -41 49 -201 148 -239 148 -28 0 -49 11 -49 26 0 12 -71 14 -445 14 -374 0 -445 -2 -445 -14z"/> <path d="M1530 2228 c-19 -5 -57 -13 -85 -18 -27 -4 -70 -15 -95 -23 -326 -108 -575 -333 -699 -632 -19 -44 -40 -94 -47 -112 -8 -17 -14 -46 -14 -65 0 -18 -7 -51 -15 -73 -20 -56 -20 -324 0 -380 8 -22 15 -55 15 -73 0 -19 6 -48 14 -65 7 -18 28 -68 47 -112 113 -272 344 -496 619 -602 150 -58 199 -66 415 -66 180 0 250 8 335 36 326 108 575 333 699 632 19 44 40 94 47 112 8 17 14 46 14 65 0 18 7 51 15 73 20 56 20 324 0 380 -8 22 -15 55 -15 73 0 19 -6 48 -14 65 -7 18 -28 68 -47 112 -124 299 -373 524 -699 632 -25 8 -67 19 -95 23 -27 5 -68 13 -90 19 -49 13 -257 13 -305 -1z',
  'path://M1260 8986 c0 -16 -21 -26 -54 -26 -12 0 -31 -7 -42 -15 -10 -8 -24 -15 -31 -15 -7 0 -34 -14 -60 -32 -131 -85 -217 -208 -244 -348 -22 -116 -28 -161 -28 -235 -1 -44 -6 -96 -11 -115 -6 -19 -15 -101 -20 -182 -6 -81 -15 -159 -20 -173 -6 -15 -10 -56 -10 -93 0 -37 -7 -112 -15 -167 -8 -55 -15 -132 -15 -172 0 -39 -5 -84 -10 -99 -6 -15 -15 -95 -20 -178 -5 -83 -14 -167 -20 -186 -5 -19 -10 -64 -10 -100 0 -36 -7 -110 -15 -164 -8 -55 -15 -130 -15 -168 0 -38 -5 -78 -10 -88 -6 -10 -13 -68 -16 -127 -4 -59 -11 -114 -17 -120 -7 -10 -58 -13 -192 -13 -212 0 -244 -9 -313 -84 -86 -93 -87 -125 -33 -686 6 -69 18 -172 26 -230 8 -58 17 -153 20 -211 2 -59 9 -119 15 -134 5 -14 10 -59 10 -98 0 -40 5 -101 11 -137 6 -36 15 -112 19 -170 8 -110 23 -256 41 -400 6 -47 14 -145 19 -218 5 -74 11 -141 15 -150 4 -9 11 -69 16 -132 13 -162 33 -301 47 -327 7 -12 12 -29 12 -37 0 -23 57 -115 99 -159 47 -51 146 -127 164 -127 8 0 20 -7 27 -15 7 -8 24 -15 39 -15 14 -1 37 -7 51 -15 20 -11 77 -14 271 -15 231 0 250 1 295 22 36 16 98 69 237 207 104 102 195 190 203 194 12 7 65 -40 212 -186 147 -145 209 -199 246 -216 45 -20 64 -21 295 -21 194 1 251 4 271 15 14 8 37 14 51 15 15 0 32 7 39 15 7 8 19 15 27 15 18 0 117 76 164 127 42 44 99 136 99 159 0 8 5 25 12 37 13 25 35 172 48 327 5 58 13 134 19 170 6 36 11 102 11 147 0 45 5 94 11 110 6 15 15 93 20 173 5 80 13 161 19 180 5 19 10 64 10 100 0 36 7 108 15 160 8 52 15 127 15 167 0 39 5 84 10 99 6 15 15 95 20 178 5 83 14 167 20 186 5 19 10 64 10 100 0 36 7 110 15 165 8 55 15 130 15 167 0 72 14 123 30 113 6 -4 10 38 10 119 0 97 -3 126 -13 126 -7 0 -21 17 -30 38 -19 44 -93 122 -116 122 -9 0 -25 7 -35 15 -16 12 -58 15 -207 15 -137 0 -189 3 -196 13 -6 6 -13 61 -17 120 -3 59 -10 117 -16 127 -5 10 -10 50 -10 88 0 38 -7 113 -15 168 -8 54 -15 128 -15 164 0 36 -5 81 -10 100 -6 19 -15 103 -20 186 -5 83 -14 163 -20 178 -5 15 -10 60 -10 99 0 40 -7 117 -15 172 -8 55 -15 130 -15 167 0 37 -4 78 -10 93 -5 14 -14 92 -20 173 -5 81 -14 163 -20 182 -5 19 -10 73 -11 120 0 47 -5 108 -10 135 -5 28 -14 70 -18 95 -27 139 -113 263 -244 348 -26 18 -53 32 -60 32 -7 0 -21 7 -31 15 -11 8 -30 15 -42 15 -33 0 -54 10 -54 26 0 12 -68 14 -425 14 -357 0 -425 -2 -425 -14z m470 -3891 c57 -54 49 -155 -14 -194 -103 -64 -229 25 -196 138 19 67 59 93 133 87 36 -2 55 -10 77 -31z m-16 -391 c10 -4 16 -18 16 -38 0 -37 30 -105 56 -127 10 -10 48 -32 84 -50 73 -38 171 -125 196 -172 56 -109 57 -251 1 -354 -60 -111 -216 -193 -370 -193 -166 0 -299 73 -382 210 -29 48 -44 90 -32 90 2 0 39 13 84 28 91 32 96 31 132 -35 28 -50 62 -76 125 -97 61 -21 85 -20 153 4 80 28 111 62 128 140 9 41 -21 122 -59 161 -26 27 -136 98 -154 100 -21 2 -100 71 -119 105 -19 32 -23 54 -23 131 0 64 4 93 13 96 18 8 133 8 151 1z"/> <path d="M1530 2228 c-19 -5 -57 -13 -85 -18 -27 -4 -70 -15 -95 -23 -326 -108 -575 -333 -699 -632 -19 -44 -40 -94 -47 -112 -8 -17 -14 -46 -14 -65 0 -18 -7 -51 -15 -73 -20 -56 -20 -324 0 -380 8 -22 15 -55 15 -73 0 -19 6 -48 14 -65 7 -18 28 -68 47 -112 113 -272 344 -496 619 -602 150 -58 199 -66 415 -66 180 0 250 8 335 36 326 108 575 333 699 632 19 44 40 94 47 112 8 17 14 46 14 65 0 18 7 51 15 73 20 56 20 324 0 380 -8 22 -15 55 -15 73 0 19 -6 48 -14 65 -7 18 -28 68 -47 112 -124 299 -373 524 -699 632 -25 8 -67 19 -95 23 -27 5 -68 13 -90 19 -49 13 -257 13 -305 -1z',
  'path://M1260 8986 c0 -16 -21 -26 -54 -26 -12 0 -31 -7 -42 -15 -10 -8 -24 -15 -31 -15 -7 0 -34 -14 -60 -32 -131 -85 -217 -208 -244 -348 -22 -116 -28 -161 -28 -235 -1 -44 -6 -96 -11 -115 -6 -19 -15 -101 -20 -182 -6 -81 -15 -159 -20 -173 -6 -15 -10 -56 -10 -93 0 -37 -7 -112 -15 -167 -8 -55 -15 -132 -15 -172 0 -39 -5 -84 -10 -99 -6 -15 -15 -95 -20 -178 -5 -83 -14 -167 -20 -186 -5 -19 -10 -64 -10 -100 0 -36 -7 -110 -15 -164 -8 -55 -15 -130 -15 -168 0 -38 -5 -78 -10 -88 -6 -10 -13 -68 -16 -127 -4 -59 -11 -114 -17 -120 -7 -10 -58 -13 -192 -13 -212 0 -244 -9 -313 -84 -86 -93 -87 -125 -33 -686 6 -69 18 -172 26 -230 8 -58 17 -153 20 -211 2 -59 9 -119 15 -134 5 -14 10 -59 10 -98 0 -40 5 -101 11 -137 6 -36 15 -112 19 -170 8 -110 23 -256 41 -400 6 -47 14 -145 19 -218 5 -74 11 -141 15 -150 4 -9 11 -69 16 -132 13 -162 33 -301 47 -327 7 -12 12 -29 12 -37 0 -23 57 -115 99 -159 47 -51 146 -127 164 -127 8 0 20 -7 27 -15 7 -8 24 -15 39 -15 14 -1 37 -7 51 -15 20 -11 77 -14 271 -15 231 0 250 1 295 22 36 16 98 69 237 207 104 102 195 190 203 194 12 7 65 -40 212 -186 147 -145 209 -199 246 -216 45 -20 64 -21 295 -21 194 1 251 4 271 15 14 8 37 14 51 15 15 0 32 7 39 15 7 8 19 15 27 15 18 0 117 76 164 127 42 44 99 136 99 159 0 8 5 25 12 37 13 25 35 172 48 327 5 58 13 134 19 170 6 36 11 102 11 147 0 45 5 94 11 110 6 15 15 93 20 173 5 80 13 161 19 180 5 19 10 64 10 100 0 36 7 108 15 160 8 52 15 127 15 167 0 39 5 84 10 99 6 15 15 95 20 178 5 83 14 167 20 186 5 19 10 64 10 100 0 36 7 110 15 165 8 55 15 130 15 167 0 72 14 123 30 113 6 -4 10 38 10 119 0 97 -3 126 -13 126 -7 0 -21 17 -30 38 -19 44 -93 122 -116 122 -9 0 -25 7 -35 15 -16 12 -58 15 -207 15 -137 0 -189 3 -196 13 -6 6 -13 61 -17 120 -3 59 -10 117 -16 127 -5 10 -10 50 -10 88 0 38 -7 113 -15 168 -8 54 -15 128 -15 164 0 36 -5 81 -10 100 -6 19 -15 103 -20 186 -5 83 -14 163 -20 178 -5 15 -10 60 -10 99 0 40 -7 117 -15 172 -8 55 -15 130 -15 167 0 37 -4 78 -10 93 -5 14 -14 92 -20 173 -5 81 -14 163 -20 182 -5 19 -10 73 -11 120 0 47 -5 108 -10 135 -5 28 -14 70 -18 95 -27 139 -113 263 -244 348 -26 18 -53 32 -60 32 -7 0 -21 7 -31 15 -11 8 -30 15 -42 15 -33 0 -54 10 -54 26 0 12 -68 14 -425 14 -357 0 -425 -2 -425 -14z"/> <path d="M1530 2228 c-19 -5 -57 -13 -85 -18 -27 -4 -70 -15 -95 -23 -326 -108 -575 -333 -699 -632 -19 -44 -40 -94 -47 -112 -8 -17 -14 -46 -14 -65 0 -18 -7 -51 -15 -73 -20 -56 -20 -324 0 -380 8 -22 15 -55 15 -73 0 -19 6 -48 14 -65 7 -18 28 -68 47 -112 113 -272 344 -496 619 -602 150 -58 199 -66 415 -66 180 0 250 8 335 36 326 108 575 333 699 632 19 44 40 94 47 112 8 17 14 46 14 65 0 18 7 51 15 73 20 56 20 324 0 380 -8 22 -15 55 -15 73 0 19 -6 48 -14 65 -7 18 -28 68 -47 112 -124 299 -373 524 -699 632 -25 8 -67 19 -95 23 -27 5 -68 13 -90 19 -49 13 -257 13 -305 -1z',
];
const markLineSetting = {
  symbol: "none",
  lineStyle: {
    opacity: 0.3,
  },
  data: [
    {
      type: "max",
      label: {
        formatter: "max: {c}",
      },
    },
    {
      type: "min",
      label: {
        formatter: "min: {c}",
      },
    },
  ],
};
cust.genderDistributionBarChartUpdate = function () {
  if (cust.charGender) {
    const result = cust.genderDistributionBarChart;
    let femaleValue = 0;
    let unknownValue = 0;
    let maleValue = 0;

    result.forEach(function (item) {
      if (item.x_val == "女") {
        femaleValue = item.y_rate;
      } else if (item.x_val == "未知") {
        unknownValue = item.y_rate;
      } else if (item.x_val == "男") {
        maleValue = item.y_rate;
      }
    });

    let dataSum = femaleValue + unknownValue + maleValue;
    cust.charGender.setOption({
      // tooltip 설정
      tooltip: {
        trigger: "axis",
        // formatter 함수를 사용하여 tooltip 내용 지정
        formatter: function (params) {
          let matchingVal = 0;
          let color = params[0].color;
          let type = params[0].name;
          switch (type) {
            case "여성":
              type = "女";
              break;
            case "미상":
              type = "未知";
              break;
            case "남성":
              type = "男";
              break;
            default:
            // Do nothing
          }
          for (let i = 0; i < result.length; i++) {
            if (result[i].x_val === type) {
              matchingVal = result[i].y_val;
              break;
            }
          }
          return (
            `${params[0].name}` +
            '<br /><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:' +
            color +
            ';margin-right:5px;"></span>' +
            '<span style="font-weight:900;float:right;margin-left:10px;font-size:14px;color:#666;">' +
            `${addCommas(matchingVal)}` +
            "</span>"
          );
        },
      },
      series: [
        {
          name: "",
          type: "pictorialBar",
          symbolClip: true,
          symbolBoundingData: cust.bodyMax,
          label: cust.labelSetting,
          data: [
            {
              value: femaleValue,
              symbol: symbols[0],
            },
            {
              value: unknownValue,
              symbol: symbols[1],
            },
            {
              value: maleValue,
              symbol: symbols[2],
            },
          ],
          markLine: markLineSetting,
          z: 10,
          barMaxWidth: 90,
        },
        {
          name: "",
          type: "pictorialBar",
          symbolBoundingData: cust.bodyMax,
          animationDuration: 0,
          barMaxWidth: 90,
          itemStyle: {
            color: "#ccc",
          },
          data: [
            {
              value: femaleValue,
              symbol: symbols[0],
            },
            {
              value: unknownValue,
              symbol: symbols[1],
            },
            {
              value: maleValue,
              symbol: symbols[2],
            },
          ],
        },
      ],
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
  }
};

cust.charGenderOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  legend: {
    data: ["type"],
    selectedMode: "single",
  },
  xAxis: {
    data: cust.labels,
    axisTick: { show: true },
    axisLine: { show: false },
    axisLabel: { show: true, fontSize: 17 },
  },
  yAxis: {
    max: cust.bodyMax,
    offset: 20,
    splitLine: { show: false },
  },
  grid: {
    top: "center",
    height: "70%",
  },
  markLine: {
    z: -100,
  },
  series: [
    {
      name: "",
      type: "pictorialBar",
      symbolClip: true,
      symbolBoundingData: cust.bodyMax,
      label: cust.labelSetting,
      data: [],
      markLine: markLineSetting,
      z: 10,
      barMaxWidth: 90,
    },
    {
      name: "",
      type: "pictorialBar",
      symbolBoundingData: cust.bodyMax,
      animationDuration: 0,
      barMaxWidth: 90,
      itemStyle: {
        color: "#ccc",
      },
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

if (document.getElementById("chart-gender")) {
  cust.charGender = echarts.init(document.getElementById("chart-gender"));
  cust.charGender.setOption(cust.charGenderOption);
}

/************************************************************************************************** */
cust.buyerProfitGraphUpdate = function () {
  let rawData = cust.buyerProfitGraph;
  if (cust.charBarCustRevenue) {
    cust.charBarCustRevenue.setOption(cust.charBarCustRevenueOption, true);
    const x_mnth = [...new Set(rawData.map((item) => item.x_mnth))];
    if (rawData.length > 0) {
      cust.charBarCustRevenue.setOption({
        xAxis: {
          type: "category",
          data: x_mnth,
        },
        series: [
          {
            data: rawData.map((item) => item["y_val"]),
            type: "bar",
          },
        ],
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData.length == 0 ? "데이터가 없습니다" : "",
                fill: "#999",
                font: "14px Microsoft YaHei",
              },
            },
          ],
        },
      });
    }
  }
};
/* 10. 구매자당 수익 그래프 SQL */
cust.charBarCustRevenueOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: "line", // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: [],
  },
  yAxis: {
    type: "value",
  },
  series: [],
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
if (document.getElementById("chart-bar-cust-revenue")) {
  cust.charBarCustRevenue = echarts.init(document.getElementById("chart-bar-cust-revenue"));
  cust.charBarCustRevenue.setOption(cust.charBarCustRevenueOption);
}

/************************************************************************************************** */
/* 12. 연령분포 - 바 그래프 SQL */
cust.ageDistributionBarChartUpdate = function () {
  if (cust.charBarAge) {
    const rawData = cust.ageDistributionBarChart;
    let dataSum = 0;

    let ageDistributionData = [];
    rawData.forEach(function (item) {
      ageDistributionData.push({
        value: item.y_val,
        rate: item.y_rate,
      });
    });

    cust.labelSetting2 = {
      show: true,
      position: "right",
      offset: [0, 0],
      formatter: function (param) {
        return Number(param.data.rate).toFixed(2) + "%";
      },
      fontSize: 15,
      fontFamily: "Arial",
    };

    let filterData = rawData.map((d) => ({
      x: d["x_val"],
      y: Number(d["y_val"]),
    }));

    filterData.map(function (item) {
      dataSum += item.y;
    });

    cust.charBarAge.setOption({
      tooltip: {
        trigger: "axis",
      },
      grid: {
        left: "0.5%",
        right: "10.5%",
        bottom: "3%",
        containLabel: true,
      },
      xAxis: {
        type: "value",
        axisLabel: {
          formatter: function (value) {
            return value / 10000 + "M"; // 값을 1000으로 나눈 후에 반환
          },
        },
      },
      yAxis: {
        type: "category",
        data: filterData.map(function (item) {
          return item.x;
        }),
      },
      series: [
        {
          name: "연령 분포",
          label: cust.labelSetting2,
          data: ageDistributionData,
        },
      ],
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
  }
};

cust.charBarAgeOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  grid: {
    left: "1%",
    right: "4%",
    bottom: "0",
    top: "0",
    containLabel: true,
  },
  xAxis: {
    type: "value",
  },
  yAxis: {
    type: "category",
    data: [],
  },
  series: [
    {
      barWidth: "60%",
      data: [],
      type: "bar",
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
if (document.getElementById("chart-bar-age")) {
  cust.charBarAge = echarts.init(document.getElementById("chart-bar-age"));
  cust.charBarAge.setOption(cust.charBarAgeOption);
}

/************************************************************************************************** */
// 지역 분포 그래프
if (document.getElementById("chart-map")) {
  cust.chartDom = document.getElementById("chart-map");
  cust.chartMap = echarts.init(cust.chartDom);
  // chartMap.showLoading();
  cust.chartMap.showLoading();
  sendGetRequest("/static/json/geo/echart-geo-cn.json", function (json) {
    cust.chartMap.hideLoading();
    cust.initMapData = json;
    echarts.registerMap("CHN", cust.initMapData);
    var data = [];
    data.sort(function (a, b) {
      return a.value - b.value;
    });
    cust.mapOption = {
      visualMap: {
        left: "right",
        min: 5000,
        max: 30000,
        inRange: {
          color: ["lightskyblue", "yellow", "orangered"],
        },
        text: ["High", "Low"],
        calculable: true,
        dimension: 0,
      },
      toolbox: {
        orient: "vertical",
        left: "right",
        top: "center",
        feature: {
          saveAsImage: {},
          dataView: {},
        },
      },
      grid: {
        left: "1%",
        right: "5%",
        bottom: "3%",
        containLabel: true,
      },
      series: [
        {
          id: "population",
          type: "map",
          roam: true,
          map: "CHN",
          // animationDurationUpdate: 1000,
          // universalTransition: true,
          data: data,
        },
      ],
    };

    let currentOption = cust.mapOption;
    cust.chartMap.setOption(currentOption, true);
  });

  // 클릭 이벤트 설정
  cust.chartMap.on("click", function (params) {
    const mapName = cust.chnProvCityMap[params.name];
    if (!mapName) {
      // 값이 없으면 함수를 빠져나감
      return;
    }
    cust.chartMap.showLoading();
    sendGetRequest(`/static/json/geo/city/${cust.chnProvCityMap[params.name]}_full.json`, function (json) {
      cust.chartMap.hideLoading();
      echarts.registerMap("CHN", json);
      cust.chartMap.setOption(cust.mapOption, true);
    });
  });
}

/* 로딩 바 (E-chart) */
cust.loadingBarOptions = {};
// 로딩 바 (E-chart)
cust.loadingBarOptions = {
  graphic: {
    elements: [
      {
        type: "group",
        left: "center",
        top: "center",
        children: new Array(7).fill(0).map((val, i) => ({
          type: "rect",
          x: i * 20,
          shape: {
            x: 0,
            y: -30,
            width: 8,
            height: 60,
          },
          style: {
            fill: "#6691e7",
          },
          keyframeAnimation: {
            duration: 1000,
            delay: i * 200,
            loop: true,
            keyframes: [
              {
                percent: 0.5,
                scaleY: 0.3,
                easing: "cubicIn",
              },
              {
                percent: 1,
                scaleY: 1,
                easing: "cubicOut",
              },
            ],
          },
        })),
      },
    ],
  },
};
if (document.getElementById("loading-bar-custom")) {
  cust.loadingBar = echarts.init(document.getElementById("loading-bar-custom"));
  cust.loadingBar.setOption(cust.loadingBarOptions);
}

// 이벤트 핸들러 함수를 배열로 정의합니다.
cust.resizeHandlers = [
  cust.chartLineVisit,
  cust.chartLineTimeSale,
  cust.charLineClickChange,
  cust.charLineDayClickChange,
  cust.chartLineBuyer,
  cust.charMixCustPrice,
  cust.charBarCustRevenue,
  cust.charMixBuyRebuy,
  cust.chartMap,
  cust.charBarRegiGrade,
  cust.charGender,
  cust.charBarAge,
];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
cust.resizeHandlers.forEach((handler) => {
  if (handler != undefined) {
    window.addEventListener("resize", eval(handler).resize);
  }
});

//로드할때 실행 될 스크립트
cust.onLoadEvent = function (initData) {
  sendGetRequest("/static/json/geo/chn_prov_city_map.json", function (json) {
    cust.chnProvCityMap = json;
  });

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

  // 방문자 수 시계열 그래프 - flatpickr 이벤트
  let visitorTimeSeriesViewer = flatpickr("#visitorTimeSeriesViewer, #dayTimeVisitorCntViewer", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        visitorTimeSeriesViewer[0].setDate([fromDate, toDate]);
        visitorTimeSeriesViewer[1].setDate([fromDate, toDate]);

        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
          },
          menu: "dashboards/common",
          tab: "customer",
          dataList: ["visitorTimeSeriesChart", "weekdayVisitorChart"],
        };
        getData(params, function (data) {
          cust.visitorTimeSeriesChart = {};
          cust.weekdayVisitorChart = {};
          if (data["visitorTimeSeriesChart"] != undefined) {
            cust.visitorTimeSeriesChart = data["visitorTimeSeriesChart"];
            cust.visitorTimeSeriesChartUpdate();
          }
          if (data["weekdayVisitorChart"] != undefined) {
            cust.weekdayVisitorChart = data["weekdayVisitorChart"];
            cust.weekdayVisitorChartUpdate();
          }
        });
      }
    },
  });

  // 클릭 전환율 그래프 - flatpickr 이벤트
  let clickChangeRateFlatpickr = flatpickr("#clickChangeRateFlatpickr, #dayClickChangeRateFlatpickr", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        clickChangeRateFlatpickr[0].setDate([fromDate, toDate]);
        clickChangeRateFlatpickr[1].setDate([fromDate, toDate]);

        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
          },
          menu: "dashboards/common",
          tab: "customer",
          dataList: ["clickConversionRate", "weekdayClickConversionRate"],
        };
        getData(params, function (data) {
          cust.clickConversionRate = {};
          cust.weekdayClickConversionRate = {};
          if (data["clickConversionRate"] != undefined) {
            cust.clickConversionRate = data["clickConversionRate"];
            cust.clickConversionRateUpdate();
          }
          if (data["weekdayClickConversionRate"] != undefined) {
            cust.weekdayClickConversionRate = data["weekdayClickConversionRate"];
            cust.weekdayClickConversionRateUpdate();
          }
        });
        
      }
    },
  });

  // 구매자 수 시계열 그래프 - flatpickr 이벤트
  flatpickr("#buyerTimeSeriesViewer", {
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
          tab: "customer",
          dataList: ["buyerTimeSeriesChart"],
        };
        getData(params, function (data) {
          cust.buyerTimeSeriesChart = {};
          if (data["buyerTimeSeriesChart"] != undefined) {
            cust.buyerTimeSeriesChart = data["buyerTimeSeriesChart"];
            cust.buyerTimeSeriesChartUpdate();
          }
        });
      }
    },
  });

  // 구매자 첫 구매 / 재 구매 비율 - flatpickr 이벤트
  flatpickr("#buyerFirstBuyRebuyChart", {
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
          tab: "customer",
          dataList: ["buyerFirstBuyRebuyChart"],
        };
        getData(params, function (data) {
          cust.buyerFirstBuyRebuyChart = {};
          if (data["buyerFirstBuyRebuyChart"] != undefined) {
            cust.buyerFirstBuyRebuyChart = data["buyerFirstBuyRebuyChart"];
            cust.buyerFirstBuyRebuyChartUpdate();
          }
        });
      }
    },
  });

  // 구매자 객 단가 그래프 - flatpickr 이벤트
  flatpickr("#custPriceViewer", {
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
          tab: "customer",
          dataList: ["averageRevenuePerCustomerGraph"],
        };
        getData(params, function (data) {
          cust.averageRevenuePerCustomerGraph = {};
          /* 구매자 객 단가 그래프 */
          if (data["averageRevenuePerCustomerGraph"] != undefined) {
            cust.averageRevenuePerCustomerGraph = data["averageRevenuePerCustomerGraph"];
            cust.averageRevenuePerCustomerGraphUpdate();
          }
        });
      }
    },
  });

  // 구매자당 수익 그래프 - flatpickr 이벤트
  flatpickr("#custRevenueViewer", {
    locale: "ko", // locale for this instance only
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);
        let params = {
          params: {
            FR_MNTH: `'${fromDate.substring(0, 7)}'`,
            TO_MNTH: `'${toDate.substring(0, 7)}'`,
            CHNL_NM: `'${chan.CHNL_NM}'`
          },
          menu: "dashboards/common",
          tab: "customer",
          dataList: ["buyerProfitGraph"],
        };
        getData(params, function (data) {
          cust.buyerProfitGraph = {};
          if (data["buyerProfitGraph"] != undefined) {
            cust.buyerProfitGraph = data["buyerProfitGraph"];
            cust.buyerProfitGraphUpdate();
          }
        });
      }
    },
  });

  let dataList = [
    "visitorAnalyticsCard", // # 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL ,
    "visitorAnalyticsChart", // # 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL
    "visitorTimeSeriesCard", // /*# 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL*/,
    "visitorTimeSeriesChart" /* 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */,
    "visitorTimeSeriesBottom" /* 2. 방문자수 시계열 그래프 - 하단표 SQL division by zero */,
    "weekdayVisitorChart" /* [도우인] 3. 요일 방문자 수 그래프 - 시계열 그래프 SQL */,
    "clickConversionRate" /* [도우인] 4. 클릭 전환율 - 시계열 그래프 SQL */,
    "weekdayClickConversionRate" /* [도우인] 5. 요일별 클릭 전환율 - 시계열 그래프 SQL */,
    "buyerTimeSeriesCard" /* [도우인] 6. 구매자 수 시계열 그래프 - 그래프상단 정보 SQL */,
    "buyerTimeSeriesChart" /* [도우인] 6. 구매자 수 시계열 그래프 - 시계열그래프 SQL */,
    "buyerTimeSeriesBottom" /* [도우인] 6. 구매자 수 시계열 그래프 - 하단표 SQL  division by zero */,
    "buyerFirstBuyRebuyChart" /* [도우인] 7. 구매자 첫구매/재구매 비율 - 시계열 그래프 SQL */,
    "buyerFirstBuyRebuyBottom" /* [도우인] 7. 구매자 첫구매/재구매 비율 - 하단 표 SQL */,
    "averageRevenuePerCustomerGraph" /* [도우인] 8. 구매자 객단가 그래프 - 그래프 SQL */,
    "buyerProfitGraph" /* [도우인] 9. 구매자당 수익 그래프 - 바 그래프 SQL */,
    "regionalDistributionBarChart" /* 11. 지역분포 그래프 - 바 그래프 SQL UV 값 없음.*/ ,
    "regionalDistributionMapChart" /* 11. 지역분포 그래프 - 지도 그래프 SQL UV 값 없음.*/,
    "genderDistributionBarChart" /* 12. 성별분포 그래프 - 바 그래프 SQL UV 값 없음.*/,
    "ageDistributionBarChart" /* 13. 연령분포 - 바 그래프 SQL UV 값 없음.*/,
  ];

  let params = {
    params: {
      FR_DT: `'${initData.fr_dt}'`,
      TO_DT: `'${initData.to_dt}'`,
      BASE_MNTH: `'${initData.base_mnth}'`,
      FR_MNTH: `'${initData.fr_dt.substring(0, 7)}'`,
      TO_MNTH: `'${initData.to_dt.substring(0, 7)}'`,
      CHNL_NM: `'${chan.CHNL_NM}'`,
    },
    menu: "dashboards/common",
    tab: "customer",
    dataList: dataList,
  };

  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      cust[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    cust.setDataBinding();
  });

  cust.onloadStatus = true; // 화면 로딩 상태
};
