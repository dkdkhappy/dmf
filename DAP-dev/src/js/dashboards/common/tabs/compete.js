let compete = {};
compete.product = {};
compete.onloadStatus = false; // 화면 로딩 상태

compete.setDataBinding = function () {
  /* 경쟁 제품 분석 - 제품 선택 박스 */
  if (Object.keys(compete.product).length > 0) {
    compete.productUpdate(compete.choicesMultipleProduct1);
    compete.productUpdate(compete.choicesMultipleProduct2);
  }
};

compete.productUpdate = function (obj) {
  let rawData = compete.product;
  let prodList = [];
  rawData.forEach((product) => {
    prodList.push({ value: product.prod_nm, label: product.prod_nm });
  });
  if (obj) {
    // obj.clearChoices();
    // obj.removeActiveItems();
    obj.setChoices(prodList, "value", "label", true);
  }
};

/********************************************** 경쟁 제품 분석 *********************************************************/
compete.competingProductAnalysisUpdate = function () {
  let rawData = compete.competingProductAnalysis;

  const prod_nm = [...new Set(rawData.map((item) => item.prod_nm))];

  const series = [];

  // 중복 제거를 위한 Set 객체 생성
  let stackSet = new Set(rawData.map((d) => d.sort_key));
  let nameSet = new Set(rawData.map((d) => d.cmpt_nm));

  let defaultData = [];

  // stack 값을 이용한 데이터 구분
  for (let stack of stackSet) {
    // name 값을 이용한 데이터 구분
    for (let name of nameSet) {
      let filteredData = rawData.filter((d) => d.sort_key === stack && d.cmpt_nm === name);
      if (filteredData.length > 0) {
        defaultData = new Array(prod_nm.length);
        defaultData[stack - 1] = Number(filteredData.map((d) => d.trde_rate)[0]);
        let newData = {
          name: name,
          type: "bar",
          stack: "total",
          data: defaultData,
          label: {
            show: true,
            position: 'inside',
            formatter: function(params){
              let labels = "";
              if(params.value > 0){
                labels = params.seriesName.substring(0, 15);
              }
              return labels;
            }
          },
        };
        series.push(newData);
      }
    }
  }

  if (compete.chartCompeteProductInfo) {
    compete.chartCompeteProductInfo.setOption(compete.chartCompeteProductInfoOption, true);
    if (rawData.length > 0) {
      compete.chartCompeteProductInfo.setOption({
        xAxis: {
          type: "category",
          data: prod_nm,
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

/* 경쟁 제품 분석 그래프 */
compete.chartCompeteProductInfoOption = {
  tooltip: {
    trigger: "item", // trigger 속성을 item으로 설정
    formatter: function (params) {
      // debugger;
      var value = params.value;
      if (!value) {
        value = 0;
      }
      var color = params.color;
      return (
        `${params.name}` +
        '<br /><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:' +
        color +
        ';margin-right:5px;"></span><span>' +
        `${params.seriesName}` +
        '</span><span style="font-weight:900;float:right;margin-left:10px;font-size:14px;color:#666;">' +
        `${value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}` +
        "</span>"
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
      magicType: {
        type: ["bar", "stack"],
      },
    },
  },
  legend: {
    show: false,
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
      // formatter: function (value, index) {
      //   return value.slice(0, 6) + "...";
      // },
      // rotate: 45,
    },
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
if (document.getElementById("chart-compete-product-info")) {
  compete.chartCompeteProductInfo = echarts.init(document.getElementById("chart-compete-product-info"));
  compete.chartCompeteProductInfo.setOption(compete.chartCompeteProductInfoOption);
}
/******************************************************************************************************************************/
/********************************************** 경쟁 제품 시계열 그래프 *********************************************************/
compete.competitorProductTimeSeriesGraphUpdate = function () {
  let rawData = compete.competitorProductTimeSeriesGraph;

  const cmpt_mnth = [...new Set(rawData.map((item) => item.cmpt_mnth))];

  const series = [];

  // rawData에서 cmpt_mnth를 그룹별로 묶기
  const groupedData = rawData.reduce((acc, cur) => {
    // 현재 데이터의 cmpt_mnth 값을 가져옴
    const month = cur.cmpt_mnth;
    // acc 객체에 month 프로퍼티가 있으면 해당 배열에 현재 데이터를 push, 없으면 month 프로퍼티와 새 배열을 추가함
    if (acc[month]) {
      acc[month].push(cur);
    } else {
      acc[month] = [cur];
    }
    return acc;
  }, {});

  let featureType = [];

  if (compete.chrtType == "exponent") {
    featureType = ["bar"];
    labelStyle = {};
  } else {
    featureType = ["bar", "stack"];
    labelStyle = {
      show: true,
      position: 'inside',
      formatter: function(params){
        return params.seriesName.substring(0,15);
      }
    };
  }

  // 그룹별로 출력
  let defaultData = [];
  let idx = 0;
  for (const month in groupedData) {
    groupedData[month].forEach(function (grpData) {
      defaultData = new Array(6);
      defaultData[idx] = compete.chrtType == "exponent" ? Number(grpData["trde_idx"]) : Number(grpData["trde_rate"]);
      let newData = {
        name: grpData["cmpt_nm"],
        type: "bar",
        data: defaultData,
        label: labelStyle
      };

      if (compete.chrtType == "percent") {
        newData.stack = "total";
      }

      series.push(newData);
    });
    idx++;
  }

  if (compete.chartStackCompeteProduct) {
    compete.chartStackCompeteProduct.setOption(compete.chartStackCompeteProductOption, true);
    if (rawData.length > 0) {
      compete.chartStackCompeteProduct.setOption(
        {
          tooltip: {
            trigger: "item", // trigger 속성을 item으로 설정
            formatter: function (params) {
              // debugger;
              var value = params.value;
              if (!value) {
                value = 0;
              }
              var color = params.color;
              return (
                `${params.name}` +
                '<br /><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:' +
                color +
                ';margin-right:5px;"></span><span>' +
                `${params.seriesName}` +
                '</span><span style="font-weight:900;float:right;margin-left:10px;font-size:14px;color:#666;">' +
                `${value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}` +
                "</span>"
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
              magicType: {
                type: featureType,
              },
            },
          },
          legend: {
            show: false,
          },
          grid: {
            left: "2%",
            right: "5%",
            bottom: "3%",
            containLabel: true,
          },
          xAxis: {
            type: "category",
            data: cmpt_mnth,
            axisLabel: {
              rotate: 45,
            },
          },
          yAxis: [
            {
              type: "value",
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
        },
        true
      );
    }
  }
};
/* 경쟁 제품 시계열 그래프 */
compete.chartStackCompeteProductOption = {
  tooltip: {
    trigger: "item", // trigger 속성을 item으로 설정
    formatter: "{b} <br/>{a} : {c}", // tooltip 내용 포맷 설정
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
  legend: {
    show: false,
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
/********************************************** 경쟁 제품 등수 변화 *********************************************************/
compete.competitionProductRankingShiftChartUpdate = function () {
  let rawData = compete.competitionProductRankingShiftChart;
  let monthRawData = compete.competitionProductRankingShiftMonth;

  if (compete.chartParallelCompeteRank) {
    compete.chartParallelCompeteRank.setOption(compete.chartParallelCompeteRankOption, true);
    if (rawData.length > 0) {
      let parallelAxis = [];
      let idx = 0;
      monthRawData.forEach((data) => {
        parallelAxis.push({
          dim: idx,
          name: data["amt_mnth"],
          inverse: true,
          min: 1
        });
        idx++;
      });

      const p_cate_val = [...new Set(rawData.map((item) => item.p_cate_val))];

      parallelAxis.push({
        dim: idx,
        name: "타사제품명",
        inverse: true,
        type: "category",
        axisLabel: {
          align: "left",
          margin: "10",
          rotate: -45,
        },
        data: p_cate_val,
      });

      let series = [];
      rawData.forEach((data) => {
        let row = [];
        data["s_data"].split(",").forEach((item) => {
          row.push(item.replace(/'/g, ""));
        });
        series.push(row);
      });

      compete.chartParallelCompeteRank.setOption(
        {
          tooltip: {
            show: true,
            trigger: "item",
            formatter: function (params) {
              let data = params.data;
              let title = "";
              let val = "";
              let month = "";
              for (var i = 0; i < data.length; i++) {
                month = parallelAxis[i].name;
                if (i == data.length - 1) {
                  title = data[data.length - 1] + "<br />";
                } else {
                  val +=
                    "<span style='display:inline-block;margin-right:6px;border-radius:10px;width:10px;height:10px;background-color:#5470c6;'></span>" +
                    "<span style='display: inline-block;margin-right:20px;margin-top:4px;'>" +
                    month +
                    "</span>" +
                    "<span style='font-weight:bold;'>" +
                    data[i] +
                    "</span>" +
                    "<br />";
                }
              }
              return title + val;
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
          parallelAxis: parallelAxis,
          parallel: {
            left: "40",
            right: "150",
          },
          series: {
            type: "parallel",
            lineStyle: {
              width: 4,
            },
            data: series,
          },
        },
        true
      );
    }
  }
};

/* 경쟁 제품 등수 변화 그래프 */
compete.chartParallelCompeteRankOption = {
  parallelAxis: [],
  parallel: {
    left: "40",
    right: "150",
  },
  series: {
    type: "parallel",
    lineStyle: {
      width: 4,
    },
    data: [],
  },
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
if (document.getElementById("chart-parallel-compete-rank")) {
  compete.chartParallelCompeteRank = echarts.init(document.getElementById("chart-parallel-compete-rank"));
  compete.chartParallelCompeteRank.setOption(compete.chartParallelCompeteRankOption);
}
/******************************************************************************************************************************/
/********************************************** 경쟁 제품 TOP5 *********************************************************/
compete.topFiveCompetingProductsUpdate = function () {
  let rawData = compete.topFiveCompetingProducts;
  if (compete.competeProdList) {
    let keysToExtract = ["cmpt_rank", "prod_img", "cmpt_nm", "trde_idx"];
    let filterData = [];
    for (var i = 0; i < rawData.length; i++) {
      filterData.push(keysToExtract.map((key) => rawData[i][key]));
    }
    compete.competeProdList.updateConfig({ data: filterData }).forceRender();
  }
};

/* 경쟁 제품 TOP5 */
if (document.getElementById("competeProdList")) {
  compete.competeProdList = new gridjs.Grid({
    columns: [
      {
        name: "등수",
        width: "50px",
      },
      {
        name: "제품 이미지",
        width: "70px",
        formatter: (cell, row) => {
          return gridjs.html(`<img style='height: 50px; width: auto;' src='${cell}' onmouseover='hoverImage(this, true)' onmouseout='hoverImage(this, false)' />`);
        },
      },
      {
        name: "제품명",
        width: "200px",
      },
      {
        name: "누적 거래지수",
        width: "110px",
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
compete.resizeHandlers = [compete.chartCompeteProductInfo.resize, compete.chartStackCompeteProduct.resize, compete.chartParallelCompeteRank.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
compete.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

compete.updateButtonStyle = function (name) {
  compete.chrtType = name;
  const buttonClasses = {
    exponent: ["exponent", "error", "btn-soft-primary", "btn-primary"],
    percent: ["percent", "nomal", "btn-soft-success", "btn-success"],
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

compete.searchData = function (type) {
  if (type == "analysis") {
    let selProduct = compete.choicesMultipleProduct1.getValue();
    let datePicker = document.getElementById("competeProdDatepicker1");
    let productArr = selProduct.map((item) => item.value);
    if (!datePicker.value) {
      dapAlert("조회 기간을 선택해 주세요.");
      return false;
    }
    if (productArr.length == 0) {
      dapAlert("제품을 선택해 주세요.");
      return false;
    }

    let dataList = ["competingProductAnalysis" /* 2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창 - 제품선택 SQL */];
    let params = {
      params: {
        FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
        TO_MNTH: `'${datePicker.value.slice(-7)}'`,
        PROD_NM: `'${productArr.join("★")}'`,
      },
      menu: "dashboards/common",
      tab: "compete",
      dataList: dataList,
    };
    getData(params, function (data) {
      compete.competingProductAnalysis = {};
      if (data["competingProductAnalysis"] != undefined) {
        compete.competingProductAnalysis = data["competingProductAnalysis"];
        compete.competingProductAnalysisUpdate();
      }
    });
  } else if (type == "graph") {
    let selProduct = compete.choicesMultipleProduct2.getValue();
    let datePicker = document.getElementById("competeProdDatepicker2");
    if (!datePicker.value) {
      dapAlert("조회 기간을 선택해 주세요.");
      return false;
    }
    if (!selProduct.value) {
      dapAlert("제품을 선택해 주세요.");
      return false;
    }

    let dataList = [
      "competitorProductTimeSeriesGraph" /* 2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창 - 제품선택 SQL */,
      "competitionProductRankingShiftMonth" /* 8. 경쟁제품 등수변화 - 월 SQL */,
      "competitionProductRankingShiftChart" /* 8. 경쟁제품 등수변화 - 평행그래프 SQL */,
      "topFiveCompetingProducts" /* 9. 경쟁 제품 TOP 5 - 표 SQL */,
    ];
    let params = {
      params: {
        FR_MNTH: `'${datePicker.value.substring(0, 7)}'`,
        // FR_MNTH: `'2022-01'`,
        TO_MNTH: `'${datePicker.value.slice(-7)}'`,
        PROD_NM: `'${selProduct.value}'`,
        // PROD_NM: `'M4 토너 에멀전 세트'`,
        // TYPE:`'${compete.chrtType}'`
      },
      menu: "dashboards/common",
      tab: "compete",
      dataList: dataList,
    };
    getData(params, function (data) {
      compete.competitorProductTimeSeriesGraph = {};
      compete.competitionProductRankingShiftMonth = {};
      compete.competitionProductRankingShiftChart = {};
      compete.topFiveCompetingProducts = {};
      if (data["competitorProductTimeSeriesGraph"] != undefined) {
        compete.competitorProductTimeSeriesGraph = data["competitorProductTimeSeriesGraph"];
        compete.competitorProductTimeSeriesGraphUpdate();
      }
      if (data["competitionProductRankingShiftMonth"] != undefined) {
        compete.competitionProductRankingShiftMonth = data["competitionProductRankingShiftMonth"];
      }
      if (data["competitionProductRankingShiftChart"] != undefined) {
        compete.competitionProductRankingShiftChart = data["competitionProductRankingShiftChart"];
        compete.competitionProductRankingShiftChartUpdate();
      }
      if (data["topFiveCompetingProducts"] != undefined) {
        compete.topFiveCompetingProducts = data["topFiveCompetingProducts"];
        compete.topFiveCompetingProductsUpdate();
      }
    });
  }
};

compete.onLoadEvent = function (initData) {
  /* 경쟁 제품 분석 flatpickr */
  flatpickr("#competeProdDatepicker1", {
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
    // onChange: function (selectedDates, dateStr, instance) {
    //   let el = this.element.id;
    //   if (selectedDates.length > 1) {
    //     const fromDate = getDateFormatter(selectedDates[0]);
    //     const toDate = getDateFormatter(selectedDates[1]);
    //     let params = {
    //       params: {
    //         FR_MNTH: `'${fromDate.substring(0, 7)}'`,
    //         TO_MNTH: `'${toDate.substring(0, 7)}'`,
    //       },
    //       menu: "dashboards/common",
    //       tab: "compete",
    //       dataList: ["product"],
    //     };
    //     getData(params, function (data) {
    //       compete.product = {};
    //       /* 4. 매출 정보에 대한 시계열 / 데이터 뷰어 - Chart Data */
    //       if (data["product"] != undefined) {
    //         compete.product = data["product"];
    //         if (el == "competeProdDatepicker1") {
    //           compete.productUpdate(compete.choicesMultipleProduct1);
    //         } else if (el == "competeProdDatepicker2") {
    //           compete.productUpdate(compete.choicesMultipleProduct2);
    //         }
    //       }
    //     });
    //   }
    // },
  });

  /* 경쟁 제품 시계열/ 등수/ TOP5 */
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
        let toMonth   = getMonthFormatter(selectedDates[1]);
        newOptions.defaultDate = [fromMonth, toMonth];
        competeProdDatePickers.forEach(picker => {          
          picker.destroy();
        });
        competeProdDatePickers = flatpickr("#competeProdDatepicker2, #competeProdDatepicker3, #competeProdDatepicker4", newOptions);
      }
    },
  };
  let competeProdDatePickers = flatpickr("#competeProdDatepicker2, #competeProdDatepicker3, #competeProdDatepicker4", newOptions);

  /**
   * 경쟁 제품 분석 - 제품 선택 Select Box
   */
  if (document.getElementById("competeSbxProduct1")) {
    const choicesMultipleProduct1 = document.getElementById("competeSbxProduct1");
    if (!compete.choicesMultipleProduct1) {
      compete.choicesMultipleProduct1 = new Choices(choicesMultipleProduct1, {
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

  if (document.getElementById("competeSbxProduct2")) {
    const choicesMultipleProduct2 = document.getElementById("competeSbxProduct2");
    if (!compete.choicesMultipleProduct2) {
      compete.choicesMultipleProduct2 = new Choices(choicesMultipleProduct2, {
        searchEnabled: false,
        shouldSort: false,
        placeholder: true,
        placeholderValue: "제품을 선택하세요.  ",
      });
    }
  }

  let btnSm = document.querySelectorAll(".btn-sm");
  btnSm.forEach(function (div) {
    div.addEventListener("click", function (e) {
      let chkTxt = this.innerText;
      compete.chrtType = chkTxt == "지수" ? "exponent" : "percent";
      compete.updateButtonStyle(compete.chrtType);
      compete.competitorProductTimeSeriesGraphUpdate();
    });
  });
  compete.updateButtonStyle("exponent");

  let dataList = ["product" /* 2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창 - 제품선택 SQL */];
  let params = {
    params: {
      FR_DT: `'${initData.fr_dt}'`,
      TO_DT: `'${initData.to_dt}'`,
      BASE_MNTH: `'${initData.base_mnth}'`,
      BASE_YEAR: `'${initData.base_year}'`,
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
