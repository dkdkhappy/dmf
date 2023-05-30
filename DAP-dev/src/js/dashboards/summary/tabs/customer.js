let cust = {};
cust.tmallChartType = "RATE";
cust.douyinChartType = "RATE";
/* zoomData */
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

cust.setDataBinding = function () {
  /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */
  if (Object.keys(cust.tmallVisitorTimeSeriesData).length > 0) {
    cust.tmallVisitorTimeSeriesDataUpdate();
  }
  /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */
  if (Object.keys(cust.tmallVisitorTimeSeriesGraph).length > 0) {
    cust.tmallVisitorTimeSeriesGraphUpdate();
  }
  /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */
  if (Object.keys(cust.tmallVisitorTimeSeriesGrid).length > 0) {
    cust.tmallVisitorTimeSeriesGridUpdate();
  }
  /* 2. Tmall 방문자 수 Break Down - 그래프 SQL */
  if (Object.keys(cust.tmallVisitorBreakDown).length > 0) {
    cust.tmallVisitorBreakDownUpdate();
  }
  /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */
  if (Object.keys(cust.douyinVisitorTimeSeriesData).length > 0) {
    cust.douyinVisitorTimeSeriesDataUpdate();
  }
  /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */
  if (Object.keys(cust.douyinVisitorTimeSeriesGraph).length > 0) {
    cust.douyinVisitorTimeSeriesGraphUpdate();
  }
  /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */
  if (Object.keys(cust.douyinVisitorTimeSeriesGrid).length > 0) {
    cust.douyinVisitorTimeSeriesGridUpdate();
  }
  /* 4. Douyin 방문자 수 Break Down - 그래프 SQL */
  if (Object.keys(cust.douyinVisitorBreakDown).length > 0) {
    cust.douyinVisitorBreakDownUpdate();
  }
  /* 5. 채널별 검색 지표 Break Down - Tmall 선택 SQL */
  if (Object.keys(cust.channelBreakDownTmallSelect).length > 0) {
    cust.channelBreakDownTmallSelectUpdate();
  }
  /* 5. 채널별 검색 지표 Break Down - Tmall 그래프 SQL */
  if (Object.keys(cust.channelBreakDownTmallChart).length > 0) {
    cust.channelBreakDownTmallChartUpdate();
  }
  /* 5. 채널별 검색 지표 Break Down - Douyin 선택 SQL */
  if (Object.keys(cust.channelBreakDownDouyinSelect).length > 0) {
    cust.channelBreakDownDouyinSelectUpdate();
  }
  /* 5. 채널별 검색 지표 Break Down - Douyin 그래프 SQL */
  if (Object.keys(cust.channelBreakDownDouyinChart).length > 0) {
    cust.channelBreakDownDouyinChartUpdate();
  }
  /* 6. 지역 분포 그래프 - Map Chart SQL */
  if (Object.keys(cust.regionalDistributionMapChart).length > 0) {
    cust.regionalDistributionMapChartUpdate();
  }
  /* 6. 지역 분포 그래프 - 표 SQL */
  if (Object.keys(cust.regionalDistributionGrid).length > 0) {
    cust.regionalDistributionGridUpdate();
  }
  /* 7. 성별 그래프 - 그래프 SQL */
  if (Object.keys(cust.genderDistributionChart).length > 0) {
    cust.genderDistributionChartUpdate();
  }
  /* 7. 성별 그래프 - 표 SQL */
  if (Object.keys(cust.genderDistributionGrid).length > 0) {
    cust.genderDistributionGridUpdate();
  }
  /* 8. 연령별 그래프 Tmall - 그래프 SQL */
  if (Object.keys(cust.ageGroupChartTmall).length > 0) {
    cust.ageGroupChartTmallUpdate();
  }
  /* 8. 연령별 그래프 Douyin - 그래프 SQL */
  if (Object.keys(cust.ageGroupChartDouyin).length > 0) {
    cust.ageGroupChartDouyinUpdate();
  }
  /* 8. 연령별 그래프 Tmall - 표 SQL */
  if (Object.keys(cust.ageGroupGridTmall).length > 0) {
    cust.ageGroupGridTmallUpdate();
  }
  /* 8. 연령별 그래프 Douyin - 표 SQL */
  if (Object.keys(cust.ageGroupGridDouyin).length > 0) {
    cust.ageGroupGridDouyinUpdate();
  }
  /* number counting 처리 */
  counter();
};

/************************************************** Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 ******************************************************/
cust.tmallVisitorTimeSeriesDataUpdate = function () {
  let rawData = cust.tmallVisitorTimeSeriesData;
  if (document.getElementById("tmall_time_series_vist_cnt")) {
    document.getElementById("tmall_time_series_vist_cnt").setAttribute("data-target", rawData[0]["vist_cnt"]);
    document.getElementById("tmall_time_series_vist_cnt").innerText = 0;
  }

  if (document.getElementById("tmall_time_series_vist_cnt_yoy")) {
    document.getElementById("tmall_time_series_vist_cnt_yoy").setAttribute("data-target", rawData[0]["vist_cnt_yoy"]);
    document.getElementById("tmall_time_series_vist_cnt_yoy").innerText = 0;
  }

  if (document.getElementById("tmall_time_series_visit_rate")) {
    document.getElementById("tmall_time_series_visit_rate").innerText = rawData[0]["vist_rate"] + "%";
  }
};
cust.tmallVisitorTimeSeriesGraphUpdate = function () {
  let rawData = cust.tmallVisitorTimeSeriesGraph;
  if (cust.chartLineTmallVisit) {
    cust.chartLineTmallVisit.setOption(cust.chartLineTmallVisitOption, true);
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

      cust.chartLineTmallVisit.setOption({
        legend: {
          data: lgnd_nm,
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
cust.tmallVisitorTimeSeriesGridUpdate = function () {
  let rawData = cust.tmallVisitorTimeSeriesGrid;
  if (cust.tmallVisitCountList) {
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(Object.values(rawData[i]));
    }
    cust.tmallVisitCountList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 방문자 수 정보에 대한 시계열 그래프 */
cust.chartLineTmallVisitOption = {
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
    data: [],
    axisLine: {
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      rotate: 45,
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
cust.chartLineTmallVisit = echarts.init(document.getElementById("chart-line-tmall-visit"));
cust.chartLineTmallVisit.setOption(cust.chartLineTmallVisitOption);

/* 방문자 수 정보에 대한 데이터 뷰어 */
if (document.getElementById("tmallVisitCountList")) {
  cust.tmallVisitCountList = new gridjs.Grid({
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
  }).render(document.getElementById("tmallVisitCountList"));
}

/*******************************************************************************************************************************************/
/************************************************** Tmall 방문자 수 Break Down ******************************************************/
cust.tmallVisitorBreakDownUpdate = function () {
  let rawData = cust.tmallVisitorBreakDown;

  if (cust.chartStackTmallVisit) {
    cust.chartStackTmallVisit.setOption(cust.chartStackTmallVisitOption, true);

    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

      cust.chartStackTmallVisit.setOption({
        xAxis: {
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
            stack: "add",
            itemStyle: {
              color: "#91cc75",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCT").map((item) => item["y_val"]),
          },
          {
            name: "Tmall 글로벌",
            type: "bar",
            stack: "add",
            itemStyle: {
              color: "#fac858",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGT").map((item) => item["y_val"]),
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
/* Tmall 방문자 수 Break Down */
cust.chartStackTmallVisitOption = {
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
    left: "1%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: ["2022-01", "2022-02", "2022-03", "2022-04", "2022-05", "2022-06", "2022-07", "2022-08", "2022-09", "2022-10", "2022-11", "2022-12"],
    axisLabel: {
      rotate: 45,
    },
  },
  yAxis: [
    {
      type: "value",
    },
  ],
  series: [
    {
      name: "Tmall 내륙",
      type: "bar",
      stack: "add",
      itemStyle: {
        color: "#91cc75",
      },
      data: [],
    },
    {
      name: "Tmall 글로벌",
      type: "bar",
      stack: "add",
      itemStyle: {
        color: "#fac858",
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
cust.chartStackTmallVisit = echarts.init(document.getElementById("chart-stack-tmall-visit"));
cust.chartStackTmallVisit.setOption(cust.chartStackTmallVisitOption);
/*******************************************************************************************************************************************/
/************************************************** Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 ******************************************************/
cust.douyinVisitorTimeSeriesDataUpdate = function () {
  let rawData = cust.douyinVisitorTimeSeriesData;
  if (document.getElementById("douyin_time_series_vist_cnt")) {
    document.getElementById("douyin_time_series_vist_cnt").setAttribute("data-target", rawData[0]["vist_cnt"]);
    document.getElementById("douyin_time_series_vist_cnt").innerText = 0;
  }

  if (document.getElementById("douyin_time_series_vist_cnt_yoy")) {
    document.getElementById("douyin_time_series_vist_cnt_yoy").setAttribute("data-target", rawData[0]["vist_cnt_yoy"]);
    document.getElementById("douyin_time_series_vist_cnt_yoy").innerText = 0;
  }

  if (document.getElementById("douyin_time_series_visit_rate")) {
    document.getElementById("douyin_time_series_visit_rate").innerText = rawData[0]["vist_rate"] + "%";
  }
};
cust.douyinVisitorTimeSeriesGraphUpdate = function () {
  let rawData = cust.douyinVisitorTimeSeriesGraph;
  if (cust.chartLineDouyinVisit) {
    cust.chartLineDouyinVisit.setOption(cust.chartLineDouyinVisitOption, true);
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

      cust.chartLineDouyinVisit.setOption({
        legend: {
          data: lgnd_nm,
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
cust.douyinVisitorTimeSeriesGridUpdate = function () {
  let rawData = cust.douyinVisitorTimeSeriesGrid;
  if (cust.douyinVisitCountList) {
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(Object.values(rawData[i]));
    }
    cust.douyinVisitCountList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 방문자 수 정보에 대한 시계열 그래프 */
cust.chartLineDouyinVisitOption = {
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
    data: [],
    axisLine: {
      lineStyle: {
        color: "#858d98",
      },
    },
    axisLabel: {
      rotate: 45,
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
cust.chartLineDouyinVisit = echarts.init(document.getElementById("chart-line-douyin-visit"));
cust.chartLineDouyinVisit.setOption(cust.chartLineDouyinVisitOption);

/* 방문자 수 정보에 대한 데이터 뷰어 */
if (document.getElementById("douyinVisitCountList")) {
  cust.douyinVisitCountList = new gridjs.Grid({
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
  }).render(document.getElementById("douyinVisitCountList"));
}
/*******************************************************************************************************************************************/
/************************************************** Douyin 방문자 수 Break Down ******************************************************/
cust.douyinVisitorBreakDownUpdate = function () {
  let rawData = cust.douyinVisitorBreakDown;

  if (cust.chartStackDouyinVisit) {
    cust.chartStackDouyinVisit.setOption(cust.chartStackDouyinVisitOption, true);

    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

      cust.chartStackDouyinVisit.setOption({
        xAxis: {
          data: x_dt,
        },
        legend: {
          textStyle: {
            color: "#858d98",
          }
        },
        series: [
          {
            name: "Douyin 내륙",
            type: "bar",
            stack: "add",
            itemStyle: {
              color: "#91cc75",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCD").map((item) => item["y_val"]),
          },
          {
            name: "Douyin 글로벌",
            type: "bar",
            stack: "add",
            itemStyle: {
              color: "#fac858",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGD").map((item) => item["y_val"]),
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
/* Douyin 방문자 수 Break Down */
cust.chartStackDouyinVisitOption = {
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
    left: "1%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "category",
    data: ["2022-01", "2022-02", "2022-03", "2022-04", "2022-05", "2022-06", "2022-07", "2022-08", "2022-09", "2022-10", "2022-11", "2022-12"],
    axisLabel: {
      rotate: 45,
    },
  },
  yAxis: [
    {
      type: "value",
    },
  ],
  series: [
    {
      name: "Douyin 내륙",
      type: "bar",
      stack: "add",
      itemStyle: {
        color: "#91cc75",
      },
      data: [],
    },
    {
      name: "Douyin 글로벌",
      type: "bar",
      stack: "add",
      itemStyle: {
        color: "#fac858",
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
cust.chartStackDouyinVisit = echarts.init(document.getElementById("chart-stack-douyin-visit"));
cust.chartStackDouyinVisit.setOption(cust.chartStackDouyinVisitOption);
/*******************************************************************************************************************************************/
/************************************************** 티몰 지표별 Break Down ******************************************************/
cust.channelBreakDownTmallSelectUpdate = function () {
  let rawData = cust.channelBreakDownTmallSelect;
  let typeList = [];
  rawData.forEach((type) => {
    typeList.push({ value: type.type_id, label: type.type_nm });
  });
  if (cust.tamllType) {
    cust.tamllType.setChoices(typeList, "value", "label", true);
    cust.tamllType.setChoiceByValue("PAID_RATE");
  }
};
cust.channelBreakDownTmallChartUpdate = function () {
  let rawData = cust.channelBreakDownTmallChart;
  if (cust.charLineTmallTableBreakdown) {
    cust.charLineTmallTableBreakdown.setOption(cust.charLineTmallTableBreakdownOption, true);

    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

      cust.charLineTmallTableBreakdown.setOption({
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
            name: [...new Set(rawData.filter((rawData) => "ALL" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#5470c6",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "ALL").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: [...new Set(rawData.filter((rawData) => "DCT" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#73c0de",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCT").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: [...new Set(rawData.filter((rawData) => "DGT" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#91cc75",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DGT").map((item) => item[`y_val_${currency}`]),
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
/* 티몰 지표 별 Break Down */
cust.charLineTmallTableBreakdownOption = {
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
    data: [],
    axisLabel: {
      rotate: 45,
    },
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
cust.charLineTmallTableBreakdown = echarts.init(document.getElementById("chart-line-tmall-table-break-down"));
cust.charLineTmallTableBreakdown.setOption(cust.charLineTmallTableBreakdownOption);

/*******************************************************************************************************************************************/
/************************************************** 도우인 지표별 Break Down ******************************************************/
cust.channelBreakDownDouyinSelectUpdate = function () {
  let rawData = cust.channelBreakDownDouyinSelect;
  let typeList = [];
  rawData.forEach((type) => {
    typeList.push({ value: type.type_id, label: type.type_nm });
  });
  if (cust.douyinType) {
    cust.douyinType.setChoices(typeList, "value", "label", true);
    cust.douyinType.setChoiceByValue("PAID_RATE");
  }
};
cust.channelBreakDownDouyinChartUpdate = function () {
  let rawData = cust.channelBreakDownDouyinChart;
  if (cust.charLineDouyinTableBreakdown) {
    cust.charLineDouyinTableBreakdown.setOption(cust.charLineDouyinTableBreakdownOption, true);
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

      cust.charLineDouyinTableBreakdown.setOption({
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
            name: [...new Set(rawData.filter((rawData) => "ALL" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#5470c6",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "ALL").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: [...new Set(rawData.filter((rawData) => "DCD" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#73c0de",
            },
            data: rawData.filter((item) => item.l_lgnd_id === "DCD").map((item) => item[`y_val_${currency}`]),
          },
          {
            name: [...new Set(rawData.filter((rawData) => "DGD" === rawData.l_lgnd_id).map((rawData) => rawData["l_lgnd_nm"]))][0],
            type: "line",
            itemStyle: {
              color: "#91cc75",
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
/* 도우인 지표 별 Break Down */
cust.charLineDouyinTableBreakdownOption = {
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
    data: [],
    axisLabel: {
      rotate: 45,
    },
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
cust.charLineDouyinTableBreakdown = echarts.init(document.getElementById("chart-line-douyin-table-break-down"));
cust.charLineDouyinTableBreakdown.setOption(cust.charLineDouyinTableBreakdownOption);

/*******************************************************************************************************************************************/
/************************************************** 지역 분포 그래프 ******************************************************/
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
};

// 지역 분포 그래프
if (document.getElementById("summary-chart-map")) {
  cust.chartDom = document.getElementById("summary-chart-map");
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

/*******************************************************************************************************************************************/
/************************************************** 지역 분포 데이터 뷰어 ******************************************************/
cust.regionalDistributionGridUpdate = function () {
  let rawData = cust.regionalDistributionGrid;
  let keysToExtract = ["city_lv_nm", "totl_vist_cnt", "dct_vist_cnt", "dgt_vist_cnt", "dcd_vist_cnt", "dgd_vist_cnt"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (cust.regiDistList) {
    cust.regiDistList.updateConfig({ data: filterData }).forceRender();
  }
};

/* 지역 분포 데이터 뷰어 */
if (document.getElementById("regiDistList")) {
  cust.regiDistList = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "100px",
      },
      {
        name: "전체",
        width: "120px",
      },
      {
        name: "Tmall 내륙",
        width: "120px",
      },
      {
        name: "Tmall 글로벌",
        width: "120px",
      },
      {
        name: "Douyin 내륙",
        width: "120px",
      },
      {
        name: "Douyin 글로벌",
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
  }).render(document.getElementById("regiDistList"));
}

/*******************************************************************************************************************************************/
/************************************************** 성별 그래프 ******************************************************/
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
cust.genderDistributionChartUpdate = function () {
  if (cust.chartGender) {
    const result = cust.genderDistributionChart;
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
    cust.chartGender.setOption({
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

cust.chartGenderOption = {
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

if (document.getElementById("summary-chart-gender")) {
  cust.chartGender = echarts.init(document.getElementById("summary-chart-gender"));
  cust.chartGender.setOption(cust.chartGenderOption);
}

/*******************************************************************************************************************************************/
/************************************************** 성별 데이터 뷰어 ******************************************************/
cust.genderDistributionGridUpdate = function () {
  let rawData = cust.genderDistributionGrid;
  let keysToExtract = ["gndr_nm", "totl_vist_cnt", "dct_vist_cnt", "dgt_vist_cnt", "dcd_vist_cnt", "dgd_vist_cnt"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (cust.genderList) {
    cust.genderList.updateConfig({ data: filterData }).forceRender();
  }
};

/* 성별 데이터 뷰어 */
if (document.getElementById("genderList")) {
  cust.genderList = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "100px",
      },
      {
        name: "전체",
        width: "120px",
      },
      {
        name: "Tmall 내륙",
        width: "120px",
      },
      {
        name: "Tmall 글로벌",
        width: "120px",
      },
      {
        name: "Douyin 내륙",
        width: "120px",
      },
      {
        name: "Douyin 글로벌",
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
  }).render(document.getElementById("genderList"));
};

/*******************************************************************************************************************************************/
/************************************************** Tmall 연령별 그래프 ******************************************************/
cust.ageGroupChartTmallUpdate = function () {
  let rawData = cust.ageGroupChartTmall;
  if (cust.chartBarAgeTmall) {
    cust.chartBarAgeTmall.setOption(cust.chartBarAgeTmallOption, true);
    if (rawData.length > 0) {
      let ageDistributionDataTmall = [];
      rawData.forEach(function (item) {
        ageDistributionDataTmall.push({
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

      cust.chartBarAgeTmall.setOption({
        tooltip: {
          trigger: "axis",
        },
        grid: {
          left: "2%",
          right: "7%",
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
            data: ageDistributionDataTmall,
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

/* 연령 그래프 */
cust.chartBarAgeTmallOption = {
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
}
cust.chartBarAgeTmall = echarts.init(document.getElementById("summary-chart-bar-age-tmall"));
cust.chartBarAgeTmall.setOption(cust.chartBarAgeTmallOption);

/*******************************************************************************************************************************************/
/************************************************** Douyin 연령별 그래프 ******************************************************/
cust.ageGroupChartDouyinUpdate = function () {
  let rawData = cust.ageGroupChartDouyin;
  if (cust.chartBarAgeDouyin) {
    cust.chartBarAgeDouyin.setOption(cust.chartBarAgeDouyinOption, true);
    if (rawData.length > 0) {
      let ageDistributionDataDouyin = [];
      rawData.forEach(function (item) {
        ageDistributionDataDouyin.push({
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

      cust.chartBarAgeDouyin.setOption({
        tooltip: {
          trigger: "axis",
        },
        grid: {
          left: "2%",
          right: "7%",
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
            data: ageDistributionDataDouyin,
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
/* 연령 그래프 */
cust.chartBarAgeDouyinOption = {
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
cust.chartBarAgeDouyin = echarts.init(document.getElementById("summary-chart-bar-age-douyin"));
cust.chartBarAgeDouyin.setOption(cust.chartBarAgeDouyinOption);

/*******************************************************************************************************************************************/
/************************************************** Tmall 연령별 데이터 뷰어 ******************************************************/
cust.ageGroupGridTmallUpdate = function () {
  let rawData = cust.ageGroupGridTmall;
  let keysToExtract = ["age_nm", "totl_vist_cnt", "dct_vist_cnt", "dgt_vist_cnt"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (cust.ageListTmall) {
    cust.ageListTmall.updateConfig({ data: filterData }).forceRender();
  }
};
/* 연령 데이터 뷰어 */
if (document.getElementById("ageListTmall")) {
  cust.ageListTmall = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "180px",
      },
      {
        name: "전체",
        width: "180px",
      },
      {
        name: "Tmall 내륙",
        width: "180px",
      },
      {
        name: "Tmall 글로벌",
        width: "180px",
      }
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
  }).render(document.getElementById("ageListTmall"));
}

/*******************************************************************************************************************************************/
/************************************************** Douyin 연령별 데이터 뷰어 ******************************************************/
cust.ageGroupGridDouyinUpdate = function () {
  let rawData = cust.ageGroupGridDouyin;
  let keysToExtract = ["age_nm", "totl_vist_cnt", "dcd_vist_cnt", "dgd_vist_cnt"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  if (cust.ageListDouyin) {
    cust.ageListDouyin.updateConfig({ data: filterData }).forceRender();
  }
};
/* 연령 데이터 뷰어 */
if (document.getElementById("ageListDouyin")) {
  cust.ageListDouyin = new gridjs.Grid({
    columns: [
      {
        name: "구분",
        width: "180px",
      },
      {
        name: "전체",
        width: "180px",
      },
      {
        name: "Douyin 내륙",
        width: "180px",
      },
      {
        name: "Douyin 글로벌",
        width: "180px",
      }
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
  }).render(document.getElementById("ageListDouyin"));
}

/*******************************************************************************************************************************************/

// 이벤트 핸들러 함수를 배열로 정의합니다.
cust.resizeHandlers = [
  cust.chartLineTmallVisit.resize,
  cust.chartStackTmallVisit.resize,
  cust.chartStackDouyinVisit.resize,
  cust.charLineTmallTableBreakdown.resize,
  cust.charLineDouyinTableBreakdown.resize,
  cust.chartMap.resize,
  cust.chartGender.resize,
  cust.chartBarAgeTmall.resize,
  cust.chartBarAgeDouyin.resize,
];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
cust.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

cust.channelBreakDownTmallChartSearch = function () {
  let datePicker = document.getElementById("tmallTableBreakDown");
  params = {
    params: {
      FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
      TO_MNTH: `'${datePicker.value.slice(-7)}'`,
      TYPE_ID: `'${cust.tamllType.getValue().value}'`,
    },
    menu: "dashboards/summary",
    tab: "customer",
    dataList: ["channelBreakDownTmallChart"],
  };
  getData(params, function (data) {
    cust.channelBreakDownTmallChart = data["channelBreakDownTmallChart"];
    cust.channelBreakDownTmallChartUpdate();
  });
};
cust.channelBreakDownDouyinChartSearch = function () {
  let datePicker = document.getElementById("douyinTableBreakDown");
  params = {
    params: {
      FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
      TO_MNTH: `'${datePicker.value.slice(-7)}'`,
      TYPE_ID: `'${cust.douyinType.getValue().value}'`,
    },
    menu: "dashboards/summary",
    tab: "customer",
    dataList: ["channelBreakDownDouyinChart"],
  };
  getData(params, function (data) {
    cust.channelBreakDownDouyinChart = data["channelBreakDownDouyinChart"];
    cust.channelBreakDownDouyinChartUpdate();
  });
};

cust.updateButtonStyle = function (name, type) {
  let buttonClasses = {
    방문자: ["error", "btn-soft-primary", "btn-primary"],
    "100%": ["nomal", "btn-soft-success", "btn-success"],
  };

  if (typeof type == "object") {
    if (type[0].indexOf("1") > 0) {
      buttonClasses["방문자"].push("dscv1");
      buttonClasses["100%"].push("dscp1");
    } else if (type[0].indexOf("2") > 0) {
      buttonClasses["방문자"].push("dscv2");
      buttonClasses["100%"].push("dscp2");
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

cust.onLoadEvent = function (initData) {
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

  sendGetRequest("/static/json/geo/chn_prov_city_map.json", function (json) {
    cust.chnProvCityMap = json;
  });

  // Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어
  flatpickr("#tmallVisitorTimeSeriesViewer", {
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
          tab: "customer",
          dataList: ["tmallVisitorTimeSeriesGraph"],
        };
        getData(params, function (data) {
          cust.tmallVisitorTimeSeriesGraph = {};
          if (data["tmallVisitorTimeSeriesGraph"] != undefined) {
            cust.tmallVisitorTimeSeriesGraph = data["tmallVisitorTimeSeriesGraph"];
            cust.tmallVisitorTimeSeriesGraphUpdate();
          }
        });
      }
    },
  });

  // Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어
  flatpickr("#douyinVisitorTimeSeriesViewer", {
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
          tab: "customer",
          dataList: ["douyinVisitorTimeSeriesGraph"],
        };
        getData(params, function (data) {
          cust.douyinVisitorTimeSeriesGraph = {};
          if (data["douyinVisitorTimeSeriesGraph"] != undefined) {
            cust.douyinVisitorTimeSeriesGraph = data["douyinVisitorTimeSeriesGraph"];
            cust.douyinVisitorTimeSeriesGraphUpdate();
          }
        });
      }
    },
  });

  // Tmall 방문자 수 BreakDown
  flatpickr("#tmallVisitBreakDownFlatpickr", {
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
            CHRT_TYPE: `'${cust.tmallChartType}'`,
          },
          menu: "dashboards/summary",
          tab: "customer",
          dataList: ["tmallVisitorBreakDown"],
        };
        getData(params, function (data) {
          cust.tmallVisitorBreakDown = {};
          if (data["tmallVisitorBreakDown"] != undefined) {
            cust.tmallVisitorBreakDown = data["tmallVisitorBreakDown"];
            cust.tmallVisitorBreakDownUpdate();
          }
        });
      }
    },
  });

  // Douyin 방문자 수 BreakDown
  flatpickr("#douyinVisitBreakDownFlatpickr", {
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
            CHRT_TYPE: `'${cust.douyinChartType}'`,
          },
          menu: "dashboards/summary",
          tab: "customer",
          dataList: ["douyinVisitorBreakDown"],
        };
        getData(params, function (data) {
          cust.douyinVisitorBreakDown = {};
          if (data["douyinVisitorBreakDown"] != undefined) {
            cust.douyinVisitorBreakDown = data["douyinVisitorBreakDown"];
            cust.douyinVisitorBreakDownUpdate();
          }
        });
      }
    },
  });

  // Tmall 지표별 BreakDown
  flatpickr("#tmallTableBreakDown", {
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
  });

  // Douyin 지표별 BreakDown
  flatpickr("#douyinTableBreakDown", {
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
  });

  if (document.getElementById("tamll_type")) {
    const tamllType = document.getElementById("tamll_type");
    if (!cust.tamllType) {
      cust.tamllType = new Choices(tamllType, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }
  if (document.getElementById("douyin_type")) {
    const douyinType = document.getElementById("douyin_type");
    if (!cust.douyinType) {
      cust.douyinType = new Choices(douyinType, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }

  let btnSm = document.querySelectorAll(".btn-smy-cust");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let chrtType = chkTxt == "방문자" ? "CNT" : "RATE";
      let classList = this.classList.value.split(" ");
      let dataList = [];
      let datePicker;
      if (classList[0].indexOf("1") > 0) {
        dataList = ["tmallVisitorBreakDown"];
        datePicker = document.getElementById("tmallVisitBreakDownFlatpickr");
        cust.tmallChartType = chrtType;
      } else if (classList[0].indexOf("2") > 0) {
        dataList = ["douyinVisitorBreakDown"];
        datePicker = document.getElementById("douyinVisitBreakDownFlatpickr");
        cust.douyinChartType = chrtType;
      }

      cust.updateButtonStyle(chkTxt, classList);
      let params = {
        params: {
          FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
          TO_MNTH: `'${datePicker.value.slice(-7)}'`,
          CHRT_TYPE: `'${chrtType}'`,
        },
        menu: "dashboards/summary",
        tab: "customer",
        dataList: dataList,
      };
      getData(params, function (data) {
        if (classList[0].indexOf("1") > 0) {
          cust.tmallVisitorBreakDown = data["tmallVisitorBreakDown"];
          cust.tmallVisitorBreakDownUpdate();
        } else if (classList[0].indexOf("2") > 0) {
          cust.douyinVisitorBreakDown = data["douyinVisitorBreakDown"];
          cust.douyinVisitorBreakDownUpdate();
        }
      });
    });
  });

  let dataList = [
    "tmallVisitorTimeSeriesData" /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */,
    "tmallVisitorTimeSeriesGraph" /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */,
    "tmallVisitorTimeSeriesGrid" /* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */,
    "tmallVisitorBreakDown" /* 2. Tmall 방문자 수 Break Down - 그래프 SQL */,
    "douyinVisitorTimeSeriesData" /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */,
    "douyinVisitorTimeSeriesGraph" /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */,
    "douyinVisitorTimeSeriesGrid" /* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */,
    "douyinVisitorBreakDown" /* 4. Douyin 방문자 수 Break Down - 그래프 SQL */,
    "channelBreakDownTmallSelect" /* 5. 채널별 검색 지표 Break Down - Tmall 선택 SQL */,
    "channelBreakDownTmallChart" /* 5. 채널별 검색 지표 Break Down - Tmall 그래프 SQL */,
    "channelBreakDownDouyinSelect" /* 5. 채널별 검색 지표 Break Down - Douyin 선택 SQL */,
    "channelBreakDownDouyinChart" /* 5. 채널별 검색 지표 Break Down - Douyin 그래프 SQL */,
    "regionalDistributionMapChart" /* 6. 지역 분포 그래프 - Map Chart SQL */,
    "regionalDistributionGrid" /* 6. 지역 분포 그래프 - 표 SQL */,
    "genderDistributionChart" /* 7. 성별 그래프 - 그래프 SQL */,
    "genderDistributionGrid" /* 7. 성별 그래프 - 표 SQL */,
    "ageGroupChartTmall" /* 8. Tmall 연령별 그래프 - 그래프 SQL */,
    "ageGroupChartDouyin" /* 8. Douyin 연령별 그래프 - 그래프 SQL */,
    "ageGroupGridTmall" /* 8. Tmall 연령별 그래프 - 표 SQL */,
    "ageGroupGridDouyin" /* 8. Douyin 연령별 그래프 - 표 SQL */,
  ];
  let params = {
    params: {
      FR_DT: `'${initData.fr_dt}'`,
      TO_DT: `'${initData.to_dt}'`,
      FR_MNTH: `'${initData.fr_dt.substring(0, 7)}'`,
      TO_MNTH: `'${initData.to_dt.substring(0, 7)}'`,
      BASE_MNTH: `'${initData.base_mnth}'`,
      BASE_YEAR: `'${initData.base_year}'`,
      CHRT_TYPE: `'RATE'`,
      TYPE_ID: `'PAID_RATE'`,
    },
    menu: "dashboards/summary",
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
    cust.updateButtonStyle("100%", "all");
    cust.setDataBinding();
  });
};
