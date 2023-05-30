let price = {};
price.onloadStatus = false; // 화면 로딩 상태
price.chartWeightAverSalesOption = {}; /* 가중 평균 판매가 (시계열 그래프) */
price.salesDayChartOption = {}; /* 할인율 발생 일수 (도넛) */
price.chartDaySalesOption = {}; /* 일자별 판매가 (시계열 그래프) */
price.chartProdSalesOption = {}; /* 제품별 할인율 및 매출비중 순위 (Grid) */

price.setDataBinding = function () {
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
  if (Object.keys(price.impCardAmtData).length > 0) {
    price.impCardAmtDataUpdate();
  }
  /* 중요정보 카드 - 그래프 */
  if (Object.keys(price.impCardAmtChart).length > 0) {
    price.impCardAmtChartUpdate();
  }
  /* 5. 가중평균 판매가 - 시계열 그래프 SQL */
  if (Object.keys(price.weightedAverageSalesPriceTimeSeries).length > 0) {
    price.weightedAverageSalesPriceTimeSeriesUpdate();
  }
  /* 6. 할인율 발생 일수 - 파이, 하단 리스트 SQL */
  if (Object.keys(price.discountRateDays).length > 0) {
    price.discountRateDaysUpdate();
  }
  /* 7. 일자별 제품 평균 판매가 - 제품 선택 SQL */
  if (Object.keys(price.dailyAverageProductSalesPriceProd).length > 0) {
    price.dailyAverageProductSalesPriceProdUpdate();
  }
  /* 8. 제품별 할인율 및 매출비중 순위 - 표 SQL */
  if (Object.keys(price.productDiscountRateAndRevenueShareRanking).length > 0) {
    price.productDiscountRateAndRevenueShareRankingUpdate();
  }

  counter();
};

/******************************************************** 중요정보 카드 ***************************************************/

/**
 * 매출 상단 카드 - 카드 내 data
 */
price.impCardAmtDataUpdate = function () {
  let rawData = price.impCardAmtData[0];
  // 상단 중요정보 카드
  // mnth_amt       /* 평균판매가 - 한달평균 */
  // mnth_d30       /* 30%~50% 할인판매 제품 수 - 한달평균 */
  // mnth_d50       /* 50%이상 할인판매 제품 수 - 한달평균 */
  // mnth_top_name  /* 할인율 1위 제품 명 - 한달평균 - 제품명 */
  // mnth_top_rate  /* 할인율 1위 제품 명 - 한달평균 - 할인율 */

  // ytd_amt        /* 평균판매가 -  YTD평균 */
  // ytd_d30        /* 30%~50% 할인판매 제품 수 - YTD평균 */
  // ytd_d50        /* 50%이상 할인판매 제품 수 - YTD평균 */
  // ytd_top_name   /* 할인율 1위 제품 명 - YTD평균 - 제품명 */
  // ytd_top_rate   /* 할인율 1위 제품 명 - YTD평균 - 할인율 */

  let cardAreaList = ["mnth_amt", "mnth_d30", "mnth_d50", "mnth_top_name", "mnth_top_rate", "ytd_amt", "ytd_d30", "ytd_d50", "ytd_top_name", "ytd_top_rate"];

  cardAreaList.forEach((cardArea) => {
    let el = document.getElementById(`${cardArea}`);
    if (el) {
      if (el.classList.contains("counter-value")) {
        el.innerText = 0;
        el.setAttribute("data-target", rawData[`${cardArea}_${currency}`]);
      } else {
        el.innerText = rawData[`${cardArea}_${currency}`];
      }
    }
  });
  document.getElementById("btn_mnth_top_name").setAttribute("data-bs-original-title", rawData[`mnth_top_name_${currency}`]);
  document.getElementById("btn_ytd_top_name").setAttribute("data-bs-original-title", rawData[`ytd_top_name_${currency}`]);
};

price.impCardAmtChartUpdate = function () {
  let rawData = price.impCardAmtChart;
  let { MNTH = [], YTD = [] } = rawData.reduce((arr, chart) => {
    arr[chart["chrt_key"]] ? arr[chart["chrt_key"]].push(chart) : (arr[chart["chrt_key"]] = [chart]);
    return arr;
  }, {});

  let mnthData = MNTH.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_${currency}`]),
    })),
    ytdData = YTD.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val_${currency}`]),
    }));

  // 전일 매출 그래프 데이터 업데이트
  if (price.priceChart1) {
    price.priceChart1.updateSeries([
      {
        name: "판매가",
        data: mnthData,
      },
    ]);
  }
  // 당월 누적 매출 그래프 데이터 업데이트
  if (price.priceChart2) {
    price.priceChart2.updateSeries([
      {
        name: "판매가",
        data: ytdData,
      },
    ]);
  }
};

/* price zoom data */
price.zoomSales = [
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

/* 중요 정보 카드 */
price.options = {
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
  chart: {
    width: 130,
    height: 120,
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
  colors: getChartColorsArray("priceChart1"),
};
if (document.querySelector("#priceChart1")) {
  price.priceChart1 = new ApexCharts(document.querySelector("#priceChart1"), price.options);
  price.priceChart1.render();
}
if (document.querySelector("#priceChart2")) {
  price.priceChart2 = new ApexCharts(document.querySelector("#priceChart2"), price.options);
  price.priceChart2.render();
}
/*******************************************************************************************************************************/
/******************************************************** 가중 평균 판매가 ***************************************************/
price.weightedAverageSalesPriceTimeSeriesUpdate = function () {
  let rawData = price.weightedAverageSalesPriceTimeSeries;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (price.chartWeightAverSales) {
    price.chartWeightAverSales.setOption(price.chartWeightAverSalesOption, true);
    if (rawData.length > 0) {
      price.chartWeightAverSales.setOption({
        legend: {
          data: ["가중평균 판매가", "가중평균 정가", "정가 대비 50프로", "정가 대비 30프로"],
          textStyle: {
            color: "#858d98",
          }
        },
        xAxis: {
          type: "category",
          data: lgnd,
        },
        series: [
          {
            name: "가중평균 판매가",
            type: "line",
            data: rawData.map((item) => item[`amt_${currency}`]),
          },
          {
            name: "가중평균 정가",
            type: "line",
            data: rawData.map((item) => item[`tag_${currency}`]),
          },
          {
            name: "정가 대비 50프로",
            type: "line",
            data: rawData.map((item) => item[`d50_${currency}`]),
          },
          {
            name: "정가 대비 30프로",
            type: "line",
            data: rawData.map((item) => item[`d30_${currency}`]),
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
/* 가중 평균 판매가 */
price.chartWeightAverSalesOption = {
  tooltip: {
    trigger: "axis",
  },
  dataZoom: price.zoomSales,
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
        type: ["line"],
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
if (document.getElementById("chart-weight-aver-sales")) {
  price.chartWeightAverSales = echarts.init(document.getElementById("chart-weight-aver-sales"));
  price.chartWeightAverSales.setOption(price.chartWeightAverSalesOption);
}
/*******************************************************************************************************************************/
/******************************************************** 할인율 발생 일수 ***************************************************/
price.discountRateDaysUpdate = function () {
  let rawData = price.discountRateDays;
  if (price.salesDayChart) {
    price.salesDayChart.setOption(price.salesDayChartOption, true);
    if (rawData.length > 0) {
      price.salesDayChart.setOption({
        series: [
          {
            data: [
              {
                name: "할인율 ~30%",
                value: rawData.map((item) => item[`d00_cnt_${currency}`]),
              },
              {
                name: "할인율 30~50%",
                value: rawData.map((item) => item[`d30_cnt_${currency}`]),
              },
              {
                name: "할인율 50% 이상",
                value: rawData.map((item) => item[`d50_cnt_${currency}`]),
              },
            ],
          },
        ],
      });

      if (document.getElementById("spnStartRate")) {
        document.getElementById("spnStartRate").innerText = rawData.map((item) => item[`d00_cnt_${currency}`])[0] + "일";
      }

      if (document.getElementById("spnInfoRate")) {
        document.getElementById("spnInfoRate").innerText = rawData.map((item) => item[`d30_cnt_${currency}`])[0] + "일";
      }

      if (document.getElementById("spnCommRate")) {
        document.getElementById("spnCommRate").innerText = rawData.map((item) => item[`d50_cnt_${currency}`])[0] + "일";
      }
    }
  }
};

/* 할인율 발생 일수 */
price.salesDayChartOption = {
  tooltip: {
    trigger: "item",
  },
  legend: {
    top: "2%",
    left: "center",
    textStyle: {
      color: "#858d98",
    }
  },
  grid: {
    bottom: "0",
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
  series: [
    {
      type: "pie",
      radius: ["40%", "70%"],
      avoidLabelOverlap: false,
      label: {
        show: false,
        position: "center",
      },
      labelLine: {
        show: false,
      },
      data: [
        {
          name: "할인율 ~30%",
          value: 20,
        },
        {
          name: "할인율 30~50%",
          value: 20,
        },
        {
          name: "할인율 50% 이상",
          value: 42,
        },
      ],
    },
  ],
};
if (document.getElementById("sales-day-chart")) {
  price.salesDayChart = echarts.init(document.getElementById("sales-day-chart"));
  price.salesDayChart.setOption(price.salesDayChartOption);
}
/*******************************************************************************************************************************/
/******************************************************** 일자별 제품 평균 판매가 ***************************************************/
price.dailyAverageProductSalesPriceProdUpdate = function () {
  let rawData = price.dailyAverageProductSalesPriceProd;
  let prodList = [];
  rawData.forEach((product) => {
    prodList.push({ value: product.prod_id, label: product.prod_nm });
  });
  if (price.priceSbxProduct) {
    price.priceSbxProduct.setChoices(prodList, "value", "label", true);
  }
};

price.dailyAverageProductSalesPriceGraphUpdate = function () {
  let rawData = price.dailyAverageProductSalesPriceGraph;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (price.chartDaySales) {
    price.chartDaySales.setOption(price.chartDaySalesOption, true);
    if (rawData.length > 0) {
      price.chartDaySales.setOption({
        legend: {
          data: ["판매가", "정가", "정가대비 30%", "정가대비 50%"],
          textStyle: {
            color: "#858d98",
          },
        },
        xAxis: {
          type: "category",
          boundaryGap: !1,
          data: lgnd,
        },
        series: [
          {
            name: "판매가",
            type: "line",
            data: rawData.map((item) => item[`amt_${currency}`]),
          },
          {
            name: "정가",
            type: "line",
            data: rawData.map((item) => item[`tag_${currency}`]),
          },
          {
            name: "정가대비 30%",
            type: "line",
            data: rawData.map((item) => item[`d30_${currency}`]),
          },
          {
            name: "정가대비 50%",
            type: "line",
            data: rawData.map((item) => item[`d50_${currency}`]),
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

price.searchData = function () {
  let selProduct = price.priceSbxProduct.getValue();
  let datePicker = document.getElementById("fltDailyDate");
  if (!datePicker.value) {
    dapAlert("조회 기간을 선택해 주세요.");
    return false;
  }

  if (!selProduct.value) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }
  let params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      // FR_MNTH: `'2022-01'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      PROD_ID: `'${selProduct.value}'`,
      // PROD_NM: `'M4 토너 에멀전 세트'`,
      // TYPE:`'${price.chrtType}'`
    },
    menu: "dashboards/common",
    tab: "price",
    dataList: ["dailyAverageProductSalesPriceGraph","productDiscountRateAndRevenueShareRanking"],
  };
  getData(params, function (data) {
    price.topFiveCompetingProducts = {};
    if (data["productDiscountRateAndRevenueShareRanking"] != undefined) {
      price.productDiscountRateAndRevenueShareRanking = data["productDiscountRateAndRevenueShareRanking"];
      price.productDiscountRateAndRevenueShareRankingUpdate();
    }
    price.topFiveCompetingProducts = {};
    if (data["dailyAverageProductSalesPriceGraph"] != undefined) {
      price.dailyAverageProductSalesPriceGraph = data["dailyAverageProductSalesPriceGraph"];
      price.dailyAverageProductSalesPriceGraphUpdate();
    }
  });
};

/* 일자별 판매가 */
price.chartDaySalesOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["방문자 수"],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: price.zoomSales,
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
        type: ["line"], // magicType으로 전환할 그래프 유형을 설정합니다.
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
if (document.getElementById("chart-day-sales")) {
  price.chartDaySales = echarts.init(document.getElementById("chart-day-sales"));
  price.chartDaySales.setOption(price.chartDaySalesOption);
}
/*******************************************************************************************************************************/
/******************************************************** 제품별 할인율 및 매출비중 순위 ***************************************************/
price.productDiscountRateAndRevenueShareRankingUpdate = function () {
  let rawData = price.productDiscountRateAndRevenueShareRanking;
  if (price.ProdSalesPercentListGrid) {
    let keysToExtract = ["disc_rank", `item_name_${currency}`, `disc_rate_${currency}`, `amt_rate_${currency}`];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    price.ProdSalesPercentListGrid.updateConfig({ data: filterData }).forceRender();
  }
};
/* 제품별 할인율 및 매출비중 순위 */
if (document.getElementById("ProdSalesPercentList")) {
  price.ProdSalesPercentListGrid = new gridjs.Grid({
    sort: true,
    columns: [
      {
        name: "순위",
        width: "60px",
      },
      {
        name: "제품명",
        width: "400px",
      },
      {
        name: "할인율(%)",
        width: "100px",
      },
      {
        name: "매출 비중",
        width: "100px",
      },
    ],
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
    // function () {
    //   return new Promise(function (resolve) {
    //     setTimeout(function () {
    //       resolve([]);
    //     }, 2000);
    //   });
    // },
  }).render(document.getElementById("ProdSalesPercentList"));
}
/*******************************************************************************************************************************/
// 이벤트 핸들러 함수를 배열로 정의합니다.
price.resizeHandlers = [price.chartWeightAverSales.resize, price.salesDayChart.resize, price.chartDaySales.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
price.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

price.onLoadEvent = function (initData) {
  price.initData = initData;
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

  let fltDailyDate = flatpickr("#fltDailyDate, #discSaleDate", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);
  
        fltDailyDate[0].setDate([fromDate, toDate]);
        fltDailyDate[1].setDate([fromDate, toDate]);
        
        if(instance._positionElement.id == "discSaleDate"){
          let params = {
            params: {
              FR_DT: `'${fromDate}'`,
              TO_DT: `'${toDate}'`,
              PROD_ID: `'${price.priceSbxProduct.getValue().value}'`,
            },
            menu: "dashboards/common",
            tab: "price",
            dataList: ["dailyAverageProductSalesPriceGraph","productDiscountRateAndRevenueShareRanking"],
          };
          getData(params, function (data) {
            price.topFiveCompetingProducts = {};
            if (data["dailyAverageProductSalesPriceGraph"] != undefined) {
              price.dailyAverageProductSalesPriceGraph = data["dailyAverageProductSalesPriceGraph"];
              price.dailyAverageProductSalesPriceGraphUpdate();
            }
            price.topFiveCompetingProducts = {};
            if (data["productDiscountRateAndRevenueShareRanking"] != undefined) {
              price.productDiscountRateAndRevenueShareRanking = data["productDiscountRateAndRevenueShareRanking"];
              price.productDiscountRateAndRevenueShareRankingUpdate();
            }
          });
        }
      }
    },
  });

  let fltWeightDate = flatpickr("#fltWeightDate, #discountDate", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        fltWeightDate[0].setDate([fromDate, toDate]);
        fltWeightDate[1].setDate([fromDate, toDate]);

        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
          },
          menu: "dashboards/common",
          tab: "price",
          dataList: ["weightedAverageSalesPriceTimeSeries"],
        };
        getData(params, function (data) {
          price.weightedAverageSalesPriceTimeSeries = {};
          if (data["weightedAverageSalesPriceTimeSeries"] != undefined) {
            price.weightedAverageSalesPriceTimeSeries = data["weightedAverageSalesPriceTimeSeries"];
            price.weightedAverageSalesPriceTimeSeriesUpdate(); //
          }
        });
      }
    },
  });

  if (document.getElementById("priceSbxProduct")) {
    const priceSbxProduct = document.getElementById("priceSbxProduct");
    if (!price.priceSbxProduct) {
      price.priceSbxProduct = new Choices(priceSbxProduct, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }

  let dataList = [
    "impCardAmtData" /* 중요정보 카드 Data 조회 */,
    "impCardAmtChart" /* 중요정보 그래프 Data 조회 */,
    "weightedAverageSalesPriceTimeSeries" /* 5. 가중평균 판매가 - 시계열 그래프 SQL */,
    "discountRateDays" /* 6. 할인율 발생 일수 - 파이, 하단 리스트 SQL */,
    "dailyAverageProductSalesPriceProd" /* 7. 일자별 제품 평균 판매가 - 제품 선택 SQL */,
    "productDiscountRateAndRevenueShareRanking" /* 8. 제품별 할인율 및 매출비중 순위 - 표 SQL */,
  ];
  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, BASE_YEAR: `'${initData.base_year}'` },
    menu: "dashboards/common",
    tab: "price",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      price[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    price.setDataBinding();
  });

  price.onloadStatus = true; // 화면 로딩 상태
};
