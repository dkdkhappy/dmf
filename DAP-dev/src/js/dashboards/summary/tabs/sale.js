let sale = {};
let currency = "rmb"; // 화면 적용 화폐 test

sale.onloadStatus = false; // 화면 로딩 상태

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
    sale.salesTimeSeriesGraphChartUpdate(); //
  }
  /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */
  if (Object.keys(sale.salesTimeSeriesGraphBottom).length > 0) {
    sale.chartLineSalesBottomUpdate();
  }
  /* 채널별 매출 비중 Break Down - 바 그래프 SQL */
  if (Object.keys(sale.channelSalesBreakDownChart).length > 0) {
    sale.channelSalesBreakDownChartUpdate();
  }
  /* 환불 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 */
  if (Object.keys(sale.refundTimeSeriesGraphData).length > 0) {
    sale.refundTimeSeriesUpdate();
  }
  /* 환불 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */
  if (Object.keys(sale.refundTimeSeriesGraphChart).length > 0) {
    sale.chartLineRefundUpdate(); //
  }
  /* 환불 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */
  if (Object.keys(sale.refundTimeSeriesGraphBottom).length > 0) {
    sale.chartLineRefundBottomUpdate();
  }
  /* 채널별 환불 비중 Break Down - 라인 그래프 SQL */
  if (Object.keys(sale.channelRefundBreakDownChart).length > 0) {
    sale.channelRefundBreakDownChartUpdate();
  }
  /* 채널 내 매출 순위 - Tmall  표 SQL */
  if (Object.keys(sale.channelSalesRankTmall).length > 0) {
    sale.channelSalesRankUpdate();
  }
  if(Object.keys(sale.storeNameTmall).length > 0){
    let params = {
      menu: "dashboards/summary",
      tab: "sales",
      dataList: ["storeNameTmall"],
    };
    getData(params, function (data) {
      Object.keys(data).forEach((key) => {
        sale[key] = data[key];
      });
      sale.storeNameUpdate();
    });
  }
  /* Top5 매출 제품 - 표 SQL */
  if (Object.keys(sale.top5SalesProduct).length > 0) {
    sale.top5SalesProductUpdate();
  }

  /* number counting 처리 */
  counter();
};

/*********************************************************** 상단 카드 **********************************************************************/

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
    "sale_rate_day_yoy",
    "sale_amt_mnth",
    "sale_rate_mnth_yoy",
    "sale_amt_year",
    "sale_rate_year_yoy",
    "refd_amt",
    "refd_rate_day_yoy",
    "refd_amt_mnth",
    "refd_rate_mnth_yoy",
    "refd_amt_year",
    "refd_rate_year_yoy",
    "dct_rank_tot",
    "dgt_rank_tot",
    "dcd_rank_tot",
    "dgd_rank_tot",
    "revn_tagt_amt",
  ];

  cardAreaList.forEach((cardArea) => {
    let el = document.getElementById(`${cardArea}`);
    if (el) {
      if (cardArea.indexOf("_yoy") > -1) {
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
      } else if (cardArea.indexOf("_rank") > -1) {
        const diff_el = document.getElementById(`${cardArea}_diff`);
        const diff_arrow_el = document.getElementById(`${cardArea}_diff_arrow`);
        if (el && diff_el && diff_arrow_el) {
          el.innerText = rawData[`${cardArea}`];
          diff_el.innerText = Math.abs(Number(rawData[`${cardArea}_diff`]));
          if (Number(rawData[`${cardArea}_diff`]) > 0) {
            diff_el.classList.add("plus_mark", "text-success");
            diff_arrow_el.classList.add("ri-arrow-up-line", "text-success");
          } else if (Number(rawData[`${cardArea}_diff`]) < 0) {
            diff_el.classList.add("minus_mark", "text-danger");
            diff_arrow_el.classList.add("ri-arrow-down-line", "text-danger");
          } else {
            diff_el.classList.add("text-muted");
            diff_arrow_el.classList.add("text-muted");
          }
        }
      } else if (cardArea == "revn_tagt_amt") {
        el.innerText = 0;
        el.setAttribute("data-target", rawData[`${cardArea}`]);
      } else {
        el.innerText = 0;
        el.setAttribute("data-target", rawData[`${cardArea}_${currency}`]);
      }
    }
  });

  if (sale.chartRadialTarget) {
    sale.chartRadialTarget.setOption({
      series: [
        {
          type: "pie",
          radius: ["40%", "70%"],
          avoidLabelOverlap: false,
          label: {
            show: true,
            position: "center",
            formatter: '{d}%'
          },
          labelLine: {
            show: false,
          },
          data: [
            {
              value: Number(rawData["revn_tagt_rate"]),
              tooltip: {
                show: true,
                formatter: '{d}%'
              },
              emphasis: {
                scale: true,
                labelLine: {
                  show: false,
                },
              },
            },
            {
              value: 100 - Number(rawData["revn_tagt_rate"]),
              itemStyle: {
                color: "#C0C0C0",
              },
              emphasis: {
                scale: false
              },
              tooltip: {
                show: false,
              },
              label: {show: false},
              selected: false,
            },
          ],
        },
      ],
    });
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

// 중요 정보 카드
sale.options = {
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

sale.areaChart1 = new ApexCharts(document.querySelector("#areaChart1"), sale.options);
sale.areaChart2 = new ApexCharts(document.querySelector("#areaChart2"), sale.options);
sale.areaChart3 = new ApexCharts(document.querySelector("#areaChart3"), sale.options);
sale.areaChart4 = new ApexCharts(document.querySelector("#areaChart4"), sale.options);
sale.areaChart5 = new ApexCharts(document.querySelector("#areaChart5"), sale.options);
sale.areaChart6 = new ApexCharts(document.querySelector("#areaChart6"), sale.options);

sale.areaChart1.render();
sale.areaChart2.render();
sale.areaChart3.render();
sale.areaChart4.render();
sale.areaChart5.render();
sale.areaChart6.render();

/* 당해 Target 대비 누적 매출 비용 */
sale.chartRadialTargetOption = {
  tooltip: {
    trigger: "item",
  },
  legend: {
    top: "2%",
    left: "center",
  },
  grid: {
    bottom: "0",
  },
  series: [],
};
if (document.getElementById("chart-radial-target")) {
  sale.chartRadialTarget = echarts.init(document.getElementById("chart-radial-target"));
  sale.chartRadialTarget.setOption(sale.chartRadialTargetOption);
}

/*******************************************************************************************************************************************/
/************************************************ 매출 정보에 대한 시계열 / 데이터 뷰어 *******************************************************/

/**
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - 상단 카드
 */
sale.salesTimeSeriesUpdate = function () {
  let rawData = sale.salesTimeSeriesGraphData;
  if (document.getElementById("time_series_sale_amt")) {
    document.getElementById("time_series_sale_amt").innerText = 0;
    document.getElementById("time_series_sale_amt").setAttribute("data-target", rawData[0][`sale_amt_year_${currency}`]);
  }

  if (document.getElementById("time_series_sale_amt_yoy")) {
    document.getElementById("time_series_sale_amt_yoy").innerText = 0;
    document.getElementById("time_series_sale_amt_yoy").setAttribute("data-target", rawData[0][`sale_amt_year_yoy_${currency}`]);
  }

  if (document.getElementById("time_series_sale_rate")) {
    document.getElementById("time_series_sale_rate").innerText = 0;
    document.getElementById("time_series_sale_rate").setAttribute("data-target", rawData[0][`sale_rate_year_yoy_${currency}`]);
  }
};

/**
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - echart
 */
sale.salesTimeSeriesGraphChartUpdate = function () {
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

      const dates = [...new Set([...dataArr["SALE"].map(({ x_dt }) => x_dt)])];

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
 * 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 Gridjs
 */

sale.chartLineSalesBottomUpdate = function () {
  if (sale.saleInfoListGrid) {
    let keysToExtract = [
      "row_titl",
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

// zoom 속성
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
/* 매출 정보에 대한 시계열 */
sale.charLineSalesOption = {
  tooltip: {
    trigger: "axis",
    sort: "ascending",
  },
  legend: {
    data: ["결제 금액 - 일매출", "결제금액 - 주매출", "결제금액 - 월매출", "환불제외금액 - 일매출", "환불제외금액 - 주매출", "환불제외금액 - 월매출"],
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
};
sale.chartLineSales = echarts.init(document.getElementById("chart-line-sales"));
sale.chartLineSales.setOption(sale.charLineSalesOption);

/* 매출 정보에 대한 데이터 뷰어saleInfoList */
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
/*******************************************************************************************************************************************/
/*************************************************** 채널별 매출 비중 Break Down *************************************************************/

sale.channelSalesBreakDownChartUpdate = function () {
  let rawData = sale.channelSalesBreakDownChart;
  let cagr = sale.channelSalesBreakDownCagr;

  if (sale.chartBarChannelSalesBreakDown) {
    sale.chartBarChannelSalesBreakDown.setOption(sale.chartBarChannelSalesBreakDownOption, true);
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

      sale.chartBarChannelSalesBreakDownLabel = {
        show: true,
        position: "top",
        offset: [0, -20],
        formatter: function (param) {
          if (param.name == x_dt[x_dt.length - 1]) {
            return "CAGR : " + cagr[0][`cagr_amt_${currency}`];
          } else {
            return "";
          }
        },
        fontSize: 17,
        fontFamily: "Arial",
      };

      sale.chartBarChannelSalesBreakDown.setOption({
        xAxis: {
          type: "category",
          data: x_dt,
        },
        legend: {
          textStyle: {
            color: "#858d98",
          }
        },
        series: [
          {
            name: "Tmall 내륙",
            type: "bar",
            stack: "Ad",
            itemStyle: {
              color: "#5470c6",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCT").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Tmall 글로벌",
            type: "bar",
            stack: "Ad",
            itemStyle: {
              color: "#73c0de",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGT").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Douyin 내륙",
            type: "bar",
            stack: "Ad",
            itemStyle: {
              color: "#91cc75",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCD").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Douyin 글로벌",
            type: "bar",
            stack: "Ad",
            // label: sale.chartBarChannelSalesBreakDownLabel,
            itemStyle: {
              color: "#fac858",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGD").map((item) => item[`y_val_${currency}`]),
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

/* 채널별 매출 비중 Break Down */
sale.chartBarChannelSalesBreakDownOption = {
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
      magicType: {
        type: ["line", "bar", "stack"],
      },
    },
  },
  legend: {},
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
  yAxis: [
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
sale.chartBarChannelSalesBreakDown = echarts.init(document.getElementById("chart-bar-channel-sales-break-down"));
sale.chartBarChannelSalesBreakDown.setOption(sale.chartBarChannelSalesBreakDownOption);
/*******************************************************************************************************************************************/
/**************************************************** 환불 정보에 대한 시계열 *****************************************************************/

/**
 * 환불 정보에 대한 시계열 / 데이터 뷰어 - 상단 카드
 */
sale.refundTimeSeriesUpdate = function () {
  let rawData = sale.refundTimeSeriesGraphData;
  /* 당해 */
  if (document.getElementById("time_series_refund_amt")) {
    document.getElementById("time_series_refund_amt").innerText = 0;
    document.getElementById("time_series_refund_amt").setAttribute("data-target", rawData[0][`refd_amt_year_${currency}`]);
  }

  if (document.getElementById("time_series_refund_amt_yoy")) {
    document.getElementById("time_series_refund_amt_yoy").innerText = 0;
    document.getElementById("time_series_refund_amt_yoy").setAttribute("data-target", rawData[0][`refd_amt_year_yoy_${currency}`]);
  }

  if (document.getElementById("time_series_refund_rate")) {
    document.getElementById("time_series_refund_rate").innerText = 0;
    document.getElementById("time_series_refund_rate").setAttribute("data-target", rawData[0][`refd_rate_year_yoy_${currency}`]);
  }

  /* 전해 */
  if (document.getElementById("time_series_pcnt_amt")) {
    document.getElementById("time_series_pcnt_amt").innerText = 0;
    document.getElementById("time_series_pcnt_amt").setAttribute("data-target", rawData[0][`pcnt_amt_year_${currency}`]);
  }

  if (document.getElementById("time_series_pcnt_amt_yoy")) {
    document.getElementById("time_series_pcnt_amt_yoy").innerText = 0;
    document.getElementById("time_series_pcnt_amt_yoy").setAttribute("data-target", rawData[0][`pcnt_amt_year_yoy_${currency}`]);
  }

  if (document.getElementById("time_series_pcnt_rate")) {
    document.getElementById("time_series_pcnt_rate").innerText = 0;
    document.getElementById("time_series_pcnt_rate").setAttribute("data-target", rawData[0][`pcnt_rate_year_${currency}`]);
  }
};

/**
 * 환불 정보에 대한 시계열 / 데이터 뷰어 - echart
 */
sale.chartLineRefundUpdate = function () {
  if (sale.chartLineRefuned) {
    sale.chartLineRefuned.setOption(sale.charLineRefunedOption, true);
    let rawData = sale.refundTimeSeriesGraphChart;
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

      const dates = [...new Set([...dataArr["REFD"].map(({ x_dt }) => x_dt)])];

      let dayValues = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []],
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
            "주매출": false,
            "월매출": false,
            "주환불": false,
            "월환불": false,
            "주환불비중": false,
            "월환불비중": false,
          },
        },
        dataZoom: sale.zoomSales,
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
  }
};

/**
 * 환불 정보에 대한 시계열 / 데이터 뷰어 - 하단 Gridjs
 */

sale.chartLineRefundBottomUpdate = function () {
  if (sale.refundInfoListGrid) {
    let keysToExtract = [
      "row_titl",
      `refd_amt_01_${currency}`,
      `refd_amt_02_${currency}`,
      `refd_amt_03_${currency}`,
      `refd_amt_04_${currency}`,
      `refd_amt_05_${currency}`,
      `refd_amt_06_${currency}`,
      `refd_amt_07_${currency}`,
      `refd_amt_08_${currency}`,
      `refd_amt_09_${currency}`,
      `refd_amt_10_${currency}`,
      `refd_amt_11_${currency}`,
      `refd_amt_12_${currency}`,
    ];
    let filterData = [];
    for (var i = 0; i < sale.refundTimeSeriesGraphBottom.length; i++) {
      filterData.push(keysToExtract.map((key) => sale.refundTimeSeriesGraphBottom[i][key]));
    }
    sale.refundInfoListGrid.updateConfig({ data: filterData }).forceRender();
  }
};

/* 환불 정보에 대한 시계열 */
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

/* 환불 정보에 대한 데이터 뷰어 */
if (document.getElementById("refundInfoList")) {
  sale.refundInfoListGrid = new gridjs.Grid({
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
  }).render(document.getElementById("refundInfoList"));
}
/*******************************************************************************************************************************************/
/*************************************************** 채널별 환불 비중 Break Down *************************************************************/
sale.channelRefundBreakDownChartUpdate = function () {
  let rawData = sale.channelRefundBreakDownChart;
  if (sale.chartBarChannelRefundBreakDown) {
    sale.chartBarChannelRefundBreakDown.setOption(sale.chartBarChannelRefundBreakDownOption, true);
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];
      sale.chartBarChannelRefundBreakDown.setOption({
        xAxis: {
          type: "category",
          data: x_dt,
        },
        yAxis: {
          max: 100
        },
        legend: {
          textStyle: {
            color: "#858d98",
          }
        },
        series: [
          {
            name: "Tmall 내륙",
            type: "line",
            itemStyle: {
              color: "#5470c6",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCT").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Tmall 글로벌",
            type: "line",
            itemStyle: {
              color: "#73c0de",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGT").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Douyin 내륙",
            type: "line",
            itemStyle: {
              color: "#91cc75",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCD").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "Douyin 글로벌",
            type: "line",
            itemStyle: {
              color: "#fac858",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGD").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: "전체",
            type: "line",
            itemStyle: {
              color: "#e66262",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "ALL").map((item) => item[`y_val_${currency}`]),
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
/* 채널별 환불 비중 Break down */
sale.chartBarChannelRefundBreakDownOption = {
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
  legend: {},
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
  yAxis: [
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
sale.chartBarChannelRefundBreakDown = echarts.init(document.getElementById("chart-bar-channel-refund-break-down"));
sale.chartBarChannelRefundBreakDown.setOption(sale.chartBarChannelRefundBreakDownOption);
/*******************************************************************************************************************************************/
/******************************************************* 채널별 브랜드 등수 *****************************************************************/
sale.searchData = function () {
  let dataList = [];
  let sbxSalesChannelName = document.getElementById("sbxSalesChannelName").value;
  let channelSalesRankingTop300IsMulti = document.getElementById("channelSalesRankingTop300IsMulti");
  if (sbxSalesChannelName == "Tmall") {
    dataList.push("channelSalesRankTmall");
  } else if (sbxSalesChannelName == "Douyin") {
    dataList.push("channelSalesRankDouyin");
  }
  let selStore = sale.selStore.getValue();
  let storeArr = [];
  if (selStore.length > 0) {
    storeArr = sale.selStore.getValue().map((item) => item.value);
  }
  let params = {
    params: {
      FR_MNTH: `'${sale.initData.fr_dt.substring(0, 7)}'`,
      TO_MNTH: `'${sale.initData.to_dt.substring(0, 7)}'`,
      KR_YN: `'${document.getElementById("channelSalesRankingTop300CountryName").value}'`,
      DEMA_YN: `'${document.getElementById("channelSalesRankingTop300IsDerma").value}'`,
      SHOP_ID: `'${storeArr.join(",")}'`,
      MLTI_YN: `'${channelSalesRankingTop300IsMulti.value}'`,
    },
    menu: "dashboards/summary",
    tab: "sales",
    dataList: dataList,
  };
  getData(params, function (data) {
    sale.channelSalesRankTmall = {};
    sale.channelSalesRankDouyin = {};
    if (sbxSalesChannelName == "Tmall") {
      if (data["channelSalesRankTmall"] != undefined) {
        sale.channelSalesRankTmall = data["channelSalesRankTmall"];
      }
    } else if (sbxSalesChannelName == "Douyin") {
      if (data["channelSalesRankDouyin"] != undefined) {
        sale.channelSalesRankDouyin = data["channelSalesRankDouyin"];
      }
    }
    sale.channelSalesRankUpdate();
  });
};

sale.channelSalesRankUpdate = function () {
  let rawData = [];
  let channelValue = document.getElementById("sbxSalesChannelName").value;
  if (channelValue == "Tmall") {
    rawData = sale.channelSalesRankTmall;
  } else if (channelValue == "Douyin") {
    rawData = sale.channelSalesRankDouyin;
  }
  if (sale.channelList) {
    let keysToExtract = ["shop_rank", "shop_nm", "sale_rate", "natn_nm", "dema_yn"];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    sale.channelList.updateConfig({ data: filterData }).forceRender();
  }
};

if (document.getElementById("sbxSalesChannelName")) {
  let sbxSalesChannelName = document.getElementById("sbxSalesChannelName");
  sbxSalesChannelName.addEventListener("change", function (val) {
    let dataList = [];
    if(this.value == "Tmall"){
      dataList = ["storeNameTmall"];
    } else if(this.value == "Douyin") {
      dataList = ["storeNameDouyin"];
    }
    let params = {
      menu: "dashboards/summary",
      tab: "sales",
      dataList: dataList,
    };
    getData(params, function (data) {
      Object.keys(data).forEach((key) => {
        sale[key] = data[key];
      });
      sale.storeNameUpdate();
    });
  });
}

/**
 * 채널별 브랜드 등수 - 상점명 선택
 */
sale.storeNameUpdate = function () {
  if (document.getElementById("channelSalesRankingTop300Brand")) {
    storeList = [];
    let channelValue = document.getElementById("sbxSalesChannelName").value;
    storeList.push({ value: "", label: "상점명을 선택하세요." });
    if(channelValue == "Tmall"){
      sale.storeNameTmall.forEach((store) => {
        storeList.push({ value: store.shop_id, label: store.shop_nm });
      });
    } else if(channelValue == "Douyin"){
      sale.storeNameDouyin.forEach((store) => {
        storeList.push({ value: store.shop_id, label: store.shop_nm });
      });
    }
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
/* 채널별 브랜드 등수 */
if (document.getElementById("channelList")) {
  sale.channelList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "100px",
      },
      {
        name: "상점명",
        width: "300px",
      },
      {
        name: "거래지수",
        width: "140px",
      },
      {
        name: "국가",
        width: "100px",
      },
      {
        name: "더마여부",
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
    data: function () {
      return new Promise(function (resolve) {
        setTimeout(function () {
          resolve([
            ["1", "XXX", "XXX", "10000", "한국", "O"],
            ["2", "XXX", "XXX", "10000", "중국", "O"],
            ["3", "XXX", "XXX", "10000", "중국", "O"],
          ]);
        }, 2000);
      });
    },
  }).render(document.getElementById("channelList"));
}
/*******************************************************************************************************************************************/
/*********************************************************** TOP5 매출 상품 *****************************************************************/
sale.top5SalesProductUpdate = function () {
  let rawData = sale.top5SalesProduct;
  if (sale.top5SaleList) {
    let keysToExtract = ["sale_rank", `prod_nm_${currency}`, `sale_amt_${currency}`, `sale_rate_${currency}`, `t_sale_rate_${currency}`, `d_sale_rate_${currency}`];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    sale.top5SaleList.updateConfig({ data: filterData }).forceRender();
  }
};
/* TOP5 매출 상품 */
if (document.getElementById("top5SaleList")) {
  sale.top5SaleList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "75px",
      },
      {
        name: "제품명",
        width: "240px",
      },
      {
        name: "매출액",
        width: "180px",
      },
      {
        name: "매출기여(%)",
        width: "100px",
      },
      {
        name: "Tmall 매출 비중",
        width: "100px",
      },
      {
        name: "Douyin 매출 비중",
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
    data: [],
  }).render(document.getElementById("top5SaleList"));
}
/*******************************************************************************************************************************************/
/****************************************************** TOP5 환불 제품 (환불 기준) ***********************************************************/

/* TOP5 환불 제품 (환불 기준) */
if (document.getElementById("top5RefundList")) {
  new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "70px",
      },
      {
        name: "제품명",
        width: "320px",
      },
      {
        name: "환불액",
        width: "180px",
      },
      {
        name: "매출 대비 환불 비중",
        width: "150px",
      },
      {
        name: "Tmall 매출 대비 환불 비중",
        width: "200px",
      },
      {
        name: "Douyin 매출 대비 환불 비중",
        width: "200px",
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
            ["1", "XXX", "10000", "10", "한국", "O"],
            ["2", "XXX", "10000", "20", "중국", "O"],
            ["3", "XXX", "10000", "30", "한국", "O"],
            ["4", "XXX", "10000", "40", "한국", "O"],
            ["5", "XXX", "10000", "50", "한국", "O"],
          ]);
        }, 2000);
      });
    },
  }).render(document.getElementById("top5RefundList"));
}
/*******************************************************************************************************************************************/
/************************************************** TOP5 환불 제품 (매출 대비 환불 기준) ******************************************************/
/* TOP5 환불 제품 (매출 대비 환불 기준) */
if (document.getElementById("top5SalesRefundList")) {
  new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "70px",
      },
      {
        name: "제품명",
        width: "320px",
      },
      {
        name: "환불액",
        width: "180px",
      },
      {
        name: "매출 대비 환불 비중",
        width: "150px",
      },
      {
        name: "Tmall 매출 대비 환불 비중",
        width: "200px",
      },
      {
        name: "Douyin 매출 대비 환불 비중",
        width: "200px",
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
            ["1", "XXX", "10000", "10", "한국", "O"],
            ["2", "XXX", "10000", "20", "중국", "O"],
            ["3", "XXX", "10000", "30", "한국", "O"],
            ["4", "XXX", "10000", "40", "한국", "O"],
            ["5", "XXX", "10000", "50", "한국", "O"],
          ]);
        }, 2000);
      });
    },
  }).render(document.getElementById("top5SalesRefundList"));
}
/*******************************************************************************************************************************************/

sale.updateButtonStyle = function (name, type) {
  let buttonClasses = {
    금액: ["error", "btn-soft-primary", "btn-primary"],
    "100%": ["nomal", "btn-soft-success", "btn-success"],
  };

  if (typeof type == "object") {
    if (type[0].indexOf("1") > 0) {
      buttonClasses["금액"].push("exponent1");
      buttonClasses["100%"].push("percent1");
    } else if (type[0].indexOf("2") > 0) {
      buttonClasses["금액"].push("exponent2");
      buttonClasses["100%"].push("percent2");
    }
  }
  Object.entries(buttonClasses).forEach(([key, classes]) => {
    if (type == "all") {
      const button = document.querySelectorAll(`.${classes[0]}`);
      button.forEach(function (btn) {
        if (btn) {
          if (key !== name) {
            btn.classList.remove(classes[2]);
            btn.classList.add(classes[1]);
          } else {
            btn.classList.remove(classes[1]);
            btn.classList.add(classes[2]);
          }
        }
      });
    } else {
      const button = document.querySelector(`.${classes[3]}`);
      if (button) {
        if (key !== name) {
          button.classList.remove(classes[2]);
          button.classList.add(classes[1]);
        } else {
          button.classList.remove(classes[1]);
          button.classList.add(classes[2]);
        }
      }
    }
  });
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

  // 매출 정보에 대한 시계열 - flatpickr 이벤트
  flatpickr("#salesTimeSeriesViewer", {
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
          menu: "dashboards/summary",
          tab: "sales",
          dataList: ["salesTimeSeriesGraphChart"],
        };
        getData(params, function (data) {
          sale.salesTimeSeriesGraphChart = {};
          /* 7. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
          if (data["salesTimeSeriesGraphChart"] != undefined) {
            sale.salesTimeSeriesGraphChart = data["salesTimeSeriesGraphChart"];
            sale.salesTimeSeriesGraphChartUpdate();
          }
        });
      }
    },
  });

  flatpickr("#salesChannelSalesBreakDownViewer", {
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
    defaultDate: [`${initData.fr_dt}`, `${initData.to_dt}`],
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        let params = {
          params: {
            FR_MNTH: `'${fromDate.substring(0, 7)}'`,
            TO_MNTH: `'${toDate.substring(0, 7)}'`,
            CHRT_TYPE: `'AMT'`,
          },
          menu: "dashboards/summary",
          tab: "sales",
          dataList: ["channelSalesBreakDownCagr", "channelSalesBreakDownChart"],
        };
        getData(params, function (data) {
          sale.channelSalesBreakDownChart = {};
          /* 7. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
          if (data["channelSalesBreakDownChart"] != undefined) {
            sale.channelSalesBreakDownChart = data["channelSalesBreakDownChart"];
            sale.channelSalesBreakDownChartUpdate();
          }
        });
      }
    },
  });

  flatpickr("#refundTimeSeriesViewer", {
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
    defaultDate: [`${initData.fr_dt}`, `${initData.to_dt}`],
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        let params = {
          params: {
            FR_MNTH: `'${fromDate.substring(0, 7)}'`,
            TO_MNTH: `'${toDate.substring(0, 7)}'`,
            CHRT_TYPE: `'AMT'`,
          },
          menu: "dashboards/summary",
          tab: "sales",
          dataList: ["channelRefundBreakDownChart"],
        };
        getData(params, function (data) {
          sale.channelRefundBreakDownChart = {};
          /* 7. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
          if (data["channelRefundBreakDownChart"] != undefined) {
            sale.channelRefundBreakDownChart = data["channelRefundBreakDownChart"];
            sale.channelRefundBreakDownChartUpdate();
          }
        });
      }
    },
  });

  flatpickr("#channelRefundBreakDownViewer", {
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
    defaultDate: [`${initData.fr_dt}`, `${initData.to_dt}`],
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        let params = {
          params: {
            FR_MNTH: `'${fromDate.substring(0, 7)}'`,
            TO_MNTH: `'${toDate.substring(0, 7)}'`,
            CHRT_TYPE: `'AMT'`,
          },
          menu: "dashboards/summary",
          tab: "sales",
          dataList: ["channelRefundBreakDownChart"],
        };
        getData(params, function (data) {
          sale.channelRefundBreakDownChart = {};
          /* 7. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 */
          if (data["channelRefundBreakDownChart"] != undefined) {
            sale.channelRefundBreakDownChart = data["channelRefundBreakDownChart"];
            sale.channelRefundBreakDownChartUpdate();
          }
        });
      }
    },
  });

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

  let btnSm = document.querySelectorAll(".btn-smy-sales");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let chrtType = chkTxt == "금액" ? "AMT" : "RATE";
      let classList = this.classList.value.split(" ");
      let dataList = [];
      let datePicker;
      if (classList[0].indexOf("1") > 0) {
        dataList = ["channelSalesBreakDownCagr", "channelSalesBreakDownChart"];
        datePicker = document.getElementById("salesChannelSalesBreakDownViewer");
      } else if (classList[0].indexOf("2") > 0) {
        dataList = ["channelRefundBreakDownChart"];
        datePicker = document.getElementById("channelRefundBreakDownViewer");
      }

      sale.updateButtonStyle(chkTxt, classList);
      let params = {
        params: {
          FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
          TO_MNTH: `'${datePicker.value.slice(-7)}'`,
          CHRT_TYPE: `'${chrtType}'`,
        },
        menu: "dashboards/summary",
        tab: "sales",
        dataList: dataList,
      };
      getData(params, function (data) {
        if (classList[0].indexOf("1") > 0) {
          sale.channelSalesBreakDownChart = data["channelSalesBreakDownChart"];
          sale.channelSalesBreakDownChartUpdate();
        } else if (classList[0].indexOf("2") > 0) {
          sale.channelRefundBreakDownChart = data["channelRefundBreakDownChart"];
          sale.channelRefundBreakDownChartUpdate();
        }
      });
    });
  });

  let dataList = [
    "impCardAmtData" /* 중요정보 카드 Data 조회 */,
    "impCardAmtChart" /* 중요정보 그래프 Data 조회 */,
    "salesTimeSeriesGraphData" /* 중요정보 그래프 Data 조회 */,
    "salesTimeSeriesGraphChart" /* 매출 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */,
    "salesTimeSeriesGraphBottom" /* 매출 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */,
    "channelSalesBreakDownCagr" /* 7. 채널별 매출 비중 Break Down - CAGR SQL */,
    "channelSalesBreakDownChart" /* 7. 채널별 매출 비중 Break Down - 바 그래프 SQL */,
    "refundTimeSeriesGraphData" /* 환불 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보 SQL */,
    "refundTimeSeriesGraphChart" /* 환불 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */,
    "refundTimeSeriesGraphBottom" /* 환불 정보에 대한 시계열 / 데이터 뷰어 - 하단 그리드 */,
    "channelRefundBreakDownChart" /* 11. 채널별 환불 비중 Break Down - 라인 그래프 SQL */,
    "storeNameTmall" /* 12. 채널 내 매출 순위 티몰 - 상점명 선택 SQL */,
    "storeNameDouyin" /* 12. 채널 내 매출 순위 도우인 - 상점명 선택 SQL */,
    "channelSalesRankTmall" /* 12. 채널 내 매출 순위 - Tmall  표 SQL */,
    "top5SalesProduct" /* 13. Top5 매출 제품 - 표 SQL */,
  ];
  let params = {
    params: {
      FR_DT: `'${initData.fr_dt}'`,
      TO_DT: `'${initData.to_dt}'`,
      FR_MNTH: `'${initData.fr_dt.substring(0, 7)}'`,
      TO_MNTH: `'${initData.to_dt.substring(0, 7)}'`,
      BASE_MNTH: `'${initData.base_mnth}'`,
      BASE_YEAR: `'${initData.base_year}'`,
      CHRT_TYPE: `'AMT'`,
      KR_YN: `'${document.getElementById("channelSalesRankingTop300CountryName").value}'`,
      DEMA_YN: `'${document.getElementById("channelSalesRankingTop300IsDerma").value}'`,
      SHOP_ID: `''`,
      MLTI_YN: `'%'`,
    },
    menu: "dashboards/summary",
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
    sale.updateButtonStyle("금액", "all");
    sale.setDataBinding();
  });

  sale.onloadStatus = true; // 화면 로딩 상태
};

// 이벤트 핸들러 함수를 배열로 정의합니다.
sale.resizeHandlers = [sale.chartRadialTarget.resize, sale.chartLineSales.resize, sale.chartBarChannelSalesBreakDown.resize, sale.chartLineRefuned.resize, sale.chartBarChannelRefundBreakDown.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
sale.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});
