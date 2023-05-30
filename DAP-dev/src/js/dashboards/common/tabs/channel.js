let chan = {};
chan.CHNL_NM = "Tmall Global";
chan.onloadStatus = false; // 화면 로딩 상태
chan.importantInfoCardData = {}; /* 중요 정보 카드 */
chan.chrtType = "AMT";

chan.setDataBinding = function () {
  /* flatpickr */
  let waterFallChartDatePickers = flatpickr("#waterFallChartDate, #monthTrendChartDate, #expenseTrendChartDate, #expenseBreakdownDate", {
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
    defaultDate: [`${chan.cmAnalysis[0]["fr_mnth"]}`, `${chan.cmAnalysis[0]["to_mnth"]}`],
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        let elId = this.element.id;
        let fromMonth = getMonthFormatter(selectedDates[0]);
        let toMonth = getMonthFormatter(selectedDates[1]);
        let dataList = [];

        if (elId == "waterFallChartDate") {
          dataList = ["waterFallChart"];
        } else if (elId == "monthTrendChartDate") {
          dataList = ["cmTrendAnalysis"];
        } else if (elId == "expenseTrendChartDate") {
          dataList = ["selectedCostCmTrendAnalysisChart"];
        } else if (elId == "expenseBreakdownDate") {
          dataList = ["costItemBreakdown"];
        }
        let params = {
          params: {
            FR_MNTH: `'${fromMonth}'`,
            TO_MNTH: `'${toMonth}'`,
            CHNL_NM: `'${chan.CHNL_NM}'`,
            COST_ID: `'${chan.choicesCmTrendSelect.getValue().value}'`,
            CHRT_TYPE: `'${chan.chrtType}'`,
          },
          menu: "dashboards/common",
          tab: "channel",
          dataList: dataList,
        };
        getData(params, function (data) {
          if (elId == "waterFallChartDate") {
            chan.waterFallChart = {};
            chan.waterFallChartCmLine = {};
            if (data["waterFallChartCmLine"] != undefined) {
              chan.waterFallChartCmLine = data["waterFallChartCmLine"];
            }
            if (data["waterFallChart"] != undefined) {
              chan.waterFallChart = data["waterFallChart"];
              chan.waterFallChartUpdate();
            }
          } else if (elId == "monthTrendChartDate") {
            chan.cmTrendAnalysis = data["cmTrendAnalysis"];
            chan.cmTrendAnalysisUpdate();
          } else if (elId == "expenseTrendChartDate") {
            chan.selectedCostCmTrendAnalysisChart = data["selectedCostCmTrendAnalysisChart"];
            chan.selectedCostCmTrendAnalysisChartUpdate();
          } else if (elId == "expenseBreakdownDate") {
            chan.costItemBreakdown = data["costItemBreakdown"];
            chan.costItemBreakdownUpdate("AMT");
          }
        });
      }
    },
  });

  /* 1. 중요정보 카드 - 금액 SQL  */
  if (Object.keys(chan.importantInfoCardData).length > 0) {
    chan.importantInfoCardDataUpdate();
  }
  /* 1. 중요정보 카드 - 그래프 SQL  */
  if (Object.keys(chan.importantInfoCardData).length > 0) {
    chan.importantInfoCardChartUpdate();
  }
  /* Contribution Margin Waterfall Chart  */
  if (Object.keys(chan.cmAnalysis).length > 0) {
    let params = {
      params: {
        FR_MNTH: `'${chan.cmAnalysis[0]["fr_mnth"]}'`,
        TO_MNTH: `'${chan.cmAnalysis[0]["to_mnth"]}'`,
        CHNL_NM: `'${chan.CHNL_NM}'`,
        CHRT_TYPE: `'${chan.chrtType}'`,
      },
      menu: "dashboards/common",
      tab: "channel",
      dataList: ["waterFallChart", "waterFallChartCmLine", "cmTrendAnalysis", "costItemBreakdown"],
    };
    getData(params, function (data) {
      chan.waterFallChart = {};
      chan.waterFallChartCmLine = {};
      /* 5. Contribution Margin Waterfall Chart - 그래프 SQL */
      if (data["waterFallChartCmLine"] != undefined) {
        chan.waterFallChartCmLine = data["waterFallChartCmLine"];
      }
      if (data["waterFallChart"] != undefined) {
        chan.waterFallChart = data["waterFallChart"];
        chan.waterFallChartUpdate();
      }
      if (data["cmTrendAnalysis"] != undefined) {
        chan.cmTrendAnalysis = data["cmTrendAnalysis"];
        chan.cmTrendAnalysisUpdate();
      }
      if (data["costItemBreakdown"] != undefined) {
        chan.costItemBreakdown = data["costItemBreakdown"];
        chan.costItemBreakdownUpdate(chan.chrtType);
      }
    });
  }
  /* 7.비용 항목 별 월별 트렌드 분석 - 비용 선택 SQL */
  if (Object.keys(chan.selectedCostCmTrendAnalysis).length > 0) {
    chan.selectedCostCmTrendAnalysisUpdate();
  }

  /* number counting 처리 */
  counter();
};
/******************************************************** Revenue, COGS, Gross Profit, Contribution Margin ***************************************************/
/**
 *  1. 중요정보 카드 - 금액 SQL
 */
chan.importantInfoCardDataUpdate = function () {
  let rawData = chan.importantInfoCardData[0];
  // 상단 중요정보 카드
  //revn_amt  : Revenue              cogs_amt       : COGS                       gp_amt       : Gross Profit         cm_amt  : Contribution Margin
  //revn_rate : Revenue 증감률       cogs_rate      : COGS 증감률                gp_rate      : Gross Profit 증감률   cm_rate : Contribution Margin
  //cm_rate   : 매출대비 COGS        gogs_revn_rate : 매출대비 Gross Profit      cm_revn_rate : 매출대비 Contribution Margin
  const cardAreaList = ["revn_amt", "revn_rate", "cogs_amt", "cogs_rate", "gp_amt", "gp_rate", "cm_amt", "cm_rate", "gogs_revn_rate", "gp_revn_rate", "cm_revn_rate"];
  cardAreaList.forEach((cardArea) => {
    const el = document.getElementById(`${cardArea}`);
    if (el) {
      if (cardArea.indexOf("_rate") > -1) {
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
          el.innerText = rawData[`${cardArea}`] + "%";
        } else {
          el.innerText = rawData[`${cardArea}`] + "%";
        }
      } else {
        const dataTarget = rawData[`${cardArea}`];
        el.innerText = 0;
        el.setAttribute("data-target", dataTarget);
      }
    }
  });
};

chan.importantInfoCardChartUpdate = function () {
  let rawData = chan.importantInfoCardChart;

  // 상단 중요정보 카드 - 그래프
  let {
    CM = [],
    COGS = [],
    GP = [],
    REVN = [],
  } = rawData.reduce((arr, chart) => {
    arr[chart["chrt_key"]] ? arr[chart["chrt_key"]].push(chart) : (arr[chart["chrt_key"]] = [chart]);
    return arr;
  }, {});

  let cmData = CM.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val`]),
    })),
    cogsData = COGS.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val`]),
    })),
    gpData = GP.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val`]),
    })),
    revnData = REVN.map((d) => ({
      x: d["x_dt"],
      y: Number(d[`y_val`]),
    }));

  /* 중요 정보 카드 : Revenue */
  if (chan.revenueCount) {
    chan.revenueCount.updateSeries([
      {
        data: revnData,
      },
    ]);
  }
  /* 중요 정보 카드 : COGS */
  if (chan.cogsCount) {
    chan.cogsCount.updateSeries([
      {
        data: cogsData,
      },
    ]);
  }
  /* 중요 정보 카드 : Gross Profit */
  if (chan.grossProfitCount) {
    chan.grossProfitCount.updateSeries([
      {
        data: gpData,
      },
    ]);
  }
  /* 중요 정보 카드 : Contribution Margin */
  if (chan.contriMarginCount) {
    chan.contriMarginCount.updateSeries([
      {
        data: cmData,
      },
    ]);
  }
};

chan.apexDefaultOptions = {
  series: [
    {
      name: "매출",
      data: [],
    },
  ],
  chart: {
    width: 130,
    height: 130,
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
  colors: getChartColorsArray("grossProfitCount"),
};

/* 중요 정보 카드 : Revenue */
if (document.querySelector("#revenueCount")) {
  chan.revenueCount = new ApexCharts(document.querySelector("#revenueCount"), chan.apexDefaultOptions);
  chan.revenueCount.render();
}
/* 중요 정보 카드 : COGS */
if (document.querySelector("#cogsCount")) {
  chan.cogsCount = new ApexCharts(document.querySelector("#cogsCount"), chan.apexDefaultOptions);
  chan.cogsCount.render();
}
/* 중요 정보 카드 : Gross Profit */
if (document.querySelector("#grossProfitCount")) {
  chan.grossProfitCount = new ApexCharts(document.querySelector("#grossProfitCount"), chan.apexDefaultOptions);
  chan.grossProfitCount.render();
}
/* 중요 정보 카드 : Contribution Margin */
if (document.querySelector("#contriMarginCount")) {
  chan.contriMarginCount = new ApexCharts(document.querySelector("#contriMarginCount"), chan.apexDefaultOptions);
  chan.contriMarginCount.render();
}

/*******************************************************************************************************************************************************/
/******************************************************** Contribution Margin Waterfall Chart ***************************************************/
chan.createWaterfallData = function (income, expenses) {
  let waterfallData = [["barLabel", "barStartValue", "barEndValue", "referenceDatapoint"]];
  let legend = ["매출", "COGS", "광고비(영업본부)", "광고비(무상지원)", "판매수수료", "물류비", "CM"];
  let cumulativeTotal = 0;
  for (let i = 0; i < income.length; i++) {
    let incomeVal = income[i];
    let expenseVal = expenses[i];
    // 수입 또는 지출이 없는 경우 건너뜁니다.
    if (incomeVal === "-" && expenseVal === "-") {
      continue;
    }
    let barStartValue = cumulativeTotal;
    if (incomeVal !== "-") {
      cumulativeTotal += Number(incomeVal);
      waterfallData.push([`${legend[i]}`, barStartValue, cumulativeTotal]);
    }
    if (expenseVal !== "-") {
      cumulativeTotal -= Number(expenseVal);
      waterfallData.push([`${legend[i]}`, barStartValue, cumulativeTotal]);
    }
  }
  return chan.roundToTwoDecimalPlaces(waterfallData);
};

chan.roundToTwoDecimalPlaces = function (arr) {
  let resultArr = [];
  for (let i = 0; i < arr.length; i++) {
    let innerArr = [];
    for (let j = 0; j < arr[i].length; j++) {
      if (typeof arr[i][j] === "number") {
        innerArr.push(parseFloat(arr[i][j].toFixed(2)));
      } else {
        innerArr.push(arr[i][j]);
      }
    }
    resultArr.push(innerArr);
  }
  return resultArr;
};

chan.chartThemeColor = ["#0076A8", "#00A3E0", "#1FBCFF", "#5ACEFF", "#78D6FF", "#A0DCFF", "#C3EDFF"];

chan.hasReferenceData = false;
chan.waterFallChartUpdate = function () {
  if (chan.chartWaterFallChannel) {
    let rawData = chan.waterFallChart;
    let lineValue = chan.waterFallChartCmLine;
    let income = rawData.find((obj) => obj.cost_nm === "수익");
    let expenses = rawData.find((obj) => obj.cost_nm === "비용");
    income = income.y_val.replaceAll(" ", "").replaceAll(/'/g, "").split(",");
    expenses = expenses.y_val.replaceAll(" ", "").replaceAll(/'/g, "").split(",");

    let waterfallData = chan.createWaterfallData(income, expenses);
    chan.lastBarIndex = waterfallData.length - 2;
    chan.chartWaterFallChannel.setOption(chan.chartWaterFallChannelOption, true);
    if (rawData.length > 0) {
      chan.chartWaterFallChannel.setOption(
        {
          tooltip: {
            trigger: "axis",
            axisPointer: {
              type: "shadow",
            },
            formatter: function (params) {
              let tar = params[0];
              let minus = tar.value[2] - tar.value[1];
              let color;
              let changeText = "";
              if (tar.name == "CM") {
                changeText = `${addCommas(tar.value[1])}`;
                color = "#90cb75";
              } else {
                changeText = `${addCommas(tar.value[1])}` + " → " + `${addCommas(tar.value[2])}`;
                if (minus > 0) {
                  color = "#5470c6";
                } else if (minus == 0) {
                  color = "#ededed";
                } else {
                  color = "#ee6666";
                }
              }
              return (
                "<span style='display: inline-block;margin-right:20px;margin-top:4px;'>" +
                `${tar.value[0]}` +
                "</span><br />" +
                "<span style='display:inline-block;margin-right:6px;border-radius:10px;width:10px;height:10px;background-color:" +
                color +
                ";'></span>" +
                "<span style='font-weight:bold;'>" +
                changeText +
                "</span>" +
                "<br />"
              );
            },
          },
          toolbox: {
            left: "right",
            top: "center",
            orient: "vertical",
            feature: {
              saveAsImage: {},
              dataView: {},
              //myCustomDataButton: myCustomDataButton(),
            },
          },
          grid: {
            left: "2%",
            right: "5%",
            bottom: "0",
            top: "15%",
            containLabel: true,
          },
          dataset: {
            source: waterfallData,
          },
          xAxis: {
            show: true,
            type: "category",
            axisLabel: {
              rotate: 45,
            },
          },
          yAxis: [
            {
              type: "value",
              name: "금액 (단위 : 백만원)"
            },
          ],
          series: [
            {
              type: "custom",
              label: {
                show: true,
                position: "top",
                color: "#97999b",
                fontWeight: "bold",
                fontSize: 10,
                formatter: (params) => {
                  let labelData = 0;
                  if (params.data[0] != "CM") {
                    labelData = params.data[2] - params.data[1];
                  } else {
                    labelData = params.data[1];
                  }
                  return addCommas(Number(labelData.toFixed(2)));
                },
              },
              datasetIndex: 0,
              encode: {
                y: 2,
              },
              // markLine: {
              //   // symbol: 'none', // 화살표 제거
              //   lineStyle: {
              //     color: "red",
              //     type: "dashed",
              //     width: 2,
              //   },
              //   data: [
              //     lineValue.length > 0
              //       ? {
              //         yAxis: lineValue[0]["cm_tagt"] ? lineValue[0]["cm_tagt"] : "",
              //       }
              //       : {
              //         name: "최대값",
              //         type: "max",
              //       },
              //   ],
              //   label: {
              //     color: "#777777",
              //     formatter: function (params) {
              //       // 여기서 params는 markLine에 해당하는 데이터를 나타냅니다.
              //       // 여기에 포맷터 함수를 작성하면 됩니다.
              //       return `${Number(lineValue[0]["cm_rate"]).toFixed(2)}%`;
              //     },
              //   },
              // },
              renderItem: (params, api) => {
                const dataIndex = api.value(0);
                const barStartValue = api.value(1);
                const barEndValue = api.value(2);
                const startCoord = api.coord([dataIndex, barStartValue]);
                const endCoord = api.coord([dataIndex, barEndValue]);

                const rectWidth = 50;
                const rectMinHeight = 1;
                let rectHeight = startCoord[1] - endCoord[1];

                const style = api.style();
                style.fill = chan.chartThemeColor[dataIndex];
                if (params.dataInsideLength - 1 == dataIndex) {
                  style.fill = "#90cb75"; // green (lastItemColor)
                } else {
                  if (rectHeight < 0) {
                    style.fill = "#ee6666"; // red (negativeColor)
                  } else if (rectHeight === 0) {
                    style.fill = "#ededed"; // ltgray (neutralValueColor)
                  } else {
                    style.fill = "#5470c6"; // blue (positiveColor)
                  }
                }

                // const referenceData = api.value(3);
                // if (referenceData === 1) {
                //   style.fill = "#228B22"; // green (referenceColor)
                //   chan.hasReferenceData = true;
                // } else if (referenceData === 0) {
                //   style.fill = "#808080"; // gray (nonReferenceColor)
                // }

                // // if referenceDatapoint undefined, set last bar to green reference color
                // if (chan.hasReferenceData === false && dataIndex === chan.lastBarIndex) {
                //   style.fill = "#228B22"; // green (referenceColor)
                // }

                rectHeight = rectHeight === 0 ? rectMinHeight : rectHeight;
                const rectItem = {
                  type: "rect",
                  shape: {
                    x: endCoord[0] - rectWidth / 2,
                    y: endCoord[1],
                    width: rectWidth,
                    height: rectHeight,
                  },
                  style: style,
                };
                return rectItem;
              },
            },
          ],
        },
        true
      );
    }
  }
};

/* Water Fall */
chan.chartWaterFallChannelOption = {
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "shadow",
    },
    formatter: function (params) {
      let tar;
      if (params[1] && params[1].value !== "-") {
        tar = params[1];
      } else {
        tar = params[2];
      }
      return tar && tar.name + "<br/>" + tar.seriesName + " : " + tar.value;
    },
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      //myCustomDataButton: myCustomDataButton(),
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
  yAxis: [
    {
      type: "value",
    },
  ],
  series: [],
};
if (document.getElementById("chart-water-fall-channel")) {
  chan.chartWaterFallChannel = echarts.init(document.getElementById("chart-water-fall-channel"));
  chan.chartWaterFallChannel.setOption(chan.chartWaterFallChannelOption);
}
/*******************************************************************************************************************************************************/
/******************************************************** Contribution Margin 월별 트렌드 분석 ***************************************************/
chan.cmTrendAnalysisUpdate = function () {
  if (chan.chartMixChannel) {
    let rawData = chan.cmTrendAnalysis;

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
    const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

    let dayValues = [[], [], []],
      series = [];
    for (let i = 0; i < lgnd.length; i++) {
      for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
        if (lgnd[i] == "CM_AMT") {
          dayValues[i][j] = Number(dataArr[lgnd[i]][j]["y_val"]);
        } else if (dataArr[lgnd[i]][j]["x_dt"] != "YTD Total") {
          dayValues[i][j] = Number(dataArr[lgnd[i]][j]["y_val"]);
        }
      }
      if (lgnd[i] === "CM_AMT") {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "bar",
          yAxisIndex: 0,
          data: dayValues[i],
        });
      } else if (lgnd[i] === "CM_RATE") {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          lineStyle: {
            type: "dashed",
          },
          yAxisIndex: 1,
          data: dayValues[i],
        });
      }
    }

    chan.chartMixChannel.setOption(chan.chartMixChannelOption, true);
    if (rawData.length > 0) {
      chan.chartMixChannel.setOption({
        legend: {
          data: lgnd_nm,
          textStyle: {
            color: "#858d98",
          },
        },
        yAxis: [
          {
            type: "value",
            name: "금액 (단위 : 백만원)",
          },
          {
            type: "value",
            name: "%",
          },
        ],
        xAxis: [
          {
            type: "category",
            data: x_dt,
            axisLabel: {
              rotate: 45,
            },
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

/* Mix Chart */
chan.chartMixChannelOption = {
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
      //myCustomDataButton: myCustomDataButton(),
    },
  },
  grid: {
    left: "2%",
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
      axisLabel: {
        rotate: 45,
      },
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

if (document.getElementById("chart-mix-channel")) {
  chan.chartMixChannel = echarts.init(document.getElementById("chart-mix-channel"));
  chan.chartMixChannel.setOption(chan.chartMixChannelOption);
}
/*******************************************************************************************************************************************************/
/******************************************************** 비용 항목 별 월별 트렌드 분석 ***************************************************/
chan.selectedCostCmTrendAnalysisUpdate = function () {
  if (chan.choicesCmTrendSelect) {
    let rawData = chan.selectedCostCmTrendAnalysis;
    costList = [];
    rawData.forEach((cost) => {
      costList.push({ value: cost.cost_id, label: cost.cost_nm });
    });
    chan.choicesCmTrendSelect.setChoices(costList, "value", "label", true);
  }
};

chan.selectedCostCmTrendAnalysisChartUpdate = function () {
  let rawData = chan.selectedCostCmTrendAnalysisChart;
  chan.chartMixCmTrend.setOption(chan.chartMixCmTrendOption, true);
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
    const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

    let dayValues = [[], []],
      series = [];
    for (let i = 0; i < lgnd.length; i++) {
      for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
        dayValues[i][j] = dataArr[lgnd[i]][j]["y_val"] ? Number(dataArr[lgnd[i]][j]["y_val"]) : 0;
      }
      if (lgnd[i] === "AMT") {
        series.push({
          name: uniqueLegends[lgnd[i]] && uniqueLegends[lgnd[i]].name ? uniqueLegends[lgnd[i]].name : "",
          type: "bar",
          yAxisIndex: 0,
          data: dayValues[i],
        });
      } else {
        series.push({
          name: uniqueLegends[lgnd[i]] && uniqueLegends[lgnd[i]].name ? uniqueLegends[lgnd[i]].name : "",
          type: "line",
          yAxisIndex: 1,
          data: dayValues[i],
        });
      }
    }
    const convertedMonths = x_dt.map((month) => {
      if (month === "YTD Total") {
        return month;
      }
      const [year, monthNum] = month.split("-");
      return `${Number(monthNum)}월`;
    });

    if(lgnd_nm[0]) {
      chan.chartMixCmTrend.setOption({
        legend: {
          data: lgnd_nm,
          textStyle: {
            color: "#858d98",
          },
        },
        yAxis: [
          {
            type: "value",
            name: "금액 (단위 : 백만원)",
          },
          {
            type: "value",
            name: "%",
          },
        ],
        xAxis: [
          {
            type: "category",
            //data: convertedMonths,
            data: x_dt,
            axisLabel: {
              rotate: 45,
            },
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

/* 비용 항목 별 월별 트렌드 분석 */
chan.chartMixCmTrendOption = {
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
      //myCustomDataButton: myCustomDataButton(),
    },
  },
  grid: {
    left: "2%",
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
if (document.getElementById("chart-mix-cm-trend")) {
  chan.chartMixCmTrend = echarts.init(document.getElementById("chart-mix-cm-trend"));
  chan.chartMixCmTrend.setOption(chan.chartMixCmTrendOption);
}
/*******************************************************************************************************************************************************/
/******************************************************** 비용 항목 별 Breakdown ***************************************************/
chan.costItemBreakdownUpdate = function (chrtType) {
  if (chan.chartStackBreakdown) {
    let rawData = chan.costItemBreakdown;

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
    const x_dt = [...new Set(rawData.map((item) => item.x_dt))];

    let dayValues = [[], [], [], [], []],
      series = [], yAxises = [];
    yAxises.push({
      type: "value",
      name: chrtType == "AMT" ? "금액 (단위 : 백만원)" : "",
    });
    chrtType == "RATE" ? yAxises[0].max = 100 : false;
    for (let i = 0; i < lgnd.length; i++) {
      for (let j = 0; j < dataArr[lgnd[i]].length; j++) {
        dayValues[i][j] = Number(dataArr[lgnd[i]][j]["y_val"]);
      }
      if (chrtType == "AMT") {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "bar",
          data: dayValues[i],
        });
      } else if (chrtType == "RATE") {
        series.push({
          name: uniqueLegends[lgnd[i]] ? uniqueLegends[lgnd[i]].name : "",
          type: "bar",
          stack: "Ad",
          data: dayValues[i],
        });
        
      }
    }
    let magicType = [];
    chan.chartStackBreakdown.setOption(chan.chartStackBreakdownOption, true);
    if (rawData.length > 0) {
      if (chrtType == "AMT") {
        magicType = ["line", "bar"];
      } else if (chrtType == "RATE") {
        magicType = ["stack"];
      }
      chan.chartStackBreakdown.setOption(
        {
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
              //myCustomDataButton: myCustomDataButton(),
              magicType: {
                type: magicType,
              },
            },
          },
          legend: {
            textStyle: {
              color: "#858d98",
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
            data: x_dt,
            axisLabel: {
              rotate: 45,
            },
          },
          yAxis: yAxises,
          series: series,
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
        },
        true
      );
    }
  }
};
/* 비용 항목 별 Breakdown */
chan.chartStackBreakdownOption = {
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
      //myCustomDataButton: myCustomDataButton(),
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
if (document.getElementById("chart-stack-break-down")) {
  chan.chartStackBreakdown = echarts.init(document.getElementById("chart-stack-break-down"));
  chan.chartStackBreakdown.setOption(chan.chartStackBreakdownOption);
}
/*******************************************************************************************************************************************************/
// 이벤트 핸들러 함수를 배열로 정의합니다.
chan.resizeHandlers = [
  chan.revenueCount,
  chan.cogsCount,
  chan.grossProfitCount,
  chan.contriMarginCount,
  chan.chartWaterFallChannel,
  chan.chartMixChannel,
  chan.chartMixCmTrend,
  chan.chartStackBreakdown,
];

// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
chan.resizeHandlers.forEach((handler) => {
  if (handler != undefined) {
    window.addEventListener("resize", eval(handler).resize);
  }
});

chan.updateButtonStyle = function (name) {
  const buttonClasses = {
    금액: ["error", "btn-soft-primary", "btn-primary"],
    "100%": ["nomal", "btn-soft-success", "btn-success"],
  };
  Object.entries(buttonClasses).forEach(([key, classes]) => {
    const button = document.querySelector(`.${classes[0]}`);
    if (button) {
      if (key !== name) {
        button.classList.remove(classes[2]);
        button.classList.add(classes[1]);
      } else {
        button.classList.remove(classes[1]);
        button.classList.add(classes[2]);
      }
    }
  });
};

chan.onLoadEvent = function () {
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

  if (!chan.choicesCmTrendSelect && document.getElementById("choicesCmTrendSelect")) {
    const choicesCmTrendSelect = document.getElementById("choicesCmTrendSelect");
    chan.choicesCmTrendSelect = new Choices(choicesCmTrendSelect, {
      searchEnabled: false,
      shouldSort: false,
    });

    choicesCmTrendSelect.addEventListener("change", function (e) {
      let datePicker = document.getElementById("expenseTrendChartDate");
      let params = {
        params: {
          FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
          TO_MNTH: `'${datePicker.value.slice(-7)}'`,
          CHNL_NM: `'${chan.CHNL_NM}'`,
          COST_ID: `'${e.target.value}'`,
        },
        menu: "dashboards/common",
        tab: "channel",
        dataList: ["selectedCostCmTrendAnalysisChart"],
      };
      getData(params, function (data) {
        chan.selectedCostCmTrendAnalysisChart = data["selectedCostCmTrendAnalysisChart"];
        chan.selectedCostCmTrendAnalysisChartUpdate();
      });
    });
  }

  let btnSm = document.querySelectorAll(".btn-sm");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let chrtType = chkTxt == "금액" ? "AMT" : "RATE";
      chan.chrtType = chrtType;
      chan.updateButtonStyle(chkTxt);
      let datePicker = document.getElementById("expenseBreakdownDate");
      let params = {
        params: {
          FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
          TO_MNTH: `'${datePicker.value.slice(-7)}'`,
          CHNL_NM: `'${chan.CHNL_NM}'`,
          CHRT_TYPE: `'${chan.chrtType}'`,
        },
        menu: "dashboards/common",
        tab: "channel",
        dataList: ["costItemBreakdown"],
      };
      getData(params, function (data) {
        chan.costItemBreakdown = data["costItemBreakdown"];
        chan.costItemBreakdownUpdate(chrtType);
      });
    });
  });

  let dataList = [
    "cmAnalysis", // # 0. 채널수익 화면에서 기본 셋팅에 필요한 일자
    "importantInfoCardData", // # 1. 중요정보 카드 - 금액 SQL
    "importantInfoCardChart", // # 1. 중요정보 카드 - Chart SQL
    "selectedCostCmTrendAnalysis" /* 7.비용 항목 별 월별 트렌드 분석 - 비용 선택 SQL */,
  ];

  let params = {
    params: { CHNL_NM: `'${chan.CHNL_NM}'` },
    menu: "dashboards/common",
    tab: "channel",
    dataList: dataList,
  };

  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      chan[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    chan.setDataBinding();
    chan.updateButtonStyle("금액");
  });
  chan.onloadStatus = true; // 화면 로딩 상태
};
