let summary = {};

summary.setDataBinding = function () {
  /* 중요정보 카드 */
  if (Object.keys(summary.impCardAmtData).length > 0) {
    summary.impCardAmtUpdate();
  }
  /* 중요정보 카드 - 그래프 */
  if (Object.keys(summary.impCardAmtChart).length > 0) {
    summary.impCardAmtChartUpdate();
  }
  /* 2. 채널 별 리뷰 지도 - 채널 선택 SQL */
  if (Object.keys(summary.channelReviewChannel).length > 0) {
    summary.channelReviewChannelUpdate();
  }
  
  /* 2. 채널 별 리뷰 지도 - 토픽 선택 SQL */
  if (Object.keys(summary.channelReviewTopic).length > 0) {
    summary.channelReviewTopicUpdate();
  }
  /* 2. 채널 별 리뷰 지도 - 트리 맵 그래프 SQL */
  if (Object.keys(summary.channelReviewTreeMap).length > 0) {
    summary.channelReviewTreeMapUpdate();
  }
  /* 3. 전월 대비 긍정/부정 비율 변화 - 표 SQL */
  if (Object.keys(summary.posNegRatioChangeMoM).length > 0) {
    summary.posNegRatioChangeMoMUpdate();
  }
  /* 4. 채널 별 긍부정 시계열 그래프 - 제품 선택 */
  if (Object.keys(summary.channelSentimentTrendProduct).length > 0) {
    summary.channelSentimentTrendProductUpdate();
  }
  /* number counting 처리 */
  counter();
};
/*************************************** 중요정보카드 **********************************************/

/**
 * 매출 상단 카드 - 카드 내 data
 */
summary.impCardAmtUpdate = function () {
  let rawData = summary.impCardAmtData;
  /*
    revw_cnt       // 전체 수집 리뷰 수     
    revw_tday_cnt  // 오늘 수집 리뷰 수     
    revw_yday_cnt  // 어제 수집 리뷰 수     
    revw_rate      // 전체 수집 리뷰 증감률 
  */
  let cardAreaList = ["revw_cnt", "revw_rate", "pstv_cnt", "ngtv_cnt", "pstv_prod_nm", "pstv_rate_chng", "ngtv_prod_nm", "ngtv_rate_chng"];
  cardAreaList.forEach((cardArea) => {
    let el = document.getElementById(`${cardArea}`);
    if (el) {
      if (cardArea.indexOf("_rate") > -1) {
        let elArrow = document.getElementById(`${cardArea}_arrow`);
        if (elArrow) {
          if (Number(rawData[0][`${cardArea}`]) > 0) {
            el.classList.add("text-success");
            elArrow.classList.add("ri-arrow-up-line", "text-success");
          } else if (Number(rawData[0][`${cardArea}`]) < 0) {
            el.classList.add("text-danger");
            elArrow.classList.add("ri-arrow-down-line", "text-danger");
          } else {
            el.classList.add("text-muted");
            elArrow.classList.add("text-muted");
          }
          el.innerText = rawData[0][`${cardArea}`] + "%";
        }
      } else if (cardArea.indexOf("_nm") > -1) {
        el.innerText = rawData[0][`${cardArea}`];
        el.nextElementSibling.setAttribute("data-bs-original-title", rawData[0][`${cardArea}`]);
      } else {
        el.innerText = 0;
        el.setAttribute("data-target", rawData[0][`${cardArea}`]);
      }
    }
  });
  // Data
  let pstvCnt = document.getElementById("pstv_cnt");
  let ntrlCnt = document.getElementById("ntrl_cnt");
  let ngtvCnt = document.getElementById("ngtv_cnt");
  if (pstvCnt) {
    pstvCnt.innerText = 0;
    pstvCnt.setAttribute("data-target", rawData[0]["pstv_cnt"]);
  }
  if (ngtvCnt) {
    ngtvCnt.innerText = 0;
    ngtvCnt.setAttribute("data-target", rawData[0]["ngtv_cnt"]);
  }
  if (summary.positiveScoreChart) {
    summary.positiveScoreChart.updateOptions({
      series: [Number(rawData[0]["pstv_rate"]), Number(rawData[0]["ntrl_rate"]), Number(rawData[0]["ngtv_rate"])],
    });
  }
  /*
    revw_diff      // 업데이트 된 리뷰수    
  */
  let revwDiff = document.getElementById("revw_diff");
  if (revwDiff) {
    revwDiff.innerText = 0;
    revwDiff.setAttribute("data-target", rawData["revw_diff"]);
  }
};

summary.impCardAmtChartUpdate = function () {
  let rawData = summary.impCardAmtChart;
  let chartData = rawData.map((d) => ({
    x: d["x_dt"],
    y: Number(d["v_val"]),
  }));
  if (summary.summaryTotalReviewCount) {
    summary.summaryTotalReviewCount.updateSeries([
      {
        data: chartData,
      },
    ]);
  }
};
/* 전체 수집 리뷰 수 */
summary.totalReviewCountOptions = {
  series: [
    {
      name: "리뷰 수",
      data: [],
    },
  ],
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
  colors: getChartColorsArray("summaryTotalReviewCount"),
};
summary.summaryTotalReviewCount = new ApexCharts(document.querySelector("#summaryTotalReviewCount"), summary.totalReviewCountOptions);
summary.summaryTotalReviewCount.render();

/* 긍정, 부정, 중립 게이지 그래프 (원형) */
summary.positiveScoreChartOptions = {
  series: [33, 34, 33],
  chart: {
    type: "donut",
    width: 180,
    height: 210,
  },
  dataLabels: {
    enabled: true,
    style: {
      fontSize: "12px", // 데이터 라벨 폰트 크기를 12px로 설정
    },
  },
  plotOptions: {
    pie: {
      startAngle: -90,
      endAngle: 90,
      donut: {
        size: "40%", // 도넛 그래프의 두께를 40%로 설정 (두께가 두꺼워짐)
      },
      // color: ["#5470c6", "#ee6666"],
      dataLabels: {
        offset: -5,
        style: {
          fontSize: "12px", // 데이터 라벨 폰트 크기를 12px로 설정
        },
      },
    },
  },
  labels: ["긍정", "중립", "부정"],
  legend: {
    position: "bottom",
    offsetY: -70,
  },
  colors: getChartColorsArray("positiveScoreChart"),
};
summary.positiveScoreChart = new ApexCharts(document.querySelector("#positiveScoreChart"), summary.positiveScoreChartOptions);
summary.positiveScoreChart.render();

/*************************************** 그래프, 그리드 **********************************************/

summary.channelReviewChannelUpdate = function () {
  let rawData = summary.channelReviewChannel;
  let channelList = [];
  rawData.forEach((channel) => {
    channelList.push({ value: channel.chnl_id, label: channel.chnl_nm });
  });
  if (summary.sbxChannel) {
    summary.sbxChannel.setChoices(channelList, "value", "label", true);
    summary.sbxChannel.setChoiceByValue("ALL");
  }
};

summary.channelReviewTopicUpdate = function () {
  let rawData = summary.channelReviewTopic;
  let topicList = [];
  rawData.forEach((topic) => {
    topicList.push({ value: topic.tpic_item, label: topic.tpic_item });
  });
  if (summary.sbxChannelTopic) {
    summary.sbxChannelTopic.setChoices(topicList, "value", "label", true);
    summary.sbxChannelTopic.setChoiceByValue("전체");
  }
};

summary.channelReviewTreeMapUpdate = function () {
  let rawData = summary.channelReviewTreeMap;
  if (summary.chartTreeChannelMyProd) {
    summary.chartTreeChannelMyProd.setOption(summary.chartTreeChannelMyProdOption, true);
    if (rawData.length > 0) {
      // 결과를 저장할 빈 객체 생성
      let brandReviewCounts = {};

      // rawData 배열을 순회하면서 브랜드별 리뷰 개수의 합을 계산
      rawData.forEach(function (data) {
        let brand = data.brnd_nm;
        let reviewCount = parseFloat(data.revw_cnt);
        let revwRate = parseFloat(data.revw_rate);
        if (brand in brandReviewCounts) {
          brandReviewCounts[brand]["revw_cnt"] += reviewCount;
          brandReviewCounts[brand]["prod_cnt"] += 1;
          brandReviewCounts[brand]["revw_rate"] += revwRate;
        } else {
          brandReviewCounts[brand] = { revw_cnt: 0, prod_cnt: 0, revw_rate: 0 };
          brandReviewCounts[brand]["revw_cnt"] = reviewCount;
          brandReviewCounts[brand]["prod_cnt"] = 1;
          brandReviewCounts[brand]["revw_rate"] = revwRate;
        }
      });

      let rootVal = 0;
      let revwRate = 0;
      let filteredData = [];
      let dataList = [];
      for (var brand in brandReviewCounts) {
        revwRate = parseFloat(brandReviewCounts[brand]["revw_rate"]) / parseFloat(brandReviewCounts[brand]["prod_cnt"]);
        rootVal += brandReviewCounts[brand]["revw_cnt"];
        filteredData = rawData.filter((item) => item.brnd_nm === brand);
        dataList = [];
        filteredData.forEach(function (data) {
          dataList.push({
            name: data.prod_nm,
            value: [parseFloat(data.revw_cnt), parseFloat(data.revw_rate)],
            itemStyle: { borderWidth: 2 },
          });
        });
      }

      summary.chartTreeChannelMyProd.setOption({
        series: [
          {
            type: "treemap",
            data: dataList,
            leafDepth: 1,
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
        visualDimension: 2,
        visualMap: {
          type: "continuous",
          inRange: {
            color: summary.psngType == "PSTV" ? ["#ed5e5e", "#91cc75", "#6691e7"] : ["#6691e7", "#91cc75", "#ed5e5e"],
            symbolSize: [20, 50],
          },
          min: 0,
          max: 100,
          calculable: true,
          show: true,
          orient: "vertical",
          right: 10,
          top: 50,
          height: 200,
        },
      });
    }
  }
};

summary.channelReviewTreeMapSearch = function () {
  let datePicker = document.getElementById("channelMyProdViewer");
  params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      WITH_FAKE: `'N'`,
      CHNL_ID: `'${summary.sbxChannel.getValue().value}'`,
      TPIC_ITEM: `'${summary.sbxChannelTopic.getValue().value}'`,
      PSNG_TYPE: `'${summary.psngType}'`,
    },
    menu: "reviewanalysis",
    tab: "summary",
    dataList: ["channelReviewTreeMap"],
  };
  getData(params, function (data) {
    summary.channelReviewTreeMap = data["channelReviewTreeMap"];
    summary.channelReviewTreeMapUpdate();
  });
};

/* 채널별 리뷰 지도 (트리) */
summary.chartTreeChannelMyProdOption = {
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
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
summary.chartTreeChannelMyProd = echarts.init(document.getElementById("chart-tree-channel-my-prod"));
summary.chartTreeChannelMyProd.setOption(summary.chartTreeChannelMyProdOption);

/************************************************************ 전월 대비 긍정 / 부정 비율 변화 **********************************************************************/
summary.posNegRatioChangeMoMUpdate = function () {
  let rawData = summary.posNegRatioChangeMoM;
  if (summary.lastMonthTopicGoodBadList) {
    let keysToExtract = ["revw_rank", "all_prod_nm", "dgt_prod_nm", "dct_prod_nm", "dgd_prod_nm", "dcd_prod_nm"];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    summary.lastMonthTopicGoodBadList.updateConfig({ data: filterData }).forceRender();
  }
};

/* 전월 대비 토픽별 긍정 / 부정 비율 변화 */
if (document.getElementById("lastMonthTopicGoodBadList")) {
  summary.lastMonthTopicGoodBadList = new gridjs.Grid({
    columns: [
      {
        name: "등수",
        width: "80px",
      },
      {
        name: "채널 전체",
        width: "150px",
      },
      {
        name: "티몰 글로벌",
        width: "150px",
      },
      {
        name: "티몰 내륙",
        width: "150px",
      },
      {
        name: "도우인 글로벌",
        width: "150px",
      },
      {
        name: "도우인 내륙",
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
  }).render(document.getElementById("lastMonthTopicGoodBadList"));
}

/************************************************************ 채널 별 긍부정 시계열 그래프 **********************************************************************/

summary.channelSentimentTrendProductUpdate = function () {
  let rawData = summary.channelSentimentTrendProduct;
  const brnd = [...new Set(rawData.map((item) => item.brnd_nm))];
  let dataList = [];
  let choicesList = [];
  brnd.forEach((data) => {
    choicesList = [];
    rawData.forEach((raw) => {
      if (raw.brnd_nm === data) {
        choicesList.push({ value: raw.prod_id, label: raw.prod_nm, selected: false, disabled: false });
      }
    });
    dataList.push({
      label: data,
      id: data,
      disabled: false,
      choices: choicesList,
    });
  });
  if (summary.choicePosiNegaProd) {
    summary.choicePosiNegaProd.setChoices(dataList, "value", "label", true);
  }
};

/* 채널 별 긍부정 시계열 그래프 - select 박스 */
const choicePosiNegaProd = document.getElementById("channel_posi_nega_prod");
if (choicePosiNegaProd) {
  if (!summary.choicePosiNegaProd) {
    summary.choicePosiNegaProd = new Choices(choicePosiNegaProd, {
      searchEnabled: false,
      shouldSort: false,
      removeItemButton: true,
      classNames: {
        removeButton: "remove",
      },
      placeholder: true,
      placeholderValue: "제품을 선택하세요.  ",
    });
  }
}

summary.channelSentimentTrendSeriesGraphUpdate = function () {
  let rawData = summary.channelSentimentTrendSeriesGraph;
  // rawData = rawData.sort(function (a, b) {
  //   if (a === 0) return -1; // 0을 가장 첫번째로 배치
  //   return new Date(a.x_dt) - new Date(b.x_dt);
  // });
  if (summary.chartLineChannelPosiNega) {
    summary.chartLineChannelPosiNega.setOption(summary.chartLineChannelPosiNegaOption, true);
    const x_dt = [...new Set(rawData.map((item) => item.x_dt))];
    const prod_nm = [...new Set(rawData.map((item) => item.prod_nm))];
    let series = [];
    let choicesSearchType = document.getElementById("choices-search-type");
    let seriesData, findData;
    prod_nm.forEach((prod) => {
      seriesData = [];
      x_dt.forEach((dt) => {
        findData = rawData.find((item) => item.prod_nm === prod && item.x_dt == dt);
        seriesData.push(findData ? findData[`${choicesSearchType.value == "1" ? "revw_rate_cum" : "revw_rate"}`] : 0);
      });
      series.push({
        name: prod,
        type: "line",
        data: seriesData,
      });
    });
    if (rawData.length > 0) {
      console.log(rawData);
      summary.chartLineChannelPosiNega.setOption({
        legend: {
          data: prod_nm,
          textStyle: {
            color: "#858d98",
          }
        },
        xAxis: {
          type: "category",
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

summary.channelSentimentTrendSearch = function () {
  let selProductSales = summary.choicePosiNegaProd.getValue();
  let productArr = selProductSales.map((item) => item.value);
  if (productArr.length == 0) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }
  dataList = ["channelSentimentTrendSeriesGraph"];
  datePicker = document.getElementById("summaryTimeSeriesDate");
  params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      PROD_ID: `'${productArr.join(",")}'`,
      PSNG_TYPE: `'${summary.psngType}'`,
    },
    menu: "reviewanalysis",
    tab: "summary",
    dataList: ["channelSentimentTrendSeriesGraph"],
  };
  getData(params, function (data) {
    summary.channelSentimentTrendSeriesGraph = data["channelSentimentTrendSeriesGraph"];
    summary.channelSentimentTrendSeriesGraphUpdate();
  });
};

/* 채널 별 긍부정 시계열 그래프 - 그래프 */
summary.chartLineChannelPosiNegaOption = {
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
        type: ["line", "bar"], // magicType으로 전환할 그래프 유형을 설정합니다.
      },
    },
  },
  grid: {
    left: "1%",
    right: "3%",
    bottom: "3%",
    containLabel: true,
  },
  legend: {},
  xAxis: {
    type: "category",
    data: [],
  },
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
summary.chartLineChannelPosiNega = echarts.init(document.getElementById("chart-line-channel-posi-nega"));
summary.chartLineChannelPosiNega.setOption(summary.chartLineChannelPosiNegaOption);

// 이벤트 핸들러 함수를 배열로 정의합니다.
summary.resizeHandlers = [summary.chartTreeChannelMyProd.resize, summary.chartLineChannelPosiNega.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
summary.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

summary.updateButtonStyle = function (name, type) {
  let buttonClasses = {
    긍정: ["error", "btn-soft-primary", "btn-primary"],
    부정: ["nomal", "btn-soft-danger", "btn-danger"],
  };
  summary.psngType = name == "긍정" ? "PSTV" : "NGTV";
  if (typeof type == "object") {
    if (type[0].indexOf("1") > 0) {
      buttonClasses["긍정"].push("pstv1");
      buttonClasses["부정"].push("ngtv1");
    } else if (type[0].indexOf("2") > 0) {
      buttonClasses["긍정"].push("pstv2");
      buttonClasses["부정"].push("ngtv2");
    } else if (type[0].indexOf("3") > 0) {
      buttonClasses["긍정"].push("pstv3");
      buttonClasses["부정"].push("ngtv3");
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

summary.onLoadEvent = function (initData) {
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

  if (document.getElementById("sbxChannel")) {
    const sbxChannel = document.getElementById("sbxChannel");
    if (!summary.sbxChannel) {
      summary.sbxChannel = new Choices(sbxChannel, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }

  if (document.getElementById("sbxChannelTopic")) {
    const sbxChannelTopic = document.getElementById("sbxChannelTopic");
    if (!summary.sbxChannelTopic) {
      summary.sbxChannelTopic = new Choices(sbxChannelTopic, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }

  flatpickr("#channelMyProdViewer, #summaryTimeSeriesDate", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
  });

  let btnSm = document.querySelectorAll(".btn-sm-rv-smy");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let psngType = chkTxt == "긍정" ? "PSTV" : "NGTV";
      let classList = this.classList.value.split(" ");
      let dataList = [];
      let datePicker, params;
      if (classList[0].indexOf("1") > 0) {
        dataList = ["channelReviewTreeMap"];
        datePicker = document.getElementById("channelMyProdViewer");
        params = {
          params: {
            FR_DT: `'${datePicker.value.substring(0, 10)}'`,
            TO_DT: `'${datePicker.value.slice(-10)}'`,
            WITH_FAKE: `'N'`,
            CHNL_ID: `'${summary.sbxChannel.getValue().value}'`,
            TPIC_ITEM: `'${summary.sbxChannelTopic.getValue().value}'`,
            PSNG_TYPE: `'${psngType}'`,
          },
          menu: "reviewanalysis",
          tab: "summary",
          dataList: dataList,
        };
      } else if (classList[0].indexOf("2") > 0) {
        dataList = ["posNegRatioChangeMoM"];
        params = {
          params: {
            PSNG_TYPE: `'${psngType}'`,
          },
          menu: "reviewanalysis",
          tab: "summary",
          dataList: dataList,
        };
      } else if (classList[0].indexOf("3") > 0) {
        let selProductSales = summary.choicePosiNegaProd.getValue();
        let productArr = selProductSales.map((item) => item.value);
        if (productArr.length == 0) {
          dapAlert("제품을 선택해 주세요.");
          return false;
        }
        dataList = ["channelSentimentTrendSeriesGraph"];
        datePicker = document.getElementById("summaryTimeSeriesDate");
        params = {
          params: {
            FR_DT: `'${datePicker.value.substring(0, 10)}'`,
            TO_DT: `'${datePicker.value.slice(-10)}'`,
            PROD_ID: `'${productArr.join(",")}'`,
            PSNG_TYPE: `'${psngType}'`,
          },
          menu: "reviewanalysis",
          tab: "summary",
          dataList: dataList,
        };
      }

      summary.updateButtonStyle(chkTxt, classList);
      getData(params, function (data) {
        if (classList[0].indexOf("1") > 0) {
          summary.channelReviewTreeMap = data["channelReviewTreeMap"];
          summary.channelReviewTreeMapUpdate();
        } else if (classList[0].indexOf("2") > 0) {
          summary.posNegRatioChangeMoM = data["posNegRatioChangeMoM"];
          summary.posNegRatioChangeMoMUpdate();
        } else if (classList[0].indexOf("3") > 0) {
          summary.channelSentimentTrendSeriesGraph = data["channelSentimentTrendSeriesGraph"];
          summary.channelSentimentTrendSeriesGraphUpdate();
        }
      });
    });
  });

  let dataList = [
    "impCardAmtData" /* 중요정보 카드 Data 조회 */,
    "impCardAmtChart" /* 중요정보 그래프 Data 조회 */,
    "channelReviewChannel" /* 2. 채널 별 리뷰 지도 - 채널 선택 SQL */,
    "channelReviewTopic" /* 2. 채널 별 리뷰 지도 - 토픽 선택 SQL */,
    "channelReviewTreeMap" /* 2. 채널 별 리뷰 지도 - 트리 맵 그래프 SQL */,
    "posNegRatioChangeMoM" /* 3. 전월 대비 긍정/부정 비율 변화 - 표 SQL */,
    "channelSentimentTrendProduct" /* 4. 채널 별 긍부정 시계열 그래프 - 제품 선택 */,
  ];
  let params = {
    params: {
      FR_DT: `'${initData.fr_dt}'`,
      TO_DT: `'${initData.to_dt}'`,
      BASE_MNTH: `'${initData.base_mnth}'`,
      BASE_YEAR: `'${initData.base_year}'`,
      WITH_FAKE: `'N'`,
      CHNL_ID: `'ALL'`,
      TPIC_ITEM: `'전체'`,
      PSNG_TYPE: `'PSTV'`,
    },
    menu: "reviewanalysis",
    tab: "summary",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      summary[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    summary.updateButtonStyle("긍정", "all");
    summary.setDataBinding();
  });
};
