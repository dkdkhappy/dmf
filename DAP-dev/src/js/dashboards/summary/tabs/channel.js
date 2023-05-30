let chan = {};
chan.onloadStatus = false; // 화면 로딩 상태

chan.setDataBinding = function () {

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
  let cmBreakDownType = "AMT";
  let waterFallChartDatePicker = flatpickr("#waterFallChartDatePicker, #cmTimeViewerDatePicker, #channelBreakDownDatePicker, #channelCmChangeDatePicker", {
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
    onClose: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromMonth = getMonthFormatter(selectedDates[0]);
        const toMonth = getMonthFormatter(selectedDates[1]);
        let params = {
          params: {
            FR_MNTH: `'${fromMonth}'`,
            TO_MNTH: `'${toMonth}'`,
            CHRT_TYPE: `'${chan.chartType}'`,
          },
          menu: "dashboards/summary",
          tab: "channel",
        };
        const elId = instance.element.id;
        switch (elId) {
          case "waterFallChartDatePicker":
            params["dataList"] = ["waterFallChart"];
            break;
          case "cmTimeViewerDatePicker":
            params["dataList"] = ["cmTimeSeriesChart"];
            break;
          case "channelBreakDownDatePicker":
            params["dataList"] = ["channelCmBreakDownChart"];
            break;
          case "channelCmChangeDatePicker":
            params["dataList"] = ["channelCmChangeChart"];
            break;
        };
        getData(params, function (data) {
          switch (elId) {
            case "waterFallChartDatePicker":
              chan.waterFallChart = {};
              if (data["waterFallChart"] != undefined) {
                chan.waterFallChart = data["waterFallChart"];
                chan.waterFallChartUpdate();
              }
              break;
            case "cmTimeViewerDatePicker":
              chan.cmTimeSeriesChart = {};
              if (data["cmTimeSeriesChart"] != undefined) {
                chan.cmTimeSeriesChart = data["cmTimeSeriesChart"];
                chan.cmTimeSeriesChartUpdate();
              }
              break;
            case "channelBreakDownDatePicker":
              chan.channelCmBreakDownChart = {};
              if (data["channelCmBreakDownChart"] != undefined) {
                chan.channelCmBreakDownChart = data["channelCmBreakDownChart"];
                chan.channelCmBreakDownChartUpdate(cmBreakDownType);
              }
              break;
            case "channelCmChangeDatePicker":
              chan.channelCmChangeChart = {};
              if (data["channelCmChangeChart"] != undefined) {
                chan.channelCmChangeChart = data["channelCmChangeChart"];
                chan.channelCmChangeChartUpdate();
              }
              break;
          };
        });
      }
    },
  });

  // CM 목표 및 달성 여부
  flatpickr("#cmAchiGoalDatePicker", {
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
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);
        let params = {
          params: {
            FR_MNTH: `'${fromDate.substring(0, 7)}'`,
            TO_MNTH: `'${toDate.substring(0, 7)}'`,
            CHRT_TYPE: `'${chan.chartType}'`,
          },
          menu: "dashboards/summary",
          tab: "channel",
          dataList: ["cmTargetAchievement"],
        };
        getData(params, function (data) {
          if (data["cmTargetAchievement"] != undefined) {
            chan.cmTargetAchievement = data["cmTargetAchievement"];
            chan.cmTargetAchievementUpdate();
          }
        });
      }
    },
  });

  /* 1. 중요정보 카드 - 금액 SQL  */
  if (Object.keys(chan.impCardAmtData).length > 0) {
    chan.impCardAmtDataUpdate();
  }
  /* 1. 중요정보 카드 - 그래프 SQL  */
  if (Object.keys(chan.impCardAmtChart).length > 0) {
    chan.impCardAmtChartUpdate();
  }
  /* Contribution Margin Waterfall Chart  */
  if (Object.keys(chan.cmAnalysis).length > 0) {
    let params = {
      params: {
        FR_MNTH: `'${chan.cmAnalysis[0]["fr_mnth"]}'`,
        TO_MNTH: `'${chan.cmAnalysis[0]["to_mnth"]}'`,
        CHRT_TYPE: `'AMT'`,
      },
      menu: "dashboards/summary",
      tab: "channel",
      dataList: ["waterFallChart", "waterFallChartCmLine", "cmTimeSeriesChart", "channelCmBreakDownChart", "channelCmChangeChart", "cmTargetAchievement"],
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
      if (data["cmTimeSeriesChart"] != undefined) {
        chan.cmTimeSeriesChart = data["cmTimeSeriesChart"];
        chan.cmTimeSeriesChartUpdate();
      }
      if (data["channelCmBreakDownChart"] != undefined) {
        chan.channelCmBreakDownChart = data["channelCmBreakDownChart"];
        chan.channelCmBreakDownChartUpdate(cmBreakDownType);
      }
      if (data["channelCmChangeChart"] != undefined) {
        chan.channelCmChangeChart = data["channelCmChangeChart"];
        chan.channelCmChangeChartUpdate();
      }
      if (data["cmTargetAchievement"] != undefined) {
        chan.cmTargetAchievement = data["cmTargetAchievement"];
        chan.cmTargetAchievementUpdate();
      }
    });
  }
  /* number counting 처리 */
  counter();
};

/******************************************************** Revenue, COGS, Gross Profit, Contribution Margin ***************************************************/
/*******************************************************************************************************************************************************/
/**
 *  1. 중요정보 카드 - 금액 SQL
 */
chan.impCardAmtDataUpdate = function () {
  let rawData = chan.impCardAmtData[0];
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

chan.impCardAmtChartUpdate = function () {
  let rawData = chan.impCardAmtChart;
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
    height: 140,
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
          yAxis: {
            show: true,
            type: "value",
            name: "금액 (단위 : 백만원)",
          },
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
                  if(params.data[0] != 'CM'){
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
              //           yAxis: lineValue[0]["cm_tagt"] ? lineValue[0]["cm_tagt"] : "",
              //         }
              //       : {
              //           name: "최대값",
              //           type: "max",
              //         },
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
    },
  },
  grid: {
    left: "0.5%",
    right: "5.5%",
    bottom: "0",
    top: "2%",
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
};
chan.chartWaterFallChannel = echarts.init(document.getElementById("chart-water-fall-channel"));
chan.chartWaterFallChannel.setOption(chan.chartWaterFallChannelOption);

/*******************************************************************************************************************************************************/
/******************************************************** CM 그래프 시계열 ***************************************************/

chan.cmTimeSeriesChartUpdate = function () {
  let rawData = chan.cmTimeSeriesChart;
  if (chan.chartMixChannel) {
    chan.chartMixChannel.setOption(chan.chartMixChannelOption, true);
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
        // debugger;
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

      chan.chartMixChannel.setOption({
        legend: {
          data: lgnd_nm,
          textStyle: {
            color: "#858d98",
          }
        },
        xAxis: [
          {
            type: "category",
            data: x_dt,
            axisLabel: {
              rotate: 45,
            },
          },
        ],
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
chan.chartMixChannel = echarts.init(document.getElementById("chart-mix-channel"));
chan.chartMixChannel.setOption(chan.chartMixChannelOption);

/*******************************************************************************************************************************************************/
/******************************************************** 채널별 CM Break Down ***************************************************/
chan.channelCmBreakDownChartUpdate = function (chrtType) {
  let rawData = chan.channelCmBreakDownChart;
  if (chan.chartStackCmBreakDown) {
    let magicTypes = [];
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];
      const l_lgnd_nm = [...new Set(rawData.map((item) => item.l_lgnd_nm))];
      
      let series = [];
      let seriesData, findData;
      
      l_lgnd_nm.forEach((prod) => {
        seriesData = [];
        x_dt.forEach((dt) => {
          findData = rawData.find((item) => item.l_lgnd_nm === prod && item.x_dt == dt);
          seriesData.push(findData && findData["y_val"] ? findData["y_val"] : 0);
        });
        series.push({
          name: prod,
          type: "bar",
          stack: "add",
          data: seriesData,
        });
      });
      chan.chartStackCmBreakDown.setOption(chan.chartStackCmBreakDownOption, true);
      if (chrtType == "AMT") {
        magicType = ["line", "bar"];
      } else if (chrtType == "RATE") {
        magicType = ["stack"];
      }
      chan.chartStackCmBreakDown.setOption({
        toolbox: {
          left: "right",
          top: "center",
          orient: "vertical",
          feature: {
            saveAsImage: {},
            dataView: {},
            magicType: {
              type: magicType,
            },
          },
        },
        legend: {
          textStyle: {
            color: "#858d98",
          }
        },
        xAxis: {
          type: "category",
          data: x_dt,
          axisLabel: {
            rotate: 45,
          },
        },
        yAxis: [
          {
            type: "value",
            name: chrtType != "AMT" ? "" : "금액 (단위 : 백만원)"
          }
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
/* 채널별 CM Break Down */
chan.chartStackCmBreakDownOption = {
  tooltip: {
    trigger: "axis",
  },
  toolbox: {},
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
chan.chartStackCmBreakDown = echarts.init(document.getElementById("chart-stack-cm-break-down"));
chan.chartStackCmBreakDown.setOption(chan.chartStackCmBreakDownOption);

/*******************************************************************************************************************************************************/
/******************************************************** 채널별 CM % 추이 ***************************************************/
chan.channelCmChangeChartUpdate = function () {
  let rawData = chan.channelCmChangeChart;
  if (chan.chartLineCmChange) {
    chan.chartLineCmChange.setOption(chan.chartLineCmChangeOption, true);
    if (rawData.length > 0) {
      const x_dt = [...new Set(rawData.map((item) => item.x_dt))];
      const l_lgnd_nm = [...new Set(rawData.map((item) => item.l_lgnd_nm))];
      let series = [];
      let seriesData, findData;
      l_lgnd_nm.forEach((prod) => {
        seriesData = [];
        x_dt.forEach((dt) => {
          findData = rawData.find((item) => item.l_lgnd_nm === prod && item.x_dt == dt);
          seriesData.push(findData && findData["y_val"] ? findData["y_val"] : 0);
        });
        series.push({
          name: prod,
          type: "line",
          data: seriesData,
        });
      });

      chan.chartLineCmChange.setOption({
        legend: {
          data: l_lgnd_nm,
          textStyle: {
            color: "#858d98"
          }
        },
        xAxis: {
          type: "category",
          boundaryGap: false,
          data: x_dt,
          axisLabel: {
            rotate: 45,
          },
        },
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

/* 채널별 CM % 추이 */
chan.chartLineCmChangeOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    data: [],
  },
  grid: {
    left: "3%",
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
    },
  },
  xAxis: {
    type: "category",
    boundaryGap: false,
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
chan.chartLineCmChange = echarts.init(document.getElementById("chart-line-cm-change"));
chan.chartLineCmChange.setOption(chan.chartLineCmChangeOption);

/*******************************************************************************************************************************************************/
/******************************************************** CM 목표 및 달성 여부 ***************************************************/
chan.cmTargetAchievementUpdate = function () {
  let rawData = chan.cmTargetAchievement;
  if (chan.channelGoalCmClearList) {
    let keysToExtract = ["chnl_nm", "cm_tagt_amt", "cm_tagt_rate", "cm_cum_amt", "cm_cum_rate", "cm_calc_txt"];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    chan.channelGoalCmClearList.updateConfig({ data: filterData }).forceRender();
  }
};
/* 채널별 목표 CM, 누적 실적, 달성 여부 */
if (document.getElementById("channelGoalCmClearList")) {
  chan.channelGoalCmClearList = new gridjs.Grid({
    columns: [
      {
        name: "",
        width: "120px",
        id: "gap",
      },
      {
        name: "목표",
        width: "300px",
        columns: [
          {
            name: "CM",
          },
          {
            name: "%",
          },
        ],
      },
      {
        name: "누적 실적",
        width: "300px",
        columns: [
          {
            name: "CM",
          },
          {
            name: "%",
          },
        ],
      },
      {
        name: "달성 여부",
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
  }).render(document.getElementById("channelGoalCmClearList"));
}

// 이벤트 핸들러 함수를 배열로 정의합니다.
chan.resizeHandlers = [chan.chartWaterFallChannel.resize, chan.chartMixChannel.resize, chan.chartStackCmBreakDown.resize, chan.chartLineCmChange.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
chan.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

chan.updateButtonStyle = function (name) {
  const buttonClasses = {
    CM: ["error", "btn-soft-primary", "btn-primary", "scamt"],
    "100%": ["nomal", "btn-soft-success", "btn-success", "scpct"],
  };
  chan.chartType = name == "CM" ? "AMT" : "RATE";
  Object.entries(buttonClasses).forEach(([key, classes]) => {
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

  let btnSm = document.querySelectorAll(".btn-smy-chan");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let chrtType = chkTxt == "CM" ? "AMT" : "RATE";
      chan.updateButtonStyle(chkTxt);

      let datePicker = document.getElementById("channelBreakDownDatePicker");

      let params = {
        params: {
          FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
          TO_MNTH: `'${datePicker.value.slice(-7)}'`,
          CHRT_TYPE: `'${chrtType}'`,
        },
        menu: "dashboards/summary",
        tab: "channel",
        dataList: ["channelCmBreakDownChart"],
      };
      getData(params, function (data) {
        chan.channelCmBreakDownChart = data["channelCmBreakDownChart"];
        chan.channelCmBreakDownChartUpdate(chrtType);
      });
    });
  });

  let dataList = [
    "cmAnalysis", // # 0. 채널수익 화면에서 기본 셋팅에 필요한 일자
    "impCardAmtData", // # 1. 중요정보 카드 - 금액 SQL
    "impCardAmtChart", // # 1. 중요정보 카드 - Chart SQL
  ];

  let params = {
    menu: "dashboards/summary",
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
    chan.updateButtonStyle("CM");
  });
  chan.onloadStatus = true; // 화면 로딩 상태
};
