let reviewAnalysisOverview = {};
reviewAnalysisOverview.psngType1 = "PSTV";
reviewAnalysisOverview.psngType2 = "PSTV";
reviewAnalysisOverview.psngType3 = "PSTV";
reviewAnalysisOverview.onloadStatus = false; // 화면 로딩 상태

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

reviewAnalysisOverview.updateButtonStyle = function (name, type) {
  let buttonClasses = {
    긍정: ["error", "btn-soft-primary", "btn-primary"],
    부정: ["nomal", "btn-soft-danger", "btn-danger"],
  };

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

reviewAnalysisOverview.onLoadEvent = function (initData) {
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

  if (document.getElementById("rvxChannelTopic")) {
    const rvxChannelTopic = document.getElementById("rvxChannelTopic");
    if (!reviewAnalysisOverview.rvxChannelTopic) {
      reviewAnalysisOverview.rvxChannelTopic = new Choices(rvxChannelTopic, {
        searchEnabled: false,
        shouldSort: false,
      });
    }
  }


  let abnormalReview = document.getElementById("abnormal-review");
  if (abnormalReview) {
    abnormalReview.addEventListener("change", function (el) {
      let withFake = "N";
      let datePicker = document.getElementById("salesTimeSeriesViewer");
      let params = {
        params: {
          FR_DT: `'${datePicker.value.substring(0, 10)}'`,
          TO_DT: `'${datePicker.value.slice(-10)}'`,
          CATE_NM: `'${reviewAnalysisOverview.reviewmapCateChoices.getValue().value}'`,
          WITH_FAKE: `'${withFake}'`,
          PSNG_TYPE: `'${reviewAnalysisOverview.psngType1}'`,
        },
        menu: "reviewanalysis/common",
        tab: "overview",
        dataList: ["productReviewTreeMap"],
      };
      getData(params, function (data) {
        reviewAnalysisOverview.productReviewTreeMap = {};
        /* 제품 별 리뷰 지도 */
        if (data["productReviewTreeMap"] != undefined) {
          reviewAnalysisOverview.productReviewTreeMap = data["productReviewTreeMap"];
          reviewAnalysisOverview.productReviewTreeMapUpdate();
        }
      });
    });
  }

  flatpickr("#salesTimeSeriesViewer", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        abnormalReview = document.getElementById("abnormal-review");
        let withFake = "N";
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);
        let params = {
          params: {
            FR_DT: `'${fromDate}'`,
            TO_DT: `'${toDate}'`,
            CATE_NM: `'${reviewAnalysisOverview.reviewmapCateChoices.getValue().value}'`,
            WITH_FAKE: `'${withFake}'`,
            PSNG_TYPE: `'${reviewAnalysisOverview.psngType1}'`,
            WITH_FAKE: `'${withFake}'`,
          },
          menu: "reviewanalysis/common",
          tab: "overview",
          dataList: ["productReviewTreeMap"],
        };
        getData(params, function (data) {
          reviewAnalysisOverview.productReviewTreeMap = {};
          /* 제품 별 리뷰 지도 */
          if (data["productReviewTreeMap"] != undefined) {
            reviewAnalysisOverview.productReviewTreeMap = data["productReviewTreeMap"];
            reviewAnalysisOverview.productReviewTreeMapUpdate();
          }
        });
      }
    },
  });

  flatpickr("#seriesDatepicker, #reviewDatepicker", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
  });

  let heatMapDatepicker = flatpickr("#heatMapDatepicker, #prodTopicRankDatepicker", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
    onChange: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        const fromDate = getDateFormatter(selectedDates[0]);
        const toDate = getDateFormatter(selectedDates[1]);

        heatMapDatepicker[0].setDate([fromDate, toDate]);
        heatMapDatepicker[1].setDate([fromDate, toDate]);
      }
    },
  });

  const choiceTopicSub1 = document.getElementById("topic_product_heatmap_overview");
  if (choiceTopicSub1) {
    if (!reviewAnalysisOverview.choiceTopicSub1) {
      reviewAnalysisOverview.choiceTopicSub1 = new Choices(choiceTopicSub1, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "토픽을 선택하세요.  ",
      });
    }

    choiceTopicSub1.addEventListener("change", function (e) {
      reviewAnalysisOverview.choiceTopicSub2.removeActiveItems();
      if (e.target.value != "전체") {
        reviewAnalysisOverview.choiceTopicSub2.enable();
        let dataList = ["topicProductHeatmapOverviewSub"];
        let params = {
          params: { TPIC_TYPE: `'${reviewAnalysisOverview.choiceTopicSub1.getValue().value}'` },
          menu: "reviewanalysis/common",
          tab: "overview",
          dataList: dataList,
        };
        getData(params, function (data) {
          reviewAnalysisOverview.topicProductHeatmapOverviewSub = {};
          if (data["topicProductHeatmapOverviewSub"] != undefined) {
            reviewAnalysisOverview.topicProductHeatmapOverviewSub = data["topicProductHeatmapOverviewSub"];
            reviewAnalysisOverview.topicProductHeatmapOverviewSubUpdate();
          }
        });
      } else {
        reviewAnalysisOverview.choiceTopicSub2.disable();
      }
    });
  }

  const choiceTopicSub2 = document.getElementById("topic_product_heatmap_overview_sub");
  if (choiceTopicSub2) {
    if (!reviewAnalysisOverview.choiceTopicSub2) {
      reviewAnalysisOverview.choiceTopicSub2 = new Choices(choiceTopicSub2, {
        searchEnabled: false,
        shouldSort: false,
        removeItemButton: true,
        classNames: {
          removeButton: "remove",
        },
        placeholder: true,
        placeholderValue: "세부 토픽을 선택하세요.  ",
      });
    }
  }

  const choiceTopicSub3 = document.getElementById("topic_product_heatmap_overview_prod");
  if (choiceTopicSub3) {
    if (!reviewAnalysisOverview.choiceTopicSub3) {
      reviewAnalysisOverview.choiceTopicSub3 = new Choices(choiceTopicSub3, {
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

  const choiceProdTopic = document.getElementById("choices-multiple-barchart");
  if (choiceProdTopic) {
    if (!reviewAnalysisOverview.choiceProdTopic) {
      reviewAnalysisOverview.choiceProdTopic = new Choices(choiceProdTopic, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
  }

  const choiceCategoryRank = document.getElementById("choices-rank");
  if (choiceCategoryRank) {
    if (!reviewAnalysisOverview.choiceCategoryRank) {
      reviewAnalysisOverview.choiceCategoryRank = new Choices(choiceCategoryRank, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "카테고리를 선택하세요.  ",
      });
    }

    choiceCategoryRank.addEventListener("change", function () {
      let dataList = ["productSentimentChangeRankingPreMonthData" /* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */];
      let params = {
        params: { CATE_NM: `'${this.value}'` },
        menu: "reviewanalysis/common",
        tab: "overview",
        dataList: dataList,
      };
      getData(params, function (data) {
        reviewAnalysisOverview.productSentimentChangeRankingPreMonthData = {};
        /* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */
        if (data["productSentimentChangeRankingPreMonthData"] != undefined) {
          reviewAnalysisOverview.productSentimentChangeRankingPreMonthData = data["productSentimentChangeRankingPreMonthData"];
          reviewAnalysisOverview.productSentimentChangeRankingPreMonthDataUpdate();
        }
      });
    });
  }
  const reviewmapCateChoices = document.getElementById("reviewmapCateChoice");
  if (reviewmapCateChoices) {
    if (!reviewAnalysisOverview.reviewmapCateChoices) {
      reviewAnalysisOverview.reviewmapCateChoices = new Choices(reviewmapCateChoices, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "카테고리를 선택하세요.  ",
      });
    }

    reviewmapCateChoices.addEventListener("change", function () {
      let dataList = ["productReviewTreeMap" /* 리뷰 Tree map */];
      let datePicker = document.getElementById("salesTimeSeriesViewer");
      params = {
        params: {
          FR_DT: `'${datePicker.value.substring(0, 10)}'`,
          TO_DT: `'${datePicker.value.slice(-10)}'`,
          WITH_FAKE: `'N'`,
          CATE_NM: `'${reviewAnalysisOverview.reviewmapCateChoices.getValue().value}'`,
          PSNG_TYPE: `'${reviewAnalysisOverview.psngType1}'`,
        },
        menu: "reviewanalysis",
        tab: "common/overview",
        dataList: dataList,
      };
      getData(params, function (data) {
        reviewAnalysisOverview.productReviewTreeMap = {};
        /* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */
        if (data["productReviewTreeMap"] != undefined) {
          reviewAnalysisOverview.productReviewTreeMap = data["productReviewTreeMap"];
          reviewAnalysisOverview.productReviewTreeMapUpdate();
        }
      });
    });
  }


  const choiceProdSeries = document.getElementById("choices-multiple-topic-chart");
  if (choiceProdSeries) {
    if (!reviewAnalysisOverview.choiceProdSeries) {
      reviewAnalysisOverview.choiceProdSeries = new Choices(choiceProdSeries, {
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

  const choiceProdReview = document.getElementById("choices-multiple-topic-pn-chart");
  if (choiceProdReview) {
    if (!reviewAnalysisOverview.choiceProdReview) {
      reviewAnalysisOverview.choiceProdReview = new Choices(choiceProdReview, {
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

  let btnSm = document.querySelectorAll(".btn-sm-ov");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      let psngType = chkTxt == "긍정" ? "PSTV" : "NGTV";
      let classList = this.classList.value.split(" ");
      if (classList[0].indexOf("1") > 0) {
        let withFake = this.checked ? "Y" : "N";
        reviewAnalysisOverview.psngType1 = psngType;
        let datePicker = document.getElementById("salesTimeSeriesViewer");
        let params = {
          params: {
            FR_DT: `'${datePicker.value.substring(0, 10)}'`,
            TO_DT: `'${datePicker.value.slice(-10)}'`,
            CATE_NM: `'${reviewAnalysisOverview.reviewmapCateChoices.getValue().value}'`,
            WITH_FAKE: `'${withFake}'`,
            PSNG_TYPE: `'${psngType}'`,
          },
          menu: "reviewanalysis/common",
          tab: "overview",
          dataList: ["productReviewTreeMap"],
        };
        getData(params, function (data) {
          reviewAnalysisOverview.productReviewTreeMap = {};
          /* 제품 별 리뷰 지도 */
          if (data["productReviewTreeMap"] != undefined) {
            reviewAnalysisOverview.productReviewTreeMap = data["productReviewTreeMap"];
            reviewAnalysisOverview.productReviewTreeMapUpdate();
          }
        });
      } else if (classList[0].indexOf("2") > 0) {
        reviewAnalysisOverview.psngType2 = psngType;
        reviewAnalysisOverview.topicProductHeatmapOverview();
      } else if (classList[0].indexOf("3") > 0) {
        reviewAnalysisOverview.psngType3 = psngType;
        reviewAnalysisOverview.productTopicRankingBarChartEvent();
      }
      reviewAnalysisOverview.updateButtonStyle(chkTxt, classList);
    });
  });

  let dataList = [
    "sentimentAnalysisReviewsStats" /* 1. 중요정보카드 - 수집 리뷰수, 긍정vs부정, 긍/부정 변환 1위 SQL */,
    "sentimentAnalysisReviewsStatsChart" /* 1. 중요정보카드 - Chart SQL */,
    "productReviewTreeMap" /* 2. 제품별 리뷰지도 - 트리 맵 그래프 SQL */,
    "channelReviewTopic"/* 2. 제품별 리뷰지도 - 리뷰 토픽 선택 그래프 SQL */,
    "topicProductHeatmapOverviewTopic" /* 3. 토픽별/제품별 히트맵 overview - 토픽 대주제 선택 SQL */,
    "topicProductHeatmapOverviewProd" /* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */,
    "productReviewTreeMapCategory" /* 제품별 리뷰지도 - 제품 대주제 전체 카테고리 자사제품 선택  */,
    "productSentimentChangeRankingPreMonth" /* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 전체, 카테고리, 자사제품 선택 SQL */,
  ];

  let params = {
    params: { FR_DT: `'${initData.fr_dt}'`, TO_DT: `'${initData.to_dt}'`, BASE_MNTH: `'${initData.base_mnth}'`, WITH_FAKE: "'N'", PSNG_TYPE: "'PSTV'", CATE_NM: "'전체'" },
    menu: "reviewanalysis/common",
    tab: "overview",
    dataList: dataList,
  };

  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      reviewAnalysisOverview[key] = data[key];
    });
    for (let i = 0; i < counterValue.length; i++) {
      badgePar = counterValue[i].parentNode.nextElementSibling;
      if (Number(counterValue[i].innerText) == 0 && badgePar != null && badgePar.firstElementChild != null) {
        badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    reviewAnalysisOverview.updateButtonStyle("긍정", "all");
    reviewAnalysisOverview.setDataBinding();
  });

  reviewAnalysisOverview.onloadStatus = true; // 화면 로딩 상태
};

reviewAnalysisOverview.setDataBinding = function () {
  /* 1. 중요정보카드 - 수집 리뷰수, 긍정vs부정, 긍/부정 변환 1위 SQL */
  if (Object.keys(reviewAnalysisOverview.sentimentAnalysisReviewsStats).length > 0) {
    reviewAnalysisOverview.sentimentAnalysisReviewsStatsUpdate();
  }
  /* 1. 중요정보카드 - Chart SQL */
  if (Object.keys(reviewAnalysisOverview.sentimentAnalysisReviewsStatsChart).length > 0) {
    reviewAnalysisOverview.sentimentAnalysisReviewsStatsChartUpdate();
  }
  if (Object.keys(reviewAnalysisOverview.channelReviewTopic).length > 0) {
    reviewAnalysisOverview.channelReviewTopicUpdate();
  }
  /* 2. 제품별 리뷰지도 - 트리 맵 그래프 SQL */
  if (Object.keys(reviewAnalysisOverview.productReviewTreeMapCategory).length > 0) {
    reviewAnalysisOverview.productReviewTreeMapCategoryUpdate();
  }
  /* 2. 제품별 리뷰지도 - 트리 맵 카테고리 선택 SQL */
  if (Object.keys(reviewAnalysisOverview.productReviewTreeMap).length > 0) {
    reviewAnalysisOverview.productReviewTreeMapUpdate();
  }
  /* 3. 토픽별/제품별 히트맵 overview - 토픽 대주제 선택 SQL */
  if (Object.keys(reviewAnalysisOverview.topicProductHeatmapOverviewTopic).length > 0) {
    reviewAnalysisOverview.topicProductHeatmapOverviewTopicUpdate();
  }
  /* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */
  if (Object.keys(reviewAnalysisOverview.topicProductHeatmapOverviewProd).length > 0) {
    reviewAnalysisOverview.topicProductHeatmapOverviewProdUpdate();
  }
  /* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 전체, 카테고리, 자사제품 선택 SQL */
  if (Object.keys(reviewAnalysisOverview.productSentimentChangeRankingPreMonth).length > 0) {
    reviewAnalysisOverview.productSentimentChangeRankingPreMonthUpdate();
  }

  /* number counting 처리 */
  counter();
};

/*************************************** 중요정보카드 **********************************************/
reviewAnalysisOverview.sentimentAnalysisReviewsStatsUpdate = function () {
  // 상단 중요정보 카드
  // revw_cnt  : 전체 수립 리뷰 수      , pstv_cnt : 긍정 리뷰 수,   pstv_rate : 긍정 리뷰 비율  , pstv_prod_nm : 긍정 변화 제품명   , ngtv_prod_nm : 부정 변화 제품명
  // revw_rate : 전체 수립 리뷰 증감률  , ngtv_cnt : 부정 리뷰 수,   ngtv_rate : 부정 리뷰 비율  , pstv_rate_chng : 긍정 변화 증감률 , ngtv_rate_chng : 부정 변화 증감률
  let rawData = reviewAnalysisOverview.sentimentAnalysisReviewsStats;
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
  reviewAnalysisOverview.positiveScoreChartOptions.series = [Number(rawData[0]["pstv_rate"]), Number(rawData[0]["ntrl_rate"]), Number(rawData[0]["ngtv_rate"])];
  reviewAnalysisOverview.positiveScoreChartOptions.labels = ["긍정", "중립", "부정"];
  if (reviewAnalysisOverview.positiveScoreChart) {
    reviewAnalysisOverview.positiveScoreChart.updateOptions(reviewAnalysisOverview.positiveScoreChartOptions);
  }
};

/* 수집된 리뷰의 긍정 부정 비중 게이지 그래프 (원형) */
reviewAnalysisOverview.positiveScoreChartOptions = {
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
if (document.querySelector("#positiveScoreChart")) {
  reviewAnalysisOverview.positiveScoreChart = new ApexCharts(document.querySelector("#positiveScoreChart"), reviewAnalysisOverview.positiveScoreChartOptions);
  reviewAnalysisOverview.positiveScoreChart.render();
}

reviewAnalysisOverview.sentimentAnalysisReviewsStatsChartUpdate = function () {
  if (reviewAnalysisOverview.totalReviewCount) {
    let rawData = reviewAnalysisOverview.sentimentAnalysisReviewsStatsChart;
    let reviewData = [];

    rawData.forEach((item) => {
      reviewData.push({
        x: item["x_dt"],
        y: item["v_val"],
      });
    });
    reviewAnalysisOverview.totalReviewCount.updateSeries([
      {
        name: "리뷰 수",
        data: reviewData,
      },
    ]);
  }
};

/* 전체 수집 리뷰 수 */
reviewAnalysisOverview.totalReviewCountOptions = {
  series: [
    {
      name: "매출",
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
  colors: getChartColorsArray("totalReviewCount"),
};
if (document.querySelector("#totalReviewCount")) {
  reviewAnalysisOverview.totalReviewCount = new ApexCharts(document.querySelector("#totalReviewCount"), reviewAnalysisOverview.totalReviewCountOptions);
  reviewAnalysisOverview.totalReviewCount.render();
}

/*************************************************************************************/


/*************************************** 제품 별 리뷰 지도 토픽 선택 피커 **********************************************/

reviewAnalysisOverview.channelReviewTopicUpdate = function () {
  let rawData = reviewAnalysisOverview.channelReviewTopic;
  let topicList = [];
  rawData.forEach((topic) => {
    topicList.push({ value: topic.tpic_item, label: topic.tpic_item });
  });
  if (reviewAnalysisOverview.rvxChannelTopic) {
    reviewAnalysisOverview.rvxChannelTopic.setChoices(topicList, "value", "label", true);
    reviewAnalysisOverview.rvxChannelTopic.setChoiceByValue("전체");
  }
};

/*************************************** 제품 별 리뷰 지도 토픽 선택 검색버튼 **********************************************/
reviewAnalysisOverview.topicReviewTreeMapSearch = function () {
  // treemap datepicker 가져오기 
  let datePicker = document.getElementById("salesTimeSeriesViewer");
  params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      WITH_FAKE: `'N'`,
      CATE_NM: `'${reviewAnalysisOverview.reviewmapCateChoices.getValue().value}'`,
      PSNG_TYPE: `'${reviewAnalysisOverview.psngType1}'`,
    },
    menu: "reviewanalysis",
    tab: "common/overview",
    dataList: ["productReviewTreeMap"],
  };
  getData(params, function (data) {
    reviewAnalysisOverview.productReviewTreeMap = data["productReviewTreeMap"];
    reviewAnalysisOverview.productReviewTreeMapUpdate();
  });
};

/***************************************제품별 리뷰 지도 카테고리 선택 ********************************************************* */

reviewAnalysisOverview.productReviewTreeMapCategoryUpdate = function () {
  if (reviewAnalysisOverview.reviewmapCateChoices) {
    let rawData = reviewAnalysisOverview.productReviewTreeMapCategory;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.cate_nm, label: data.cate_nm });
    });
    reviewAnalysisOverview.reviewmapCateChoices.setChoices(dataList, "value", "label", true);
  }
};


/*************************************** 제품 별 리뷰 지도 **********************************************/
reviewAnalysisOverview.productReviewTreeMapUpdate = function () {
  if (reviewAnalysisOverview.chartTreeProdReview) {
    let rawData = reviewAnalysisOverview.productReviewTreeMap;
    reviewAnalysisOverview.chartTreeProdReview.setOption(reviewAnalysisOverview.chartTreeProdReviewOption, true);
    if (rawData.length > 0) {
      // 결과를 저장할 빈 객체 생성
      let brandReviewCounts = {};

      // rawData 배열을 순회하면서 브랜드별 리뷰 개수의 합을 계산
      rawData.forEach(function (data) {
        let brand = data.brnd_nm;
        let reviewCount = parseFloat(data.revw_cnt);
        let pstvRate = parseFloat(data.pstv_rate);
        if (brand in brandReviewCounts) {
          brandReviewCounts[brand]["revw_cnt"] += reviewCount;
          brandReviewCounts[brand]["prod_cnt"] += 1;
          brandReviewCounts[brand]["pstv_rate"] += pstvRate;
        } else {
          brandReviewCounts[brand] = { revw_cnt: 0, prod_cnt: 0, pstv_rate: 0 };
          brandReviewCounts[brand]["revw_cnt"] = reviewCount;
          brandReviewCounts[brand]["prod_cnt"] = 1;
          brandReviewCounts[brand]["pstv_rate"] = pstvRate;
        }
      });

      let dataList = [];
      let rootVal = 0;
      let pstvRate = 0;
      let filteredData = [];
      let childrenData = [];
      for (var brand in brandReviewCounts) {
        pstvRate = parseFloat(brandReviewCounts[brand]["pstv_rate"]) / parseFloat(brandReviewCounts[brand]["prod_cnt"]);
        rootVal += brandReviewCounts[brand]["revw_cnt"];
        filteredData = rawData.filter((item) => item.brnd_nm === brand);
        childrenData = [];
        filteredData.forEach(function (data) {
          childrenData.push({
            name: data.prod_nm,
            value: [parseFloat(data.revw_cnt), parseFloat(data.pstv_rate)],
            itemStyle: { borderWidth: 2 },
          });
        });

        if (childrenData.length > 0) {
          dataList.push({ name: brand, value: [brandReviewCounts[brand]["revw_cnt"], pstvRate], itemStyle: { borderWidth: 2 }, children: childrenData });
        } else {
          dataList.push({ name: brand, value: [brandReviewCounts[brand]["revw_cnt"], pstvRate] });
        }
      }
      reviewAnalysisOverview.chartTreeProdReview.setOption({
        series: [
          {
            type: "treemap",
            data: dataList,
            leafDepth: 2,
          },
        ],
        visualDimension: 2,
        visualMap: {
          type: "continuous",
          inRange: {
            color: reviewAnalysisOverview.psngType1 == "PSTV" ? ["#ee6666", "#8d4ad9", "#5470c6"] : ["#5470c6", "#8d4ad9", "#ee6666"],
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

/* 제품별 리뷰 지도 (트리) */
reviewAnalysisOverview.chartTreeProdReviewOption = {
  toolbox: {
    left: "right",
    top: "center",
    orient: "vertical",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  series: [
    {
      type: "treemap",
      data: [],
    },
  ],
};
if (document.getElementById("chart-tree-prod-review")) {
  reviewAnalysisOverview.chartTreeProdReview = echarts.init(document.getElementById("chart-tree-prod-review"));
  reviewAnalysisOverview.chartTreeProdReview.setOption(reviewAnalysisOverview.chartTreeProdReviewOption);
}

/*************************************************************************************/

/******************************************** 토픽 별 / 제품 별 히트맵 *********************************************/
reviewAnalysisOverview.topicProductHeatmapOverviewTopicUpdate = function () {
  if (reviewAnalysisOverview.choiceTopicSub1) {
    let rawData = reviewAnalysisOverview.topicProductHeatmapOverviewTopic;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.tpic_type, label: data.tpic_type });
    });
    reviewAnalysisOverview.choiceTopicSub1.setChoices(dataList, "value", "label", true);
    reviewAnalysisOverview.choiceTopicSub1.setChoiceByValue("전체");
  }
};

reviewAnalysisOverview.topicProductHeatmapOverviewSubUpdate = function () {
  if (reviewAnalysisOverview.choiceTopicSub2) {
    let rawData = reviewAnalysisOverview.topicProductHeatmapOverviewSub;
    const tpic = [...new Set(rawData.map((item) => item.tpic_type))];
    let dataList = [];
    let choicesList = [];
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
    reviewAnalysisOverview.choiceTopicSub2.setChoices(dataList, "value", "label", true);
  }
};

reviewAnalysisOverview.topicProductHeatmapOverviewProdUpdate = function () {
  let rawData = reviewAnalysisOverview.topicProductHeatmapOverviewProd;
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
  if (reviewAnalysisOverview.choiceTopicSub3) reviewAnalysisOverview.choiceTopicSub3.setChoices(dataList, "value", "label", true);
  if (reviewAnalysisOverview.choiceProdTopic) reviewAnalysisOverview.choiceProdTopic.setChoices(dataList, "value", "label", true);
  if (reviewAnalysisOverview.choiceProdReview) reviewAnalysisOverview.choiceProdReview.setChoices(dataList, "value", "label", true);
  if (reviewAnalysisOverview.choiceProdSeries) reviewAnalysisOverview.choiceProdSeries.setChoices(dataList, "value", "label", true);
};

reviewAnalysisOverview.topicProductHeatmapOverview = function () {
  const tpicType = reviewAnalysisOverview.choiceTopicSub1.getValue();
  const tpicItem = reviewAnalysisOverview.choiceTopicSub2.getValue();
  const prodId = reviewAnalysisOverview.choiceTopicSub3.getValue();
  const psngType = reviewAnalysisOverview.psngType2;

  let tpicValue = tpicType.value;
  let itemValue = "";
  let prodValue = "";

  if (tpicType.value === "토픽선택" && tpicItem.length === 0) {
    dapAlert("세부 토픽을 선택해 주세요.");
    return false;
  }

  if (prodId.length == 0) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }

  itemValue = tpicItem.map((item) => item.value).join(",");
  prodValue = prodId.map((item) => item.value).join(",");

  const dataList = ["topicProductHeatmapOverviewTopicHeatMapTopic", "topicProductHeatmapOverviewTopicHeatMapProd", "topicProductHeatmapOverviewTopicHeatMap"];

  const datePicker = document.getElementById("heatMapDatepicker");
  const params = {
    params: {
      FR_DT: `'${datePicker.value.substring(0, 10)}'`,
      TO_DT: `'${datePicker.value.slice(-10)}'`,
      TPIC_TYPE: `'${tpicValue}'`,
      TPIC_ITEM: `'${itemValue}'`,
      PROD_ID: `'${prodValue}'`,
      PSNG_TYPE: `'${psngType}'`,
    },
    menu: "reviewanalysis/common",
    tab: "overview",
    dataList,
  };

  getData(params, function (data) {
    // update data if it exists
    reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapTopic = data?.topicProductHeatmapOverviewTopicHeatMapTopic || {};
    reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapProd = data?.topicProductHeatmapOverviewTopicHeatMapProd || {};
    reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMap = data?.topicProductHeatmapOverviewTopicHeatMap || {};

    // update chart
    reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapUpdate(psngType);
  });
};

reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapUpdate = function (psngType) {
  reviewAnalysisOverview.heatMapTopicProd.setOption(reviewAnalysisOverview.heatMapTopicProdOption, true);
  let rawDataTopic = reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapTopic;
  let rawDataProd = reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMapProd;
  let rawData = reviewAnalysisOverview.topicProductHeatmapOverviewTopicHeatMap;
  reviewAnalysisOverview.heatMapTopicProd.setOption(reviewAnalysisOverview.heatMapTopicProdOption, true);
  let color = [];
  psngType == "NGTV" ? (color = ["#5470c6", "#8d4ad9", "#ee6666"]) : (color = ["#ee6666", "#8d4ad9", "#5470c6"]);
  if (rawDataTopic.length > 0 && rawDataProd.length > 0 && rawData.length > 0) {
    let maxVal = 0;
    let heatmapData = [];
    heatmapData = rawData.map(({ tpic_item, prod_nm, pstv_rate }) => [tpic_item, prod_nm, Number(pstv_rate)]);

    const sortedTopic = rawDataTopic;
    const topic = sortedTopic.map((item) => item.tpic_item);
    const prod = rawDataProd.map((item) => item.prod_nm);

    maxVal = rawData.reduce(function (prev, current) {
      return Number(prev.pstv_rate) > Number(current.pstv_rate) ? prev : current;
    }).pstv_rate;

    let data = heatmapData.map(function (item) {
      return [item[1], item[0], item[2] || "-"];
    });
    let dataSum = heatmapData.length;
    reviewAnalysisOverview.heatMapTopicProd.setOption({
      visualMap: {
        min: 0,
        max: 100,
        inRange: {
          color: color,
        },
      },
      xAxis: {
        data: prod,
      },
      yAxis: {
        data: topic,
      },
      series: [
        {
          data: data,
        },
      ],
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
};

/* 토픽별/제품별 히트맵 Overview */
reviewAnalysisOverview.heatMapTopicProdOption = {
  tooltip: {
    position: "top",
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
    top: "0%",
    right: "3%",
    left: "9%",
    bottom: "6.5%",
  },
  xAxis: {
    type: "category",
    data: [],
    axisLabel: {
      // rotate: 45,
      // formatter: function (value, index) {
      //   return value.slice(0, 10) + "...";
      // },
    },
  },
  yAxis: {
    type: "category",
    data: [],
    splitArea: {
      show: true,
    },
  },
  visualMap: {
    min: 0,
    max: 10,
    show: false,
    inRange: {
      color: ["#ee6666", "#8d4ad9", "#5470c6"],
    },
  },
  series: [
    {
      type: "heatmap",
      data: [],
      label: {
        show: true,
      },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowColor: "rgba(0, 0, 0, 0.5)",
        },
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
if (document.getElementById("heat-map-topic-prod")) {
  reviewAnalysisOverview.heatMapTopicProd = echarts.init(document.getElementById("heat-map-topic-prod"));
  reviewAnalysisOverview.heatMapTopicProd.setOption(reviewAnalysisOverview.heatMapTopicProdOption);
}

/**************************************************************************************************************/
/************************************************* 제품 별 토픽 순위 *********************************/
reviewAnalysisOverview.productTopicRankingBarChartEvent = function () {
  let prodId = reviewAnalysisOverview.choiceProdTopic.getValue();
  let prodValue = "";
  let prodName = "";
  let psngType = reviewAnalysisOverview.psngType3;

  if (prodId.label == "제품을 선택하세요.") {
    // 제품 선택 옵션 선택 시 뜨는 Alert
    dapAlert("제품을 선택해 주세요.");
    return false;
  } else {
    prodValue = prodId.value;
    prodName = prodId.label;
  }

  let dataList = ["productTopicRankingBarChart" /* 4. 제품별 토픽순위 Bar 그래프 - 바 그래프 SQL */];

  let datePicker = document.getElementById("heatMapDatepicker");
  let params = {
    params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'${prodValue}'`, PSNG_TYPE: `'${psngType}'` },
    menu: "reviewanalysis/common",
    tab: "overview",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisOverview.productTopicRankingBarChart = {};
    /* 4. 제품별 토픽순위 Bar 그래프 - 바 그래프 SQL */
    if (data["productTopicRankingBarChart"] != undefined) {
      reviewAnalysisOverview.productTopicRankingBarChart = data["productTopicRankingBarChart"];
      reviewAnalysisOverview.productTopicRankingBarChartUpdate(prodName, psngType);
    }
  });
};

reviewAnalysisOverview.productTopicRankingBarChartUpdate = function (prodName, psngType) {
  let rawData = reviewAnalysisOverview.productTopicRankingBarChart;
  let color = "";
  psngType == "NGTV" ? (color = "#ee6666") : (color = "#5470c6");

  reviewAnalysisOverview.chartBarTopicRank.setOption({
    xAxis: [
      {
        type: "category",
        data: rawData.map((item) => item.x_item), // x값으로 이루어진 배열,
        axisTick: {
          alignWithLabel: true,
        },
        axisLabel: {
          rotate: 45,
        },
      },
    ],
    yAxis: [
      {
        type: "value",
      },
    ],
    series: [
      {
        name: prodName,
        type: "bar",
        barWidth: "40%",
        data: rawData.map((item) => item.y_val),
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
};

/* 제품별 토픽순위 Bar 그래프 */
reviewAnalysisOverview.chartBarTopicRankOption = {
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
        type: ["line", "bar"],
      },
    },
  },
  legend: {
    data: [],
    formatter: function (value, index) {
      return value.slice(0, 6) + "...";
    },
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
if (document.getElementById("chart-bar-topic-rank")) {
  reviewAnalysisOverview.chartBarTopicRank = echarts.init(document.getElementById("chart-bar-topic-rank"));
  reviewAnalysisOverview.chartBarTopicRank.setOption(reviewAnalysisOverview.chartBarTopicRankOption);
}

/***************************************************************************************************************************/
/****************************************************** 전월 대비 제품 긍정, 부정 비율 변화 순위 **************************************/
reviewAnalysisOverview.productSentimentChangeRankingPreMonthUpdate = function () {
  if (reviewAnalysisOverview.choiceCategoryRank) {
    let rawData = reviewAnalysisOverview.productSentimentChangeRankingPreMonth;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.cate_nm, label: data.cate_nm });
    });
    reviewAnalysisOverview.choiceCategoryRank.setChoices(dataList, "value", "label", true);
  }
};

reviewAnalysisOverview.productSentimentChangeRankingPreMonthDataUpdate = function () {
  let rawData = reviewAnalysisOverview.productSentimentChangeRankingPreMonthData;
  let keysToExtract = ["revw_rank", `pstv_prod_nm`, `ngtv_prod_nm`];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  reviewAnalysisOverview.posiNegaMom.updateConfig({ data: filterData }).forceRender();
};

/* 전월대비 제품 긍정, 부정 비율변화 순위 */
reviewAnalysisOverview.posiNegaMom = undefined;
if (document.getElementById("posi-nega-mom")) {
  reviewAnalysisOverview.posiNegaMom = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "75px",
      },
      {
        name: "긍정 변화 TOP 5",
        width: "300px",
      },
      {
        name: "부정 변화 TOP 5",
        width: "300px",
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
  }).render(document.getElementById("posi-nega-mom"));
}

/***************************************************************************************************************************/
/****************************************************** 제품 별 긍, 부정 비율 시계열 그래프 **************************************/

reviewAnalysisOverview.productSentimentRatioTimeSeriesSch = function () {
  let dataList = ["productSentimentRatioTimeSeriesChart" /* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */];

  let prodId = reviewAnalysisOverview.choiceProdSeries.getValue();
  const valuesArray = prodId.map((item) => item.value);
  let prodValue = valuesArray.join(",");

  if (prodId.length == 0) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }

  let datePicker = document.getElementById("seriesDatepicker");
  let params = {
    // params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'617136486827,621909301972,43249505908,12669264079'` },
    // params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'617136486827'` },
    params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'${prodValue}'` },
    menu: "reviewanalysis/common",
    tab: "overview",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisOverview.productSentimentRatioTimeSeriesChart = {};
    /* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */
    if (data["productSentimentRatioTimeSeriesChart"] != undefined) {
      reviewAnalysisOverview.productSentimentRatioTimeSeriesChart = data["productSentimentRatioTimeSeriesChart"];
      reviewAnalysisOverview.productSentimentRatioTimeSeriesChartUpdate();
    }
  });
};

reviewAnalysisOverview.productSentimentRatioTimeSeriesChartUpdate = function () {
  const rawData = reviewAnalysisOverview.productSentimentRatioTimeSeriesChart;
  reviewAnalysisOverview.chartMixPosiNega.setOption(reviewAnalysisOverview.chartMixPosiNegaOption, true);
  if (rawData.length > 0) {
    const choicesSearchType = document.getElementById("choices-search-type").value;
    const prodId = [...new Set(rawData.map((item) => item.prod_id))];
    let category = [...new Set(rawData.map((item) => item.x_dt))];

    category = category.sort(function (a, b) {
      if (a === 0) return -1; // 0을 가장 첫번째로 배치
      return new Date(a) - new Date(b);
    });

    const uniqueLegends = prodId.reduce((result, id) => {
      const { prod_id, prod_nm } = rawData.find((item) => item.prod_id === id);
      result[prod_id] = { id: prod_id, name: prod_nm };
      return result;
    }, {});

    let series = [];
    let filteredData = [];

    const keysToExtract1 = ["x_dt", "pstv_rate"];
    const keysToExtract2 = ["x_dt", "ngtv_rate"];
    const keysToExtract3 = ["x_dt", "revw_cnt"];
    const keysToExtractCum1 = ["x_dt", "pstv_rate_cum"];
    const keysToExtractCum2 = ["x_dt", "ngtv_rate_cum"];
    const keysToExtractCum3 = ["x_dt", "revw_cnt_cum"];

    prodId.forEach((id) => {
      filteredData = rawData.filter((item) => item.prod_id === id);

      filteredData = filteredData.sort(function (a, b) {
        if (a === 0) return -1; // 0을 가장 첫번째로 배치
        return new Date(a.x_dt) - new Date(b.x_dt);
      });

      let keysToExtractArr1 = filteredData.map((item) => (choicesSearchType === "1" ? keysToExtractCum1.map((key) => item[key]) : keysToExtract1.map((key) => item[key])));
      let keysToExtractArr2 = filteredData.map((item) => (choicesSearchType === "1" ? keysToExtractCum2.map((key) => item[key]) : keysToExtract2.map((key) => item[key])));
      let keysToExtractArr3 = filteredData.map((item) => (choicesSearchType === "1" ? keysToExtractCum3.map((key) => item[key]) : keysToExtract3.map((key) => item[key])));

      series.push({
        name: `${uniqueLegends[id]["name"]}-긍정비율`,
        type: "line",
        yAxisIndex: 0,
        data: keysToExtractArr1,
      });

      series.push({
        name: `${uniqueLegends[id]["name"]}-부정비율`,
        type: "line",
        yAxisIndex: 0,
        data: keysToExtractArr2,
      });

      series.push({
        name: `${uniqueLegends[id]["name"]}-일별 리뷰 수`,
        type: "bar",
        yAxisIndex: 1,
        data: keysToExtractArr3,
      });
    });

    reviewAnalysisOverview.chartMixPosiNega.setOption({
      yAxis: [
        {
          type: "value",
        },
        {
          type: "value",
        },
      ],
      xAxis: [
        {
          type: "category",
          data: category,
        },
      ],
      series,
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

/* 제품별 긍부정 비율 시계열 */
reviewAnalysisOverview.chartMixPosiNegaOption = {
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
    textStyle: {
      color: "#858d98",
    },
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
if (document.getElementById("chart-mix-posi-nega")) {
  reviewAnalysisOverview.chartMixPosiNega = echarts.init(document.getElementById("chart-mix-posi-nega"));
  reviewAnalysisOverview.chartMixPosiNega.setOption(reviewAnalysisOverview.chartMixPosiNegaOption);
}

/***************************************************************************************************************************/
/****************************************************** 제품 별 리뷰 속성 그래프 **************************************/

reviewAnalysisOverview.productReviewAttributeChartSch = function () {
  let dataList = ["productReviewAttributeChart" /* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 SQL */];

  let prodId = reviewAnalysisOverview.choiceProdReview.getValue();
  const valuesArray = prodId.map((item) => item.value);
  let prodValue = valuesArray.join(",");

  if (prodId.length == 0) {
    dapAlert("제품을 선택해 주세요.");
    return false;
  }

  let datePicker = document.getElementById("reviewDatepicker");
  let params = {
    // params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'617136486827,621909301972,43249505908,12669264079'` },
    params: { FR_DT: `'${datePicker.value.substring(0, 10)}'`, TO_DT: `'${datePicker.value.slice(-10)}'`, PROD_ID: `'${prodValue}'` },
    menu: "reviewanalysis/common",
    tab: "overview",
    dataList: dataList,
  };
  getData(params, function (data) {
    reviewAnalysisOverview.productReviewAttributeChart = {};
    /* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */
    if (data["productReviewAttributeChart"] != undefined) {
      reviewAnalysisOverview.productReviewAttributeChart = data["productReviewAttributeChart"];
      reviewAnalysisOverview.productReviewAttributeChartUpdate();
    }
  });
};

reviewAnalysisOverview.productReviewAttributeChartUpdate = function () {
  const rawData = reviewAnalysisOverview.productReviewAttributeChart;
  const choicesSearchType = document.getElementById("choices-prod-search-type").value;

  reviewAnalysisOverview.chartBarProdReview.setOption({
    xAxis: {
      type: "category",
      data: rawData.map((item) => item.prod_nm),
    },
    yAxis: [
      {
        type: "value",
      },
    ],
    series: [
      {
        name: "강긍정",
        type: "bar",
        itemStyle: {
          color: "#5470c6",
        },
        data: rawData.map(({ pstv_5_cnt, pstv_5_rate }) => (choicesSearchType === "1" ? pstv_5_cnt : pstv_5_rate)),
      },
      {
        name: "약긍정",
        type: "bar",
        itemStyle: {
          color: "#73c0de",
        },
        data: rawData.map(({ pstv_4_cnt, pstv_4_rate }) => (choicesSearchType === "1" ? pstv_4_cnt : pstv_4_rate)),
      },
      {
        name: "중립",
        type: "bar",
        itemStyle: {
          color: "#91cc75",
        },
        data: rawData.map(({ ntrl_3_cnt, ntrl_3_rate }) => (choicesSearchType === "1" ? ntrl_3_cnt : ntrl_3_rate)),
      },
      {
        name: "약부정",
        type: "bar",
        itemStyle: {
          color: "#fac858",
        },
        data: rawData.map(({ ngtv_2_cnt, ngtv_2_rate }) => (choicesSearchType === "1" ? ngtv_2_cnt : ngtv_2_rate)),
      },
      {
        name: "강부정",
        type: "bar",
        itemStyle: {
          color: "#ee6666",
        },
        data: rawData.map(({ ngtv_1_cnt, ngtv_1_rate }) => (choicesSearchType === "1" ? ngtv_1_cnt : ngtv_1_rate)),
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

/* 제품별 리뷰 속성 그래프 */
reviewAnalysisOverview.chartBarProdReviewOption = {
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
    data: [],
    axisLabel: {
      formatter: function (value, index) {
        return value.slice(0, 6) + "...";
      },
    },
  },
  yAxis: [
    {
      type: "value",
    },
  ],
  series: [
    {
      name: "강긍정",
      type: "bar",
      itemStyle: {
        color: "#5470c6",
      },
      data: [],
    },
    {
      name: "약긍정",
      type: "bar",
      itemStyle: {
        color: "#73c0de",
      },
      data: [],
    },
    {
      name: "중립",
      type: "bar",
      itemStyle: {
        color: "#91cc75",
      },
      data: [],
    },
    {
      name: "약부정",
      type: "bar",
      itemStyle: {
        color: "#fac858",
      },
      data: [],
    },
    {
      name: "강부정",
      type: "bar",
      itemStyle: {
        color: "#ee6666",
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
if (document.getElementById("chart-bar-prod-review")) {
  reviewAnalysisOverview.chartBarProdReview = echarts.init(document.getElementById("chart-bar-prod-review"));
  reviewAnalysisOverview.chartBarProdReview.setOption(reviewAnalysisOverview.chartBarProdReviewOption);
}

// 이벤트 핸들러 함수를 배열로 정의합니다.
reviewAnalysisOverview.resizeHandlers = [
  reviewAnalysisOverview.positiveScoreChart,
  reviewAnalysisOverview.totalReviewCount,
  reviewAnalysisOverview.chartTreeProdReview,
  reviewAnalysisOverview.heatMapTopicProd,
  reviewAnalysisOverview.chartBarTopicRank,
  reviewAnalysisOverview.chartMixPosiNega,
  reviewAnalysisOverview.chartBarProdReview,
  reviewAnalysisOverview.chartBarCateTopic,
];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
reviewAnalysisOverview.resizeHandlers.forEach((handler) => {
  if (handler != undefined) {
    window.addEventListener("resize", eval(handler).resize);
  }
});
