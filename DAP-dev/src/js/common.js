function getChartColorsArray(e) {
  if (null !== document.getElementById(e)) {
    var t = document.getElementById(e).getAttribute("data-colors");
    if (t)
      return (t = JSON.parse(t)).map(function (e) {
        var t = e.replace(" ", "");
        return -1 === t.indexOf(",")
          ? getComputedStyle(document.documentElement).getPropertyValue(t) || t
          : 2 == (e = e.split(",")).length
          ? "rgba(" + getComputedStyle(document.documentElement).getPropertyValue(e[0]) + "," + e[1] + ")"
          : t;
      });
    console.warn("data-colors Attribute not found on:", e);
  }
}

/**
 *
 * @param {string} name 가져올 쿠키 명
 * @returns 쿠키에서 추출한 값
 */
function getCookie(name) {
  var cookieValue = null;
  if (document.cookie && document.cookie !== "") {
    var cookies = document.cookie.split(";");
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i].trim();
      // Does this cookie string begin with the name we want?
      if (cookie.substring(0, name.length + 1) === name + "=") {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

/**
 *
 * @param {string} url 조회 할 url
 * @param {object} params 조회 할 파라미터
 * @returns 조회 한 결과 object
 */
function sendAjaxRequest(url, params, callback) {
  var httpRequest, result;
  var csrftoken = getCookie("csrftoken");
  let dl = document.getElementById("data-loading");
  try {
    /* 통신에 사용 될 XMLHttpRequest 객체 정의 */
    httpRequest = new XMLHttpRequest();
    /* httpRequest의 readyState가 변화했을때 함수 실행 */
    httpRequest.onreadystatechange = () => {
      /* readyState가 Done이고 응답 값이 200일 때, 받아온 response로 name과 age를 그려줌 */
      if (httpRequest.readyState === XMLHttpRequest.DONE) {
        if (httpRequest.status === 200) {
          result = httpRequest.response;
          if (callback) {
            callback(result);
          }
        } else {
          dapAlert("오류");
        }
      }
      dl.style.visibility = "hidden";
    };
    /* Post 방식으로 요청 */
    httpRequest.open("POST", url, true);
    /* Response Type을 Json으로 사전 정의 */
    httpRequest.responseType = "json";
    /* 요청 Header에 컨텐츠 타입은 Json으로 사전 정의 */
    httpRequest.setRequestHeader("Content-Type", "application/json");
    httpRequest.setRequestHeader("X-CSRFToken", csrftoken);
    /* 정의된 서버에 Json 형식의 요청 Data를 포함하여 요청을 전송 */
    httpRequest.send(JSON.stringify(params));
    dl.style.visibility = "visible";
  } catch (e) {
    Swal.fire({
      title: e.message,
      confirmButtonClass: "btn btn-primary w-xs mt-2",
      buttonsStyling: false,
      showCloseButton: true,
    });
  }
}

/**
 *
 * @param {object} params 조회 할 파라미터
 * 예시 
 * let params = {
    "params": {
      "FR_DT": "2023-02-01",
      "TO_DT": "2023-02-01"
    },
    "menu": "dashboards",
    "tab": "sales",
    "dataList": ["refundTimeSeriesByProduct", "salesRankingLYMoM"]
  }
 * @returns 조회 한 결과 object
 */
function getData(params, callback) {
  var httpRequest, result;
  var progress = true;
  var csrftoken = getCookie("csrftoken");
  let dl = document.getElementById("data-loading");
  try {
    if (!params.hasOwnProperty("params")) {
      params["params"] = {};
    }

    if (!params.hasOwnProperty("menu")) {
      console.error("getData : 메뉴명 데이터가 없습니다.");
      return false;
    }

    if (!params.hasOwnProperty("dataList")) {
      console.error("getData : 조회할 데이터 목록이 없습니다.");
      return false;
    }

    if (params.hasOwnProperty("progress")) {
      progress = params["progress"];
    }

    /* 통신에 사용 될 XMLHttpRequest 객체 정의 */
    httpRequest = new XMLHttpRequest();
    /* httpRequest의 readyState가 변화했을때 함수 실행 */
    httpRequest.onreadystatechange = () => {
      /* readyState가 Done이고 응답 값 200 */
      if (httpRequest.readyState === XMLHttpRequest.DONE) {
        if (httpRequest.status === 200) {
          result = parseJSON(httpRequest.responseText);
          for (row in result) {
            if (result[row] == null) {
              result[row] = [];
              console.log(`쿼리 데이터 없음 : ${row}`);
            }
          }
          if (callback) {
            callback(result);
          }
        } else {
          dapAlert("오류");
        }
      }
      if (progress) dl.style.visibility = "hidden";
    };
    /* Post 방식으로 요청 */
    httpRequest.open("POST", "/getData", true);
    /* Response Type을 Json으로 사전 정의 */
    httpRequest.responseType = "text";
    /* 요청 Header에 컨텐츠 타입은 Json으로 사전 정의 */
    httpRequest.setRequestHeader("Content-Type", "application/json");
    httpRequest.setRequestHeader("X-CSRFToken", csrftoken);
    /* 정의된 서버에 Json 형식의 요청 Data를 포함하여 요청을 전송 */
    httpRequest.send(JSON.stringify(params));
    if (progress) dl.style.visibility = "visible";
  } catch (e) {
    Swal.fire({
      title: e.message,
      confirmButtonClass: "btn btn-primary w-xs mt-2",
      buttonsStyling: false,
      showCloseButton: true,
    });
  }
}

function sendGetRequest(url, callback) {
  const httpRequest = new XMLHttpRequest();
  httpRequest.open("GET", url, true);

  httpRequest.onload = function () {
    if (httpRequest.status === 200) {
      // 성공적으로 데이터를 받은 경우, 받은 데이터를 처리합니다.
      const data = httpRequest.response;
      callback(data);
    } else {
      // 실패한 경우, 에러를 처리합니다.
      console.error("요청이 실패하였습니다.");
    }
  };

  httpRequest.onerror = function () {
    console.error("요청이 실패하였습니다.");
  };
  httpRequest.responseType = "json";
  httpRequest.send();
}

function parseJSON(responseText) {
  try {
    // JSON 문자열을 유효한 형식으로 변환합니다.
    const validJSONString = responseText.replace(/NaN/g, '"NaN"');
    // JSON 문자열을 파싱하여 자바스크립트 객체로 반환합니다.
    const data = JSON.parse(validJSONString);
    return data;
  } catch (error) {
    console.error("JSON parsing error:", error);
    return null;
  }
}

function replaceNullWithZero(json) {
  if (typeof json !== "object") {
    return json;
  }

  for (const key in json) {
    if (json.hasOwnProperty(key)) {
      const value = json[key];
      if (value === null) {
        json[key] = 0;
      } else if (value === "null") {
        json[key] = 0;
      } else if (value === NaN) {
        json[key] = 0;
      } else if (!value) {
        json[key] = 0;
      } else if (typeof value === "object") {
        replaceNullWithZero(value);
      }
    }
  }

  return json;
}

function replaceNaNWithZero(arr) {
  return arr.map((val) => (isNaN(val) ? 0 : val));
}

function addCommas(value) {
  let newValue = value ?? 0;
  return newValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// counter-value
function counter() {
  var counter = document.querySelectorAll(".counter-value");
  if (counter) {
    var speed = 10; // The higher the slower
    counter &&
      Array.from(counter).forEach(function (counter_value) {
        function updateCount() {
          var target = +counter_value.getAttribute("data-target");
          var count = +counter_value.innerText;
          var inc = target / speed;
          if (inc < 1) {
            inc = 1;
          }
          // Check if target is reached
          if (count < target) {
            // Add inc to count and output in counter_value
            counter_value.innerText = (count + inc).toFixed(0);
            // Call function every ms
            setTimeout(updateCount, 1);
          } else {
            counter_value.innerText = numberWithCommas(target);
          }
          numberWithCommas(counter_value.innerText);
        }
        updateCount();
      });

    function numberWithCommas(x) {
      return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
}

function getMonthStartAndToday() {
  let today = new Date();
  const year = today.getFullYear();
  const month = (today.getMonth() + 1).toString().padStart(2, "0");
  const day = today.getDate().toString().padStart(2, "0");

  const monthStart = `${year}-${month}-01`;
  today = `${year}-${month}-${day}`;
  let toMonth = `${year}-${month}`;
  return { monthStart, today, toMonth };
}

function getDateFormatter(date) {
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function getMonthFormatter(date) {
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  return `${year}-${month}`;
}

/**
 * alert 메시지
 * @param {string} name 메시지 내용
 */
function dapAlert(message) {
  Swal.fire({
    title: message,
    confirmButtonClass: "btn btn-primary w-xs mt-2",
    buttonsStyling: false,
    showCloseButton: true,
  });
}
/**
 *
 * 번역 기능
 */
function getTranslate(params, callback) {
  var httpRequest, result;
  var progress = true;
  var csrftoken = getCookie("csrftoken");
  let dl = document.getElementById("data-loading");
  try {
    if (!params.hasOwnProperty("params")) {
      params["params"] = {};
    }

    if (params.hasOwnProperty("progress")) {
      progress = params["progress"];
    }

    /* 통신에 사용 될 XMLHttpRequest 객체 정의 */
    httpRequest = new XMLHttpRequest();
    /* httpRequest의 readyState가 변화했을때 함수 실행 */
    httpRequest.onreadystatechange = () => {
      /* readyState가 Done이고 응답 값 200 */
      if (httpRequest.readyState === XMLHttpRequest.DONE) {
        if (httpRequest.status === 200) {
          result = parseJSON(httpRequest.responseText);
          if (callback) {
            callback(result);
          }
        } else {
          dapAlert("오류");
        }
      }
      if (progress) dl.style.visibility = "hidden";
    };
    /* Post 방식으로 요청 */
    httpRequest.open("POST", "/getTranslate", true);
    /* Response Type을 Json으로 사전 정의 */
    httpRequest.responseType = "text";
    /* 요청 Header에 컨텐츠 타입은 Json으로 사전 정의 */
    httpRequest.setRequestHeader("Content-Type", "application/json");
    httpRequest.setRequestHeader("X-CSRFToken", csrftoken);
    /* 정의된 서버에 Json 형식의 요청 Data를 포함하여 요청을 전송 */
    httpRequest.send(JSON.stringify(params));
    if (progress) dl.style.visibility = "visible";
  } catch (e) {
    Swal.fire({
      title: e.message,
      confirmButtonClass: "btn btn-primary w-xs mt-2",
      buttonsStyling: false,
      showCloseButton: true,
    });
  }
}

let gridTable; // 전역 변수로 선언

function myCustomDataButton() {
  renderGridTable();
  const customDataButton = {
    show: true, // 버튼을 표시합니다.
    title: "Excel", // 버튼의 툴팁 제목을 설정합니다.
    icon: "path://M9.293 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V4.707A1 1 0 0 0 13.707 4L10 .293A1 1 0 0 0 9.293 0zM9.5 3.5v-2l3 3h-2a1 1 0 0 1-1-1zM5.884 6.68 8 9.219l2.116-2.54a.5.5 0 1 1 .768.641L8.651 10l2.233 2.68a.5.5 0 0 1-.768.64L8 10.781l-2.116 2.54a.5.5 0 0 1-.768-.641L7.349 10 5.116 7.32a.5.5 0 1 1 .768-.64z", // 버튼 아이콘을 설정합니다.
    onclick: function (params) {
      let lgnd = params.option.legend.length > 0 && params.option.legend[0].data ? true : false;
      let xAxis = typeof params.option.xAxis[0].data != "undefined" ? true : false;
      let yAxis = typeof params.option.yAxis[0].data != "undefined" ? true : false;
      let series = params.option.series.length > 0 ? true : false;
      let dataset = typeof params.option.dataset != "undefined" ? true : false;

      let columnData = ["구분"];
      let allData = [];
      let rowData = [];
      if (lgnd && xAxis && series) {
        /*
         * 유형 1
         * e.option.legend[0].data
         * e.option.xAxis[0].data
         * e.option.series
         */
        // 카테고리로 넘어오는 항목은 컬럼 다르게 생성
        if (params.option.xAxis[0].type === "category") {
          let column = [...new Set(params.option.series.map((item) => item.name))];
          columnData.push(...column);
        } else {
          columnData.push(...params.option.xAxis[0].data);
        }
        for (let i = 0; i < params.option.xAxis[0].data.length; i++) {
          rowData = [];
          rowData.push(params.option.xAxis[0].data[i]);
          for (let r = 0; r < params.option.series.length; r++) {
            rowData.push(params.option.series[r].data[i] != undefined ? params.option.series[r].data[i] : "");
          }
          allData.push(rowData);
        }
      } else if (xAxis && series && yAxis) {
        /*
         * 유형 3
         * e.option.xAxis[0].data
         * e.option.series
         */
        // 헤더 생성
        columnData.push(...params.option.xAxis[0].data);
        for (let i = 0; i < params.option.xAxis[0].data.length; i++) {
          rowData = [];
          rowData.push(params.option.xAxis[0].data[i]);
          for (let r = 0; r < params.option.series.length; r++) {
            rowData.push(params.option.series[r].data[i] != undefined ? params.option.series[r].data[i] : "");
          }
          allData.push(rowData);
        }
      } else if (xAxis && series) {
        /*
         * 유형 3
         * e.option.xAxis[0].data
         * e.option.series
         */
        // 헤더 생성
        let column = [...new Set(params.option.series.map((item) => item.name))];
        columnData.push(...column);
        for (let i = 0; i < params.option.xAxis[0].data.length; i++) {
          rowData = [];
          rowData.push(params.option.xAxis[0].data[i]);
          for (let r = 0; r < params.option.series.length; r++) {
            rowData.push(params.option.series[r].data[i] != undefined ? params.option.series[r].data[i] : "");
          }
          allData.push(rowData);
        }
      } else if (lgnd && yAxis && series) {
        /*
         * 유형 1
         * e.option.legend[0].data
         * e.option.xAxis[0].data
         * e.option.series
         */
        // 헤더 생성
        columnData.push(...params.option.legend[0].data);
        for (let i = 0; i < params.option.yAxis[0].data.length; i++) {
          rowData = [];
          rowData.push(params.option.yAxis[0].data[i]);
          for (let r = 0; r < params.option.series.length; r++) {
            rowData.push(params.option.series[r].data[i] != undefined ? params.option.series[r].data[i] : "");
          }
          allData.push(rowData);
        }
      } else if (yAxis && series) {
        /*
         * 유형 3
         * e.option.xAxis[0].data
         * e.option.series
         */
        // 헤더 생성
        let column = [...new Set(params.option.series.map((item) => item.name))];
        columnData.push(...column);
        for (let i = 0; i < params.option.yAxis[0].data.length; i++) {
          rowData = [];
          rowData.push(params.option.yAxis[0].data[i]);
          for (let r = 0; r < params.option.series.length; r++) {
            rowData.push(params.option.series[r].data[i] != undefined ? params.option.series[r].data[i] : "");
          }
          allData.push(rowData);
        }
      } else if (dataset) {
        /*
         * 유형 3
         * e.option.dataset[0]["source"]
         */
        columnData = params.option.dataset[0]["source"][0];
        for (let i = 1; i < params.option.dataset[0]["source"].length; i++) {
          allData.push(params.option.dataset[0]["source"][i]);
        }
      }
      // console.log(columnData);
      // console.log(allData);
      updateGridTable(columnData, allData);
    },
  };
  return customDataButton;
}

function updateGridTable(columns, rows) {
  const container = document.getElementById("grid-table");
  container.innerHTML = ""; // 컨테이너 비우기
  gridTable.updateConfig({ columns: columns, data: rows }).forceRender();

  const modal = document.getElementById("exampleModalgrid");
  modal.classList.add("show");
  modal.style.display = "block";
  document.body.classList.add("modal-open");
  //모달 닫기버튼 이벤트
  const closeButton = document.querySelector('[data-bs-dismiss="modal"]');
  closeButton.addEventListener("click", function () {
    modal.classList.remove("show");
    modal.style.display = "none";
    document.body.classList.remove("modal-open");
  });

  const excelDownload = document.querySelector("#saveButton");
  function downloadGrid() {
    const headers = columns;
    const data = [headers, ...rows];
    const worksheet = XLSX.utils.aoa_to_sheet(data);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "시트명");
    XLSX.writeFile(workbook, `${fileNameToTime("dataView")}.xlsx`);

    // Remove the event listener after the download process starts
    excelDownload.removeEventListener("click", downloadGrid);
  }

  excelDownload.addEventListener("click", downloadGrid);
}

function fileNameToTime(filename) {
  var today = new Date();
  var year = today.getFullYear();
  var month = today.getMonth() + 1;
  var day = today.getDate();
  var hours = today.getHours();
  var minutes = today.getMinutes();
  var seconds = today.getSeconds();
  // 월과 일이 10보다 작은 경우 앞에 0을 붙여줍니다.
  if (month < 10) {
    month = "0" + month;
  }
  if (day < 10) {
    day = "0" + day;
  }
  // 시간, 분, 초가 10보다 작은 경우 앞에 0을 붙여줍니다.
  if (hours < 10) {
    hours = "0" + hours;
  }
  if (minutes < 10) {
    minutes = "0" + minutes;
  }
  if (seconds < 10) {
    seconds = "0" + seconds;
  }
  var time = year + "" + month + "" + day + "" + hours + "" + minutes + "" + seconds;
  return `${filename}_${time}`;
}

function renderGridTable() {
  const container = document.getElementById("grid-table");
  container.innerHTML = ""; // 컨테이너 내용 비우기
  gridTable = new gridjs.Grid({
    columns: [
      {
        name: "구분",
      },
    ],
    sort: true,
    transpose: true, // transpose option
    pagination: {
      enabled: true,
      limit: 10,
    },
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
  }).render(container);
  return gridTable;
}

function copyToClipboard(elementId) {
  // 복사할 텍스트를 가져옵니다.
  var r = document.createRange();
  r.selectNode(document.getElementById(elementId));
  window.getSelection().removeAllRanges();
  window.getSelection().addRange(r);
  document.execCommand("copy");
  window.getSelection().removeAllRanges();
}

function hoverImage(element, isHovered) {
  const targetElement = document.getElementById("zoomImg");
  
  const card_height = element.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.offsetHeight;
  const table_height = element.parentElement.parentElement.parentElement.parentElement.offsetHeight;
  const top = card_height - table_height;

  const tr0 = element.parentElement.parentElement.parentElement.parentElement.parentElement.childNodes[0];
  const left = tr0.childNodes[0].childNodes[0].offsetWidth + tr0.childNodes[0].childNodes[1].offsetWidth

  const grid_width = element.parentElement.parentElement.parentElement.parentElement.offsetWidth;
  const td00_width = element.parentElement.parentElement.parentElement.childNodes[0].offsetWidth;
  const td01_width = element.parentElement.parentElement.parentElement.childNodes[1].offsetWidth;

  let layer_width = grid_width - td00_width - td01_width;
  layer_width = layer_width > table_height ? table_height : layer_width;
  
  if (isHovered) {
    targetElement.src = element.src;
    targetElement.style.width = layer_width + "px";
    targetElement.style.height = layer_width + "px";
    targetElement.style.zIndex = "9999";
    targetElement.style.position = "absolute";
    targetElement.style.top = top + "px";
    targetElement.style.left = left + "px";
    targetElement.style.display = "block";
  } else {
    targetElement.style.display = "none";
  }
}
