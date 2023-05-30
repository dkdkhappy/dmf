let route = {};

/* keyword analysis */
const rtSearchKwd = document.getElementById("rtSearchKwd");

/* 콤보 박스 */
const rtSearchKwdChoice = document.getElementById("rtSearchKwdChoice");
if (document.getElementById("rtSearchKwdChoice")) {
  if (!route.rtSearchKwdChoice) {
    route.rtSearchKwdChoice = new Choices(rtSearchKwdChoice, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

const rtJumpNumber = document.getElementById("rtJumpNumber");
if (document.getElementById("rtJumpNumber")) {
  if (!route.rtJumpNumber) {
    route.rtJumpNumber = new Choices(rtJumpNumber, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

route.handlePaste = function (event) {
  const clipboardData = event.clipboardData || window.clipboardData;
  const pastedData = clipboardData.getData("text");
  const regex = /^\d+$/; // 정규식을 사용하여 숫자만 허용
  if (!regex.test(pastedData)) {
    event.preventDefault(); // 붙여넣기를 취소
  }
};

const rtSearchVolumeLimit = document.getElementById("rtSearchVolumeLimit");
if (document.getElementById("rtSearchVolumeLimit")) {
  rtSearchVolumeLimit.addEventListener("input", (event) => {
    const inputValue = event.target.value;
    const sanitizedValue = inputValue.replace(/[^0-9]/g, "");
    event.target.value = sanitizedValue;
  });
}

const rtGenderChoice = document.getElementById("rtGenderChoice");
if (document.getElementById("rtGenderChoice")) {
  if (!route.rtGenderChoice) {
    route.rtGenderChoice = new Choices(rtGenderChoice, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

route.onLoadEvent = function (initData) {
  flatpickr("#routeDate", {
    locale: "ko", // locale for this instance only
    mode: "range",
    plugins: [
      new monthSelectPlugin({
        shorthand: true, //defaults to false
        dateFormat: "Y-m", //defaults to "F Y"
        altFormat: "Y-m", //defaults to "F Y"
      }),
    ],
  });

  /* 생키 그래프 */
  am4core.useTheme(am4themes_animated);
  // Themes end
  route.amchart = am4core.create("chart-sankey-intention", am4charts.SankeyDiagram);
  route.amchart.hiddenState.properties.opacity = 0; // this creates initial fade-in

  let hoverState = route.amchart.links.template.states.create("hover");
  hoverState.properties.fillOpacity = 0.6;

  route.amchart.dataFields.fromName = "from";
  route.amchart.dataFields.toName = "to";
  route.amchart.dataFields.value = "value";

  // for right-most label to fit
  route.amchart.paddingTop = 20;
  route.amchart.paddingBottom = 20;
  route.amchart.paddingLeft = 10;
  route.amchart.paddingRight = 100;

  // make nodes draggable
  var nodeTemplate = route.amchart.nodes.template;
  nodeTemplate.inert = true;
  nodeTemplate.readerTitle = "Drag me!";
  nodeTemplate.showSystemTooltip = true;
  nodeTemplate.width = 20;

  // make nodes draggable
  var nodeTemplate = route.amchart.nodes.template;
  nodeTemplate.readerTitle = "Click to show/hide or drag to rearrange";
  nodeTemplate.showSystemTooltip = true;
  nodeTemplate.cursorOverStyle = am4core.MouseCursorStyle.pointer;

  route.amchart.events.on("beforedatavalidated", function (ev) {
    // check if there's data
    if (ev.target.data.length == 0) {
      route.showIndicator();
    } else if (route.indicator) {
      route.hideIndicator();
    }
  });

  nodeTemplate.events.on('hit', function(ev) {
    // console.log(ev.target.properties.name);
    rtSearchKwd.value = ev.target.properties.name;
    route.searchData();
  });

};

route.indicator;
route.showIndicator = function () {
  if (route.indicator) {
    route.indicator.show();
  } else {
    route.indicator = route.amchart.tooltipContainer.createChild(am4core.Container);
    route.indicator.background.fill = am4core.color("#fff");
    route.indicator.background.fillOpacity = 0.8;
    route.indicator.width = am4core.percent(100);
    route.indicator.height = am4core.percent(100);

    var indicatorLabel = route.indicator.createChild(am4core.Label);
    indicatorLabel.text = "데이터가 없습니다";
    indicatorLabel.align = "center";
    indicatorLabel.valign = "middle";
    indicatorLabel.fontSize = 20;
  }
};

route.hideIndicator = function () {
  route.indicator.hide();
};

route.searchData = function () {
  let datePicker = document.getElementById("routeDate");
  if (!rtSearchKwd.value) {
    dapAlert("키워드를 입력해주세요.");
    return false;
  }
  if (!datePicker.value) {
    dapAlert("조회 기간을 선택해 주세요.");
    return false;
  }
  if (!rtJumpNumber.value) {
    dapAlert("점프수를 선택해주세요.");
    return false;
  }
  if (!rtSearchVolumeLimit.value) {
    dapAlert("검색량 제한을 입력해주세요.");
    return false;
  }
  let url = "/keywordprod/getMakeSankeyData";
  let google_search = document.getElementById("rtGoogleSearch").checked;
  let google_trend = document.getElementById("rtGoogleTrend").checked;
  let naver_search = document.getElementById("rtNaverSearch").checked;
  let params = {
    fr_mnth: `'${datePicker.value.substring(0, 7)}'`,
    to_mnth: `'${datePicker.value.slice(-7)}'`,
    keyword: rtSearchKwd.value,
    steps: Number(rtJumpNumber.value),
    direction: rtSearchKwdChoice.value,
    gender: "",
    cutoff: Number(rtSearchVolumeLimit.value),
    google_search: route.firstUpper(google_search),
    google_trend: route.firstUpper(google_trend),
    naver_search: route.firstUpper(naver_search),
  };
  sendAjaxRequest(url, params, route.setDataBind);
};

route.firstUpper = function (txt) {
  var boolValue = txt;
  var stringValue = boolValue.toString(); // boolean 값을 string으로 변환
  stringValue = stringValue.charAt(0).toUpperCase() + stringValue.slice(1); // 첫 글자 대문자로 변경
  return stringValue;
};

route.setDataBind = function (data) {
  let rawData = data.links;
  console.log(rawData.length);
  for (let i = 0; i < rawData.length; i++) {
    // "from" 속성 생성하고 "source" 값 할당
    rawData[i].from = rawData[i].source;
    // "source" 속성 삭제
    delete rawData[i].source;

    // "to" 속성 생성하고 "target" 값 할당
    rawData[i].to = rawData[i].target;
    // "target" 속성 삭제
    delete rawData[i].target;
  }
  route.amchart.data = rawData;
};
