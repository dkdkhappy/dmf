let compete = {};
compete.onloadStatus = false; // 화면 로딩 상태

compete.setDataBinding = function () {
  /* 1. 도우인 경쟁사 비중 - 카테고리 선택 SQL */
  if (Object.keys(compete.assistantCompetitorRatioCategory).length > 0) {
    compete.assistantCompetitorRatioCategoryUpdate();
    compete.dcSearchData("샵");
  }
};

compete.assistantCompetitorRatioCategoryUpdate = function () {
  let rawData = compete.assistantCompetitorRatioCategory;
  let categoryList = [];
  rawData.forEach((category) => {
    categoryList.push({ value: category.cate_no, label: category.cate_nm });
  });
  compete.choicesMultipleCategory.setChoices(categoryList, "value", "label", true);
  if (categoryList.length > 0) {
    compete.choicesMultipleCategory.setChoiceByValue(categoryList[0]["value"]);
  }
};

/********************************************** 도우인 경쟁사 비중 *********************************************************/
compete.assistantCompetitorRatioPieChartUpdate = function () {
  let rawData = compete.assistantCompetitorRatioPieChart;
  if (compete.chartPieCompeteInfo) {
    compete.chartPieCompeteInfo.setOption(compete.chartPieCompeteInfoOption, true);
    if (rawData.length > 0) {
      compete.chartPieCompeteInfo.setOption({
        series: [
          {
            type: "pie",
            radius: "50%",
            data: rawData.map((data) => {
              return {
                name: data.col_nm,
                value: data.lost_rate,
                cnt: data.lost_cnt,
              };
            }),
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
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

/* 도우인 경쟁사 비중 */
compete.chartPieCompeteInfoOption = {
  tooltip: {
    trigger: "item",
  },
  legend: {
    orient: "horizontal",
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
if (document.getElementById("chart-pie-compete-info")) {
  compete.chartPieCompeteInfo = echarts.init(document.getElementById("chart-pie-compete-info"));
  compete.chartPieCompeteInfo.setOption(compete.chartPieCompeteInfoOption);
}
/******************************************************************************************************************************/
/********************************************** 도우인 경쟁사 시계열 그래프 *********************************************************/
compete.assistantCompetitorTimeSeriesChartUpdate = function () {
  let rawData = compete.assistantCompetitorTimeSeriesChart;
  if (compete.chartStackCompeteProduct) {
    compete.chartStackCompeteProduct.setOption(compete.chartStackCompeteProductOption, true);
    if (rawData.length > 0) {
      const lgnd = [...new Set(rawData.map((item) => item.l_lgnd_id))];
      const lgnd_nm = [...new Set(rawData.map((item) => item.l_lgnd_nm))];
      let x_dt = [...new Set(rawData.map((item) => item.x_dt))];
      x_dt = x_dt.sort(function (a, b) {
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
          name: rawData.filter((item) => item.l_lgnd_id == lgnd[i])[0]["l_lgnd_nm"],
          type: "line",
          smooth: true,
          connectNulls: true,
          data: seriesData,
        });
      }

      compete.chartStackCompeteProduct.setOption({
        legend: {
          data: lgnd_nm,
        },
        xAxis: {
          type: "category",
          boundaryGap: false,
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
/* 도우인 경쟁사 시계열 그래프 */
compete.chartStackCompeteProductOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {},
  grid: {
    left: "3%",
    right: "4%",
    bottom: "3%",
    containLabel: true,
  },
  toolbox: {
    feature: {
      saveAsImage: {},
    },
  },
  xAxis: {
    type: "category",
    boundaryGap: false,
    data: [],
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
if (document.getElementById("chart-stack-compete-product")) {
  compete.chartStackCompeteProduct = echarts.init(document.getElementById("chart-stack-compete-product"));
  compete.chartStackCompeteProduct.setOption(compete.chartStackCompeteProductOption);
}
/******************************************************************************************************************************/
/********************************************** 도우인 경쟁사 목록 *********************************************************/
compete.assistantCompetitorListUpdate = function (chkTxt) {
  let rawData = compete.assistantCompetitorList;
  let prodName = "";
  let prodImg = "";
  if (compete.competeProdList) {
    let keysToExtract = ["sort_key", "col_url", "col_nm"];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    if(chkTxt == "샵"){
      prodImg = "샵 이미지";
      prodName = "샵 명";
    } else {
      prodImg = "제품 이미지";
      prodName = "제품 명";
    }
    compete.competeProdList
    .updateConfig({ 
      columns: [
        {
          name: "순위",
          width: "50px",
        },
        {
          name: prodImg,
          width: "70px",
          formatter: (cell, row) => {
            return gridjs.html(`<img style='height: 50px; width: auto;' src='${cell}' />`);
          },
        },
        {
          name: prodName,
          width: "500px",
        },
      ],
      data: filterData
    }).forceRender();
  }
};

/* 경쟁사 목록 */
if (document.getElementById("competeProdList")) {
  compete.competeProdList = new gridjs.Grid({
    columns: [
      {
        name: "순위",
        width: "50px",
      },
      {
        name: "샵 이미지",
        width: "70px",
        formatter: (cell, row) => {
          return gridjs.html(`<img style='height: 50px; width: auto;' src='${cell}' onmouseover='hoverImage(this, true)' onmouseout='hoverImage(this, false)' />`);
        },
      },
      {
        name: "샵 명",
        width: "500px",
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
        "font-size": "12px",
      },
    },
    data: [],
  }).render(document.getElementById("competeProdList"));
}
/******************************************************************************************************************************/

// 이벤트 핸들러 함수를 배열로 정의합니다.
compete.resizeHandlers = [compete.chartPieCompeteInfo.resize, compete.chartStackCompeteProduct.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
compete.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

compete.updateButtonStyle = function (name) {
  compete.chrtType = name == "샵" ? "SHOP" : "PROD";
  let buttonClasses = {
    샵: ["error", "btn-soft-primary", "btn-primary", "dcshop"],
    제품: ["nomal", "btn-soft-success", "btn-success", "dcproduct"],
  };
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

compete.dcSearchData = function (chkTxt) {
  let datePicker = document.getElementById("competeProdDatepicker1");
  if (!datePicker.value) {
    dapAlert("조회 기간을 선택해 주세요.");
    return false;
  }
  let dataList = ["assistantCompetitorRatioPieChart", "assistantCompetitorTimeSeriesChart", "assistantCompetitorList"];

  let params = {
    params: {
      FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
      TO_MNTH: `'${datePicker.value.slice(-7)}'`,
      CATE_NO: `'${compete.choicesMultipleCategory.getValue().value}'`,
      CHRT_TYPE: `'${compete.chrtType}'`,
    },
    menu: "dashboards/common",
    tab: "compete",
    dataList: dataList,
  };
  getData(params, function (data) {
    compete.assistantCompetitorRatioPieChart = {};
    if (data["assistantCompetitorRatioPieChart"] != undefined) {
      compete.assistantCompetitorRatioPieChart = data["assistantCompetitorRatioPieChart"];
      compete.assistantCompetitorRatioPieChartUpdate();
    }
    if (data["assistantCompetitorTimeSeriesChart"] != undefined) {
      compete.assistantCompetitorTimeSeriesChart = data["assistantCompetitorTimeSeriesChart"];
      compete.assistantCompetitorTimeSeriesChartUpdate();
    }
    if (data["assistantCompetitorList"] != undefined) {
      compete.assistantCompetitorList = data["assistantCompetitorList"];
      compete.assistantCompetitorListUpdate(chkTxt);
    }
  });
};

compete.onLoadEvent = function (initData) {
  /* 경쟁사 비중 / 경쟁사 시계열 / 경쟁사 목록 */
  const newOptions = {
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
    onClose: function (selectedDates, dateStr, instance) {
      if (selectedDates.length > 1) {
        let fromMonth = getMonthFormatter(selectedDates[0]);
        let toMonth = getMonthFormatter(selectedDates[1]);
        newOptions.defaultDate = [fromMonth, toMonth];
        competeProdDatePickers.forEach((picker) => {
          picker.destroy();
        });
        competeProdDatePickers = flatpickr("#competeProdDatepicker1, #competeProdDatepicker2, #competeProdDatepicker3", newOptions);
        let dataList = [
          "assistantCompetitorRatioCategory" /* 1. 도우인 경쟁사 비중 - 카테고리 선택 SQL */,
          "assistantCompetitorTimeSeriesChart" /* 2. 도우인 경쟁사 시계열 그래프 - 시계열 그래프 SQL */,
          "assistantCompetitorList" /* 3. 도우인 경쟁사 목록 - 표 SQL */,
        ];
        let params = {
          params: {
            FR_MNTH: `'${fromMonth.substring(0, 7)}'`,
            TO_MNTH: `'${toMonth.substring(0, 7)}'`,
            CATE_NO: `'${compete.choicesMultipleCategory.getValue().value}'`,
            CHRT_TYPE: `'${compete.chrtType}'`,
          },
          menu: "dashboards/common",
          tab: "compete",
          dataList: dataList,
        };
        getData(params, function (data) {
          Object.keys(data).forEach((key) => {
            compete[key] = data[key];
          });
          compete.setDataBinding();
        });
      }
    },
  };
  let competeProdDatePickers = flatpickr("#competeProdDatepicker1, #competeProdDatepicker2, #competeProdDatepicker3", newOptions);

  /**
   * 도우인 경쟁사 비중 - 제품 선택 Select Box
   */

  if (document.getElementById("competeSbxCategory")) {
    const choicesMultipleCategory = document.getElementById("competeSbxCategory");
    if (!compete.choicesMultipleCategory) {
      compete.choicesMultipleCategory = new Choices(choicesMultipleCategory, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "카테고리를 선택하세요.  ",
      });
    }
  }

  let btnSm = document.querySelectorAll(".btn-sm-dc");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      chkTxt = this.innerText;
      compete.updateButtonStyle(chkTxt);
      compete.dcSearchData(chkTxt);
      compete.assistantCompetitorListUpdate(chkTxt);
      
    });
  });
  compete.updateButtonStyle("샵");

  let dataList = ["assistantCompetitorRatioCategory" /* 1. 도우인 경쟁사 비중 - 카테고리 선택 SQL */];
  let params = {
    params: {
      FR_MNTH: `'${initData.fr_dt.substring(0, 7)}'`,
      TO_MNTH: `'${initData.to_dt.substring(0, 7)}'`,
    },
    menu: "dashboards/common",
    tab: "compete",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      compete[key] = data[key];
    });
    compete.setDataBinding();
  });

  compete.onloadStatus = true; // 화면 로딩 상태
};
