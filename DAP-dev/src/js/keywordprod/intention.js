let keywordprod = {};

/* keyword analysis */
const ibxSearchKwd = document.getElementById("ibxSearchKwd");
if (!keywordprod.ibxSearchKwd) {
  keywordprod.ibxSearchKwd = new Choices(ibxSearchKwd, {
    searchEnabled: false,
    shouldSort: false,
    removeItemButton: true,
    classNames: {
      removeButton: "remove",
    },
    placeholder: true,
    placeholderValue: "키워드를 입력하세요.  ",
  });
}



const dbSearchGridSearchBtn = document.getElementById("db-search-grid-search-btn");
dbSearchGridSearchBtn.addEventListener("click", function (e) {
  let keyword = keywordprod.ibxSearchKwd.getValue();
  let keywordValue = "";
  if (keyword.length == 0) {
    dapAlert("키워드를 입력하세요.");
    return false;
  } else {
    const valuesArray = keyword.map((item) => item.value);
    keywordValue = valuesArray.join(",");
  }

  let dataList = [
    "totalSearchVolume" /* 2. Volume, Google Traffic, Naver Traffic, CPC -  전체 검색량 SQL */,
    "totalSearchVolumeChart" /* 2. Volume, Google Traffic, Naver Traffic, CPC -  Chart SQL */,
    "genderAgeInterestChart" /* 3. 네이버 데이터 기준 성별 분포(남, 여), 연령별 분포, 정보성 상업성 비율 - 성별, 연령, 정보/상업 그래프 SQL */,
    "volumeTimeTrend" /* 4. Volume Time trend - 시계열 그래프 SQL*/,
    "googleSuggestedKeywords" /* 5. Google 연관 키워드 List - 표 SQL*/,
    "naverSuggestedKeywords" /* 6. Naver 연관 키워드 List - 표 SQL */,
    "top10NetworkComparisonChart" /* 7. Top 10 비교 - 네트워크 그래프 SQL */,
  ];

  let params = {
    params: { KWRD_NM: `'${keywordValue}'` ,
    VOL: top30VolChoice.value},
    menu: "keywordprod",
    dataList: dataList,
  };
  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      keywordprod[key] = replaceNullWithZero(data[key]);
    });
    for (let i = 0; i < keywordprod.counterValue.length; i++) {
      keywordprod.badgePar = keywordprod.counterValue[i].parentNode.nextElementSibling;
      if (Number(keywordprod.counterValue[i].innerText) == 0 && keywordprod.badgePar != null && keywordprod.badgePar.firstElementChild != null) {
        keywordprod.badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    keywordprod.setDataBinding();
  });
});

/************************************************콤보박스 */
/* 콤보 박스 */
const top30VolChoice = document.getElementById("top30VolChoice");
if (document.getElementById("top30VolChoice")) {
  if (!keywordprod.top30VolChoice) {
    keywordprod.top30VolChoice = new Choices(top30VolChoice, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}
top30VolChoice.addEventListener("change", function () {
  console.log("change standard") ;
  let keyword = keywordprod.ibxSearchKwd.getValue();
  let keywordValue = "";
  if (keyword.length == 0) {
    dapAlert("키워드를 입력하세요.");
    return false;
  } else {
    const valuesArray = keyword.map((item) => item.value);
    keywordValue = valuesArray.join(",");
  }
  let dataList = [
    "top10NetworkComparisonChart" /* 7. Top 10 비교 - 네트워크 그래프 SQL */,
  ];

  let params = {
    params: { KWRD_NM: `'${keywordValue}'` ,
    VOL: top30VolChoice.value},
    menu: "keywordprod",
    dataList: dataList,
  };
  getData(params, function (data) {
    Object.keys(data).forEach((key) => {
      keywordprod[key] = replaceNullWithZero(data[key]);
    });
    for (let i = 0; i < keywordprod.counterValue.length; i++) {
      keywordprod.badgePar = keywordprod.counterValue[i].parentNode.nextElementSibling;
      if (Number(keywordprod.counterValue[i].innerText) == 0 && keywordprod.badgePar != null && keywordprod.badgePar.firstElementChild != null) {
        keywordprod.badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    keywordprod.setDataBinding();
  })
  keywordprod.top10NetworkComparisonChartUpdate()
  }
      )

const chatGPTCommnetBtn = document.getElementById("chat-gpt-comment-btn");
chatGPTCommnetBtn.addEventListener("click", function (e) {
  let keyword = keywordprod.ibxSearchKwd.getValue();
  let keywordValue = "";
  console.log("start 챗지피티");
  if (keyword.length == 0) {
    dapAlert("키워드를 입력하세요.");
    return false;
  } else {
    const valuesArray = keyword.map((item) => item.value);
    keywordValue = valuesArray.join(",");
  }

  let dataList = ["top10NetworkComparisonChart" /* 7. Top 10 비교 - 네트워크 그래프 SQL */];

  let params = {
    params: { 
      KWRD_NM: `'${keywordValue}'`,
      VOL: top30VolChoice.value,
    },
    menu: "keywordprod",
    dataList: dataList,
    progress: false,
  };
  /* 쿼리 날리기 */
  getData(params, function (data) {
    Object.keys(data).forEach((key) => {
      keywordprod[key] = replaceNullWithZero(data[key]);
    });
    for (let i = 0; i < keywordprod.counterValue.length; i++) {
      keywordprod.badgePar = keywordprod.counterValue[i].parentNode.nextElementSibling;
      if (Number(keywordprod.counterValue[i].innerText) == 0 && keywordprod.badgePar != null && keywordprod.badgePar.firstElementChild != null) {
        keywordprod.badgePar.firstElementChild.style.display = "inline-block";
      }
    }
    /* 데이터 바인딩에 보내기 */
    chatGPTCommentUpdate();
  });
});

function chatGPTCommentUpdate() {
  let keyword = keywordprod.ibxSearchKwd.getValue();
  let keywordValue = "";
  console.log("start 챗지피티");
  if (keyword.length == 0) {
    dapAlert("키워드를 입력하세요.");
    return false;
  } else {
    const valuesArray = keyword.map((item) => item.value);
    keywordValue = valuesArray.join(",");
  }

  let rawData = keywordprod.top10NetworkComparisonChart;
  console.log(rawData);
  let url = "/keywordprod/getIntentionChatGpt";
  let params = {
    data: rawData,
    kwrd: `'${keywordValue}'`,
  };
  sendAjaxRequest(url, params, setGptCommentBind);
}
const gptExplainView = document.getElementById("gpt-explain");
gptExplainView.innerText = "Chat GPT의 해석결과를 알고 싶으시면 버튼을 클릭하세요";

function setGptCommentBind(data) {
  console.log("setgpttext :", data);
  const element = document.getElementById("gpt-explain");
  if (data.gptResponse) {
    element.innerHTML = data.gptResponse;
  } else {
    element.innerText = "조회 오류입니다.";
  }
}

keywordprod.setDataBinding = function () {
  /* 2. Volume, Google Traffic, Naver Traffic, CPC -  전체 검색량 SQL */
  keywordprod.totalSearchVolumeUpdate();
  /* 2. Volume, Google Traffic, Naver Traffic, CPC -  Chart SQL */
  keywordprod.totalSearchVolumeChartUpdate();
  /* 3. 네이버 데이터 기준 성별 분포(남, 여), 연령별 분포, 정보성 상업성 비율 - 성별, 연령, 정보/상업 그래프 SQL */
  keywordprod.genderAgeInterestChartUpdate();
  /* 4. Volume Time trend - 시계열 그래프 SQL*/
  keywordprod.volumeTimeTrendUpdate();
  /* 5. Google 연관 키워드 List - 표 SQL*/
  keywordprod.googleSuggestedKeywordsUpdate();
  /* 6. Naver 연관 키워드 List - 표 SQL */
  keywordprod.naverSuggestedKeywordsUpdate();
  /* 7. Top 10 비교 - 네트워크 그래프 SQL */
  keywordprod.top10NetworkComparisonChartUpdate();
  counter();
};

/******************************************************** Volume, Google Traffic, Naver Traffic, CPC ***************************************************/

keywordprod.totalSearchVolumeUpdate = function () {
  let rawData = keywordprod.totalSearchVolume;

  let cardAreaList = ["t_vol", "g_vol", "n_vol", "g_cpc", "t_vol_rate", "g_vol_rate", "n_vol_rate"];
  cardAreaList.forEach((cardArea) => {
    let el = document.getElementById(`${cardArea}`);
    if (cardArea.indexOf("_rate") > -1) {
      let elArrow = document.getElementById(`${cardArea}_arrow`);

      el.classList.remove("text-muted", "ri-arrow-up-line", "text-success", "ri-arrow-down-line", "text-danger");
      elArrow.classList.remove("text-muted", "ri-arrow-up-line", "text-success", "ri-arrow-down-line", "text-danger");

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
    } else {
      el.innerText = 0;
      el.setAttribute("data-target", rawData[0][`${cardArea}`]);
    }
  });
};

keywordprod.totalSearchVolumeChartUpdate = function () {
  let rawData = keywordprod.totalSearchVolumeChart;

  let {
    TOTAL = [],
    GOOGLE = [],
    NAVER = [],
  } = rawData.reduce((arr, chart) => {
    arr[chart["chrt_key"]] ? arr[chart["chrt_key"]].push(chart) : (arr[chart["chrt_key"]] = [chart]);
    return arr;
  }, {});

  let totalData = TOTAL.map((d) => ({
      x: d["x_dt"],
      y: Number(d["y_val"]),
    })),
    googleData = GOOGLE.map((d) => ({
      x: d["x_dt"],
      y: Number(d["y_val"]),
    })),
    naverData = NAVER.map((d) => ({
      x: d["x_dt"],
      y: Number(d["y_val"]),
    }));

  // Volume 그래프 데이터 업데이트
  keywordprod.volumeCount.updateSeries([
    {
      name: "Traffic",
      data: totalData.sort(function (a, b) {
        return new Date(a.x) - new Date(b.x);
      }),
    },
  ]);
  // Google Traffic 그래프 데이터 업데이트
  keywordprod.googleTrafficCount.updateSeries([
    {
      name: "Traffic",
      data: googleData.sort(function (a, b) {
        return new Date(a.x) - new Date(b.x);
      }),
    },
  ]);
  // Naver Traffic 그래프 데이터 업데이트
  keywordprod.naverTrafficCount.updateSeries([
    {
      name: "Traffic",
      data: naverData.sort(function (a, b) {
        return new Date(a.x) - new Date(b.x);
      }),
    },
  ]);
};

/* volume */
keywordprod.volumeCountOptions = {
  series: [
    {
      name: "volume",
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
  colors: getChartColorsArray("volumeCount"),
};
keywordprod.volumeCount = new ApexCharts(document.querySelector("#volumeCount"), keywordprod.volumeCountOptions);
keywordprod.volumeCount.render();

/* Google Traffic */
keywordprod.googleTrafficCountOptions = {
  series: [
    {
      name: "Google",
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
  colors: getChartColorsArray("googleTrafficCount"),
};
keywordprod.googleTrafficCount = new ApexCharts(document.querySelector("#googleTrafficCount"), keywordprod.googleTrafficCountOptions);
keywordprod.googleTrafficCount.render();

/* Naver Traffic */
keywordprod.naverTrafficCountOptions = {
  series: [
    {
      name: "Naver",
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
  colors: getChartColorsArray("naverTrafficCount"),
};
keywordprod.naverTrafficCount = new ApexCharts(document.querySelector("#naverTrafficCount"), keywordprod.naverTrafficCountOptions);
keywordprod.naverTrafficCount.render();
/*******************************************************************************************************************************************************/
/******************************************************** 성별, 연령, 정보/상업 ***************************************************/

keywordprod.genderAgeInterestChartUpdate = function () {
  // 성별
  keywordprod.chartGenderUpdate();
  // 연령
  keywordprod.chartBarAgeRankUpdate();
  // 정보/상업
  keywordprod.versusChartUpdate();
};

keywordprod.chartGenderUpdate = function () {
  let rawData = keywordprod.genderAgeInterestChart;
  let feme_rate = 0;
  let male_rate = 0;
  if (rawData.length > 0) {
    feme_rate = rawData[0]["feme_rate"];
    male_rate = rawData[0]["male_rate"];
  }
  keywordprod.chartGender.setOption(keywordprod.chartGenderOption, true);
  keywordprod.chartGender.setOption({
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
            matchingVal = feme_rate;
            break;
          case "남성":
            matchingVal = male_rate;
            break;
          default:
          // Do nothing
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
      data: keywordprod.labels,
      axisTick: { show: true },
      axisLine: { show: false },
      axisLabel: { show: true, fontSize: 17 },
    },
    yAxis: {
      max: keywordprod.bodyMax,
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
        symbolBoundingData: keywordprod.bodyMax,
        label: keywordprod.labelSetting,
        data: [
          {
            value: feme_rate,
            symbol: symbols[0],
          },
          {
            value: male_rate,
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
        symbolBoundingData: keywordprod.bodyMax,
        animationDuration: 0,
        barMaxWidth: 90,
        itemStyle: {
          color: "#ccc",
        },
        data: [
          {
            value: feme_rate,
            symbol: symbols[0],
          },
          {
            value: male_rate,
            symbol: symbols[2],
          },
        ],
      },
    ],
  });
};

/* 성별 그래프 - 바 그래프 SQL */
keywordprod.labels = ["여성", "남성"];
keywordprod.bodyMax = 100;

keywordprod.labelSetting = {
  show: true,
  position: "top",
  offset: [0, -20],
  formatter: function (param) {
    return ((param.value / keywordprod.bodyMax) * 100).toFixed(0) + "%";
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

/* 성별분포 그래프 - 바 그래프 SQL */
keywordprod.chartGenderOption = {
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
    data: keywordprod.labels,
    axisTick: { show: true },
    axisLine: { show: false },
    axisLabel: { show: true, fontSize: 17 },
  },
  yAxis: {
    max: keywordprod.bodyMax,
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
      symbolBoundingData: keywordprod.bodyMax,
      label: keywordprod.labelSetting,
      data: [],
      markLine: markLineSetting,
      z: 10,
      barMaxWidth: 90,
    },
    {
      name: "",
      type: "pictorialBar",
      symbolBoundingData: keywordprod.bodyMax,
      animationDuration: 0,
      barMaxWidth: 90,
      itemStyle: {
        color: "#ccc",
      },
      data: [],
    },
  ],
};

keywordprod.chartGender = echarts.init(document.getElementById("chart-gender"));
keywordprod.chartGender.setOption(keywordprod.chartGenderOption);

keywordprod.chartBarAgeRankUpdate = function () {
  let rawData = keywordprod.genderAgeInterestChart;
  let age_10_rate = 0;
  let age_20_rate = 0;
  let age_30_rate = 0;
  let age_40_rate = 0;
  let age_50_rate = 0;

  if (rawData.length > 0) {
    age_10_rate = rawData[0]["age_10_rate"];
    age_20_rate = rawData[0]["age_20_rate"];
    age_30_rate = rawData[0]["age_30_rate"];
    age_40_rate = rawData[0]["age_40_rate"];
    age_50_rate = rawData[0]["age_50_rate"];
  }
  keywordprod.chartBarAgeRank.setOption(keywordprod.chartBarAgeRankOption, true);
  keywordprod.chartBarAgeRank.setOption({
    series: [
      {
        data: [age_10_rate, age_20_rate, age_30_rate, age_40_rate, age_50_rate],
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
};

/* 연령별 Bar 그래프 */
keywordprod.chartBarAgeRankOption = {
  tooltip: {
    trigger: "axis",
  },
  grid: {
    left: "2%",
    right: "7%",
    bottom: "3%",
    top: "3%",
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
    data: ["10대", "20대", "30대", "40대", "50대 이상"],
    formatter: function (value, index) {
      return value.slice(0, 6) + "...";
    },
  },
  xAxis: [
    {
      type: "category",
      data: ["10대", "20대", "30대", "40대", "50대 이상"],
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
  series: [
    {
      name: "연령별",
      type: "bar",
      barWidth: "60%",
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
keywordprod.chartBarAgeRank = echarts.init(document.getElementById("chart-bar-age-rank"));
keywordprod.chartBarAgeRank.setOption(keywordprod.chartBarAgeRankOption);

keywordprod.versusChartUpdate = function () {
  let rawData = keywordprod.genderAgeInterestChart;
  let info_rate = 0;
  let comm_rate = 0;

  let spnInfoRate = document.getElementById("spnInfoRate");
  let spnCommRate = document.getElementById("spnCommRate");

  if (rawData.length > 0) {
    info_rate = rawData[0]["info_rate"];
    comm_rate = rawData[0]["comm_rate"];
    spnInfoRate.innerText = `${info_rate}%`;
    spnCommRate.innerText = `${comm_rate}%`;
  } else {
    spnInfoRate.innerText = "0%";
    spnCommRate.innerText = "0%";
  }
  keywordprod.versusChart.setOption(keywordprod.versusChartOption, true);
  keywordprod.versusChart.setOption({
    legend: {
      textStyle: {
        color: "#858d98",
      },
    },
    series: [
      {
        data:
          rawData.length == 0
            ? []
            : [
                {
                  value: info_rate,
                  name: "정보성",
                },
                {
                  value: comm_rate,
                  name: "상업성",
                },
              ],
      },
    ],
  });
};

/* 정보성 VS 상업성 */
keywordprod.versusChartOption = {
  tooltip: {
    trigger: "item",
  },
  legend: {
    top: "2%",
    left: "center",
  },
  grid: {
    bottom: "0",
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
  series: [
    {
      type: "pie",
      radius: ["40%", "70%"],
      avoidLabelOverlap: false,
      label: {
        show: false,
        position: "center",
      },
      labelLine: {
        show: false,
      },
      data: [],
    },
  ],
};
keywordprod.versusChart = echarts.init(document.getElementById("versus-chart"));
keywordprod.versusChart.setOption(keywordprod.versusChartOption);

/*********************************************************************************************************************************/
/******************************************************** Volume Time Trend ***************************************************/

keywordprod.volumeTimeTrendUpdate = function () {
  let rawData = keywordprod.volumeTimeTrend;

  const lgnd = [...new Set(rawData.map((item) => item.l_lgnd))];
  let category = [...new Set(rawData.map((item) => item.x_dt))];
  category = category.sort(function (a, b) {
    if (a === 0) return -1; // 0을 가장 첫번째로 배치
    return new Date(a) - new Date(b);
  });

  let seriesData = [];
  lgnd.forEach((id) => {
    let filterData = rawData.filter((item) => item.l_lgnd == id);

    filterData = filterData.sort(function (a, b) {
      if (a.x_dt < b.x_dt) return -1;
      if (a.x_dt > b.x_dt) return 1;
      return 0;
    });

    let arr = [];
    filterData.forEach(function (data) {
      let y_val = data["y_val"];
      arr.push([data["x_dt"], Number(y_val)]);
    });
    seriesData.push({
      name: filterData[0]["l_lgnd"],
      type: "line",
      data: arr,
    });
  });

  keywordprod.chartLineVolumeTimeTrend.setOption(keywordprod.chartLineVolumeTimeTrendOption, true);
  keywordprod.chartLineVolumeTimeTrend.setOption({
    legend: {
      data: lgnd,
      textStyle: {
        color: "#858d98",
      },
    },
    xAxis: {
      type: "category",
      boundaryGap: false,
      data: category,
    },
    series: seriesData,
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
};
/* Volume Time Trend */
keywordprod.chartLineVolumeTimeTrendOption = {
  tooltip: {
    trigger: "axis",
  },
  legend: {
    textStyle: {
      color: "#858d98",
    },
  },
  grid: {
    left: "2%",
    right: "3%",
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
        type: ["line", "bar", "stack"],
      },
    },
  },
  xAxis: {
    type: "category",
    boundaryGap: false,
    data: ["2022-03-01", "2023-03-02"],
  },
  yAxis: [
    {
      type: "value",
      name: "검색건수"
    },
  ],
  series: [
    {
      data: {
        sort_key: 1,
        l_lgnd_id: "VTT1",
        l_lgnd_nm: "검색어1",
        x_dt: "2022-03-01",
        y_val: 12.96,
      },
      name: "검색어1",
      type: "line",
    },
    {
      data: {
        sort_key: 2,
        l_lgnd_id: "VTT2",
        l_lgnd_nm: "검색어2",
        x_dt: "2023-03-02",
        y_val: 1.96,
      },
      name: "검색어2",
      type: "line",
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

keywordprod.chartLineVolumeTimeTrend = echarts.init(document.getElementById("chart-line-volume-time-trend"));
keywordprod.chartLineVolumeTimeTrend.setOption(keywordprod.chartLineVolumeTimeTrendOption);
/******************************************************************************************************************************/
/******************************************************** Google 연관 키워드 List ***************************************************/

keywordprod.googleSuggestedKeywordsUpdate = function () {
  let rawData = keywordprod.googleSuggestedKeywords;
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(Object.values(rawData[i]));
  }
  keywordprod.googleRelatedKeywords
    .updateConfig({
      data: function () {
        return new Promise(function (resolve) {
          setTimeout(function () {
            resolve(filterData);
          }, 2000);
        });
      },
    })
    .forceRender();
};

/* Google 연관 키워드 List */
if (document.getElementById("google-related-keywords")) {
  keywordprod.googleRelatedKeywords = new gridjs.Grid({
    columns: [
      {
        name: "키워드 명",
      },
      {
        name: "과거 1달전 검색량",
      },
      {
        name: "과거 1년 누적 검색량"
      },
      {
        name: "CPC",
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
    pagination: {
      limit: 5,
    },
    data: [],
  }).render(document.getElementById("google-related-keywords"));
}
/***********************************************************************************************************************************/
/******************************************************** Top 10 비교 ***************************************************/

keywordprod.getNetworkChartSize = () => {
  const element = document.getElementById("network-chart");
  const elementWidth = element.offsetWidth;
  const elementHeight = element.offsetHeight;

  const nodeSymbolSize = (elementWidth * 0.15).toFixed(2);
  const symbolSize = (elementWidth * 0.1).toFixed(2);
  const repulsion = (elementWidth * 0.8).toFixed(2);

  function getRepulsion(elementWitdh) {
    if (elementWitdh > 900) {
      return 1300;
    }

    if (elementWitdh > 600) {
      return 950;
    }

    return Math.round(repulsion);
  }

  const x = elementWidth * 0.33;
  const y = elementHeight / 2;
  let params = {
    nodeSymbolSize: nodeSymbolSize > 120 ? 120 : Math.round(nodeSymbolSize),
    symbolSize: symbolSize > 75 ? 75 : Math.round(symbolSize),
    x: x,
    y: y,
    repulsion: getRepulsion(elementWidth),
  };
  console.log(params);
  return {
    nodeSymbolSize: nodeSymbolSize > 120 ? 120 : Math.round(nodeSymbolSize),
    symbolSize: symbolSize > 75 ? 75 : Math.round(symbolSize),
    x: x,
    y: y,
    repulsion: getRepulsion(elementWidth),
  };
};

let calcSettings = keywordprod.getNetworkChartSize();
console.log("calcSettings : ", calcSettings);

keywordprod.top10NetworkComparisonChartUpdate = () => {
  let rawData = keywordprod.top10NetworkComparisonChart;
  let googleVolSum = 0;
  let naverVolSum = 0;
  for (const node of rawData) {
    if (node.node_key === "GOOGLE") {
      googleVolSum += node.vol;
    } else if (node.node_key === "NAVER") {
      naverVolSum += node.vol;
    }
  }
  let gColor = "#4285F4"; // 구글 노드 컬러
  let nColor = "#00C43B"; // 네이버 노드 컬러
  let cColor = "#FBBC05"; // 공통 노드 컬러

  keywordprod.graph = {
    nodes: [
      {
        id: "0",
        name: "GOOGLE",
        symbolSize: calcSettings.nodeSymbolSize,
        category: 0,
        x: calcSettings.x,
        y: calcSettings.y,
        g_vol: googleVolSum,
        fixed: true,
        itemStyle: {
          color: gColor,
        },
      },
      {
        id: "1",
        name: "NAVER",
        symbolSize: calcSettings.nodeSymbolSize,
        category: "1",
        x: calcSettings.x + calcSettings.x,
        y: calcSettings.y,
        n_vol: naverVolSum,
        fixed: true,
        itemStyle: {
          color: nColor,
        },
      },
    ],
    edges: [],
  };

  const nodeKey = [...new Set(rawData.map((item) => item.kwrd_nm))];
  // GOOGLE : 0
  // NAVER  : 1
  let index = 2;
  nodeKey.forEach((node) => {
    let filterData = rawData.filter((item) => item.kwrd_nm == node);
    filterData.forEach((data) => {
      if (filterData.length == 1) {
        if (data["node_key"] == "GOOGLE") {
          keywordprod.graph.nodes.push({
            id: index.toString(),
            name: data["kwrd_nm"],
            g_vol: data["vol"],
            g_rank: data["rank"],
            symbolSize: calcSettings.symbolSize,
            category: "0",
            itemStyle: {
              color: gColor,
            },
          });
          keywordprod.graph.edges.push({
            source: index.toString(),
            target: "0",
          });
          index++;
        } else if (data["node_key"] == "NAVER") {
          keywordprod.graph.nodes.push({
            id: index.toString(),
            name: data["kwrd_nm"],
            n_vol: data["vol"],
            n_rank: data["rank"],
            symbolSize: calcSettings.symbolSize,
            category: "1",
            itemStyle: {
              color: nColor,
            },
          });
          keywordprod.graph.edges.push({
            source: index.toString(),
            target: "1",
          });
          index++;
        }
      } else {
        let isNode = false;

        for (let i = 0; i < keywordprod.graph.nodes.length; i++) {
          if (keywordprod.graph.nodes[i].name === data["kwrd_nm"]) {
            isNode = true;
            break;
          }
        }
        if (!isNode) {
          var googleNode = filterData.find(function (node) {
            return node.node_key === "GOOGLE";
          });
          var naverNode = filterData.find(function (node) {
            return node.node_key === "NAVER";
          });
          keywordprod.graph.nodes.push({
            id: index.toString(),
            name: data["kwrd_nm"],
            g_vol: googleNode["vol"],
            g_rank: googleNode["rank"],
            n_vol: naverNode["vol"],
            n_rank: naverNode["rank"],
            symbolSize: calcSettings.symbolSize,
            category: "2",
            itemStyle: {
              color: cColor,
            },
          });
          keywordprod.graph.edges.push({
            source: index.toString(),
            target: "0",
          });
          keywordprod.graph.edges.push({
            source: index.toString(),
            target: "1",
          });
          index++;
        }
      }
    });
  });
  console.log("keywordprod : ", keywordprod.graph.nodes);
  keywordprod.networkChart.setOption(
    {
      tooltip: {},
      series: [
        {
          type: "graph",
          layout: "force",
          data: keywordprod.graph.nodes,
          links: keywordprod.graph.edges,
          roam: true,
          label: {
            show: true,
          },
          force: {
            repulsion: calcSettings.repulsion,
            //edgeLength: 100,
          },
        },
      ],
    },
    true
  );

  keywordprod.chartResize();
};

keywordprod.networkChartOption = {
  title: {
    text: "",
  },
  tooltip: {},
  toolbox: {
    orient: "vertical",
    left: "right",
    top: "center",
    feature: {
      saveAsImage: {},
      dataView: {},
    },
  },
  series: [
    {
      type: "graph",
      layout: "force",
      symbolSize: calcSettings.symbolSize,
      categories: [
        {
          name: "GOOGLE",
        },
        {
          name: "NAVER",
        },
        {
          name: "COMMON",
        },
      ],
      roam: true,
      label: {
        show: true,
      },
      force: {
        repulsion: calcSettings.repulsion,
      },
      data: [],
      links: [],
      lineStyle: {
        width: 3, // 라인 두께
        color: "#9A60B4", // 라인 색상 (진한 빨강)
      },
    },
  ],
  color: ["#4285F4", "#00C43B", "#FBBC05"],
};

// Node 크기를 계산하는 함수
keywordprod.getNodeSize = function (maxSize, value, maxValue) {
  const minSize = 30;
  if (value <= 0) {
    return 0; // 값이 0 이하인 경우 Node 크기 0 반환
  } else {
    // 가장 큰 값에 대한 비율 계산
    const ratio = value / maxValue;
    return minSize + ratio * (maxSize - minSize); // Node 크기 범위: 최소값 ~ 최대값
  }
};

// Network Chart를 표시할 div 요소 가져오기
const networkChartDom = document.getElementById("network-chart");
keywordprod.networkChart = echarts.init(networkChartDom);
keywordprod.networkChart.setOption(keywordprod.networkChartOption);

keywordprod.chartResize = () => {
  keywordprod.networkChart.resize();
  const calcReSettings = keywordprod.getNetworkChartSize();

  if (!keywordprod.graph) {
    return;
  }

  keywordprod.graph.nodes.forEach((element, index) => {
    if (element.name.includes("GOOGLE") || element.name.includes("NAVER")) {
      keywordprod.graph.nodes[index].x = element.name.includes("GOOGLE") ? calcReSettings.x : calcReSettings.x * 2;
      keywordprod.graph.nodes.forEach((item, index) => {
        if (item.fixed) {
          keywordprod.graph.nodes[index].symbolSize = calcReSettings.nodeSymbolSize;
        } else {
          if (keywordprod.graph.nodes[index].hasOwnProperty("g_vol") && keywordprod.graph.nodes[index].hasOwnProperty("n_vol")) {
            const maxValue = Math.max(...keywordprod.top10NetworkComparisonChart.map((item) => item.vol)); // 주어진 값 중 가장 큰 값
            const currentValue = Math.max(...[keywordprod.graph.nodes[index]["g_vol"], keywordprod.graph.nodes[index]["n_vol"]]);
            keywordprod.graph.nodes[index].symbolSize = keywordprod.getNodeSize(calcReSettings.symbolSize, currentValue, maxValue);
          } else if (keywordprod.graph.nodes[index].hasOwnProperty("g_vol")) {
            const maxValue = Math.max(...keywordprod.top10NetworkComparisonChart.filter((item) => item.node_key == "GOOGLE").map((item) => item.vol)); // 주어진 값 중 가장 큰 값
            const currentValue = keywordprod.graph.nodes[index]["g_vol"];
            keywordprod.graph.nodes[index].symbolSize = keywordprod.getNodeSize(calcReSettings.symbolSize, currentValue, maxValue);
          } else if (keywordprod.graph.nodes[index].hasOwnProperty("n_vol")) {
            const maxValue = Math.max(...keywordprod.top10NetworkComparisonChart.filter((item) => item.node_key == "NAVER").map((item) => item.vol)); // 주어진 값 중 가장 큰 값
            const currentValue = keywordprod.graph.nodes[index]["n_vol"];
            keywordprod.graph.nodes[index].symbolSize = keywordprod.getNodeSize(calcReSettings.symbolSize, currentValue, maxValue);
          }
        }
      });
      // 데이터 바꿔치기
      const option = {
        tooltip: {
          show: true,
          formatter: function (params) {
            let rtnMsg = `<div style="font-size:14px;color:#666;font-weight:400;line-height:1;text-align:left;margin:0;">${params.name}</div>`;
            if ("g_vol" in params["data"]) {
              rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#4285F4"};margin-right:5px;"></span><span>구글 검색량</span></p><span style="font-weight:900;float:right;">${addCommas(
                params["data"]["g_vol"]
              )}</span></div>`;
            }
            if ("g_rank" in params["data"]) {
              rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#4285F4"};margin-right:5px;"></span><span>구글 키워드 랭킹</span></p><span style="font-weight:900;float:right;">${addCommas(
                params["data"]["g_rank"]
              )}</span></div>`;
            }
            if ("n_vol" in params["data"]) {
              rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#00C43B"};margin-right:5px;"></span><span>네이버 검색량</span></p><span style="font-weight:900;float:right;">${addCommas(
                params["data"]["n_vol"]
              )}</span></div>`;
            }
            if ("n_rank" in params["data"]) {
              rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#00C43B"};margin-right:5px;"></span><span>네이버 키워드 랭킹</span></p><span style="font-weight:900;float:right;">${addCommas(
                params["data"]["n_rank"]
              )}</span></div>`;
            }
            return rtnMsg;
          },
        },
        toolbox: {
          orient: "vertical",
          left: "right",
          top: "center",
          feature: {
            saveAsImage: {},
            dataView: {},
            restore: {},
          },
        },
        label: {
          show: true,
          // position: "right",
          // formatter: "{b}",
        },
        animationDurationUpdate: 1500,
        animationEasingUpdate: "quinticInOut",
        series: [
          {
            type: "graph",
            layout: "force",
            data: keywordprod.graph.nodes,
            links: keywordprod.graph.edges,
            roam: true,
            label: {
              show: true,
            },
            force: {
              repulsion: calcReSettings.repulsion,
              //edgeLength: 100,
            },
          },
        ],
      };
      keywordprod.networkChart.setOption(option, true);
    }
  });
};

keywordprod.networkChart.on("click", function (params) {
  if (params.componentType === "series" && params.seriesType === "graph") {
    if (params.dataType === "node" && !["NAVER", "GOOGLE"].includes(params.data["name"])) {
      keywordprod.removeData = keywordprod.networkChart.getOption().series[0].data.filter((obj) => obj.id !== params.data["id"]);
      keywordprod.networkChart.setOption({
        series: [
          {
            type: "graph",
            data: keywordprod.removeData,
            links: keywordprod.networkChart.getOption().series[0].links,
          },
        ],
      });
    }
  }
});




let resizeTimeout;
window.addEventListener("resize", function () {
  // window의 크기가 변경된 후 500 밀리초 후에 실행될 코드 작성
  clearTimeout(resizeTimeout);
  resizeTimeout = setTimeout(function () {
    keywordprod.chartResize();
  }, 500);
});



/************************************************************************************************************************/
/******************************************************** Naver 연관 키워드 List ***************************************************/

keywordprod.naverSuggestedKeywordsUpdate = function () {
  let rawData = keywordprod.naverSuggestedKeywords;
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(Object.values(rawData[i]));
  }
  keywordprod.naverRelatedKeywords
    .updateConfig({
      data: function () {
        return new Promise(function (resolve) {
          setTimeout(function () {
            resolve(filterData);
          }, 2000);
        });
      },
    })
    .forceRender();
};

/* Naver 연관 키워드 List */
if (document.getElementById("naver-related-keywords")) {
  keywordprod.naverRelatedKeywords = new gridjs.Grid({
    columns: [
      {
        name: "키워드 명",
      },
      {
        name: "과거 1달전 검색량",
      },
      {
        name: "과거 1년 누적 검색량"
      },
      {
        name: "경쟁률",
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
    pagination: {
      limit: 5,
    },
    data: [],
  }).render(document.getElementById("naver-related-keywords"));
}
/**********************************************************************************************************************************/

// 이벤트 핸들러 함수를 배열로 정의합니다.
keywordprod.resizeHandlers = [
  keywordprod.volumeCount.resize,
  keywordprod.googleTrafficCount.resize,
  keywordprod.naverTrafficCount.resize,
  keywordprod.chartGender.resize,
  keywordprod.chartBarAgeRank.resize,
  keywordprod.versusChart.resize,
  keywordprod.chartLineVolumeTimeTrend.resize,
  keywordprod.networkChart.resize,
];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
keywordprod.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

keywordprod.onLoadEvent = function () {
  /*
   * 상단 카드 init
   */
  keywordprod.counterValue = document.getElementsByClassName("counter-value");
  keywordprod.badgePar;
  for (let i = 0; i < keywordprod.counterValue.length; i++) {
    keywordprod.badgePar = keywordprod.counterValue[i].parentNode.nextElementSibling;
    if (Number(keywordprod.counterValue[i].innerText) == 0 && keywordprod.badgePar != null && keywordprod.badgePar.firstElementChild != null) {
      keywordprod.badgePar.firstElementChild.style.display = "none";
    }
  }
};
