let funnel = {};
funnel.onloadStatus = false; // 화면 로딩 상태

funnel.setDataBinding = function () {
  /* 제품 정보 */
  if (Object.keys(funnel.product).length > 0) {
    funnel.productUpdate("all");
  }
  /* 1. Unique Visitor (UV) - 시계열 그래프 SQL */
  if (Object.keys(funnel.channelImpression).length > 0) {
    funnel.channelImpressionUpdate();
  }
  /* 2. Unique Visitor (UV) 추이 분석 - 표 SQL */
  if (Object.keys(funnel.yearlyChannelImpression).length > 0) {
    funnel.yearlyChannelImpressionUpdate();
  }
  /* 3. 채널 클릭한 사람 수 (중복 제외) - 표 SQL */
  if (Object.keys(funnel.channelClickPerson).length > 0) {
    funnel.channelClickPersonUpdate();
  }
  /* 4. 당해 연도 채널 클릭한 사람수 (중복제외) - 표 SQL */
  if (Object.keys(funnel.yearlyChannelClickPerson).length > 0) {
    funnel.yearlyChannelClickPersonUpdate();
  }
  /* 5. 채널 클릭한 수 - 시계열 그래프 SQL */
  if (Object.keys(funnel.channelClick).length > 0) {
    funnel.channelClickUpdate();
  }
  /* 6. 당해 연도 채널 클릭한 수 - 표 SQL */
  if (Object.keys(funnel.yearlyChannelClick).length > 0) {
    funnel.yearlyChannelClickUpdate();
  }
  /* 7. 채널 노출 당 클릭한 수 - 시계열 그래프  SQL */
  if (Object.keys(funnel.channelClickPerImpress).length > 0) {
    funnel.channelClickPerImpressUpdate();
  }
  /* 8. 채널 클릭 전환율 - 시계열 그래프 SQL */
  if (Object.keys(funnel.channelClickConversionRate).length > 0) {
    funnel.channelClickConversionRateUpdate();
  }
  /* 13. 채널 퍼널분석 - 퍼널 그래프 SQL */
  if (Object.keys(funnel.channelFunnelAnalysis).length > 0) {
    funnel.channelFunnelAnalysisUpdate();
  }
  /* 14. 채널 전환율 분석 - 표 SQL */
  if (Object.keys(funnel.channelConversionRateAnalysis).length > 0) {
    funnel.channelConversionRateAnalysisUpdate();
  }
  /* 15. 당해 연도 채널 구매전환율 - 표 SQL */
  if (Object.keys(funnel.yearlyChannelPurchaseConversionRate).length > 0) {
    funnel.yearlyChannelPurchaseConversionRateUpdate();
  }
  /* 16. 검색경로 라이브 퍼널분석 - 퍼널 그래프 SQL */
  if (Object.keys(funnel.channelFunnelSearchAnalysis).length > 0) {
    funnel.channelFunnelSearchAnalysisUpdate();
  }
  /* 17. 검색경로 라이브 전환율 분석 - 표 SQL */
  if (Object.keys(funnel.channelSearchConversionRateAnalysis).length > 0) {
    funnel.channelSearchConversionRateAnalysisUpdate();
  }
  /* 18. 검색경로 라이브 전환율 분석 - 표 SQL */
  if (Object.keys(funnel.yearlyChannelSearchPurchaseConversionRate).length > 0) {
    funnel.yearlyChannelSearchPurchaseConversionRateUpdate();
  }

  /* 19. 쇼핑 추천 라이브 퍼널분석 - 퍼널 그래프 SQL */
  if (Object.keys(funnel.channelFunnelShopRecAnalysis).length > 0) {
    funnel.channelFunnelShopRecAnalysisUpdate();
  }
  /* 20. 쇼핑 추천 라이브 전환율 분석 - 표 SQL */
  if (Object.keys(funnel.channelShopRecConversionRateAnalysis).length > 0) {
    funnel.channelShopRecConversionRateAnalysisUpdate();
  }
  /* 21. 쇼핑 추천 라이브 전환율 분석 - 표 SQL */
  if (Object.keys(funnel.yearlyChannelShopRecPurchaseConversionRate).length > 0) {
    funnel.yearlyChannelShopRecPurchaseConversionRateUpdate();
  }
  /* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */
  if (Object.keys(funnel.productPCCRCumulativeYoY).length > 0) {
    funnel.productPCCRCumulativeYoYUpdate();
  }

  // /* 21. 쇼핑 추천 라이브 전환율 분석 - 퍼널 그래프 SQL */
  // if (Object.keys(funnel.productFunnelShopRecAnalysis).length > 0) {
  //   funnel.productFunnelShopRecAnalysisUpdate();
  // }

  /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  if (Object.keys(funnel.storeFunnelMetricYoY).length > 0) {
    funnel.storeFunnelMetricYoYUpdate();
  }
  /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  if (Object.keys(funnel.storeFunnelMetricWek).length > 0) {
    funnel.storeFunnelMetricWekUpdate();
  }
  /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  if (Object.keys(funnel.storeFunnelMetricMon).length > 0) {
    funnel.storeFunnelMetricMonUpdate();
  }
  /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  if (Object.keys(funnel.storeFunnelMetricMoM).length > 0) {
    funnel.storeFunnelMetricMoMUpdate();
  }
  /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  if (Object.keys(funnel.productFunnelMetricWek).length > 0) {
    funnel.productFunnelMetricWekUpdate();
  }


  // /* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 방문자 TOP 5 */
  // if (Object.keys(funnel.productVisitorsCumulativeVisitorsYoY).length > 0) {
  //   funnel.productVisitorsCumulativeVisitorsYoYUpdate();
  // }
  // /* 5. Page View (PV) - 시계열 그래프 SQL */
  // if (Object.keys(funnel.channelPageViews).length > 0) {
  //   funnel.channelPageViewsUpdate();
  // }
  // /* 6. Page View (PV) 추이 분석 - 표 SQL */
  // if (Object.keys(funnel.yearlyChannelPageViews).length > 0) {
  //   funnel.yearlyChannelPageViewsUpdate();
  // }
  // /* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */
  // if (Object.keys(funnel.productPageViewsCumulativePageViewsYoY).length > 0) {
  //   funnel.productPageViewsCumulativePageViewsYoYUpdate();
  // }
  // /* 9. 체널 Unique Visitor (UV) 당 Page View (PV) - 시계열 그래프 SQL */
  // if (Object.keys(funnel.pageViewsPerChannelVisitor).length > 0) {
  //   funnel.pageViewsPerChannelVisitorUpdate();
  // }
  // /* 10. Unique Visitor (UV) 당 Page View (PV) 추이 분석 - 표 SQL */
  // if (Object.keys(funnel.pageViewsPerYearlyChannelVisitor).length > 0) {
  //   funnel.pageViewsPerYearlyChannelVisitorUpdate();
  // }
  // /* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */
  // if (Object.keys(funnel.pagesPerProductVisitorCumulativePagesPerVisitorYoY).length > 0) {
  //   funnel.pagesPerProductVisitorCumulativePagesPerVisitorYoYUpdate();
  // }
  // /* 13. 채널 퍼널분석 - 퍼널 그래프 SQL */
  // if (Object.keys(funnel.channelFunnelAnalysis).length > 0) {
  //   funnel.channelFunnelAnalysisUpdate();
  // }
  // /* 14. 채널 전환율 분석 - 표 SQL */
  // if (Object.keys(funnel.channelConversionRateAnalysis).length > 0) {
  //   funnel.channelConversionRateAnalysisUpdate();
  // }
  // /* 15. 당해 연도 채널 구매전환율 - 표 SQL */
  // if (Object.keys(funnel.yearlyChannelPurchaseConversionRate).length > 0) {
  //   funnel.yearlyChannelPurchaseConversionRateUpdate();
  // }

  // /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
  // if (Object.keys(funnel.storeFunnelMetricYoY).length > 0) {
  //   funnel.storeFunnelMetricYoYUpdate();
  // }
};

funnel.productUpdate = function (type) {
  let rawData = funnel.product;
  let prodList = [];
  rawData.forEach((product) => {
    prodList.push({ value: product.prod_id, label: product.prod_nm });
  });
  if (funnel.funnelProductSelect1 && (type == "all" || type == "funnelProductVisitDatepicker")) {
    funnel.funnelProductSelect1.clearChoices();
    //funnel.funnelProductSelect1.removeActiveItems();
    funnel.funnelProductSelect1.setChoices(prodList, "value", "label", true);
  }
  if (funnel.funnelProductSelect2 && (type == "all" || type == "funnelProdPageViewDatePicker")) {
    funnel.funnelProductSelect2.clearChoices();
    //funnel.funnelProductSelect2.removeActiveItems();
    funnel.funnelProductSelect2.setChoices(prodList, "value", "label", true);
  }
  if (funnel.funnelProductSelect3 && (type == "all" || type == "funnelProdVisitPageViewDatepicker")) {
    funnel.funnelProductSelect3.clearChoices();
    //funnel.funnelProductSelect3.removeActiveItems();
    funnel.funnelProductSelect3.setChoices(prodList, "value", "label", true);
  }
  if (funnel.funnelProductSelect4 && (type == "all" || type == "funnelProdFunnelDatepicker")) {
    funnel.funnelProductSelect4.clearChoices();
    //funnel.funnelProductSelect4.removeActiveItems();
    funnel.funnelProductSelect4.setChoices(prodList, "value", "label", true);
  }
  if (funnel.funnelProductSelect5 && (type == "all" || type == "funnelProdFunnelMetricsDatepicker")) {
    funnel.funnelProductSelect5.clearChoices();
    //funnel.funnelProductSelect5.removeActiveItems();
    funnel.funnelProductSelect5.setChoices(prodList, "value", "label", true);
  }

  /* 라이브 별 퍼널 분석 */
  if (funnel.funnelProductShopRecSelect && (type == "all" || type == "funnelProdFunnlShopRecDatepicker")) {
    funnel.funnelProductShopRecSelect.clearChoices();
    //funnel.funnelProductShopRecSelect.removeActiveItems();
    funnel.funnelProductShopRecSelect.setChoices(prodList, "value", "label", true);
  }
  
};

/********************************************** 채널 노출수 (중복제외) **********************************************/
funnel.channelImpressionUpdate = function () {
  let rawData = funnel.channelImpression;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineFunnel) {
    funnel.chartLineFunnel.setOption(funnel.chartLineFunnelOption, true);
    if (rawData.length > 0) {
      funnel.chartLineFunnel.setOption({
        xAxis: {
          data: lgnd,
        },
        yAxis: [
          {
            type: "value",
            name: "채널 노출 (단위 : 회)",
            nameTextStyle: {
              padding: [0,0,0,-40]
            }
          },
        ],
        series: [
          {
            type: "line",
            connectNulls: true,
            data: rawData.map((item) => item["y_val"]),
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

// zoom 속성
funnel.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

/* 채널 방문자 시계열 그래프 */
funnel.chartLineFunnelOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-funnel")) {
  funnel.chartLineFunnel = echarts.init(document.getElementById("chart-line-funnel"));
  funnel.chartLineFunnel.setOption(funnel.chartLineFunnelOption);
}


/********************************************** 채널 클릭한 사람 수 (중복제외) **********************************************/
funnel.channelClickPersonUpdate = function () {
  let rawData = funnel.channelClickPerson;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineFunnelClickPerson) {
    funnel.chartLineFunnelClickPerson.setOption(funnel.chartLineFunnelClickPersonOption, true);
    if (rawData.length > 0) {
      funnel.chartLineFunnelClickPerson.setOption({
        xAxis: {
          data: lgnd,
        },
        yAxis: [
          {
            type: "value",
            name: "클릭한 사람 수 (단위 : 명)",
            nameTextStyle: {
              padding: [0,0,0,20]
            }
          },
        ],
        series: [
          {
            type: "line",
            connectNulls: true,
            data: rawData.map((item) => item["y_val"]),
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

// zoom 속성
funnel.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

/* 채널 방문자 시계열 그래프 */
funnel.chartLineFunnelClickPersonOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-funnel-click-person")) {
  funnel.chartLineFunnelClickPerson = echarts.init(document.getElementById("chart-line-funnel-click-person"));
  funnel.chartLineFunnelClickPerson.setOption(funnel.chartLineFunnelClickPersonOption);
}


/*************************************************************************************************************/
/********************************************** 당해 연도 채널 클릭한 사람 수 (중복제외) **********************************************/

funnel.yearlyChannelClickPersonUpdate = function () {
  let rawData = funnel.yearlyChannelClickPerson;
  let keysToExtract = [
    "row_titl",
    "vist_cnt_01",
    "vist_cnt_02",
    "vist_cnt_03",
    "vist_cnt_04",
    "vist_cnt_05",
    "vist_cnt_06",
    "vist_cnt_07",
    "vist_cnt_08",
    "vist_cnt_09",
    "vist_cnt_10",
    "vist_cnt_11",
    "vist_cnt_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelClickPersionList) {
    funnel.channelClickPersionList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 노출 데이터 뷰어 */
if (document.getElementById("channelClickPersionList")) {
  funnel.channelClickPersionList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelClickPersionList"));
}
/*************************************************************************************************************/
/********************************************** 채널 클릭 수 (중복제외) **********************************************/
funnel.channelClickUpdate = function () {
  let rawData = funnel.channelClick;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineFunnelClick) {
    funnel.chartLineFunnelClick.setOption(funnel.chartLineFunnelClickOption, true);
    if (rawData.length > 0) {
      funnel.chartLineFunnelClick.setOption({
        xAxis: {
          data: lgnd,
        },
        yAxis: [
          {
            type: "value",
            name: "채널 클릭 수 (단위 : 클릭)",
            nameTextStyle: {
              padding: [0,0,0,20]
            }
          },
        ],
        series: [
          {
            type: "line",
            connectNulls: true,
            data: rawData.map((item) => item["y_val"]),
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

// zoom 속성
funnel.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

/* 채널 방문자 시계열 그래프 */
funnel.chartLineFunnelClickOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-funnel-click")) {
  funnel.chartLineFunnelClick = echarts.init(document.getElementById("chart-line-funnel-click"));
  funnel.chartLineFunnelClick.setOption(funnel.chartLineFunnelClickOption);
}


/*************************************************************************************************************/
/********************************************** 당해 연도 채널 클릭한 사람 수 (중복제외) **********************************************/

funnel.yearlyChannelClickUpdate = function () {
  let rawData = funnel.yearlyChannelClick;
  let keysToExtract = [
    "row_titl",
    "vist_cnt_01",
    "vist_cnt_02",
    "vist_cnt_03",
    "vist_cnt_04",
    "vist_cnt_05",
    "vist_cnt_06",
    "vist_cnt_07",
    "vist_cnt_08",
    "vist_cnt_09",
    "vist_cnt_10",
    "vist_cnt_11",
    "vist_cnt_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelClickList) {
    funnel.channelClickList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 노출 데이터 뷰어 */
if (document.getElementById("channelClickList")) {
  funnel.channelClickList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelClickList"));
}
/*************************************************************************************************************/
/********************************************** 채널 노출 당 클릭 수 (중복제외) **********************************************/
funnel.channelClickPerImpressUpdate = function () {
  let rawData = funnel.channelClickPerImpress;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineFunnelClickPerImpress) {
    funnel.chartLineFunnelClickPerImpress.setOption(funnel.chartLineFunnelClickPerImpressOption, true);
    if (rawData.length > 0) {
      funnel.chartLineFunnelClickPerImpress.setOption({
        xAxis: {
          data: lgnd,
        },
        yAxis: [
          {
            type: "value",
            name: "클릭/노출 (단위 : 노출)",
            nameTextStyle: {
              padding: [0,0,0,50]
            }
          },
        ],
        series: [
          {
            type: "line",
            connectNulls: true,
            data: rawData.map((item) => item["y_val"]),
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

// zoom 속성
funnel.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

/* 채널 방문자 시계열 그래프 */
funnel.chartLineFunnelClickPerImpressOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-funnel-click-per-impress")) {
  funnel.chartLineFunnelClickPerImpress = echarts.init(document.getElementById("chart-line-funnel-click-per-impress"));
  funnel.chartLineFunnelClickPerImpress.setOption(funnel.chartLineFunnelClickPerImpressOption);
}



/*************************************************************************************************************/
/********************************************** 채널 컨버전 레이트 그래프 시작 (중복제외) **********************************************/
funnel.channelClickConversionRateUpdate = function () {
  let rawData = funnel.channelClickConversionRate;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineFunnelClickConversionRate) {
    funnel.chartLineFunnelClickConversionRate.setOption(funnel.chartLineFunnelClickConversionRateOption, true);
    if (rawData.length > 0) {
      funnel.chartLineFunnelClickConversionRate.setOption({
        xAxis: {
          data: lgnd,
        },
        yAxis: [
          {
            type: "value",
            name: "클릭 전환율 (단위 : %)",
            nameTextStyle: {
              padding: [0,0,0,40]
            }
          },
        ],
        series: [
          {
            type: "line",
            connectNulls: true,
            data: rawData.map((item) => item["y_val"]),
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

// zoom 속성
funnel.zoomSales = [
  {
    show: true,
    realtime: true,
    start: 0,
    end: 100,
    xAxisIndex: [0, 1],
  },
];

/* 채널 방문자 시계열 그래프 */
funnel.chartLineFunnelClickConversionRateOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-funnel-click-conversion-rate")) {
  funnel.chartLineFunnelClickConversionRate = echarts.init(document.getElementById("chart-line-funnel-click-conversion-rate"));
  funnel.chartLineFunnelClickConversionRate.setOption(funnel.chartLineFunnelClickConversionRateOption);
}


/*************************************************************************************************************/
/********************************************** 채널 컨버전 레이트 종료 (중복제외) **********************************************/

/*************************************************************************************************************/
/********************************************** 채널 퍼널분석 **********************************************/

funnel.channelFunnelAnalysisUpdate = function () {
  let rawData = funnel.channelFunnelAnalysis;
  if (funnel.chartFunnelChannelFunnel) {
    funnel.chartFunnelChannelFunnel.setOption(funnel.chartFunnelChannelFunnelOption, true);
    if (rawData.length > 0) {
      funnel.chartFunnelChannelFunnel.setOption(
        {
          tooltip: {
            trigger: "item",
            // formatter: '{a} <br/>{b} : {c}%'
          },
          toolbox: {
            left: "right",
            top: "center",
            orient: "vertical",
            feature: {
              dataView: { readOnly: false },
              saveAsImage: {},
            },
          },
          legend: {
            data: ["노출", "클릭" ,"주문", "구매", "환불"],
            textStyle: {
              color: "#858d98",
            },
          },
          series: [
            {
              name: "Funnel",
              type: "funnel",
              left: "0",
              top: 60,
              bottom: 60,
              width: "100%",
              min: 0,
              max: 100,
              minSize: "0%",
              maxSize: "50%",
              sort: "descending",
              gap: 2,
              label: {
                show: true,
                position: "inside",
              },
              labelLine: {
                length: 10,
                lineStyle: {
                  width: 1,
                  type: "solid",
                },
              },
              itemStyle: {
                borderColor: "#fff",
                borderWidth: 1,
              },
              emphasis: {
                label: {
                  fontSize: 20,
                },
              },
              data: [
                { value: rawData.filter((item) => item.lgnd_id == "REFD")[0]["step_cnt"], name: "환불" },
                { value: rawData.filter((item) => item.lgnd_id == "PAID")[0]["step_cnt"], name: "구매" },
                { value: rawData.filter((item) => item.lgnd_id == "ORDR")[0]["step_cnt"], name: "주문" },
                { value: rawData.filter((item) => item.lgnd_id == "CLCK")[0]["step_cnt"], name: "클릭" },
                { value: rawData.filter((item) => item.lgnd_id == "IMPR")[0]["step_cnt"], name: "노출" },
                
              ],
            },
          ],
        },
        true
      );
    }
  }
};
/* 채널 퍼널분석 */
funnel.chartFunnelChannelFunnelOption = {
  tooltip: {
    trigger: "item",
    // formatter: '{a} <br/>{b} : {c}%'
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      dataView: { readOnly: false },
      saveAsImage: {},
    },
  },
  legend: {
    data: ["노출","클릭", "주문", "구매", "환불"],
  },
  series: [
    {
      name: "Funnel",
      type: "funnel",
      left: "0",
      top: 60,
      bottom: 60,
      width: "100%",
      min: 0,
      max: 100,
      minSize: "0%",
      maxSize: "50%",
      sort: "descending",
      gap: 2,
      label: {
        show: true,
        position: "inside",
      },
      labelLine: {
        length: 10,
        lineStyle: {
          width: 1,
          type: "solid",
        },
      },
      itemStyle: {
        borderColor: "#fff",
        borderWidth: 1,
      },
      emphasis: {
        label: {
          fontSize: 20,
        },
      },
      data: [
        { value: 25, name: "환불" },
        { value: 50, name: "구매" },
        { value: 75, name: "주문" },
        { value: 100, name: "클릭" },
        { value: 120, name: "노출" },

      ],
    },
  ],
};
if (document.getElementById("chart-funnel-channel-funnel")) {
  funnel.chartFunnelChannelFunnel = echarts.init(document.getElementById("chart-funnel-channel-funnel"));
  funnel.chartFunnelChannelFunnel.setOption(funnel.chartFunnelChannelFunnelOption);
}

/*************************************************************************************************************/
/********************************************** 채널 전환율 분석 **********************************************/
funnel.channelConversionRateAnalysisUpdate = function () {
  let rawData = funnel.channelConversionRateAnalysis;
  let keysToExtract = ["lgnd_nm", "step_cnt", "step_rate", "ordr_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelChangeList) {
    funnel.channelChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 채널 전환율 분석 (데이터 뷰어) */
if (document.getElementById("channelChangeList")) {
  funnel.channelChangeList = new gridjs.Grid({
    columns: [
      {
        name: "단계명",
        width: "150px",
      },
      {
        name: "단계별 인원수",
        width: "150px",
      },
      {
        name: "단계별 전환율",
        width: "150px",
      },
      {
        name: "구매 전환율",
        width: "150px",
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
  }).render(document.getElementById("channelChangeList"));
}

/*************************************************************************************************************/
/******채널 구매 전환율 추이 분석*******************************************************************************************************/

funnel.yearlyChannelPurchaseConversionRateUpdate = function () {
  let rawData = funnel.yearlyChannelPurchaseConversionRate;
  let keysToExtract = [
    "row_titl",
    "ordr_rate_01",
    "ordr_rate_02",
    "ordr_rate_03",
    "ordr_rate_04",
    "ordr_rate_05",
    "ordr_rate_06",
    "ordr_rate_07",
    "ordr_rate_08",
    "ordr_rate_09",
    "ordr_rate_10",
    "ordr_rate_11",
    "ordr_rate_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelBuyChangeList) {
    funnel.channelBuyChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 구매전환율 */
if (document.getElementById("channelBuyChangeList")) {
  funnel.channelBuyChangeList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelBuyChangeList"));
}
/************************************************************************** */

/*************************************************************************************************************/
/********************************************** 검색경로 라이브 퍼널분석 **********************************************/

funnel.channelFunnelSearchAnalysisUpdate = function () {
  let rawData = funnel.channelFunnelSearchAnalysis;
  if (funnel.chartFunnelChannelFunnelSearch) {
    funnel.chartFunnelChannelFunnelSearch.setOption(funnel.chartFunnelChannelFunnelSearchOption, true);
    if (rawData.length > 0) {
      funnel.chartFunnelChannelFunnelSearch.setOption(
        {
          tooltip: {
            trigger: "item",
            // formatter: '{a} <br/>{b} : {c}%'
          },
          toolbox: {
            left: "right",
            top: "center",
            orient: "vertical",
            feature: {
              dataView: { readOnly: false },
              saveAsImage: {},
            },
          },
          legend: {
            data: ["노출","상품노출", "클릭" , "구매"],
            textStyle: {
              color: "#858d98",
            },
          },
          series: [
            {
              name: "Funnel",
              type: "funnel",
              left: "0",
              top: 60,
              bottom: 60,
              width: "100%",
              min: 0,
              max: 100,
              minSize: "0%",
              maxSize: "50%",
              sort: "descending",
              gap: 2,
              label: {
                show: true,
                position: "inside",
              },
              labelLine: {
                length: 10,
                lineStyle: {
                  width: 1,
                  type: "solid",
                },
              },
              itemStyle: {
                borderColor: "#fff",
                borderWidth: 1,
              },
              emphasis: {
                label: {
                  fontSize: 20,
                },
              },
              data: [
                { value: rawData.filter((item) => item.lgnd_id == "PAID")[0]["step_cnt"], name: "구매" },
                { value: rawData.filter((item) => item.lgnd_id == "CLCK")[0]["step_cnt"], name: "클릭" },
                { value: rawData.filter((item) => item.lgnd_id == "PRIM")[0]["step_cnt"], name: "상품노출" },
                { value: rawData.filter((item) => item.lgnd_id == "IMPR")[0]["step_cnt"], name: "노출" },
                
              ],
            },
          ],
        },
        true
      );
    }
  }
};
/* 채널 퍼널분석 */
funnel.chartFunnelChannelFunnelSearchOption = {
  tooltip: {
    trigger: "item",
    // formatter: '{a} <br/>{b} : {c}%'
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      dataView: { readOnly: false },
      saveAsImage: {},
    },
  },
  legend: {
    data: ["노출","상품노출","클릭",  "구매"],
  },
  series: [
    {
      name: "Funnel",
      type: "funnel",
      left: "0",
      top: 60,
      bottom: 60,
      width: "100%",
      min: 0,
      max: 100,
      minSize: "0%",
      maxSize: "50%",
      sort: "descending",
      gap: 2,
      label: {
        show: true,
        position: "inside",
      },
      labelLine: {
        length: 10,
        lineStyle: {
          width: 1,
          type: "solid",
        },
      },
      itemStyle: {
        borderColor: "#fff",
        borderWidth: 1,
      },
      emphasis: {
        label: {
          fontSize: 20,
        },
      },
      data: [
        { value: 50, name: "구매" },
        { value: 80, name: "클릭" },
        { value: 90, name: "상품노출" },
        { value: 100, name: "노출" },

      ],
    },
  ],
};
if (document.getElementById("chart-funnel-channel-funnel-search")) {
  funnel.chartFunnelChannelFunnelSearch = echarts.init(document.getElementById("chart-funnel-channel-funnel-search"));
  funnel.chartFunnelChannelFunnelSearch.setOption(funnel.chartFunnelChannelFunnelSearchOption);
}

/************************************************************************************************************************************/

/********************************************** 검색경로 채널 전환율 분석 **********************************************/
funnel.channelSearchConversionRateAnalysisUpdate = function () {
  let rawData = funnel.channelSearchConversionRateAnalysis;
  let keysToExtract = ["lgnd_nm", "step_cnt", "step_rate", "ordr_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelSearchChangeList) {
    funnel.channelSearchChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 채널 전환율 분석 (데이터 뷰어) */
if (document.getElementById("channelSearchChangeList")) {
  funnel.channelSearchChangeList = new gridjs.Grid({
    columns: [
      {
        name: "단계명",
        width: "150px",
      },
      {
        name: "단계별 인원수",
        width: "150px",
      },
      {
        name: "단계별 전환율",
        width: "150px",
      },
      {
        name: "구매 전환율",
        width: "150px",
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
  }).render(document.getElementById("channelSearchChangeList"));
}

/*************************************************************************************************************/

/******당해 연도 검색경로 라이브 구매 전환율*******************************************************************************************************/

funnel.yearlyChannelSearchPurchaseConversionRateUpdate = function () {
  let rawData = funnel.yearlyChannelSearchPurchaseConversionRate;
  let keysToExtract = [
    "row_titl",
    "ordr_rate_01",
    "ordr_rate_02",
    "ordr_rate_03",
    "ordr_rate_04",
    "ordr_rate_05",
    "ordr_rate_06",
    "ordr_rate_07",
    "ordr_rate_08",
    "ordr_rate_09",
    "ordr_rate_10",
    "ordr_rate_11",
    "ordr_rate_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelSearchBuyChangeList) {
    funnel.channelSearchBuyChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 구매전환율 */
if (document.getElementById("channelSearchBuyChangeList")) {
  funnel.channelSearchBuyChangeList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelSearchBuyChangeList"));
}
/************************************************************************** */


/************* 쇼핑몰 추천 유입경로 **************** */

/*************************************************************************************************************/
/********************************************** 검색경로 라이브 퍼널분석 **********************************************/

funnel.channelFunnelShopRecAnalysisUpdate = function () {
  let rawData = funnel.channelFunnelShopRecAnalysis;
  if (funnel.chartFunnelChannelFunnelShopRec) {
    funnel.chartFunnelChannelFunnelShopRec.setOption(funnel.chartFunnelChannelFunnelShopRecOption, true);
    if (rawData.length > 0) {
      funnel.chartFunnelChannelFunnelShopRec.setOption(
        {
          tooltip: {
            trigger: "item",
            // formatter: '{a} <br/>{b} : {c}%'
          },
          toolbox: {
            left: "right",
            top: "center",
            orient: "vertical",
            feature: {
              dataView: { readOnly: false },
              saveAsImage: {},
            },
          },
          legend: {
            data: ["노출", "클릭" , "구매"],
            textStyle: {
              color: "#858d98",
            },
          },
          series: [
            {
              name: "Funnel",
              type: "funnel",
              left: "0",
              top: 60,
              bottom: 60,
              width: "100%",
              min: 0,
              max: 100,
              minSize: "0%",
              maxSize: "50%",
              sort: "descending",
              gap: 2,
              label: {
                show: true,
                position: "inside",
              },
              labelLine: {
                length: 10,
                lineStyle: {
                  width: 1,
                  type: "solid",
                },
              },
              itemStyle: {
                borderColor: "#fff",
                borderWidth: 1,
              },
              emphasis: {
                label: {
                  fontSize: 20,
                },
              },
              data: [
                { value: rawData.filter((item) => item.lgnd_id == "PAID")[0]["step_cnt"], name: "구매" },
                { value: rawData.filter((item) => item.lgnd_id == "CLCK")[0]["step_cnt"], name: "클릭" },
                { value: rawData.filter((item) => item.lgnd_id == "IMPR")[0]["step_cnt"], name: "노출" },
                
              ],
            },
          ],
        },
        true
      );
    }
  }
};
/* 채널 퍼널분석 */
funnel.chartFunnelChannelFunnelShopRecOption = {
  tooltip: {
    trigger: "item",
    // formatter: '{a} <br/>{b} : {c}%'
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      dataView: { readOnly: false },
      saveAsImage: {},
    },
  },
  legend: {
    data: ["노출","클릭",  "구매"],
  },
  series: [
    {
      name: "Funnel",
      type: "funnel",
      left: "0",
      top: 60,
      bottom: 60,
      width: "100%",
      min: 0,
      max: 100,
      minSize: "0%",
      maxSize: "50%",
      sort: "descending",
      gap: 2,
      label: {
        show: true,
        position: "inside",
      },
      labelLine: {
        length: 10,
        lineStyle: {
          width: 1,
          type: "solid",
        },
      },
      itemStyle: {
        borderColor: "#fff",
        borderWidth: 1,
      },
      emphasis: {
        label: {
          fontSize: 20,
        },
      },
      data: [
        { value: 50, name: "구매" },
        { value: 80, name: "클릭" },
        { value: 100, name: "노출" },

      ],
    },
  ],
};
if (document.getElementById("chart-funnel-channel-funnel-ShopRec")) {
  funnel.chartFunnelChannelFunnelShopRec = echarts.init(document.getElementById("chart-funnel-channel-funnel-ShopRec"));
  funnel.chartFunnelChannelFunnelShopRec.setOption(funnel.chartFunnelChannelFunnelShopRecOption);
}

/************************************************************************************************************************************/

/********************************************** 검색경로 채널 전환율 분석 **********************************************/
funnel.channelShopRecConversionRateAnalysisUpdate = function () {
  let rawData = funnel.channelShopRecConversionRateAnalysis;
  let keysToExtract = ["lgnd_nm", "step_cnt", "step_rate", "ordr_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelShopRecChangeList) {
    funnel.channelShopRecChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 채널 전환율 분석 (데이터 뷰어) */
if (document.getElementById("channelShopRecChangeList")) {
  funnel.channelShopRecChangeList = new gridjs.Grid({
    columns: [
      {
        name: "단계명",
        width: "150px",
      },
      {
        name: "단계별 인원수",
        width: "150px",
      },
      {
        name: "단계별 전환율",
        width: "150px",
      },
      {
        name: "구매 전환율",
        width: "150px",
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
  }).render(document.getElementById("channelShopRecChangeList"));
}

/*************************************************************************************************************/

/******당해 연도 검색경로 라이브 구매 전환율*******************************************************************************************************/

funnel.yearlyChannelShopRecPurchaseConversionRateUpdate = function () {
  let rawData = funnel.yearlyChannelShopRecPurchaseConversionRate;
  let keysToExtract = [
    "row_titl",
    "ordr_rate_01",
    "ordr_rate_02",
    "ordr_rate_03",
    "ordr_rate_04",
    "ordr_rate_05",
    "ordr_rate_06",
    "ordr_rate_07",
    "ordr_rate_08",
    "ordr_rate_09",
    "ordr_rate_10",
    "ordr_rate_11",
    "ordr_rate_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelShopRecBuyChangeList) {
    funnel.channelShopRecBuyChangeList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 구매전환율 */
if (document.getElementById("channelShopRecBuyChangeList")) {
  funnel.channelShopRecBuyChangeList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelShopRecBuyChangeList"));
}
/************************************************************************** */
/********************************************** 퍼널분석 쇼핑몰 추천 세부 채널 분석 시작 **********************************************/
funnel.productFunnelShopRecAnalysisUpdate = function () {
  let rawData = funnel.productFunnelShopRecAnalysis;
  if (rawData.length > 0) {
    const sort_key_prod = [...new Set(rawData.map((item) => item.sort_key_prod))];
    for (let i = 1; i <= 3; i++) {
      if (document.getElementById(`chart-funnel-prod-shoprec-funnel${i}`)) {
        if (sort_key_prod[i - 1] == i) {
          funnel[`chartFunnelProdShopRecFunnel${i}`].setOption(
            {
              title: {
                text: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "IMPR")[0]["prod_nm"],
                top: 10,
                left: "center",
              },
              tooltip: {
                trigger: "item",
              },
              series: [
                {
                  name: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "IMPR")[0]["prod_nm"],
                  type: "funnel",
                  left: "5%",
                  right: "5%",
                  top: 60,
                  bottom: 10,
                  width: "90%",
                  min: 0,
                  max: 100,
                  minSize: "0%",
                  sort: "descending",
                  gap: 2,
                  label: {
                    show: true,
                    position: "inside",
                  },
                  labelLine: {
                    length: 10,
                    lineStyle: {
                      width: 1,
                      type: "solid",
                    },
                  },
                  itemStyle: {
                    borderColor: "#fff",
                    borderWidth: 1,
                  },
                  emphasis: {
                    label: {
                      fontSize: 20,
                    },
                  },
                  data: [
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "PAID")[0]["step_cnt"], name: "구매" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "ORDR")[0]["step_cnt"], name: "주문" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "VIST")[0]["step_cnt"], name: "방문" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "CLCK")[0]["step_cnt"], name: "클릭" },                    
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "IMPR")[0]["step_cnt"], name: "노출" },
                  ],
                },
              ],
            },
            true
          );
        } else {
          funnel[`chartFunnelProdShopRecFunnel${i}`].setOption(
            {
              title: {
                top: 10,
                left: "center",
              },
              tooltip: {
                trigger: "item",
              },
              series: [],
            },
            true
          );
        }
      }
    }
  }
};
/* 제품별 Funnel 분석 */
/* 제품1 */
funnel.chartFunnelProdShopRecFunnelOption1 = {
  title: {
    top: 10,
    left: "center",
  },
  tooltip: {
    trigger: "item",
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
if (document.getElementById("chart-funnel-prod-shoprec-funnel1")) {
  funnel.chartFunnelProdShopRecFunnel1 = echarts.init(document.getElementById("chart-funnel-prod-shoprec-funnel1"));
  funnel.chartFunnelProdShopRecFunnel1.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
    },
    series: [],
  });
}
if (document.getElementById("chart-funnel-prod-shoprec-funnel2")) {
  funnel.chartFunnelProdShopRecFunnel2 = echarts.init(document.getElementById("chart-funnel-prod-shoprec-funnel2"));
  funnel.chartFunnelProdShopRecFunnel2.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
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
  });
}
if (document.getElementById("chart-funnel-prod-shoprec-funnel3")) {
  funnel.chartFunnelProdShopRecFunnel3 = echarts.init(document.getElementById("chart-funnel-prod-shoprec-funnel3"));
  funnel.chartFunnelProdShopRecFunnel3.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
    },
    series: [],
  });
}
/*************************************************************************************************************/
/*************************************************************************************************************/
/********************************************** 제품별 구매 전환율 TOP5 **********************************************/
/* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */
funnel.productPCCRCumulativeYoYUpdate = function () {
  let rawData = funnel.productPCCRCumulativeYoY;
  let keysToExtract = ["ordr_rank", "prod_nm_yoy", "ordr_val_yoy", "prod_nm", "ordr_val"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodBuyChangeList) {
    funnel.prodBuyChangeList
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
                name: "라이브 명",
              },
              {
                name: "구매 전환율",
              },
            ],
          },
          {
            name: "금년 동기 누적",
            width: "600px",
            columns: [
              {
                name: "라이브 명",
              },
              {
                name: "구매 전환율",
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
  }
};
/* 17. 제품별 구매 전환율 Top 5 - 전년 동월 대비 구매 전환율 TOP 5 */
funnel.productPCCRMoMUpdate = function () {
  let rawData = funnel.productPCCRMoM;
  let keysToExtract = ["ordr_rank", "prod_nm_yoy", "ordr_val_yoy",  "prod_nm", "ordr_val"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodBuyChangeList) {
    funnel.prodBuyChangeList
      .updateConfig({
        columns: [
          {
            name: "등수",
            width: "100px",
          },
          {
            name: "전년",
            width: "600px",
            columns: [
              // {
              //   name: "전년 제품ID",
              // },
              {
                name: "라이브 아이디",
              },
              {
                name: "구매 전환율",
              },
            ],
          },
          {
            name: "금년",
            width: "600px",
            columns: [
              // {
              //   name: "금년 제품ID",
              // },
              {
                name: "라이브 아이디",
              },
              {
                name: "구매 전환율",
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
  }
};
/* 17. 제품별 구매 전환율 Top 5 - 월별 구매 전환율 TOP 5 */
funnel.productPCMonthlyCRUpdate = function () {
  let rawData = funnel.productPCMonthlyCR;
  let keysToExtract = [
    "ordr_rank",
    "prod_nm_01",
    "prod_nm_02",
    "prod_nm_03",
    "prod_nm_04",
    "prod_nm_05",
    "prod_nm_06",
    "prod_nm_07",
    "prod_nm_08",
    "prod_nm_09",
    "prod_nm_10",
    "prod_nm_11",
    "prod_nm_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodBuyChangeList) {
    funnel.prodBuyChangeList
      .updateConfig({
        columns: [
          {
            name: "등수",
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
        data: function () {
          return new Promise(function (resolve) {
            setTimeout(function () {
              resolve(filterData);
            }, 2000);
          });
        },
      })
      .forceRender();
  }
};

/* 제품별 구매 전환율 TOP5 */
if (document.getElementById("prodBuyChangeList")) {
  funnel.prodBuyChangeList = new gridjs.Grid({
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
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
          },
        ],
      },
      {
        name: "금년 동기 누적",
        width: "400px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
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
  }).render(document.getElementById("prodBuyChangeList"));
}

/*************************************************************************************************************/
/********************************************** 스토어 Funnel 지표 비교 **********************************************/

/* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
funnel.storeFunnelMetricYoYUpdate = function () {
  let rawData = funnel.storeFunnelMetricYoY;
  let keysToExtract = ["row_titl", `col_yoy_${currency}`, `col_${currency}`];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.storeFunnelList) {
    funnel.storeFunnelList
      .updateConfig({
        columns: [
          {
            name: "구분",
            width: "100px",
          },
          {
            name: "전년도 동기 누적",
            width: "150px",
          },
          {
            name: "당해 연도 누적",
            width: "150px",
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
  }
};

/* 18. 스토어 Funnel 지표 비교 - B. 전년 동월대비 비교 SQL */
funnel.storeFunnelMetricMoMUpdate = function () {
  let rawData = funnel.storeFunnelMetricMoM;
  let keysToExtract = ["row_titl", `col_yoy_${currency}`, `col_${currency}`];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.storeFunnelList) {
    funnel.storeFunnelList
      .updateConfig({
        columns: [
          {
            name: "구분",
            width: "100px",
          },
          {
            name: "전년도 동기 누적",
            width: "150px",
          },
          {
            name: "당해 연도 누적",
            width: "150px",
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
  }
};

/* 18. 스토어 Funnel 지표 비교 - C. 당해 연도 월별 비교 SQL */
funnel.storeFunnelMetricMonUpdate = function () {
  let rawData = funnel.storeFunnelMetricMon;
  let keysToExtract = [
    "row_titl",
    `col_00_${currency}`,
    `col_01_${currency}`,
    `col_02_${currency}`,
    `col_03_${currency}`,
    `col_04_${currency}`,
    `col_05_${currency}`,
    `col_06_${currency}`,
    `col_07_${currency}`,
    `col_08_${currency}`,
    `col_09_${currency}`,
    `col_10_${currency}`,
    `col_11_${currency}`,
    `col_12_${currency}`,
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.storeFunnelList) {
    funnel.storeFunnelList
      .updateConfig({
        columns: [
          {
            name: "구분",
            width: "100px",
          },
          {
            name: "당해 연도 누적",
            width: "150px",
          },
          {
            name: "1월",
            width: "150px",
          },
          {
            name: "2월",
            width: "150px",
          },
          {
            name: "3월",
            width: "150px",
          },
          {
            name: "4월",
            width: "150px",
          },
          {
            name: "5월",
            width: "150px",
          },
          {
            name: "6월",
            width: "150px",
          },
          {
            name: "7월",
            width: "150px",
          },
          {
            name: "8월",
            width: "150px",
          },
          {
            name: "9월",
            width: "150px",
          },
          {
            name: "10월",
            width: "150px",
          },
          {
            name: "11월",
            width: "150px",
          },
          {
            name: "12월",
            width: "150px",
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
  }
};

/* 18. 스토어 Funnel 지표 비교 - D. 당해 연도 주차별 비교 SQL */
funnel.storeFunnelMetricWekUpdate = function () {
  let rawData = funnel.storeFunnelMetricWek;
  let dateRawData = funnel.yearMonthWeek;

  let columns = [
    {
      name: "구분",
      width: "100px",
    },
    {
      name: "당해 연도 누적",
      width: "150px",
    },
  ];
  const monthData = {};
  dateRawData.forEach((data) => {
    const month = data.col_mnth;
    const week = data.col_week;
    if (!monthData[month]) {
      monthData[month] = [];
    }
    monthData[month].push(week);
  });

  for (const month in monthData) {
    const weeks = monthData[month];
    let weekArr = [];
    weeks.forEach((week) => {
      weekArr.push({
        name: week,
      });
    });
    columns.push({
      name: month,
      width: "440px",
      columns: weekArr,
    });
  }

  let keysToExtract = ["row_titl"];
  for (let i = 0; i <= 53; i++) {
    const colIndex = i.toString().padStart(2, "0"); // 2자리수로 변환
    keysToExtract.push(`col_${colIndex}_${currency}`);
  }
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.storeFunnelList) {
    funnel.storeFunnelList
      .updateConfig({
        columns: columns,
        data: function () {
          return new Promise(function (resolve) {
            setTimeout(function () {
              resolve(filterData);
            }, 2000);
          });
        },
      })
      .forceRender();
  }
};

/* 스토어 Funnel 지표 비교 */
if (document.getElementById("storeFunnelList")) {
  funnel.storeFunnelList = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "100px",
      },
      {
        name: "전년도 동기 누적",
        width: "150px",
      },
      {
        name: "당해 연도 누적",
        width: "150px",
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
  }).render(document.getElementById("storeFunnelList"));
}
/*************************************************************************************************************/

/****라이브별 funnel 지표 비교  */


/********************************************** 라이브별 Funnel 지표 비교 **********************************************/
funnel.productFunnelMetricWekUpdate = function () {
  let rawData = funnel.productFunnelMetricWek;
  let dateRawData = funnel.yearMonthWeek;

  let columns = [
    {
      name: "구분",
      width: "100px",
    },
    {
      name: "당해 연도 누적",
      width: "150px",
    },
  ];
  const monthData = {};
  dateRawData.forEach((data) => {
    const month = data.col_mnth;
    const week = data.col_week;
    if (!monthData[month]) {
      monthData[month] = [];
    }
    monthData[month].push(week);
  });

  for (const month in monthData) {
    const weeks = monthData[month];
    let weekArr = [];
    weeks.forEach((week) => {
      weekArr.push({
        name: week,
      });
    });
    columns.push({
      name: month,
      width: "440px",
      columns: weekArr,
    });
  }

  let keysToExtract = ["row_titl"];
  for (let i = 0; i <= 53; i++) {
    const colIndex = i.toString().padStart(2, "0"); // 2자리수로 변환
    keysToExtract.push(`col_${colIndex}_${currency}`);
  }

  let filterRawData = [];
  let filterData = [];
  if (rawData.length > 0) {
    const sort_key_prod = [...new Set(rawData.map((item) => item.sort_key_prod))];
    for (let i = 1; i <= 3; i++) {
      if (document.getElementById(`prodFunnelList${i}`)) {
        if (sort_key_prod[i - 1] == i) {
          filterData = [];
          filterRawData = rawData.filter((obj) => obj.sort_key_prod === i);
          const prod_nm = [...new Set(filterRawData.map((item) => item.prod_nm))];
          for (var j = 0; j < filterRawData.length; j++) {
            filterData.push(keysToExtract.map((key) => filterRawData[j][key]));
          }
          const element = document.getElementById(`prodFunnelListTitle${i}`);
          if (element) {
            document.getElementById(`prodFunnelListTitle${i}`).innerText = prod_nm;
          }
          if (i == 1) {
            if (element) {
              element.style.display = "block";
            }
          } else {
            const prodFunnelDiv = document.getElementById(`prodFunnelDiv${i}`);
            if (prodFunnelDiv) {
              prodFunnelDiv.style.display = "block";
            }
          }

          if (funnel[`prodFunnelList${i}`]) {
            funnel[`prodFunnelList${i}`]
              .updateConfig({
                columns: columns,
                data: filterData,
              })
              .forceRender();
          }
        }
      }
    }
  }
};

/* 제품별 Funnel 지표 비교(당해 연도 주차별) 1번 테이블 */
if (document.getElementById("prodFunnelList1")) {
  funnel.prodFunnelList1 = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "130px",
      },
      {
        name: "당해 연도 누적",
        width: "130px",
      },
      {
        name: "1월",
        width: "440px",
        columns: [
          {
            name: "1W",
          },
          {
            name: "2W",
          },
          {
            name: "3W",
          },
          {
            name: "4W",
          },
          {
            name: "5W",
          },
        ],
      },
    ],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
        "border-top": "1px solid #e9ebec",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
        "border-top": "1px solid #e9ebec",
      },
    },
    data: [],
  }).render(document.getElementById("prodFunnelList1"));
}
if (document.getElementById("prodFunnelListTitle1")) {
  const element = document.getElementById("prodFunnelListTitle1");
  element.style.display = "none";
}

/* 제품별 Funnel 지표 비교(당해 연도 주차별) 2번 테이블 */
if (document.getElementById("prodFunnelList2")) {
  funnel.prodFunnelList2 = new gridjs.Grid({
    columns: [],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
        "border-top": "1px solid #e9ebec",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
        "border-top": "1px solid #e9ebec",
      },
    },
    data: [],
  }).render(document.getElementById("prodFunnelList2"));
}
if (document.getElementById("prodFunnelDiv2")) {
  const element = document.getElementById("prodFunnelDiv2");
  element.style.display = "none";
}

/* 제품별 Funnel 지표 비교(당해 연도 주차별) 3번 테이블 */
if (document.getElementById("prodFunnelList3")) {
  funnel.prodFunnelList3 = new gridjs.Grid({
    columns: [],
    language,
    style: {
      th: {
        "text-align": "center",
        "font-size": "12px",
        "border-top": "1px solid #e9ebec",
      },
      td: {
        "text-align": "center",
        "font-size": "11px",
        "border-top": "1px solid #e9ebec",
      },
    },
    data: [],
  }).render(document.getElementById("prodFunnelList3"));
}
if (document.getElementById("prodFunnelDiv3")) {
  const element = document.getElementById("prodFunnelDiv3");
  element.style.display = "none";
}

















































































































/*************************************************************************************************************/
/********************************************** Unique Visitor (UV) 추이 분석 **********************************************/

funnel.yearlyChannelImpressionUpdate = function () {
  let rawData = funnel.yearlyChannelImpression;
  let keysToExtract = [
    "row_titl",
    "vist_cnt_01",
    "vist_cnt_02",
    "vist_cnt_03",
    "vist_cnt_04",
    "vist_cnt_05",
    "vist_cnt_06",
    "vist_cnt_07",
    "vist_cnt_08",
    "vist_cnt_09",
    "vist_cnt_10",
    "vist_cnt_11",
    "vist_cnt_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelImpressionList) {
    funnel.channelImpressionList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 당해 연도 채널 노출 데이터 뷰어 */
if (document.getElementById("channelImpressionList")) {
  funnel.channelImpressionList = new gridjs.Grid({
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
    data: [],
  }).render(document.getElementById("channelImpressionList"));
}
/*************************************************************************************************************/
/********************************************** 제품별 Unique Visitor (UV) **********************************************/

funnel.uniqueVisitorsByProductUpdate = function () {
  let rawData = funnel.uniqueVisitorsByProduct;

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
  let x_dt = [...new Set(rawData.map((item) => item.x_dt))];
  x_dt = x_dt.sort(function (a, b) {
    if (a === 0) return -1; // 0을 가장 첫번째로 배치
    return new Date(a) - new Date(b);
  });

  let series = [];

  for (let i = 0; i < lgnd.length; i++) {
    let seriesData = [];
    x_dt.forEach((dt) => {
      let value = rawData.filter((item) => item.x_dt === dt && item.l_lgnd_id === lgnd[i]);
      if (value.length > 0) {
        seriesData.push(Number(value[0]["y_val"]));
      } else {
        seriesData.push("");
      }
    });
    series.push({
      name: uniqueLegends[lgnd[i]].name,
      type: "line",
      yAxisIndex: 0,
      connectNulls: true,
      data: seriesData,
    });
  }

  if (funnel.chartLineProdVisitor) {
    funnel.chartLineProdVisitor.setOption(funnel.chartLineProdVisitorOption, true);
    if (rawData.length > 0) {
      funnel.chartLineProdVisitor.setOption({
        legend: {
          data: lgnd_nm,
        },
        dataZoom: funnel.zoomSales,
        xAxis: {
          data: x_dt,
        },
        series: series,
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData == 0 ? "데이터가 없습니다" : "",
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

/* 제품별 방문자 시계열 그래프 */
funnel.chartLineProdVisitorOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-prod-visitor")) {
  funnel.chartLineProdVisitor = echarts.init(document.getElementById("chart-line-prod-visitor"));
  funnel.chartLineProdVisitor.setOption(funnel.chartLineProdVisitorOption);
}
/*************************************************************************************************************/
/********************************************** Unique Visitor (UV) Top 5 제품 **********************************************/
/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 방문자 TOP 5 */
funnel.productVisitorsCumulativeVisitorsYoYUpdate = function () {
  let rawData = funnel.productVisitorsCumulativeVisitorsYoY;
  let keysToExtract = ["vist_rank", "prod_id_yoy", "prod_nm_yoy", "vist_cnt_yoy", "vist_rate_yoy", "prod_id", "prod_nm", "vist_cnt", "vist_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitorList) {
    funnel.prodVisitorList
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
                name: "방문자 수",
              },
              {
                name: "방문자 비중",
              },
            ],
          },
          {
            name: "금년 동기 누적",
            width: "600px",
            columns: [
              {
                name: "제품명",
              },
              {
                name: "방문자 수",
              },
              {
                name: "방문자 비중",
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
  }
};
/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년 동월 대비 방문자 TOP 5 */
funnel.productVisitorsVisitorsMoMUpdate = function () {
  let rawData = funnel.productVisitorsVisitorsMoM;
  let keysToExtract = ["vist_rank", "prod_nm_yoy", "vist_cnt_yoy", "vist_rate_yoy", "prod_nm", "vist_cnt", "vist_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitorList) {
    funnel.prodVisitorList
      .updateConfig({
        columns: [
          {
            name: "등수",
            width: "100px",
          },
          {
            name: "전년",
            width: "600px",
            columns: [
              // {
              //   name: "전년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "방문자 수",
              },
              {
                name: "방문자 비중",
              },
            ],
          },
          {
            name: "금년",
            width: "600px",
            columns: [
              // {
              //   name: "금년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "방문자 수",
              },
              {
                name: "방문자 비중",
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
  }
};
/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 월별 방문자 TOP 5 */
funnel.productVisitorsMonthlyVisitorsUpdate = function () {
  let rawData = funnel.productVisitorsMonthlyVisitors;
  let keysToExtract = [
    "vist_rank",
    "prod_id_01",
    "prod_id_02",
    "prod_id_03",
    "prod_id_04",
    "prod_id_05",
    "prod_id_06",
    "prod_id_07",
    "prod_id_08",
    "prod_id_09",
    "prod_id_10",
    "prod_id_11",
    "prod_id_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitorList) {
    funnel.prodVisitorList
      .updateConfig({
        columns: [
          {
            name: "등수",
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
        data: function () {
          return new Promise(function (resolve) {
            setTimeout(function () {
              resolve(filterData);
            }, 2000);
          });
        },
      })
      .forceRender();
  }
};

/* 제품별 Unique Visitor (UV) 데이터 뷰어 */
if (document.getElementById("prodVisitorList")) {
  funnel.prodVisitorList = new gridjs.Grid({
    columns: [],
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
  }).render(document.getElementById("prodVisitorList"));
}
/*************************************************************************************************************/
/********************************************** Page View (PV) **********************************************/

funnel.channelPageViewsUpdate = function () {
  let rawData = funnel.channelPageViews;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineChannelPage) {
    funnel.chartLineChannelPage.setOption(funnel.chartLineChannelPageOption, true);
    if (rawData.length > 0) {
      funnel.chartLineChannelPage.setOption({
        xAxis: {
          data: lgnd,
        },
        series: [
          {
            type: "line",
            data: rawData.map((item) => item["y_val"]),
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
/* Page View (PV) */
funnel.chartLineChannelPageOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-channel-page")) {
  funnel.chartLineChannelPage = echarts.init(document.getElementById("chart-line-channel-page"));
  funnel.chartLineChannelPage.setOption(funnel.chartLineChannelPageOption);
}

/*************************************************************************************************************/
/********************************************** Page View (PV) 추이 분석 **********************************************/
funnel.yearlyChannelPageViewsUpdate = function () {
  let rawData = funnel.yearlyChannelPageViews;
  let keysToExtract = [
    "row_titl",
    "pgvw_cnt_01",
    "pgvw_cnt_02",
    "pgvw_cnt_03",
    "pgvw_cnt_04",
    "pgvw_cnt_05",
    "pgvw_cnt_06",
    "pgvw_cnt_07",
    "pgvw_cnt_08",
    "pgvw_cnt_09",
    "pgvw_cnt_10",
    "pgvw_cnt_11",
    "pgvw_cnt_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelPageList) {
    funnel.channelPageList.updateConfig({ data: filterData }).forceRender();
  }
};
/* Page View (PV) 추이 분석 */
if (document.getElementById("channelPageList")) {
  funnel.channelPageList = new gridjs.Grid({
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
  }).render(document.getElementById("channelPageList"));
}

/*************************************************************************************************************/
/********************************************** 제품별 Page View (PV) **********************************************/

funnel.productPageViewsUpdate = function () {
  let rawData = funnel.productPageViews;

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
  let x_dt = [...new Set(rawData.map((item) => item.x_dt))];
  x_dt = x_dt.sort(function (a, b) {
    if (a === 0) return -1; // 0을 가장 첫번째로 배치
    return new Date(a) - new Date(b);
  });

  let series = [];

  for (let i = 0; i < lgnd.length; i++) {
    let seriesData = [];
    x_dt.forEach((dt) => {
      let value = rawData.filter((item) => item.x_dt === dt && item.l_lgnd_id === lgnd[i]);
      if (value.length > 0) {
        seriesData.push(Number(value[0]["y_val"]));
      } else {
        seriesData.push("");
      }
    });
    series.push({
      name: uniqueLegends[lgnd[i]].name,
      type: "line",
      yAxisIndex: 0,
      connectNulls: true,
      data: seriesData,
    });
  }

  if (funnel.chartLineProdPage) {
    funnel.chartLineProdPage.setOption(funnel.chartLineProdPageOption, true);
    if (rawData.length > 0) {
      funnel.chartLineProdPage.setOption({
        legend: {
          data: lgnd_nm,
        },
        xAxis: {
          data: x_dt,
        },
        series: series,
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData == 0 ? "데이터가 없습니다" : "",
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

/* 제품별 Page View (PV) */
funnel.chartLineProdPageOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-prod-page")) {
  funnel.chartLineProdPage = echarts.init(document.getElementById("chart-line-prod-page"));
  funnel.chartLineProdPage.setOption(funnel.chartLineProdPageOption);
}

/*************************************************************************************************************/
/********************************************** Page View (PV) Top 5 제품 **********************************************/
/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */
funnel.productPageViewsCumulativePageViewsYoYUpdate = function () {
  let rawData = funnel.productPageViewsCumulativePageViewsYoY;
  let keysToExtract = ["pgvw_rank", "prod_nm_yoy", "pgvw_cnt_yoy", "pgvw_rate_yoy", "prod_nm", "pgvw_cnt", "pgvw_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodPageList) {
    funnel.prodPageList
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
                name: "페이지뷰 건수",
              },
              {
                name: "페이지뷰 비중",
              },
            ],
          },
          {
            name: "금년 동기 누적",
            width: "600px",
            columns: [
              {
                name: "제품명",
              },
              {
                name: "페이지뷰 건수",
              },
              {
                name: "페이지뷰 비중",
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
  }
};
/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년 동월 대비 페이지뷰 TOP 5 */
funnel.productPageViewsPageViewsMoMUpdate = function () {
  let rawData = funnel.productPageViewsPageViewsMoM;
  let keysToExtract = ["pgvw_rank", "prod_nm_yoy", "pgvw_cnt_yoy", "pgvw_rate_yoy", "prod_nm", "pgvw_cnt", "pgvw_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodPageList) {
    funnel.prodPageList
      .updateConfig({
        columns: [
          {
            name: "등수",
            width: "100px",
          },
          {
            name: "전년",
            width: "600px",
            columns: [
              // {
              //   name: "전년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "페이지뷰 건수",
              },
              {
                name: "페이지뷰 비중",
              },
            ],
          },
          {
            name: "금년",
            width: "600px",
            columns: [
              // {
              //   name: "금년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "페이지뷰 건수",
              },
              {
                name: "페이지뷰 비중",
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
  }
};
/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 월별 페이지뷰 TOP 5 */
funnel.productPageViewsMonthlyPageViewsUpdate = function () {
  let rawData = funnel.productPageViewsMonthlyPageViews;
  let keysToExtract = [
    "pgvw_rank",
    "prod_id_01",
    "prod_id_02",
    "prod_id_03",
    "prod_id_04",
    "prod_id_05",
    "prod_id_06",
    "prod_id_07",
    "prod_id_08",
    "prod_id_09",
    "prod_id_10",
    "prod_id_11",
    "prod_id_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodPageList) {
    funnel.prodPageList
      .updateConfig({
        columns: [
          {
            name: "등수",
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
        data: function () {
          return new Promise(function (resolve) {
            setTimeout(function () {
              resolve(filterData);
            }, 2000);
          });
        },
      })
      .forceRender();
  }
};

/* 제품별 Page View (PV) 데이터 뷰어 */
if (document.getElementById("prodPageList")) {
  funnel.prodPageList = new gridjs.Grid({
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
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
          },
        ],
      },
      {
        name: "금년 동기 누적",
        width: "400px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
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
  }).render(document.getElementById("prodPageList"));
}

/*************************************************************************************************************/
/********************************************** Unique Visitor (UV) 당 Page View (PV) **********************************************/

funnel.pageViewsPerChannelVisitorUpdate = function () {
  let rawData = funnel.pageViewsPerChannelVisitor;
  const lgnd = [...new Set(rawData.map((item) => item.x_dt))];
  if (funnel.chartLineChannelVisitPage) {
    funnel.chartLineChannelVisitPage.setOption(funnel.chartLineChannelVisitPageOption, true);
    if (rawData.length > 0) {
      funnel.chartLineChannelVisitPage.setOption({
        xAxis: {
          data: lgnd,
        },
        series: [
          {
            type: "line",
            data: rawData.map((item) => item["y_val"]),
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

/* Unique Visitor (UV) 당 Page View (PV) 시계열 그래프 */
funnel.chartLineChannelVisitPageOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-channel-visit-page")) {
  funnel.chartLineChannelVisitPage = echarts.init(document.getElementById("chart-line-channel-visit-page"));
  funnel.chartLineChannelVisitPage.setOption(funnel.chartLineChannelVisitPageOption);
}

/*************************************************************************************************************/
/********************************************** Unique Visitor (UV) 당 Page View (PV) 추이 분석 **********************************************/
funnel.pageViewsPerYearlyChannelVisitorUpdate = function () {
  let rawData = funnel.pageViewsPerYearlyChannelVisitor;
  let keysToExtract = [
    "row_titl",
    "pgvw_cnt_01",
    "pgvw_cnt_02",
    "pgvw_cnt_03",
    "pgvw_cnt_04",
    "pgvw_cnt_05",
    "pgvw_cnt_06",
    "pgvw_cnt_07",
    "pgvw_cnt_08",
    "pgvw_cnt_09",
    "pgvw_cnt_10",
    "pgvw_cnt_11",
    "pgvw_cnt_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.channelVisitPageList) {
    funnel.channelVisitPageList.updateConfig({ data: filterData }).forceRender();
  }
};
/* Unique Visitor (UV) 당 Page View (PV) 추이 분석 */
if (document.getElementById("channelVisitPageList")) {
  funnel.channelVisitPageList = new gridjs.Grid({
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
  }).render(document.getElementById("channelVisitPageList"));
}

/*************************************************************************************************************/
/********************************************** 제품별 Unique Visitor (UV) 당 Page View (PV) **********************************************/

funnel.pageViewsPerProductVisitorUpdate = function () {
  let rawData = funnel.pageViewsPerProductVisitor;

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
  let x_dt = [...new Set(rawData.map((item) => item.x_dt))];
  x_dt = x_dt.sort(function (a, b) {
    if (a === 0) return -1; // 0을 가장 첫번째로 배치
    return new Date(a) - new Date(b);
  });

  let series = [];

  for (let i = 0; i < lgnd.length; i++) {
    let seriesData = [];
    x_dt.forEach((dt) => {
      let value = rawData.filter((item) => item.x_dt === dt && item.l_lgnd_id === lgnd[i]);
      if (value.length > 0) {
        seriesData.push(Number(value[0]["y_val"]));
      } else {
        seriesData.push("");
      }
    });
    series.push({
      name: uniqueLegends[lgnd[i]].name,
      type: "line",
      yAxisIndex: 0,
      connectNulls: true,
      data: seriesData,
    });
  }

  if (funnel.chartLineProdVisitPage) {
    funnel.chartLineProdVisitPage.setOption(funnel.chartLineProdVisitPageOption, true);
    if (rawData.length > 0) {
      funnel.chartLineProdVisitPage.setOption({
        legend: {
          data: lgnd_nm,
        },
        xAxis: {
          data: x_dt,
        },
        series: series,
        graphic: {
          elements: [
            {
              type: "text",
              left: "center",
              top: "middle",
              style: {
                text: rawData == 0 ? "데이터가 없습니다" : "",
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

/* 제품별 Unique Visitor (UV) 당 Page View (PV) 시계열 그래프 */
funnel.chartLineProdVisitPageOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: ["", ""],
    textStyle: {
      color: "#858d98",
    },
  },
  dataZoom: funnel.zoomSales,
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
if (document.getElementById("chart-line-prod-visit-page")) {
  funnel.chartLineProdVisitPage = echarts.init(document.getElementById("chart-line-prod-visit-page"));
  funnel.chartLineProdVisitPage.setOption(funnel.chartLineProdVisitPageOption);
}

/*************************************************************************************************************/
/********************************************** Unique Visitor (UV) 당 Page View (PV) Top 5 제품**********************************************/
/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년도 동기 누적 대비 누적 방문자당 페이지뷰 TOP 5 */
funnel.pagesPerProductVisitorCumulativePagesPerVisitorYoYUpdate = function () {
  let rawData = funnel.pagesPerProductVisitorCumulativePagesPerVisitorYoY;
  let keysToExtract = ["pgvw_rank", "prod_nm_yoy", "pgvw_cnt_yoy", "pgvw_rate_yoy", "prod_nm", "pgvw_cnt", "pgvw_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitPageInfo) {
    funnel.prodVisitPageInfo
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
                name: "Unique Visitor (UV) 당 Page View (PV) 건수",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 비중",
              },
            ],
          },
          {
            name: "금년 동기 누적",
            width: "600px",
            columns: [
              {
                name: "제품명",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 건수",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 비중",
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
  }
};
/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년 동월 대비 방문자당 페이지뷰 TOP 5 */
funnel.pagesPerProductVisitorPagesPerVisitorMoMUpdate = function () {
  let rawData = funnel.pagesPerProductVisitorPagesPerVisitorMoM;
  let keysToExtract = ["pgvw_rank", "prod_nm_yoy", "pgvw_cnt_yoy", "pgvw_rate_yoy", "prod_nm", "pgvw_cnt", "pgvw_rate"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitPageInfo) {
    funnel.prodVisitPageInfo
      .updateConfig({
        columns: [
          {
            name: "등수",
            width: "100px",
          },
          {
            name: "전년",
            width: "600px",
            columns: [
              // {
              //   name: "전년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 건수",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 비중",
              },
            ],
          },
          {
            name: "금년",
            width: "600px",
            columns: [
              // {
              //   name: "금년 제품ID",
              // },
              {
                name: "제품명",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 건수",
              },
              {
                name: "Unique Visitor (UV) 당 Page View (PV) 비중",
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
  }
};
/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 월별 방문자당 페이지뷰 TOP 5 */
funnel.pagesPerProductVisitorPagesPerVisitorMonthlyUpdate = function () {
  let rawData = funnel.pagesPerProductVisitorPagesPerVisitorMonthly;
  let keysToExtract = [
    "pgvw_rank",
    "prod_id_01",
    "prod_id_02",
    "prod_id_03",
    "prod_id_04",
    "prod_id_05",
    "prod_id_06",
    "prod_id_07",
    "prod_id_08",
    "prod_id_09",
    "prod_id_10",
    "prod_id_11",
    "prod_id_12",
  ];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (funnel.prodVisitPageInfo) {
    funnel.prodVisitPageInfo
      .updateConfig({
        columns: [
          {
            name: "등수",
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
        data: function () {
          return new Promise(function (resolve) {
            setTimeout(function () {
              resolve(filterData);
            }, 2000);
          });
        },
      })
      .forceRender();
  }
};

/* 제품별 Page View (PV) 데이터 뷰어 */
if (document.getElementById("prodVisitPageInfo")) {
  funnel.prodVisitPageInfo = new gridjs.Grid({
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
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
          },
        ],
      },
      {
        name: "금년 동기 누적",
        width: "400px",
        columns: [
          {
            name: "제품명",
          },
          {
            name: "방문자 수",
          },
          {
            name: "방문자 비중",
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
  }).render(document.getElementById("prodVisitPageInfo"));
}

/********************************************** 제품 별 퍼널 분석 **********************************************/
funnel.productFunnelAnalysisUpdate = function () {
  let rawData = funnel.productFunnelAnalysis;
  if (rawData.length > 0) {
    const sort_key_prod = [...new Set(rawData.map((item) => item.sort_key_prod))];
    for (let i = 1; i <= 3; i++) {
      if (document.getElementById(`chart-funnel-prod-funnel${i}`)) {
        if (sort_key_prod[i - 1] == i) {
          funnel[`chartFunnelProdFunnel${i}`].setOption(
            {
              title: {
                text: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "REFD")[0]["prod_nm"],
                top: 10,
                left: "center",
              },
              tooltip: {
                trigger: "item",
              },
              series: [
                {
                  name: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "REFD")[0]["prod_nm"],
                  type: "funnel",
                  left: "5%",
                  right: "5%",
                  top: 60,
                  bottom: 10,
                  width: "90%",
                  min: 0,
                  max: 100,
                  minSize: "0%",
                  sort: "descending",
                  gap: 2,
                  label: {
                    show: true,
                    position: "inside",
                  },
                  labelLine: {
                    length: 10,
                    lineStyle: {
                      width: 1,
                      type: "solid",
                    },
                  },
                  itemStyle: {
                    borderColor: "#fff",
                    borderWidth: 1,
                  },
                  emphasis: {
                    label: {
                      fontSize: 20,
                    },
                  },
                  data: [
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "REFD")[0]["step_cnt"], name: "환불" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "PAID")[0]["step_cnt"], name: "구매" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "ORDR")[0]["step_cnt"], name: "주문" },
                    { value: rawData.filter((item) => item.sort_key_prod == i && item.lgnd_id == "VIST")[0]["step_cnt"], name: "방문" },
                  ],
                },
              ],
            },
            true
          );
        } else {
          funnel[`chartFunnelProdFunnel${i}`].setOption(
            {
              title: {
                top: 10,
                left: "center",
              },
              tooltip: {
                trigger: "item",
              },
              series: [],
            },
            true
          );
        }
      }
    }
  }
};
/* 제품별 Funnel 분석 */
/* 제품1 */
funnel.chartFunnelProdFunnelOption1 = {
  title: {
    top: 10,
    left: "center",
  },
  tooltip: {
    trigger: "item",
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
if (document.getElementById("chart-funnel-prod-funnel1")) {
  funnel.chartFunnelProdFunnel1 = echarts.init(document.getElementById("chart-funnel-prod-funnel1"));
  funnel.chartFunnelProdFunnel1.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
    },
    series: [],
  });
}
if (document.getElementById("chart-funnel-prod-funnel2")) {
  funnel.chartFunnelProdFunnel2 = echarts.init(document.getElementById("chart-funnel-prod-funnel2"));
  funnel.chartFunnelProdFunnel2.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
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
  });
}
if (document.getElementById("chart-funnel-prod-funnel3")) {
  funnel.chartFunnelProdFunnel3 = echarts.init(document.getElementById("chart-funnel-prod-funnel3"));
  funnel.chartFunnelProdFunnel3.setOption({
    title: {
      top: 10,
      left: "center",
    },
    tooltip: {
      trigger: "item",
    },
    series: [],
  });
}


/*************************************************************************************************************/

funnel.searchData = function (type) {
  let prodSelect, datePicker, dataList, dataProp;

  if (type === "pd_visit") {
    prodSelect = funnel.funnelProductSelect1;
    datePicker = document.getElementById("funnelProductVisitDatepicker");
    dataList = ["uniqueVisitorsByProduct"];
    dataProp = "uniqueVisitorsByProduct";
  } else if (type === "pd_page") {
    prodSelect = funnel.funnelProductSelect2;
    datePicker = document.getElementById("funnelProdPageViewDatePicker");
    dataList = ["productPageViews"];
    dataProp = "productPageViews";
  } else if (type === "pd_vp") {
    prodSelect = funnel.funnelProductSelect3;
    datePicker = document.getElementById("funnelProdVisitPageViewDatepicker");
    dataList = ["pageViewsPerProductVisitor"];
    dataProp = "pageViewsPerProductVisitor";
  } else if (type === "ch_fu") {
    prodSelect = funnel.funnelProductSelect4;
    datePicker = document.getElementById("funnelProdFunnelDatepicker");
    dataList = ["productFunnelAnalysis"];
    dataProp = "productFunnelAnalysis";
  } else if (type === "ch_fu2") {
    prodSelect = funnel.funnelProductShopRecSelect;
    datePicker = document.getElementById("funnelProdFunnlShopRecDatepicker");
    dataList = ["productFunnelShopRecAnalysis"];
    dataProp = "productFunnelShopRecAnalysis";
  } else if (type === "pd_funnel") {
    document.getElementById(`prodFunnelDiv2`).style.display = "none";
    document.getElementById(`prodFunnelDiv3`).style.display = "none";
    prodSelect = funnel.funnelProductSelect5;
    datePicker = document.getElementById("funnelProdFunnelMetricsDatepicker");
    dataList = ["productFunnelMetricWek"];
    dataProp = "productFunnelMetricWek";
  } else {
    return; // Exit early if type is not recognized
  }

  const prodId = prodSelect.getValue();
  if (prodId.length === 0) {
    dapAlert("제품을 선택해 주세요.");
    return;
  }

  const prodValue = prodId.map((item) => item.value).join(",");
  const params = {
    params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'${prodValue}'` },
    menu: "dashboards/common",
    tab: "funnel",
    dataList: dataList,
  };

  getData(params, function (data) {
    funnel[dataProp] = {};
    if (data[dataProp] != undefined) {
      funnel[dataProp] = data[dataProp];
      funnel[`${dataProp}Update`]();
    }
  });
};

funnel.onLoadEvent = function (initData) {
  flatpickr(
    "#funnelProductVisitDatepicker, #funnelProdPageViewDatePicker, #funnelProdFunnelDatepicker, #funnelProdFunnelMetricsDatepicker, #funnelProdVisitPageViewDatepicker, #funnelProdFunnlShopRecDatepicker",
    {
      locale: "ko", // locale for this instance only
      defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
      mode: "range",
    }
  );

  flatpickr(
    "#funnelChannelImpressionDatepicker, #funnelChannelClickPersonDatepicker, #funnelChannelClickDatepicker, #funnelChannelClickPerImpressDatepicker, #funnelChannelClickConversionRateDatepicker",
    {
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
            tab: "funnel",
          };

          const elId = instance.element.id;
          switch (elId) {
            case "funnelChannelImpressionDatepicker":
              // 채널 노출 수
              params["dataList"] = ["channelImpression"];
              break;
            case "funnelChannelClickPersonDatepicker":
              // 채널 클릭한 사람 수
              params["dataList"] = ["channelClickPerson"];
              break;
            case "funnelChannelClickDatepicker":
              // 채널 클릭 수
              params["dataList"] = ["channelClick"];
              break;
            case "funnelChannelClickPerImpressDatepicker":
              // 채널 노출 당 클릭수 수
              params["dataList"] = ["channelClickPerImpress"];
              break;
            case "funnelChannelClickConversionRateDatepicker":
              // 채널 클릭 전환율 
              params["dataList"] = ["channelClickConversionRate"];
              break;

            case "funnelChannelVisitPageViewDatepicker":
              // Unique Visitor (UV) 당 Page View (PV)
              params["dataList"] = ["pageViewsPerYearlyChannelVisitor"];
              break;
            case "funnelChannelFunnelDatepicker":
              // 채널 퍼널분석
              params["dataList"] = ["channelFunnelAnalysis", "channelConversionRateAnalysis"];
              break;
            case "funnelChannelFunnelSearchDatepicker":
              // 채널 퍼널분석
              params["dataList"] = ["channelFunnelSearchAnalysis", "channelSearchConversionRateAnalysis"];
              break;



          }

          getData(params, function (data) {
            switch (elId) {
              case "funnelChannelImpressionDatepicker":
                funnel.channelImpression = {};
                if (data["channelImpression"] != undefined) {
                  funnel.channelImpression = data["channelImpression"];
                  funnel.channelImpressionUpdate();
                }
                break;
              case "funnelChannelClickPersonDatepicker":
                funnel.channelClickPerson = {};
                if (data["channelClickPerson"] != undefined) {
                  funnel.channelClickPerson = data["channelClickPerson"];
                  funnel.channelClickPersonUpdate();
                }
                break;
              case "funnelChannelClickDatepicker":
                funnel.channelClick = {};
                if (data["channelClick"] != undefined) {
                  funnel.channelClick = data["channelClick"];
                  funnel.channelClickUpdate();
                }
                break;
              case "funnelChannelClickPerImpressDatepicker":
                funnel.channelClick = {};
                if (data["channelClickPerImpress"] != undefined) {
                  funnel.channelClickPerImpress = data["channelClickPerImpress"];
                  funnel.channelClickPerImpressUpdate();
                }
                break;
              case "funnelChannelClickConversionRateDatepicker":
                funnel.channelClickConversionRate = {};
                if (data["channelClickConversionRate"] != undefined) {
                  funnel.channelClickConversionRate = data["channelClickConversionRate"];
                  funnel.channelClickConversionRateUpdate();
                }
                break;

              case "funnelChannelPageViewDatepicker":
                // Page View (PV)
                funnel.channelPageViews = {};
                if (data["channelPageViews"] != undefined) {
                  funnel.channelPageViews = data["channelPageViews"];
                  funnel.channelPageViewsUpdate();
                }
                break;
              case "funnelChannelVisitPageViewDatepicker":
                // Unique Visitor (UV) 당 Page View (PV)
                funnel.pageViewsPerChannelVisitor = {};
                if (data["pageViewsPerChannelVisitor"] != undefined) {
                  funnel.pageViewsPerChannelVisitor = data["pageViewsPerChannelVisitor"];
                  funnel.pageViewsPerChannelVisitorUpdate();
                }
                break;
            }
          });
        }
      },
    }
  );

  // flatpickr 이벤트2 - 2023-04-06 양윤지
  let funnelDatePicker2 = flatpickr("#funnelChannelFunnelDatepicker, #funnelChannelChangeDatepicker, #funnelChannelFunnelSearchDatepicker, #funnelChannelSearchChangeDatepicker, #funnelChannelFunnelShopRecDatepicker, #funnelChannelShopRecChangeDatepicker", {
      locale: "ko", // locale for this instance only
      defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
      mode: "range",
      onChange: function (selectedDates, dateStr, instance) {
        if (selectedDates.length > 1) {
          const fromDate = getDateFormatter(selectedDates[0]);
          const toDate = getDateFormatter(selectedDates[1]);

          // funnelDatePicker2[0].setDate([fromDate, toDate]);
          // funnelDatePicker2[1].setDate([fromDate, toDate]);

          // funnelDatePicker2 에 선언된 모든 flatpickr 날짜 변경하도록 수정
          funnelDatePicker2.forEach(datePicker => {
            datePicker.setDate([fromDate, toDate]);
          })

          let params = {
            params: {
              FR_DT: `'${fromDate}'`,
              TO_DT: `'${toDate}'`,
            },
            menu: "dashboards/common",
            tab: "funnel",
            dataList: ["channelFunnelAnalysis", "channelConversionRateAnalysis","channelFunnelSearchAnalysis", "channelSearchConversionRateAnalysis","channelFunnelShopRecAnalysis", "channelShopRecConversionRateAnalysis", "product" ]
          };

          getData(params, function (data) {
            funnel.channelFunnelAnalysis = {};
            if (data["channelFunnelAnalysis"] != undefined) {
              funnel.channelFunnelAnalysis = data["channelFunnelAnalysis"];
              funnel.channelFunnelAnalysisUpdate();
            }
            funnel.channelConversionRateAnalysis = {};
            if (data["channelConversionRateAnalysis"] != undefined) {
              funnel.channelConversionRateAnalysis = data["channelConversionRateAnalysis"];
              funnel.channelConversionRateAnalysisUpdate();
            }
            if (data["channelFunnelSearchAnalysis"] != undefined) {
              funnel.channelFunnelSearchAnalysis = data["channelFunnelSearchAnalysis"];
              funnel.channelFunnelSearchAnalysisUpdate();
            }
            if (data["channelSearchConversionRateAnalysis"] != undefined) {
              funnel.channelSearchConversionRateAnalysis = data["channelSearchConversionRateAnalysis"];
              funnel.channelSearchConversionRateAnalysisUpdate();
            }
            if (data["channelFunnelShopRecAnalysis"] != undefined) {
              funnel.channelFunnelShopRecAnalysis = data["channelFunnelShopRecAnalysis"];
              funnel.channelFunnelShopRecAnalysisUpdate();
            }
            if (data["channelShopRecConversionRateAnalysis"] != undefined) {
              funnel.channelShopRecConversionRateAnalysis = data["channelShopRecConversionRateAnalysis"];
              funnel.channelShopRecConversionRateAnalysisUpdate();
            }
            if (data["product"] != undefined) {
              funnel.product = data["product"];
              funnel.productUpdate("all");
            }


          });
        }
      },
    }
  );
  
  // flatpickr 이벤트3 - 2023-04-04 양윤지
  flatpickr("#lastMonthVisitorFlatpickr, #lastMonthPageFlatpickr, #lastMonthProdVisitPageFlatpickr, #lastMonthProdBuyChangeFlatpickr", {
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
        tab: "funnel",
      };
      // debugger;
      const elId = instance.element.id;
      switch (elId) {
        case "lastMonthVisitorFlatpickr":
          params["dataList"] = ["productVisitorsVisitorsMoM"];
          break;
        case "lastMonthPageFlatpickr":
          params["dataList"] = ["productPageViewsPageViewsMoM"];
          break;
        case "lastMonthProdVisitPageFlatpickr":
          params["dataList"] = ["pagesPerProductVisitorPagesPerVisitorMoM"];
          break;
        case "lastMonthProdBuyChangeFlatpickr":
          params["dataList"] = ["productPCCRMoM"];
          break;
      };
      getData(params, function (data) {
        switch (elId) {
          case "lastMonthVisitorFlatpickr":
            funnel.productVisitorsVisitorsMoM = {};
            if (data["productVisitorsVisitorsMoM"] != undefined) {
              funnel.productVisitorsVisitorsMoM = data["productVisitorsVisitorsMoM"];
              funnel.productVisitorsVisitorsMoMUpdate();
            };
            break;
          case "lastMonthPageFlatpickr":
            funnel.productPageViewsPageViewsMoM = {};
            if (data["productPageViewsPageViewsMoM"] != undefined) {
              funnel.productPageViewsPageViewsMoM = data["productPageViewsPageViewsMoM"];
              funnel.productPageViewsPageViewsMoMUpdate();
            };
            break;
          case "lastMonthProdVisitPageFlatpickr":
            funnel.pagesPerProductVisitorPagesPerVisitorMoM = {};
            if (data["pagesPerProductVisitorPagesPerVisitorMoM"] != undefined) {
              funnel.pagesPerProductVisitorPagesPerVisitorMoM = data["pagesPerProductVisitorPagesPerVisitorMoM"];
              funnel.pagesPerProductVisitorPagesPerVisitorMoMUpdate();
            };
            break;
          case "lastMonthProdBuyChangeFlatpickr":
            funnel.productPCCRMoM = {};
            if (data["productPCCRMoM"] != undefined) {
              funnel.productPCCRMoM = data["productPCCRMoM"];
              funnel.productPCCRMoMUpdate();
            };
            break;
        };
      });
    },
  });

  funnel.onloadStatus = true; // 화면 로딩 상태

  /* 제품별 방문자 시계열 그래프 - 제품 선택 Select Box */
  let productOption = {
    searchEnabled: false,
    shouldSort: false,
    removeItemButton: true,
    classNames: {
      removeButton: "remove",
    },
    placeholder: true,
    placeholderValue: "제품을 선택하세요.  ",
  };
  const funnelProductSelect1 = document.getElementById("funnelProductSelect1");
  if (funnelProductSelect1) funnel.funnelProductSelect1 = new Choices(funnelProductSelect1, productOption);

  /* 제품별 Page View (PV) 시계열 그래프 - 제품 선택 Select Box */
  const funnelProductSelect2 = document.getElementById("funnelProductSelect2");
  if (funnelProductSelect2) funnel.funnelProductSelect2 = new Choices(funnelProductSelect2, productOption);

  /* 제품별 Unique Visitor (UV) 당 Page View (PV) 시계열 그래프 - 제품 선택 Select Box */
  const funnelProductSelect3 = document.getElementById("funnelProductSelect3");
  if (funnelProductSelect3) funnel.funnelProductSelect3 = new Choices(funnelProductSelect3, productOption);

  /* 제품별 Funnel 분석 - 제품 선택 Select Box */
  const funnelProductSelect4 = document.getElementById("funnelProductSelect4");
  if (funnelProductSelect4)
    funnel.funnelProductSelect4 = new Choices(funnelProductSelect4, {
      searchEnabled: false,
      shouldSort: false,
      maxItemCount: 3,
      removeItemButton: true,
      classNames: {
        removeButton: "remove",
      },
      placeholder: true,
      placeholderValue: "제품을 선택하세요.  ",
    });


  /* 제품별 Funnel 분석 - 제품 선택 Select Box */
  const funnelProductShopRecSelect = document.getElementById("funnelProductShopRecSelect");
  if (funnelProductShopRecSelect)
    funnel.funnelProductShopRecSelect = new Choices(funnelProductShopRecSelect, {
      searchEnabled: false,
      shouldSort: false,
      maxItemCount: 3,
      removeItemButton: true,
      classNames: {
        removeButton: "remove",
      },
      placeholder: true,
      placeholderValue: "라이브 채널을 선택하세요.  ",
    });




  /* 제품별 Funnel 지표 비교 - 제품 선택 Select Box */
  const funnelProductSelect5 = document.getElementById("funnelProductSelect5");
  if (funnelProductSelect5)
    funnel.funnelProductSelect5 = new Choices(funnelProductSelect5, {
      searchEnabled: false,
      shouldSort: false,
      maxItemCount: 3,
      removeItemButton: true,
      classNames: {
        removeButton: "remove",
      },
      placeholder: true,
      placeholderValue: "제품을 선택하세요.  ",
    });

  /* 제품별 Unique Visitor (UV) 데이터 뷰어 - 콤보 박스 */
  if (document.getElementById("productsVisitorInfo")) {
    let productsVisitorInfo = document.getElementById("productsVisitorInfo");
    const cProductsVisitorInfo = new Choices(productsVisitorInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cProductsVisitorInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let productsVisitorInfoList = [
      { value: "yoy", label: "전년도 동기 누적 대비 누적 방문자 TOP5" },
      { value: "mom", label: "전년 동월 대비 방문자 TOP5" },
      { value: "mon", label: "월별 방문자 TOP5" },
    ];
    cProductsVisitorInfo.setChoices(productsVisitorInfoList, "value", "label", true);
    cProductsVisitorInfo.setChoiceByValue("yoy");

    productsVisitorInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["productVisitorsCumulativeVisitorsYoY" /* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 방문자 TOP 5 */],
        mom: ["productVisitorsVisitorsMoM" /* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년 동월 대비 방문자 TOP 5 */],
        mon: ["productVisitorsMonthlyVisitors" /* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 월별 방문자 TOP 5 */],
      };
      let params = {
        params: { BASE_MNTH: `'${initData.base_mnth}'` },
        menu: "dashboards/common",
        tab: "funnel",
        dataList: dataList[type],
      };
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          funnel[key] = data[key];
        });
        let last_year_month_vist = document.getElementById("last_year_month_vist");
        switch (type) {
          case "yoy":
            last_year_month_vist.style.display = "none";
            funnel.productVisitorsCumulativeVisitorsYoYUpdate();
            break;
          case "mom":
            last_year_month_vist.style.display = "block";
            funnel.productVisitorsVisitorsMoMUpdate();
            break;
          case "mon":
            last_year_month_vist.style.display = "none";
            funnel.productVisitorsMonthlyVisitorsUpdate();
            break;
        }
      });
    });
  }

  /* 제품별 Page View (PV) 데이터 뷰어 - 콤보 박스 */
  if (document.getElementById("prodPageListInfo")) {
    let prodPageListInfo = document.getElementById("prodPageListInfo");
    const cProdPageListInfo = new Choices(prodPageListInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cProdPageListInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let prodPageListInfoList = [
      { value: "yoy", label: "전년도 동기 누적 대비 누적 페이지뷰 TOP5" },
      { value: "mom", label: "전년 동월 대비 페이지뷰 TOP5" },
      { value: "mon", label: "월별 페이지뷰 TOP5" },
    ];
    cProdPageListInfo.setChoices(prodPageListInfoList, "value", "label", true);
    cProdPageListInfo.setChoiceByValue("yoy");

    prodPageListInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["productPageViewsCumulativePageViewsYoY" /* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */],
        mom: ["productPageViewsPageViewsMoM" /* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년 동월 대비 페이지뷰 TOP 5 */],
        mon: ["productPageViewsMonthlyPageViews" /* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 월별 페이지뷰 TOP 5 */],
      };
      let params = {
        params: { BASE_MNTH: `'${initData.base_mnth}'` },
        menu: "dashboards/common",
        tab: "funnel",
        dataList: dataList[type],
      };
      let last_year_month_page = document.getElementById("last_year_month_page");
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          funnel[key] = data[key];
        });
        switch (type) {
          case "yoy":
            last_year_month_page.style.display = "none";
            funnel.productPageViewsCumulativePageViewsYoYUpdate();
            break;
          case "mom":
            last_year_month_page.style.display = "block";
            funnel.productPageViewsPageViewsMoMUpdate();
            break;
          case "mon":
            last_year_month_page.style.display = "none";
            funnel.productPageViewsMonthlyPageViewsUpdate();
            break;
        }
      });
    });
  }

  /* 제품별 Unique Visitor (UV) 당 Page View (PV) 데이터 뷰어 - 콤보 박스 */
  if (document.getElementById("prodVisitPageListInfo")) {
    let prodVisitPageListInfo = document.getElementById("prodVisitPageListInfo");
    const cProdVisitPageListInfo = new Choices(prodVisitPageListInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cProdVisitPageListInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let prodVisitPageListInfoList = [
      { value: "yoy", label: "전년도 동기 누적 대비 누적 방문자당 페이지뷰 TOP5" },
      { value: "mom", label: "전년 동월 대비 방문자당 페이지뷰 TOP5" },
      { value: "mon", label: "월별 방문자당 페이지뷰 TOP5" },
    ];
    cProdVisitPageListInfo.setChoices(prodVisitPageListInfoList, "value", "label", true);
    cProdVisitPageListInfo.setChoiceByValue("yoy");

    prodVisitPageListInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["pagesPerProductVisitorCumulativePagesPerVisitorYoY" /* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */],
        mom: ["pagesPerProductVisitorPagesPerVisitorMoM" /* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년 동월 대비 페이지뷰 TOP 5 */],
        mon: ["pagesPerProductVisitorPagesPerVisitorMonthly" /* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 월별 페이지뷰 TOP 5 */],
      };
      let params = {
        params: { BASE_MNTH: `'${initData.base_mnth}'` },
        menu: "dashboards/common",
        tab: "funnel",
        dataList: dataList[type],
      };
      let last_year_month_vist_page = document.getElementById("last_year_month_vist_page");
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          funnel[key] = data[key];
        });
        switch (type) {
          case "yoy":
            last_year_month_vist_page.style.display = "none";
            funnel.pagesPerProductVisitorCumulativePagesPerVisitorYoYUpdate();
            break;
          case "mom":
            last_year_month_vist_page.style.display = "block";
            funnel.pagesPerProductVisitorPagesPerVisitorMoMUpdate();
            break;
          case "mon":
            last_year_month_vist_page.style.display = "none";
            funnel.pagesPerProductVisitorPagesPerVisitorMonthlyUpdate();
            break;
        }
      });
    });
  }

  /* 제품별 구매 전환율 TOP5 - 콤보 박스 */
  if (document.getElementById("prodBuyChangeListInfo")) {
    let prodBuyChangeListInfo = document.getElementById("prodBuyChangeListInfo");
    const cProdBuyChangeListInfo = new Choices(prodBuyChangeListInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cProdBuyChangeListInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let prodBuyChangeListInfoList = [
      { value: "yoy", label: "전년도 동기 누적 대비 구매 전환율 TOP5" },
      { value: "mom", label: "전년 동월 대비 구매 전환율 TOP5" },
      { value: "mon", label: "월별 구매 전환율 TOP5" },
    ];
    cProdBuyChangeListInfo.setChoices(prodBuyChangeListInfoList, "value", "label", true);
    cProdBuyChangeListInfo.setChoiceByValue("yoy");

    prodBuyChangeListInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["productPCCRCumulativeYoY" /* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */],
        mom: ["productPCCRMoM" /* 17. 제품별 구매 전환율 Top 5 - 전년 동월 대비 구매 전환율 TOP 5 */],
        mon: ["productPCMonthlyCR" /* 17. 제품별 구매 전환율 Top 5 - 월별 구매 전환율 TOP 5 */],
      };
      let params = {
        params: { BASE_MNTH: `'${initData.base_mnth}'` },
        menu: "dashboards/common",
        tab: "funnel",
        dataList: dataList[type],
      };
      let last_year_month_buy_change = document.getElementById("last_year_month_buy_change");
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          funnel[key] = data[key];
        });
        switch (type) {
          case "yoy":
            last_year_month_buy_change.style.display = "none";
            funnel.productPCCRCumulativeYoYUpdate();
            break;
          case "mom":
            last_year_month_buy_change.style.display = "block";
            funnel.productPCCRMoMUpdate();
            break;
          case "mon":
            last_year_month_buy_change.style.display = "none";
            funnel.productPCMonthlyCRUpdate();
            break;
        }
      });
    });
  }

  /* 스토어 Funnel 지표 비교 - 콤보 박스 */
  if (document.getElementById("storeFunnelListInfo")) {
    let storeFunnelListInfo = document.getElementById("storeFunnelListInfo");
    const cStoreFunnelListInfo = new Choices(storeFunnelListInfo, {
      searchEnabled: false,
      shouldSort: false,
    });
    // 선택 항목 초기화 (선택 해제)
    cStoreFunnelListInfo.clearChoices();

    // option 엘리먼트 생성 및 추가
    let storeFunnelListInfoList = [
      { value: "yoy", label: "전년도 동기 누적 대비 비교" },
      { value: "mom", label: "전년 동월 대비 비교" },
      { value: "mon", label: "당해 연도 월별 비교" },
      { value: "wek", label: "당해 연도 주차별 비교" },
    ];
    cStoreFunnelListInfo.setChoices(storeFunnelListInfoList, "value", "label", true);
    cStoreFunnelListInfo.setChoiceByValue("yoy");

    storeFunnelListInfo.addEventListener("change", function (val) {
      let type = this.value;
      let dataList = {
        yoy: ["storeFunnelMetricYoY" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */],
        mom: ["storeFunnelMetricMoM" /* 18. 스토어 Funnel 지표 비교 - B. 전년 동월대비 비교 SQL */],
        mon: ["storeFunnelMetricMon" /* 18. 스토어 Funnel 지표 비교 - C. 당해 연도 월별 비교 SQL */],
        wek: ["storeFunnelMetricWek" /* 18. 스토어 Funnel 지표 비교 - D. 당해 연도 주차별 비교 SQL */],
      };
      let params = {
        params: { BASE_MNTH: `'${initData.base_mnth}'` },
        menu: "dashboards/common",
        tab: "funnel",
        dataList: dataList[type],
      };
      getData(params, function (data) {
        Object.keys(data).forEach((key) => {
          funnel[key] = data[key];
        });
        switch (type) {
          case "yoy":
            funnel.storeFunnelMetricYoYUpdate();
            break;
          case "mom":
            funnel.storeFunnelMetricMoMUpdate();
            break;
          case "mon":
            funnel.storeFunnelMetricMonUpdate();
            break;
          case "wek":
            funnel.storeFunnelMetricWekUpdate();
            break;
        }
      });
    });
  }

  // 이벤트 핸들러 함수를 배열로 정의합니다.
  funnel.resizeHandlers = [
    funnel.chartLineFunnel.resize,
    funnel.chartLineFunnelClickPerson.resize,
    funnel.chartLineFunnelClick.resize,
    funnel.chartLineFunnelClickPerImpress.resize,
    funnel.chartLineFunnelClickConversionRate.resize,
    funnel.chartFunnelChannelFunnel.resize,
    funnel.chartFunnelProdShopRecFunnel1.resize,
    funnel.chartFunnelProdShopRecFunnel2.resize,
    funnel.chartFunnelProdShopRecFunnel3.resize,
    
    // funnel.chartLineProdVisitor.resize,
    // funnel.chartLineChannelPage.resize,
    // funnel.chartLineProdPage.resize,
    // funnel.chartLineChannelVisitPage.resize,
    // funnel.chartLineProdVisitPage.resize,
    // funnel.chartFunnelChannelFunnel.resize,
    // funnel.chartFunnelProdFunnel1.resize,
    // funnel.chartFunnelProdFunnel2.resize,
    // funnel.chartFunnelProdFunnel3.resize,
  ];
  // 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
  funnel.resizeHandlers.forEach((handler) => {
    window.addEventListener("resize", handler);
  });

  let dataList = [
    "product" /* 제품 선택 */,
    "yearMonthWeek" /* 당해 연도 월/주차 SQL */,
    "channelImpression" /* 1. 채널 노출 수  - 시계열 그래프 SQL */,
    "yearlyChannelImpression" /* 2. 당해 연도 채널 노출 수  - 표 SQL */,
    "channelClickPerson" /* 3. 채널 클릭한 사람 수  - 시계열 그래프  SQL */,
    "yearlyChannelClickPerson"/* 4. 당해 연도  채널 클릭한 사람 수  - 표 SQL */,
    "channelClick" /* 5. 채널 클릭 수  - 시계열 그래프  SQL */,
    "yearlyChannelClick"/* 6. 당해 연도  채널 클릭 수  - 표 SQL */,
    "channelClickPerImpress"/* 7. 클릭당 노출 수 -  시계열 그래프 SQL */,
    "channelClickConversionRate"/* 8. 클릭 전환율 수 -  시계열 그래프 SQL */,
    "channelFunnelAnalysis" /* 9. 채널 퍼널분석 - 퍼널 그래프 SQL */,
    "channelConversionRateAnalysis" /* 10. 채널 전환율 분석 - 표 SQL */,
    "yearlyChannelPurchaseConversionRate" /* 11. 당해 연도 채널 구매전환율 - 표 SQL */,
    "channelFunnelSearchAnalysis" /* 12. 검색경로 라이브 퍼널분석 - 퍼널 그래프 SQL */,
    "channelSearchConversionRateAnalysis" /* 13. 검색경로 라이브 전환율 분석 - 표 SQL */,
    "yearlyChannelSearchPurchaseConversionRate" /* 14. 당해 연도 채널 구매전환율 - 표 SQL */,
    "channelFunnelShopRecAnalysis" /* 15. 쇼핑 추천 경로 라이브 퍼널분석 - 퍼널 그래프 SQL */,
    "channelShopRecConversionRateAnalysis" /* 16. 쇼핑 추천 경로  라이브 전환율 분석 - 표 SQL */,
    "yearlyChannelShopRecPurchaseConversionRate" /* 17. 당해 연도 쇼핑 추천 경로  채널 구매전환율 - 표 SQL */,
    "productPCCRCumulativeYoY" /* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */,
    "storeFunnelMetricYoY" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,
    "storeFunnelMetricMoM" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,
    "storeFunnelMetricMon" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,
    "storeFunnelMetricWek" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,
    "productFunnelMetricWek"  /* 18. 라이브별 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,




    // "yearlyChannelClick" /* 4. 당해 연도 채널 클릭수  - 표 SQL */,
    // "productVisitorsCumulativeVisitorsYoY" /* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 방문자 TOP 5 */,
    // "channelPageViews" /* 5. Page View (PV) - 시계열 그래프 SQL */,
    // "yearlyChannelPageViews" /* 6. Page View (PV) 추이 분석 - 표 SQL */,
    // "productPageViewsCumulativePageViewsYoY" /* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */,
    // "pageViewsPerChannelVisitor" /* 9. 체널 Unique Visitor (UV) 당 Page View (PV) - 시계열 그래프 SQL */,
    // "pageViewsPerYearlyChannelVisitor" /* 10. Unique Visitor (UV) 당 Page View (PV) 추이 분석 - 표 SQL */,
    // "pagesPerProductVisitorCumulativePagesPerVisitorYoY" /* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */,
    // "channelFunnelAnalysis" /* 13. 채널 퍼널분석 - 퍼널 그래프 SQL */,
    // "channelConversionRateAnalysis" /* 14. 채널 전환율 분석 - 표 SQL */,
    // "yearlyChannelPurchaseConversionRate" /* 15. 당해 연도 채널 구매전환율 - 표 SQL */,
    // "productPCCRCumulativeYoY" /* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */,
    // "storeFunnelMetricYoY" /* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */,
  ];
  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, BASE_YEAR: `'${initData.base_year}'`, PROD_ID: `'51255454543,30630284395,73301786234'` },
    menu: "dashboards/common",
    tab: "funnel",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      funnel[key] = data[key];
    });
    funnel.setDataBinding();
  });
};
