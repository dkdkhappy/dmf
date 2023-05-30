let price = {};
price.onloadStatus = false; // 화면 로딩 상태

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

  /* 1. 티몰 할인율 분석 - 시계열 그래프 SQL */
  if (Object.keys(price.discountRateAnalysisTmall).length > 0) {
    price.discountRateAnalysisTmallUpdate();
  }
  /* 2. 도우인 할인율 분석 - 시계열 그래프 SQL */
  if (Object.keys(price.discountRateAnalysisDouyin).length > 0) {
    price.discountRateAnalysisDouyinUpdate();
  }
  /* 3. 월별 할인현황 - 표 SQL */
  if (Object.keys(price.monthlyDiscountStatus).length > 0) {
    price.monthlyDiscountStatusUpdate();
  }
  /* 4. 전 채널 기준 제품별 할인율 - 표 SQL */
  if (Object.keys(price.discountRateByChannel).length > 0) {
    price.discountRateByChannelUpdate();
  }
};

/******************************************************* 티몰 할인율 분석 *******************************************************************/
price.discountRateAnalysisTmallUpdate = function () {
  let rawData = price.discountRateAnalysisTmall;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (price.chartLineTmallDiscRate) {
    price.chartLineTmallDiscRate.setOption(price.chartLineTmallDiscRateOption, true);
    if (rawData.length > 0) {
      price.chartLineTmallDiscRate.setOption({
        legend: {
          data: ["가중평균 판매가", "가중평균 정가", "정가 대비 50프로", "정가 대비 30프로"],
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

/* 티몰 할인율 분석 그래프 */
price.chartLineTmallDiscRateOption = {
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
price.chartLineTmallDiscRate = echarts.init(document.getElementById("chart-line-tmall-disc-rate"));
price.chartLineTmallDiscRate.setOption(price.chartLineTmallDiscRateOption);

/*******************************************************************************************************************************************/
/******************************************************* 도우인 할인율 분석 *******************************************************************/
price.discountRateAnalysisDouyinUpdate = function () {
  let rawData = price.discountRateAnalysisDouyin;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (price.chartLineDouyinDiscRate) {
    price.chartLineDouyinDiscRate.setOption(price.chartLineDouyinDiscRateOption, true);
    if (rawData.length > 0) {
      price.chartLineDouyinDiscRate.setOption({
        legend: {
          data: ["가중평균 판매가", "가중평균 정가", "정가 대비 50프로", "정가 대비 30프로"],
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
/* 도우인 할인율 분석 그래프 */
price.chartLineDouyinDiscRateOption = {
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
price.chartLineDouyinDiscRate = echarts.init(document.getElementById("chart-line-douyin-disc-rate"));
price.chartLineDouyinDiscRate.setOption(price.chartLineDouyinDiscRateOption);

/********************************************************************************************************************************************/
/******************************************************* 월별 할인현황 *******************************************************************/
price.monthlyDiscountStatusUpdate = function () {
  let rawData = price.monthlyDiscountStatus;
  if (price.monthDiscountList) {
    let keysToExtract = ["titl_mnth", "titl_nm", `all_cnt_${currency}`, `dct_cnt_${currency}`, `dgt_cnt_${currency}`, `dcd_cnt_${currency}`, `dgd_cnt_${currency}`];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    // 동일한 셀 값을 찾고, rowspan을 설정
    let preData = "";
    price.monthDiscountList
      .updateConfig({
        columns: [
          {
            name: "월",
            width: "100px",
            // Render 함수를 사용하여 rowspan 설정
            attributes: (cell, row, column) => {
              // add these attributes to the td elements only
              if (cell) {
                let res = {};
                if (preData == cell) {
                  res = { style: "display: none" };
                } else {
                  res = { rowspan: rawData.filter((item) => item.titl_mnth == cell).length };
                }
                preData = cell;
                return res;
              }
            },
          },
          {
            name: "할인율 구간",
            width: "120px",
          },
          {
            name: "전체",
            width: "120px",
          },
          {
            name: "Tmall Global",
            width: "120px",
          },
          {
            name: "Tmall China",
            width: "120px",
          },
          {
            name: "Douyin Global",
            width: "120px",
          },
          {
            name: "Douyin China",
            width: "120px",
          },
        ],
        data: filterData,
      })
      .forceRender();
  }
};
/* 월별 할인현황 데이터 뷰어 */
if (document.getElementById("monthDiscountList")) {
  price.monthDiscountList = new gridjs.Grid({
    columns: [
      {
        name: "월",
        width: "100px",
      },
      {
        name: "할인율 구간",
        width: "120px",
      },
      {
        name: "전체",
        width: "120px",
      },
      {
        name: "Tmall Global",
        width: "120px",
      },
      {
        name: "Tmall China",
        width: "120px",
      },
      {
        name: "Douyin Global",
        width: "120px",
      },
      {
        name: "Douyin China",
        width: "120px",
      },
    ],
    language,
    pagination: {
      limit: 12,
    },
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
  }).render(document.getElementById("monthDiscountList"));
}
/***************************************************************************************************************************************/
/******************************************************* 전 채널 기준 제품별 할인율 *******************************************************************/
price.discountRateByChannelUpdate = function () {
  let rawData = price.discountRateByChannel;
  if (price.allChannelProdList) {
    let keysToExtract = [
      "sale_rank",
      `prod_nm_${currency}`,
      `d_rate_${currency}`,
      `all_rate_${currency}`,
      `dct_d_rate_${currency}`,
      `dgt_d_rate_${currency}`,
      `dcd_d_rate_${currency}`,
      `dgd_d_rate_${currency}`,
    ];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    price.allChannelProdList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 전 채널 기준 제품별 할인율 */
if (document.getElementById("allChannelProdList")) {
  price.allChannelProdList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "100px",
      },
      {
        name: "제품명",
        width: "340px",
      },
      {
        name: "전 채널 할인율",
        width: "120px",
      },
      {
        name: "전 채널 매출 비중",
        width: "120px",
      },
      {
        name: "Tmall Global",
        width: "120px",
      },
      {
        name: "Tmall China",
        width: "120px",
      },
      {
        name: "Douyin Global",
        width: "120px",
      },
      {
        name: "Douyin China",
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
    data: [],
  }).render(document.getElementById("allChannelProdList"));
}
/****************************************************************************************************************************************************/

// 이벤트 핸들러 함수를 배열로 정의합니다.
price.resizeHandlers = [price.chartLineTmallDiscRate.resize, price.chartLineDouyinDiscRate.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
price.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

// 로드 시 이벤트 발생
price.onLoadEvent = function (initData) {
  flatpickr("#tmallDiscRateFlatpickr", {
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
          tab: "price",
          dataList: ["discountRateAnalysisTmall"],
        };
        getData(params, function (data) {
          price.discountRateAnalysisTmall = {};
          if (data["discountRateAnalysisTmall"] != undefined) {
            price.discountRateAnalysisTmall = data["discountRateAnalysisTmall"];
            price.discountRateAnalysisTmallUpdate();
          }
        });
      }
    },
  });

  flatpickr("#douyinDiscRateFlatpickr", {
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
          tab: "price",
          dataList: ["discountRateAnalysisDouyin"],
        };
        getData(params, function (data) {
          price.discountRateAnalysisDouyin = {};
          if (data["discountRateAnalysisDouyin"] != undefined) {
            price.discountRateAnalysisDouyin = data["discountRateAnalysisDouyin"];
            price.discountRateAnalysisDouyinUpdate(); //
          }
        });
      }
    },
  });

  let dataList = [
    "discountRateAnalysisTmall" /* 1. 티몰 할인율 분석 - 시계열 그래프 SQL */,
    "discountRateAnalysisDouyin" /* 2. 도우인 할인율 분석 - 시계열 그래프 SQL */,
    "monthlyDiscountStatus" /* 3. 월별 할인현황 - 표 SQL */,
    "discountRateByChannel" /* 4. 전 채널 기준 제품별 할인율 - 표 SQL */,
  ];
  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, BASE_YEAR: `'${initData.base_year}'` },
    menu: "dashboards/summary",
    tab: "price",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      price[key] = data[key];
    });
    price.setDataBinding();
  });

  price.onloadStatus = true; // 화면 로딩 상태
};
