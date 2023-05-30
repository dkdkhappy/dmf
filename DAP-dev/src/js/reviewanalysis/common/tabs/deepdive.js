let reviewAnalysisDeepdive = {};
reviewAnalysisDeepdive.psngType1 = "PSTV";
reviewAnalysisDeepdive.psngType2 = "PSTV";
reviewAnalysisDeepdive.psngType3 = "PSTV";
reviewAnalysisDeepdive.psngType4 = "PSTV";
reviewAnalysisDeepdive.onloadStatus = false; // 화면 로딩 상태

reviewAnalysisDeepdive.updateButtonStyle = function (name, type) {
  let buttonClasses = {
    긍정: ["error", "btn-soft-primary", "btn-primary"],
    부정: ["nomal", "btn-soft-danger", "btn-danger"],
  };

  if (typeof type == "object") {
    if (type[0].indexOf("1") > 0) {
      buttonClasses["긍정"].push("dd-pstv1");
      buttonClasses["부정"].push("dd-ngtv1");
    } else if (type[0].indexOf("2") > 0) {
      buttonClasses["긍정"].push("dd-pstv2");
      buttonClasses["부정"].push("dd-ngtv2");
    } else if (type[0].indexOf("3") > 0) {
      buttonClasses["긍정"].push("dd-pstv3");
      buttonClasses["부정"].push("dd-ngtv3");
    } else if (type[0].indexOf("4") > 0) {
      buttonClasses["긍정"].push("dd-pstv4");
      buttonClasses["부정"].push("dd-ngtv4");
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

reviewAnalysisDeepdive.updateButtonStyle2 = function (name) {
  const buttonClasses = {
    대주제: ["bigTit", "error", "btn-soft-primary", "btn-primary"],
    효능: ["effic", "nomal", "btn-soft-success", "btn-success"],
  };
  Object.entries(buttonClasses).forEach(([key, classes]) => {
    const button = document.querySelector(`.${classes[0]}`);
    if (button) {
      if (key !== name) {
        button.classList.remove(classes[3]);
        button.classList.add(classes[2]);
      } else {
        button.classList.remove(classes[2]);
        button.classList.add(classes[3]);
      }
    }
  });
};

/* 제품 선택 */
reviewAnalysisDeepdive.viewReviewBarProdUpdate = function () {
  let rawData = reviewAnalysisDeepdive.viewReviewBarProd;
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
  reviewAnalysisDeepdive.schProduct1.setChoices(dataList, "value", "label", true);
};

/* 제품 선택 */
reviewAnalysisDeepdive.commonProdUpdate = function () {
  let rawData = reviewAnalysisDeepdive.commonProd;
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
  if (reviewAnalysisDeepdive.schProduct2) reviewAnalysisDeepdive.schProduct2.setChoices(dataList, "value", "label", true);
  if (reviewAnalysisDeepdive.schProduct3) reviewAnalysisDeepdive.schProduct3.setChoices(dataList, "value", "label", true);
  if (reviewAnalysisDeepdive.schProduct4) reviewAnalysisDeepdive.schProduct4.setChoices(dataList, "value", "label", true);
};

reviewAnalysisDeepdive.topicRadarCategoryUpdate = function () {
  if (reviewAnalysisDeepdive.schCategory) {
    let rawData = reviewAnalysisDeepdive.topicRadarCategory;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.cate_nm, label: data.cate_nm });
    });
    reviewAnalysisDeepdive.schCategory.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schCategory.setChoiceByValue(dataList[0].value);
  }
};
reviewAnalysisDeepdive.viewReviewBarCategoryUpdate = function () {
  if (reviewAnalysisDeepdive.schCategory2) {
    let rawData = reviewAnalysisDeepdive.viewReviewBarCategory;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.cate_nm, label: data.cate_nm });
    });
    reviewAnalysisDeepdive.schCategory2.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schCategory2.setChoiceByValue(dataList[0].value);
  }
};

// reviewAnalysisDeepdive.viewReviewBarTpicTypeUpdate = function () {
//   let rawData = reviewAnalysisDeepdive.viewReviewBarTpicType;
//   let dataList = [];
//   rawData.forEach((data) => {
//     dataList.push({ value: data.tpic_type, label: data.tpic_type });
//   });
//   if (reviewAnalysisDeepdive.schTopic0) {
//     reviewAnalysisDeepdive.schTopic1.setChoices(dataList, "value", "label", true);
//     reviewAnalysisDeepdive.schTopic1.setChoiceByValue("전체");
//   }
// };

reviewAnalysisDeepdive.topicRadarTpicTypeUpdate = function () {
  let rawData = reviewAnalysisDeepdive.topicRadarTpicType;
  let dataList = [];
  rawData.forEach((data) => {
    dataList.push({ value: data.tpic_type, label: data.tpic_type });
  });
  if (reviewAnalysisDeepdive.schTopic0) {
    reviewAnalysisDeepdive.schTopic0.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schTopic0.setChoiceByValue("전체");
  }
  if (reviewAnalysisDeepdive.schTopic1) {
    reviewAnalysisDeepdive.schTopic1.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schTopic1.setChoiceByValue("전체");
  }
  if (reviewAnalysisDeepdive.schTopic2) {
    reviewAnalysisDeepdive.schTopic2.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schTopic2.setChoiceByValue("전체");
  }
  if (reviewAnalysisDeepdive.schTopic3) {
    reviewAnalysisDeepdive.schTopic3.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schTopic3.setChoiceByValue("전체");
  }
  if (reviewAnalysisDeepdive.schTopic4) {
    reviewAnalysisDeepdive.schTopic4.setChoices(dataList, "value", "label", true);
    reviewAnalysisDeepdive.schTopic4.setChoiceByValue("전체");
  }
};

reviewAnalysisDeepdive.topicRadarTpicTypeSubUpdate = function (target) {
  let rawData = reviewAnalysisDeepdive.topicRadarTpicTypeSub;
  const tpic = [...new Set(rawData.map((item) => item.tpic_type))];
  let dataList = [];
  let choicesList = [];
  let option = document.createElement("option");
  choicesList.push({ value: "", label: "세부 토픽을 선택하세요.", disabled: true });
  tpic.forEach((data) => {
    choicesList = [];
    rawData.forEach((raw) => {
      if (raw.tpic_type === data) {
        choicesList.push({ value: raw.tpic_item, label: raw.tpic_item, selected: false, disabled: false });
      }
    });
    dataList.push({
      label: data,
      id: data,
      disabled: false,
      choices: choicesList,
    });
  });
  reviewAnalysisDeepdive[`${target}`].setChoices(dataList, "value", "label", true);
};

/******************************************************** 토픽별 바그래프 ***************************************************/

reviewAnalysisDeepdive.chartBarTopicSch = function () {
  let topic = reviewAnalysisDeepdive.schTopic0.getValue();
  let topicSub = reviewAnalysisDeepdive.schTopicSub0.getValue();
  let prodId = reviewAnalysisDeepdive.schProduct1.getValue();
  let cate_nm = reviewAnalysisDeepdive.schCategory2.getValue();
  let psngType = reviewAnalysisDeepdive.psngType1;

  let topicValue = topic.value;
  let topicItemValue = "";
  let prodValue = "";

  if (topicValue === "토픽선택" && topicSub.value == "") {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  topicItemValue = topicSub.value;
  prodValue = prodId.map((item) => item.value).join(",");

  const datePicker = document.getElementById("topicBarDatepicker");

  let dataList = ["viewReviewBar" /* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */];
  let params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      TPIC_TYPE: `'${topicValue}'`,
      TPIC_ITEM: `'${topicItemValue ? topicItemValue : ""}'`,
      PROD_ID: `'${prodValue}'`,
      CATE_NM: `'${cate_nm.value}'`,
      PSNG_TYPE: `'${psngType}'`,
    },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.viewReviewBar = {};
    /* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */
    if (data["viewReviewBar"] != undefined) {
      reviewAnalysisDeepdive.viewReviewBar = replaceNullWithZero(data["viewReviewBar"]);
      reviewAnalysisDeepdive.viewReviewBarUpdate(psngType);
    }
  });
};

reviewAnalysisDeepdive.viewReviewBarUpdate = function (psngType) {
  let rawData = reviewAnalysisDeepdive.viewReviewBar;
  let color,
    name = "";
  psngType == "NGTV" ? [(color = "#ee6666"), (name = "부정 비율")] : [(color = "#5470c6"), (name = "긍정 비율")];

  reviewAnalysisDeepdive.chartBarTopic.setOption(reviewAnalysisDeepdive.chartBarTopicOption, true);
  if (rawData.length > 0) {
    reviewAnalysisDeepdive.chartBarTopic.setOption({
      xAxis: {
        type: "value",
        min: 0,
        max: 100,
      },
      yAxis: {
        type: "category",
        data: rawData.map((item) => item.prod_nm),
      },
      series: [
        {
          name: name,
          type: "bar",
          data: rawData.map((item) => item.pstv_rate),
          itemStyle: {
            color: color,
          },
        },
      ],
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
};

/* zoom data */
reviewAnalysisDeepdive.zoomDeepdive = [
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
/* 토픽별 바 그래프 */
reviewAnalysisDeepdive.chartBarTopicOption = {
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
    right: "4%",
    bottom: "3%",
    top: "3%",
    containLabel: true,
  },
  xAxis: {
    type: "value",
  },
  yAxis: {
    type: "category",
    data: [],
    axisLabel: {
      formatter: function (value, index) {
        var val = value.slice(0, 20);
        if (val > 20) {
          val = value.slice(0, 20) + "...";
        }
        return val;
      },
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
if (document.getElementById("chart-bar-topic")) {
  reviewAnalysisDeepdive.chartBarTopic = echarts.init(document.getElementById("chart-bar-topic"));
  reviewAnalysisDeepdive.chartBarTopic.setOption(reviewAnalysisDeepdive.chartBarTopicOption);
}
/*************************************************************************************************************************/
/**************************************************** 조회 토픽 리뷰 수/긍정 리뷰 수 ***************************************/

reviewAnalysisDeepdive.chartMixTopicPosiReviewSch = function () {
  let category = reviewAnalysisDeepdive.schCategory.getValue();
  let topic = reviewAnalysisDeepdive.schTopic1.getValue();
  let topicSub = reviewAnalysisDeepdive.schTopicSub1.getValue();
  let psngType = reviewAnalysisDeepdive.psngType2;

  let cateValue = "";
  let topicValue = topic.value;
  let topicItemValue = "";

  if (!category) {
    dapAlert("카테고리를 선택해 주세요.");
    return false;
  } else {
    cateValue = category.value;
  }

  if (topicValue === "토픽선택" && topicSub.length === 0) {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  topicItemValue = topicSub.map((item) => item.value).join(",");

  const datePicker = document.getElementById("topicBarDatepicker");

  let dataList = ["topicRadarBar" /* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */];
  let params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      CATE_NM: `'${cateValue}'`,
      TPIC_TYPE: `'${topicValue}'`,
      TPIC_ITEM: `'${topicItemValue}'`,
      PSNG_TYPE: `'${psngType}'`,
    },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.topicRadarBar = {};
    /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 바 그래프 SQL */
    if (data["topicRadarBar"] != undefined) {
      reviewAnalysisDeepdive.topicRadarBar = replaceNullWithZero(data["topicRadarBar"]);
      reviewAnalysisDeepdive.topicRadarBarUpdate(psngType);
    }
  });
};

reviewAnalysisDeepdive.topicRadarBarUpdate = function (psngType) {
  let rawData = reviewAnalysisDeepdive.topicRadarBar;
  let lgnd,
    color = "";
  psngType == "NGTV" ? [(lgnd = "부정 리뷰 비율"), (color = "#ee6666")] : [(lgnd = "긍정 리뷰 비율"), (color = "#5470c6")];

  reviewAnalysisDeepdive.chartMixTopicPosiReview.setOption(reviewAnalysisDeepdive.chartMixTopicPosiReviewOption, true);
  if (rawData.length > 0) {
    reviewAnalysisDeepdive.chartMixTopicPosiReview.setOption({
      xAxis: {
        type: "category",
        data: rawData.map((item) => item.tpic_item),
        axisLabel: {
          rotate: 45,
        },
      },
      yAxis: [
        {
          type: "value",
          min: 0,
          max: 100,
        },
        {
          type: "value",
        },
      ],
      legend: {
        textStyle: {
          color: "#858d98",
        },
      },
      series: [
        {
          name: "리뷰 수",
          type: "bar",
          yAxisIndex: 1,
          data: rawData.map((item) => item.revw_cnt),
          itemStyle: {
            color: "#91cc75",
          },
        },
        {
          name: lgnd,
          type: "line",
          data: rawData.map((item) => item.pstv_rate),
          itemStyle: {
            color: color,
          },
        },
      ],
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
};

/* 조회 토픽 리뷰 수 / 긍정 리뷰 수 */
reviewAnalysisDeepdive.chartMixTopicPosiReviewOption = {
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
if (document.getElementById("chart-mix-topic-posi-review")) {
  reviewAnalysisDeepdive.chartMixTopicPosiReview = echarts.init(document.getElementById("chart-mix-topic-posi-review"));
  reviewAnalysisDeepdive.chartMixTopicPosiReview.setOption(reviewAnalysisDeepdive.chartMixTopicPosiReviewOption);
}

/**************************************************************************************************************/

/************************************************** 카테고리 별 / 토픽 100% 바 그래프 ************************************************************/

reviewAnalysisDeepdive.categoryTopic100pBarChartCategoryUpdate = function () {
  if (reviewAnalysisDeepdive.schCategory3) {
    let rawData = reviewAnalysisDeepdive.categoryTopic100pBarChartCategory;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.cate_nm, label: data.cate_nm });
    });
    reviewAnalysisDeepdive.schCategory3.setChoices(dataList, "value", "label", true);
  }
};

reviewAnalysisDeepdive.categoryTopic100pBarChartUpdate = function () {
  let rawData = reviewAnalysisDeepdive.categoryTopic100pBarChart;
  reviewAnalysisDeepdive.chartBarCateTopic.setOption({
    xAxis: {
      type: "value",
      min: 0,
      max: 100,
    },
    yAxis: {
      type: "category",
      data: rawData.map((item) => item.tpic_item),
    },
    series: [
      {
        data: rawData.map((item) => item.pstv_rate),
      },
      {
        data: rawData.map((item) => item.ntrl_rate),
      },
      {
        data: rawData.map((item) => item.ngtv_rate),
      },
    ],
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
};

/* 카테고리별 / 토픽 100% 바그래프 */
reviewAnalysisDeepdive.chartBarCateTopicOption = {
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "shadow",
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
  legend: {
    textStyle: {
      color: "#858d98",
    },
  },
  grid: {
    left: "1%",
    right: "6%",
    bottom: "2%",
    top: "8%",
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
      name: "긍정",
      type: "bar",
      stack: "total",
      itemStyle: {
        color: "#5470c6",
      },
      label: {
        show: true,
      },
      emphasis: {
        focus: "series",
      },
      data: [],
    },
    {
      name: "중립",
      type: "bar",
      stack: "total",
      itemStyle: {
        color: "#91cc75",
      },
      label: {
        show: true,
      },
      emphasis: {
        focus: "series",
      },
      data: [],
    },
    {
      name: "부정",
      type: "bar",
      stack: "total",
      itemStyle: {
        color: "#ee6666",
      },
      label: {
        show: true,
      },
      emphasis: {
        focus: "series",
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
if (document.getElementById("chart-bar-cate-topic")) {
  reviewAnalysisDeepdive.chartBarCateTopic = echarts.init(document.getElementById("chart-bar-cate-topic"));
  reviewAnalysisDeepdive.chartBarCateTopic.setOption(reviewAnalysisDeepdive.chartBarCateTopicOption);
}

/*************************************************************************************************************************/
/****************************************************** 토픽별 레이더 그래프 ************************************************/
reviewAnalysisDeepdive.chartRaderTopicSch = function (validationCheck = true) {
  let tpicType = reviewAnalysisDeepdive.schTopic2.getValue();
  let tpicItem = reviewAnalysisDeepdive.schTopicSub2.getValue();
  let prodId = reviewAnalysisDeepdive.schProduct2.getValue();
  let psngType = reviewAnalysisDeepdive.psngType3;
  let avgType = reviewAnalysisDeepdive.schAverage.getValue();

  let tpicValue = tpicType.value;
  let itemValue = "";
  let prodValue = "";

  if (tpicValue === "토픽선택" && tpicItem.length === 0 && validationCheck) {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  if (prodId.label == "제품을 선택하세요." && validationCheck) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  } else {
    prodValue = prodId.value;
  }

  itemValue = tpicItem.map((item) => item.value).join(",");

  let dataList = ["topicRadar" /* 3. 토픽별 레이더 그래프 - 레이더 그래프 SQL */, "radarTooltip" /* 4. 레이더 부연설명 그래프 - 바 그래프 SQL */];

  let topicRadarDatepicker = document.getElementById("topicRadarDatepicker");
  let params = {
    params: {
      FR_DT: `'${topicRadarDatepicker.value.substring(0, 10)}'`,
      TO_DT: `'${topicRadarDatepicker.value.slice(-10)}'`,
      TPIC_TYPE: `'${tpicValue}'`,
      TPIC_ITEM: `'${itemValue}'`,
      PROD_ID: `'${prodValue}'`,
      PSNG_TYPE: `'${psngType}'`,
      AVG_TYPE: `'${avgType.value}'`,
    },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.topicRadar = {};
    reviewAnalysisDeepdive.radarTooltip = {};
    /* 3. 토픽별 레이더 그래프 - 레이더 그래프 SQL */
    if (data["topicRadar"] != undefined) {
      reviewAnalysisDeepdive.topicRadar = replaceNullWithZero(data["topicRadar"]);
      reviewAnalysisDeepdive.topicRadarUpdate();
    }
    /* 4. 레이더 부연설명 그래프 - 바 그래프 SQL */
    if (data["radarTooltip"] != undefined) {
      reviewAnalysisDeepdive.radarTooltip = replaceNullWithZero(data["radarTooltip"]);
      reviewAnalysisDeepdive.radarTooltipUpdate();
    }
  });
};

reviewAnalysisDeepdive.topicRadarUpdate = function () {
  let rawData = reviewAnalysisDeepdive.topicRadar;
  reviewAnalysisDeepdive.chartRaderTopic.setOption(reviewAnalysisDeepdive.chartRaderTopicOption, true);
  if (rawData.length > 0) {
    let indicator = [];
    const maxProdRate = Math.max(...rawData.map((item) => parseFloat(item.prod_rate)));
    const maxAvgRate = Math.max(...rawData.map((item) => parseFloat(item.avg_rate)));
    const maxRate = Math.max(maxProdRate, maxAvgRate);
    rawData.forEach(function (item) {
      var obj = {
        name: item.tpic_item,
        max: maxRate,
        avg: parseFloat(item.avg_rate),
        prod: parseFloat(item.prod_rate),
      };
      indicator.push(obj);
    });
    reviewAnalysisDeepdive.chartRaderTopic.setOption({
      radar: {
        indicator: indicator,
      },
      series: [
        {
          type: "radar",
          data: [
            {
              name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "제품 긍정 비율" : "제품 부정 비율"}`,
              value: indicator.map((item) => item.prod),
            },
          ],
          itemStyle: {
            color: "#5470c6",
          },
        },
        {
          type: "radar",
          data: [
            {
              name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? document.getElementById("schAverage").innerText + " 긍정 비율" : document.getElementById("schAverage").innerText + " 부정 비율"}`,
              value: indicator.map((item) => item.avg),
            },
          ],
          itemStyle: {
            color: "#91cc75",
          },
        },
      ],
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
};

/* 토픽별 레이더 그래프 */
reviewAnalysisDeepdive.chartRaderTopicOption = {
  legend: {
    orient: "vertical",
    top: "center",
    left: "left",
    textStyle: {
      color: "#858d98",
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
  tooltip: {},
  radar: {
    indicator: [],
  },
  series: [
    {
      type: "radar",
      data: [],
      itemStyle: {
        color: "#5470c6",
      },
    },
    {
      type: "radar",
      data: [],
      itemStyle: {
        color: "#91cc75",
      },
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
if (document.getElementById("chart-rader-topic")) {
  reviewAnalysisDeepdive.chartRaderTopic = echarts.init(document.getElementById("chart-rader-topic"));
  reviewAnalysisDeepdive.chartRaderTopic.setOption(reviewAnalysisDeepdive.chartRaderTopicOption);
}
/************************************************************************************************************************/
/***************************************************** 레이더 부연설명 그래프 ***********************************************/
reviewAnalysisDeepdive.radarTooltipUpdate = function () {
  let rawData = reviewAnalysisDeepdive.radarTooltip;
  reviewAnalysisDeepdive.chartBarSubRader.setOption(reviewAnalysisDeepdive.chartBarSubRaderOption, true);
  if (rawData.length > 0) {
    const tpicItem = [...new Set(rawData.map((item) => item.tpic_item))];
    reviewAnalysisDeepdive.chartBarSubRader.setOption({
      xAxis: [
        {
          type: "category",
          data: tpicItem,
          axisLabel: {
            rotate: 45,
          },
        },
      ],
      series: [
        {
          name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "제품 긍정비율" : "제품 부정비율"}`,
          type: "bar",
          data: rawData.filter((item) => item.l_lgnd === `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "제품 긍정비율" : "제품 부정비율"}`).map((item) => item.pstv_rate),
        },
        {
          name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "평균 긍정비율" : "평균 부정비율"}`,
          type: "bar",
          data: rawData.filter((item) => item.l_lgnd === `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "평균 긍정비율" : "평균 부정비율"}`).map((item) => item.pstv_rate),
        },
        {
          name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "업계최고 긍정비율" : "업계최고 부정비율"}`,
          type: "bar",
          data: rawData.filter((item) => item.l_lgnd === `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "업계최고 긍정비율" : "업계최고 부정비율"}`).map((item) => item.pstv_rate),
        },
        {
          name: `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "업계최저 긍정비율" : "업계최저 부정비율"}`,
          type: "bar",
          data: rawData.filter((item) => item.l_lgnd === `${reviewAnalysisDeepdive.psngType3 == "PSTV" ? "업계최저 긍정비율" : "업계최저 부정비율"}`).map((item) => item.pstv_rate),
        },
      ],
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
};
/* 레이더 부연 설명 그래프 */
reviewAnalysisDeepdive.chartBarSubRaderOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    textStyle: {
      color: "#858d98",
    },
  },
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
      magicType: {
        type: ["line", "bar"],
      },
    },
  },
  grid: {
    left: "2%",
    right: "5%",
    bottom: "3%",
    containLabel: true,
  },
  xAxis: [
    {
      type: "category",
      data: [],
      axisTick: {
        alignWithLabel: true,
      },
    },
  ],
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
if (document.getElementById("chart-bar-sub-rader")) {
  reviewAnalysisDeepdive.chartBarSubRader = echarts.init(document.getElementById("chart-bar-sub-rader"));
  reviewAnalysisDeepdive.chartBarSubRader.setOption(reviewAnalysisDeepdive.chartBarSubRaderOption);
}

/*************************************************************************************************************************/
/****************************************************** 토픽별 시계열 그래프 ************************************************/
reviewAnalysisDeepdive.chartLineTopicSch = function () {
  let tpicType = reviewAnalysisDeepdive.schTopic3.getValue();
  let tpicItem = reviewAnalysisDeepdive.schTopicSub3.getValue();

  let prodId = reviewAnalysisDeepdive.schProduct3.getValue();
  let psngType = reviewAnalysisDeepdive.psngType4;

  let tpicValue = tpicType.value;
  let itemValue = "";
  let prodValue = "";

  if (tpicValue === "토픽선택" && tpicItem.value == "") {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  if (prodId.length == 0) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }

  itemValue = tpicItem.value;
  prodValue = prodId.map((item) => item.value).join(",");

  let dataList = ["topicTimeSeries" /* 5. 토픽별 시계열 그래프 - 시계열 그래프 SQL */];

  let datePicker = document.getElementById("topicSeriesDatepicker");
  let params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      TPIC_TYPE: `'${tpicValue}'`,
      TPIC_ITEM: `'${itemValue}'`,
      PROD_ID: `'${prodValue}'`,
      PSNG_TYPE: `'${psngType}'`,
    },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.topicTimeSeries = {};
    /* 5. 토픽별 시계열 그래프 - 시계열 그래프 SQL */
    if (data["topicTimeSeries"] != undefined) {
      reviewAnalysisDeepdive.topicTimeSeries = replaceNullWithZero(data["topicTimeSeries"]);
      reviewAnalysisDeepdive.topicTimeSeriesUpdate(psngType);
    }
  });
};

reviewAnalysisDeepdive.topicTimeSeriesUpdate = function (psngType) {
  let rawData = reviewAnalysisDeepdive.topicTimeSeries;
  reviewAnalysisDeepdive.chartLineTopic.setOption(reviewAnalysisDeepdive.chartLineTopicOption, true);
  if (rawData.length > 0) {
    let schTimePoint = document.getElementById("schTimePoint").value;
    let category = [...new Set(rawData.map((item) => item.x_dt))];
    let prodId = [...new Set(rawData.map((item) => item.prod_id))];
    let prodNm = [...new Set(rawData.map((item) => item.prod_nm))];
    let addText = "";
    psngType == "NGTV" ? (addText = " - 부정도") : (addText = " - 긍정도");

    category = category.sort(function (a, b) {
      if (a === 0) return -1; // 0을 가장 첫번째로 배치
      return new Date(a) - new Date(b);
    });

    let seriesData = [];
    prodId.forEach((id) => {
      let filterData = rawData.filter((item) => item.prod_id == id);

      filterData = filterData.sort(function (a, b) {
        if (a.x_dt < b.x_dt) return -1;
        if (a.x_dt > b.x_dt) return 1;
        return 0;
      });

      let pstvArr = [];
      let revwArr = [];
      filterData.forEach(function (data) {
        let pstv = schTimePoint == "1" ? data["pstv_rate_cum"] : data["pstv_rate"];
        let revw = schTimePoint == "1" ? data["revw_cnt_cum"] : data["revw_cnt"];
        pstvArr.push([data["x_dt"], Number(pstv)]);
        revwArr.push([data["x_dt"], Number(revw)]);
      });
      seriesData.push({
        name: filterData[0]["prod_nm"] + addText,
        type: "line",
        data: pstvArr,
      });
      seriesData.push({
        name: filterData[0]["prod_nm"] + " - 리뷰수",
        type: "bar",
        data: revwArr,
      });
    });

    reviewAnalysisDeepdive.chartLineTopic.setOption({
      legend: {
        formatter: function (name) {
          return name;
        },
        textStyle: {
          color: "#858d98",
        },
      },
      xAxis: [
        {
          type: "category",
          data: category,
        },
      ],
      series: seriesData,
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
};

/* 토픽별 시계열 그래프 */
reviewAnalysisDeepdive.chartLineTopicOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {},
  dataZoom: reviewAnalysisDeepdive.zoomDeepdive,
  grid: {
    left: "2%",
    right: "4%",
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
  xAxis: {
    type: "category",
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
        top: "center",
        style: {
          text: "데이터가 없습니다",
          fill: "#999",
          font: "14px Microsoft YaHei",
        },
      },
    ],
  },
};
if (document.getElementById("chart-line-topic")) {
  reviewAnalysisDeepdive.chartLineTopic = echarts.init(document.getElementById("chart-line-topic"));
  reviewAnalysisDeepdive.chartLineTopic.setOption(reviewAnalysisDeepdive.chartLineTopicOption);
}
/*************************************************************************************************************************/
/******************************************************* 워드 크라우드 ****************************************************/
reviewAnalysisDeepdive.wordCloudSch = function () {
  let prodId = reviewAnalysisDeepdive.schProduct4.getValue();
  let tpicType = reviewAnalysisDeepdive.schTopic4.getValue();
  let tpicItem = reviewAnalysisDeepdive.schTopicSub4.getValue();

  let tpicValue = tpicType.value;
  let itemValue = "";
  let prodValue = "";

  if (tpicValue === "토픽선택" && tpicItem.length === 0) {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  if (!prodId.value) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }

  itemValue = tpicItem.map((item) => item.value).join(",");
  prodValue = prodId.value;

  let dataList = ["wordCloud" /* 5. 토픽별 시계열 그래프 - 시계열 그래프 SQL */];
  let topicWordExcept = document.getElementById("topic-word-except");
  let exctTopic = topicWordExcept.checked ? "Y" : "N";
  let datePicker = document.getElementById("wordCloudDatepicker");
  let params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      TPIC_TYPE: `'${tpicValue}'`,
      TPIC_ITEM: `'${itemValue}'`,
      PROD_ID: `'${prodValue}'`,
      EXCT_TOPIC: `'${exctTopic}'`,
    },
    menu: "reviewanalysis/common",
    progress: false,
    tab: "deepdive",
    dataList: dataList,
  };

  reviewAnalysisDeepdive.wordCloud1 = false;
  reviewAnalysisDeepdive.wordCloud2 = false;

  document.getElementById("data-loading").style.visibility = "visible";
  params.params.PSNG_TYPE = `'PSTV'`;
  getData(params, function (data) {
    reviewAnalysisDeepdive.wordCloud = {};
    reviewAnalysisDeepdive.wordCloudKorean = {};
    /* 6. 워드 크라우드 - 워드 크라우드 SQL */
    if (data["wordCloud"] != undefined) {
      // 중국어 원본 Word Cloud 표시
      reviewAnalysisDeepdive.wordCloud = replaceNullWithZero(data["wordCloud"]);
      reviewAnalysisDeepdive.wordCloudUpdate(reviewAnalysisDeepdive.wordCloud, reviewAnalysisDeepdive.wordCloudChart, reviewAnalysisDeepdive.wordCloudOption);

      // 한국어 번역 Word Cloud 표시
      reviewAnalysisDeepdive.wordCloudKorean = replaceNullWithZero(data["wordCloud"]);
      reviewAnalysisDeepdive.wordCloudKorean.progress = false;
      getTranslate(reviewAnalysisDeepdive.wordCloudKorean, reviewAnalysisDeepdive.wordCloudKoreanUpdate);
      reviewAnalysisDeepdive.wordCloudKoreanChart.showLoading(); // 로딩 화면 표시
    }
  });
  params.params.PSNG_TYPE = `'NGTV'`;
  getData(params, function (data) {
    reviewAnalysisDeepdive.wordCloud = {};
    reviewAnalysisDeepdive.wordCloudKorean = {};
    /* 6. 워드 크라우드 - 워드 크라우드 SQL */
    if (data["wordCloud"] != undefined) {
      // 중국어 원본 Word Cloud 표시
      reviewAnalysisDeepdive.wordCloud = replaceNullWithZero(data["wordCloud"]);
      reviewAnalysisDeepdive.wordCloudUpdate(reviewAnalysisDeepdive.wordCloud, reviewAnalysisDeepdive.wordCloudNegaChart, reviewAnalysisDeepdive.wordCloudNegaOption);

      // 한국어 번역 Word Cloud 표시
      reviewAnalysisDeepdive.wordCloudKorean = replaceNullWithZero(data["wordCloud"]);
      reviewAnalysisDeepdive.wordCloudKorean.progress = false;
      getTranslate(reviewAnalysisDeepdive.wordCloudKorean, reviewAnalysisDeepdive.wordCloudKoreanNegaUpdate);
      reviewAnalysisDeepdive.wordCloudKoreanChart.showLoading(); // 로딩 화면 표시
    }
  });
};

// 중국어 원본 Word Cloud
reviewAnalysisDeepdive.wordCloudUpdate = function (rawData, target, options) {
  target.setOption(options, true);
  if (rawData.length > 0) {
    let seriesData = rawData.map((item) => ({ name: item.word_item, value: Number(item.word_cnt) }));
    target.setOption({
      series: [
        {
          data: seriesData,
        },
      ],
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
};

reviewAnalysisDeepdive.wordCloudOption = {
  title: {
    text: "긍정",
    left: "center",
    top: 10,
  },
  tooltip: {},
  series: [
    {
      type: "wordCloud",
      // gridSize: 3,
      // sizeRange: [12, 50],
      // rotationRange: [-90, 90],
      // shape: "pentagon",
      // width: 600,
      // height: 400,
      // drawOutOfBound: true,
      textStyle: {
        color: function () {
          return "rgb(" + [Math.round(Math.random() * 160), Math.round(Math.random() * 160), Math.round(Math.random() * 160)].join(",") + ")";
        },
      },
      emphasis: {
        textStyle: {
          shadowBlur: 10,
          shadowColor: "#333",
        },
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
if (document.getElementById("word-cloud")) {
  reviewAnalysisDeepdive.wordCloudChart = echarts.init(document.getElementById("word-cloud"));
  reviewAnalysisDeepdive.wordCloudChart.setOption(reviewAnalysisDeepdive.wordCloudOption);
}

// 중국어 원본 Word Cloud - 부정
reviewAnalysisDeepdive.wordCloudNegaOption = {
  title: {
    text: "부정",
    left: "center",
    top: 10,
  },
  tooltip: {},
  series: [
    {
      type: "wordCloud",
      // gridSize: 3,
      // sizeRange: [12, 50],
      // rotationRange: [-90, 90],
      // shape: "pentagon",
      // width: 600,
      // height: 400,
      // drawOutOfBound: true,
      textStyle: {
        color: function () {
          return "rgb(" + [Math.round(Math.random() * 160), Math.round(Math.random() * 160), Math.round(Math.random() * 160)].join(",") + ")";
        },
      },
      emphasis: {
        textStyle: {
          shadowBlur: 10,
          shadowColor: "#333",
        },
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
if (document.getElementById("word-cloud")) {
  reviewAnalysisDeepdive.wordCloudNegaChart = echarts.init(document.getElementById("word-cloud-nega"));
  reviewAnalysisDeepdive.wordCloudNegaChart.setOption(reviewAnalysisDeepdive.wordCloudNegaOption);
}

// 한국어 번역 Word Cloud
reviewAnalysisDeepdive.wordCloudKoreanUpdate = function (data) {
  let rawData = data["data"];
  reviewAnalysisDeepdive.wordCloudKoreanChart.setOption(reviewAnalysisDeepdive.wordCloudKoreanOption, true);
  reviewAnalysisDeepdive.wordCloudKoreanChart.hideLoading(); // 로딩 화면 숨김
  if (rawData && rawData.length > 0) {
    let seriesData;
    seriesData = rawData.map((item) => ({ name: item.word_item, value: Number(item.word_cnt) }));
    reviewAnalysisDeepdive.wordCloudKoreanChart.setOption({
      series: [
        {
          data: seriesData,
        },
      ],
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
};

reviewAnalysisDeepdive.wordCloudKoreanOption = {
  title: {
    text: "긍정",
    left: "center",
    top: 10,
  },
  tooltip: {},
  series: [
    {
      type: "wordCloud",
      // gridSize: 3,
      // sizeRange: [12, 50],
      // rotationRange: [-90, 90],
      // shape: "pentagon",
      // width: 600,
      // height: 400,
      // drawOutOfBound: true,
      textStyle: {
        color: function () {
          return "rgb(" + [Math.round(Math.random() * 160), Math.round(Math.random() * 160), Math.round(Math.random() * 160)].join(",") + ")";
        },
      },
      emphasis: {
        textStyle: {
          shadowBlur: 10,
          shadowColor: "#333",
        },
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
if (document.getElementById("word-cloud-korean")) {
  reviewAnalysisDeepdive.wordCloudKoreanChart = echarts.init(document.getElementById("word-cloud-korean"));
  reviewAnalysisDeepdive.wordCloudKoreanChart.setOption(reviewAnalysisDeepdive.wordCloudKoreanOption);
  reviewAnalysisDeepdive.wordCloudKoreanChart.on("finished", () => {
    reviewAnalysisDeepdive.wordCloud2 = true;
    if (reviewAnalysisDeepdive.wordCloud1 && reviewAnalysisDeepdive.wordCloud2) {
      document.getElementById("data-loading").style.visibility = "hidden";
    }
  });
}

reviewAnalysisDeepdive.wordCloudKoreanNegaUpdate = function (data) {
  let rawData = data["data"];
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart.setOption(reviewAnalysisDeepdive.wordCloudKoreanNegaOption, true);
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart.hideLoading(); // 로딩 화면 숨김
  if (rawData && rawData.length > 0) {
    let seriesData;
    seriesData = rawData.map((item) => ({ name: item.word_item, value: Number(item.word_cnt) }));
    reviewAnalysisDeepdive.wordCloudKoreanNegaChart.setOption({
      series: [
        {
          data: seriesData,
        },
      ],
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
};

// 한국어 번역 Word Cloud - 부정
reviewAnalysisDeepdive.wordCloudKoreanNegaOption = {
  title: {
    text: "부정",
    left: "center",
    top: 10,
  },
  tooltip: {},
  series: [
    {
      type: "wordCloud",
      // gridSize: 3,
      // sizeRange: [12, 50],
      // rotationRange: [-90, 90],
      // shape: "pentagon",
      // width: 600,
      // height: 400,
      // drawOutOfBound: true,
      textStyle: {
        color: function () {
          return "rgb(" + [Math.round(Math.random() * 160), Math.round(Math.random() * 160), Math.round(Math.random() * 160)].join(",") + ")";
        },
      },
      emphasis: {
        textStyle: {
          shadowBlur: 10,
          shadowColor: "#333",
        },
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
if (document.getElementById("word-cloud-nega-korean")) {
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart = echarts.init(document.getElementById("word-cloud-nega-korean"));
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart.setOption(reviewAnalysisDeepdive.wordCloudKoreanNegaOption);
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart.on("finished", () => {
    reviewAnalysisDeepdive.wordCloud1 = true;
    if (reviewAnalysisDeepdive.wordCloud1 && reviewAnalysisDeepdive.wordCloud2) {
      document.getElementById("data-loading").style.visibility = "hidden";
    }
  });
}

/*************************************************************************************************************************/
reviewAnalysisDeepdive.viewReviewBarProdSearch = function () {
  reviewAnalysisDeepdive.schProduct1.removeActiveItems();
  let fr_dt = "";
  let to_dt = "";
  let tpic_type = "";
  let cate_nm = "";
  let psng_type = "";
  let tpic_item = "";
  const datePicker = document.getElementById("topicBarDatepicker");
  fr_dt = datePicker.value.substring(0, 10);
  to_dt = datePicker.value.slice(-10);
  tpic_type = reviewAnalysisDeepdive.schTopic0.getValue().value;
  cate_nm = reviewAnalysisDeepdive.schCategory2.getValue().value;
  psng_type = reviewAnalysisDeepdive.psngType1;
  tpic_item = reviewAnalysisDeepdive.schTopicSub0.getValue().value;

  let dataList = ["viewReviewBarProd"];
  let params = {
    params: { FR_DT: `'${fr_dt}'`, TO_DT: `'${to_dt}'`, TPIC_TYPE: `'${tpic_type}'`, CATE_NM: `'${cate_nm}'`, PSNG_TYPE: `'${psng_type}'`, TPIC_ITEM: `'${tpic_item}'` },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.viewReviewBarProd = {};
    if (data["viewReviewBarProd"] != undefined) {
      reviewAnalysisDeepdive.viewReviewBarProd = data["viewReviewBarProd"];
      reviewAnalysisDeepdive.viewReviewBarProdUpdate();
    }
  });
};

reviewAnalysisDeepdive.subTopicUpdate = function (val, target) {
  let dataList = ["topicRadarTpicTypeSub"];
  let params = {
    params: { TPIC_TYPE: `'${val}'` },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisDeepdive.topicRadarTpicTypeSub = {};
    if (data["topicRadarTpicTypeSub"] != undefined) {
      reviewAnalysisDeepdive.topicRadarTpicTypeSub = data["topicRadarTpicTypeSub"];
      reviewAnalysisDeepdive.topicRadarTpicTypeSubUpdate(target);
    }
  });
};

reviewAnalysisDeepdive.onLoadEvent = function (initData) {
  flatpickr("#topicBarDatepicker, #topicSeriesDatepicker, #radarParaphraseDatepicker, #wordCloudDatepicker", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates) {
      if (selectedDates.length > 1) {
        if (this.element.id == "topicBarDatepicker") {
          reviewAnalysisDeepdive.viewReviewBarProdSearch();
        }
      }
    },
  });

  let topicRaderFlatpickr = flatpickr("#topicRadarDatepicker, #radarParaphraseDatepicker", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        topicRaderFlatpickr[0].setDate([fromDate, toDate]);
        topicRaderFlatpickr[1].setDate([fromDate, toDate]);

        if (this == topicRaderFlatpickr[1]) {
          let validationCheck = false;
          reviewAnalysisDeepdive.chartRaderTopicSch(validationCheck);
        }
      }
    },
  });

  const schAverage = document.getElementById("schAverage");
  if (!reviewAnalysisDeepdive.schAverage && schAverage) {
    reviewAnalysisDeepdive.schAverage = new Choices(schAverage, {
      searchEnabled: false,
      shouldSort: false,
    });
  }

  const prodOption = {
    searchEnabled: false,
    shouldSort: false,
    removeItemButton: true,
    classNames: {
      removeButton: "remove",
    },
    placeholder: true,
    placeholderValue: "제품을 선택하세요.  ",
  };
  const schProduct1 = document.getElementById("schProduct1");
  const schProduct2 = document.getElementById("schProduct2");
  const schProduct3 = document.getElementById("schProduct3");
  const schProduct4 = document.getElementById("schProduct4");
  if (!reviewAnalysisDeepdive.schProduct1 && schProduct1) {
    reviewAnalysisDeepdive.schProduct1 = new Choices(schProduct1, prodOption);
  }
  if (!reviewAnalysisDeepdive.schProduct2 && schProduct2) {
    reviewAnalysisDeepdive.schProduct2 = new Choices(schProduct2, {
      searchEnabled: false,
      shouldSort: false,
      placeholder: true,
      placeholderValue: "제품을 선택하세요.  ",
    });
  }
  if (!reviewAnalysisDeepdive.schProduct3 && schProduct3) {
    reviewAnalysisDeepdive.schProduct3 = new Choices(schProduct3, prodOption);
  }
  if (!reviewAnalysisDeepdive.schProduct4 && schProduct4) {
    reviewAnalysisDeepdive.schProduct4 = new Choices(schProduct4, {
      searchEnabled: false,
      shouldSort: false,
      placeholder: true,
      placeholderValue: "제품을 선택하세요.  ",
    });
  }

  const schCategory = document.getElementById("schCategory");
  if (!reviewAnalysisDeepdive.schCategory && schCategory) {
    reviewAnalysisDeepdive.schCategory = new Choices(schCategory, {
      searchEnabled: false,
      shouldSort: false,
      placeholder: true,
      placeholderValue: "카테고리를 선택하세요.  ",
    });
  }

  const schCategory2 = document.getElementById("schCategory2");
  if (!reviewAnalysisDeepdive.schCategory2 && schCategory2) {
    reviewAnalysisDeepdive.schCategory2 = new Choices(schCategory2, {
      searchEnabled: false,
      shouldSort: false,
      placeholder: true,
      placeholderValue: "카테고리를 선택하세요.  ",
    });
    schCategory2.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.viewReviewBarProdSearch();
    });
  }

  const schCategory3 = document.getElementById("choices-category-barchart");
  if (schCategory3) {
    if (!reviewAnalysisDeepdive.schCategory3) {
      reviewAnalysisDeepdive.schCategory3 = new Choices(schCategory3, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "카테고리를 선택하세요.  ",
      });
    }
    schCategory3.addEventListener("change", function () {
      let dataList = ["categoryTopic100pBarChart" /* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 SQL */];
      let params = {
        params: { CATE_NM: `'${this.value}'` },
        menu: "reviewanalysis/common",
        tab: "deepdive",
        dataList: dataList,
      };
      getData(params, function (data) {
        reviewAnalysisDeepdive.categoryTopic100pBarChart = {};
        if (data["categoryTopic100pBarChart"] != undefined) {
          reviewAnalysisDeepdive.categoryTopic100pBarChart = data["categoryTopic100pBarChart"];
          reviewAnalysisDeepdive.categoryTopic100pBarChartUpdate();
        }
      });
    });
  }

  const topicOption = {
    searchEnabled: false,
    shouldSort: false,
    placeholder: true,
    placeholderValue: "토픽을 선택하세요.  ",
  };

  const schTopic0 = document.getElementById("schTopic0");
  if (schTopic0) {
    if (!reviewAnalysisDeepdive.schTopic0) {
      reviewAnalysisDeepdive.schTopic0 = new Choices(schTopic0, topicOption);
    }
    schTopic0.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.schTopicSub0.removeActiveItems();
      let dataList = [];
      dataList.push({ value: "", label: "세부 토픽을 선택하세요." });
      reviewAnalysisDeepdive.schTopicSub0.setChoices(dataList, "value", "label", true);
      reviewAnalysisDeepdive.schTopicSub0.setChoiceByValue("");
      reviewAnalysisDeepdive.viewReviewBarProdSearch();
      if (e.target.value != "전체") {
        reviewAnalysisDeepdive.schTopicSub0.enable();
        reviewAnalysisDeepdive.subTopicUpdate(e.target.value, "schTopicSub0");
      } else {
        reviewAnalysisDeepdive.schTopicSub0.disable();
      }
    });
  }

  const schTopic1 = document.getElementById("schTopic1");
  if (schTopic1) {
    if (!reviewAnalysisDeepdive.schTopic1) {
      reviewAnalysisDeepdive.schTopic1 = new Choices(schTopic1, topicOption);
    }
    schTopic1.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.schTopicSub1.removeActiveItems();
      if (e.target.value != "전체") {
        reviewAnalysisDeepdive.schTopicSub1.enable();
        reviewAnalysisDeepdive.subTopicUpdate(e.target.value, "schTopicSub1");
      } else {
        reviewAnalysisDeepdive.schTopicSub1.disable();
      }
    });
  }

  const schTopic2 = document.getElementById("schTopic2");
  if (schTopic2) {
    if (!reviewAnalysisDeepdive.schTopic2) {
      reviewAnalysisDeepdive.schTopic2 = new Choices(schTopic2, topicOption);
    }
    schTopic2.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.schTopicSub2.removeActiveItems();
      if (e.target.value != "전체") {
        reviewAnalysisDeepdive.schTopicSub2.enable();
        reviewAnalysisDeepdive.subTopicUpdate(e.target.value, "schTopicSub2");
      } else {
        reviewAnalysisDeepdive.schTopicSub2.disable();
      }
    });
  }

  const schTopic3 = document.getElementById("schTopic3");
  if (schTopic3) {
    if (!reviewAnalysisDeepdive.schTopic3) {
      reviewAnalysisDeepdive.schTopic3 = new Choices(schTopic3, topicOption);
    }
    schTopic3.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.schTopicSub3.removeActiveItems();
      let dataList = [];
      dataList.push({ value: "", label: "세부 토픽을 선택하세요." });
      reviewAnalysisDeepdive.schTopicSub3.setChoices(dataList, "value", "label", true);
      reviewAnalysisDeepdive.schTopicSub3.setChoiceByValue("");
      if (e.target.value != "전체") {
        reviewAnalysisDeepdive.schTopicSub3.enable();
        reviewAnalysisDeepdive.subTopicUpdate(e.target.value, "schTopicSub3");
      } else {
        reviewAnalysisDeepdive.schTopicSub3.disable();
      }
    });
  }

  const schTopic4 = document.getElementById("schTopic4");
  if (schTopic4) {
    if (!reviewAnalysisDeepdive.schTopic4) {
      reviewAnalysisDeepdive.schTopic4 = new Choices(schTopic4, topicOption);
    }
    schTopic4.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.schTopicSub4.removeActiveItems();
      if (e.target.value != "전체") {
        reviewAnalysisDeepdive.schTopicSub4.enable();
        reviewAnalysisDeepdive.subTopicUpdate(e.target.value, "schTopicSub4");
      } else {
        reviewAnalysisDeepdive.schTopicSub4.disable();
      }
    });
  }

  const topicSubOption = {
    searchEnabled: false,
    shouldSort: false,
    removeItemButton: true,
    placeholder: true,
    placeholderValue: "세부 토픽을 선택하세요.  ",
  };

  const topicSubOption2 = {
    searchEnabled: false,
    shouldSort: false,
  };

  const schTopicSub0 = document.getElementById("schTopicSub0");
  const schTopicSub1 = document.getElementById("schTopicSub1");
  const schTopicSub2 = document.getElementById("schTopicSub2");
  const schTopicSub3 = document.getElementById("schTopicSub3");
  const schTopicSub4 = document.getElementById("schTopicSub4");

  if (!reviewAnalysisDeepdive.schTopicSub0 && schTopicSub0) {
    reviewAnalysisDeepdive.schTopicSub0 = new Choices(schTopicSub0, topicSubOption2);
    schTopicSub0.addEventListener("change", function (e) {
      reviewAnalysisDeepdive.viewReviewBarProdSearch();
    });
  }
  if (!reviewAnalysisDeepdive.schTopicSub1 && schTopicSub1) {
    reviewAnalysisDeepdive.schTopicSub1 = new Choices(schTopicSub1, topicSubOption);
  }
  if (!reviewAnalysisDeepdive.schTopicSub2 && schTopicSub2) {
    reviewAnalysisDeepdive.schTopicSub2 = new Choices(schTopicSub2, topicSubOption);
  }
  if (!reviewAnalysisDeepdive.schTopicSub3 && schTopicSub3) {
    reviewAnalysisDeepdive.schTopicSub3 = new Choices(schTopicSub3, topicSubOption2);
  }
  if (!reviewAnalysisDeepdive.schTopicSub4 && schTopicSub4) {
    reviewAnalysisDeepdive.schTopicSub4 = new Choices(schTopicSub4, topicSubOption);
  }

  let btnSm = document.querySelectorAll(".btn-sm-dd");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let psngType = chkTxt == "긍정" ? "PSTV" : "NGTV";
      let classList = this.classList.value.split(" ");
      if (classList[0].indexOf("1") > 0) {
        reviewAnalysisDeepdive.psngType1 = psngType;
        reviewAnalysisDeepdive.chartBarTopicSch();
      } else if (classList[0].indexOf("2") > 0) {
        reviewAnalysisDeepdive.psngType2 = psngType;
        reviewAnalysisDeepdive.chartMixTopicPosiReviewSch();
      } else if (classList[0].indexOf("3") > 0) {
        reviewAnalysisDeepdive.psngType3 = psngType;
        reviewAnalysisDeepdive.chartRaderTopicSch();
      } else if (classList[0].indexOf("4") > 0) {
        reviewAnalysisDeepdive.psngType4 = psngType;
        reviewAnalysisDeepdive.chartLineTopicSch();
      }
      reviewAnalysisDeepdive.updateButtonStyle(chkTxt, classList);
    });
  });

  let btnSmDdTp = document.querySelectorAll(".btn-sm-dd-tp");
  btnSmDdTp.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      reviewAnalysisDeepdive.updateButtonStyle2(chkTxt);
      let dataList = [];
      if (chkTxt == "대주제") {
        dataList = ["categoryTopic100pBarChart" /* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 (대주제) SQL */];
      } else if (chkTxt == "효능") {
        dataList = ["categoryTopic100pBarChartEfficacy" /* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 (효능) SQL */];
      }
      let params = {
        params: { CATE_NM: `'${schCategory3.value}'` },
        menu: "reviewanalysis/common",
        tab: "deepdive",
        dataList: dataList,
      };
      getData(params, function (data) {
        reviewAnalysisDeepdive.categoryTopic100pBarChart = {};
        if (chkTxt == "대주제") {
          if (data["categoryTopic100pBarChart"] != undefined) {
            reviewAnalysisDeepdive.categoryTopic100pBarChart = data["categoryTopic100pBarChart"];
            reviewAnalysisDeepdive.categoryTopic100pBarChartUpdate();
          }
        } else if (chkTxt == "효능") {
          if (data["categoryTopic100pBarChartEfficacy"] != undefined) {
            reviewAnalysisDeepdive.categoryTopic100pBarChart = data["categoryTopic100pBarChartEfficacy"];
            reviewAnalysisDeepdive.categoryTopic100pBarChartUpdate();
          }
        }
      });
    });
  });

  let dataList = [
    "viewReviewBarCategory" /* 1. 토픽별 바그래프 -  카테고리 선택 SQL */,
    "viewReviewBarProd" /* 1. 토픽별 바그래프 -  제품 선택 SQL */,
    "commonProd",
    // "viewReviewBarTpicType" /* 1. 토픽별 바그래프 - 토픽 대주제 선택 SQL */,
    // "viewReviewBarTpicTypeSub" /* 1. 토픽별 바그래프 - 토픽 세부주제 선택 SQL */,
    "topicRadarCategory" /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 카테고리 선택 SQL */,
    "topicRadarTpicType" /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 대주제 선택 SQL */,
    "categoryTopic100pBarChartCategory" /* 5. 카테고리별 / 토픽 100% 바그래프 - 카테고리 선택 SQL */,
  ];

  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, WITH_FAKE: "'N'", PSNG_TYPE: "'PSTV'", TPIC_TYPE: "'전체'", CATE_NM: "'전체'", TPIC_ITEM: "''" },
    menu: "reviewanalysis/common",
    tab: "deepdive",
    dataList: dataList,
  };

  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      reviewAnalysisDeepdive[key] = replaceNullWithZero(data[key]);
    });
    reviewAnalysisDeepdive.updateButtonStyle("긍정", "all");
    reviewAnalysisDeepdive.updateButtonStyle2("대주제");
    reviewAnalysisDeepdive.setDataBinding();
  });
  reviewAnalysisDeepdive.onloadStatus = true; // 화면 로딩 상태
};

reviewAnalysisDeepdive.setDataBinding = function () {
  /* 제품 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.commonProd).length > 0) {
    reviewAnalysisDeepdive.commonProdUpdate();
  }
  // /* 1. 토픽별 바그래프 - 토픽 대주제 선택 SQL */
  // if (Object.keys(reviewAnalysisDeepdive.viewReviewBarTpicType).length > 0) {
  //   // console.table(reviewAnalysisDeepdive.topicRadarTpicType);
  //   reviewAnalysisDeepdive.viewReviewBarTpicTypeUpdate();
  // }
  /* 1. 토픽별 바그래프 -  카테고리 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.viewReviewBarCategory).length > 0) {
    // console.table(reviewAnalysisDeepdive.viewReviewBarCategory);
    reviewAnalysisDeepdive.viewReviewBarCategoryUpdate();
  }
  /* 1. 토픽별 바그래프 -  제품 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.viewReviewBarProd).length > 0) {
    // console.table(reviewAnalysisDeepdive.viewReviewBarProd);
    reviewAnalysisDeepdive.viewReviewBarProdUpdate();
  }
  /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 카테고리 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.topicRadarCategory).length > 0) {
    // console.table(reviewAnalysisDeepdive.topicRadarCategory);
    reviewAnalysisDeepdive.topicRadarCategoryUpdate();
  }
  /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 대주제 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.topicRadarTpicType).length > 0) {
    // console.table(reviewAnalysisDeepdive.topicRadarTpicType);
    reviewAnalysisDeepdive.topicRadarTpicTypeUpdate();
  }
  /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */
  if (Object.keys(reviewAnalysisDeepdive.categoryTopic100pBarChartCategory).length > 0) {
    // console.table(reviewAnalysisDeepdive.topicRadarTpicTypeSub);
    reviewAnalysisDeepdive.categoryTopic100pBarChartCategoryUpdate();
  }

  // reviewAnalysisDeepdive.viewReviewBarProdSearch();
};

// 이벤트 핸들러 함수를 배열로 정의합니다.
reviewAnalysisDeepdive.resizeHandlers = [
  reviewAnalysisDeepdive.chartBarTopic,
  reviewAnalysisDeepdive.chartMixTopicPosiReview,
  reviewAnalysisDeepdive.chartBarTopic,
  reviewAnalysisDeepdive.chartBarCateTopic,
  reviewAnalysisDeepdive.chartRaderTopic,
  reviewAnalysisDeepdive.chartBarSubRader,
  reviewAnalysisDeepdive.chartLineTopic,
  reviewAnalysisDeepdive.wordCloudChart,
  reviewAnalysisDeepdive.wordCloudKoreanChart,
  reviewAnalysisDeepdive.wordCloudNegaChart,
  reviewAnalysisDeepdive.wordCloudKoreanNegaChart,
];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
reviewAnalysisDeepdive.resizeHandlers.forEach((handler) => {
  if (handler != undefined) {
    window.addEventListener("resize", eval(handler).resize);
  }
});
