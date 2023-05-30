let network = {};



/* keyword analysis */
const nwSearchKwd = document.getElementById("nwSearchKwd");

/* 콤보 박스 */
const nwSearchKwdChoice = document.getElementById("nwSearchKwdChoice");
if (document.getElementById("nwSearchKwdChoice")) {
  if (!network.nwSearchKwdChoice) {
    network.nwSearchKwdChoice = new Choices(nwSearchKwdChoice, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

const nwJumpNumber = document.getElementById("nwJumpNumber");
if (document.getElementById("nwJumpNumber")) {
  if (!network.nwJumpNumber) {
    network.nwJumpNumber = new Choices(nwJumpNumber, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

const nwSearchVolumeLimit = document.getElementById("nwSearchVolumeLimit");
if (document.getElementById("nwSearchVolumeLimit")) {
  nwSearchVolumeLimit.addEventListener("input", (event) => {
    const inputValue = event.target.value;
    const sanitizedValue = inputValue.replace(/[^0-9]/g, "");
    event.target.value = sanitizedValue;
  });
}

const nwGenderChoice = document.getElementById("nwGenderChoice");
if (document.getElementById("nwGenderChoice")) {
  if (!network.nwGenderChoice) {
    network.nwGenderChoice = new Choices(nwGenderChoice, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

/* network analysis chart */
network.networkChartOption = {
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
      symbolSize: 75,
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
const networkChart = document.getElementById("chart-network-analysis");
network.networkChart = echarts.init(networkChart);
network.networkChart.setOption(network.networkChartOption);

network.searchData = function () {
  if (!nwSearchKwd.value) {
    dapAlert("키워드를 입력해주세요.");
    return false;
  }
  if (!nwJumpNumber.value) {
    dapAlert("점프수를 선택해주세요.");
    return false;
  }
  if (!nwSearchVolumeLimit.value) {
    dapAlert("검색량 제한을 입력해주세요.");
    return false;
  }
  let url = "/keywordprod/getNetworkJson";
  let google_search = document.getElementById("nwGoogleSearch").checked;
  let google_trend = document.getElementById("nwGoogleTrend").checked;
  let naver_search = document.getElementById("nwNaverSearch").checked;

  let params = {
    keyword: nwSearchKwd.value,
    steps: Number(nwJumpNumber.value),
    direction: nwSearchKwdChoice.value,
    gender: "",
    cutoff: Number(nwSearchVolumeLimit.value),
    google_search: network.firstUpper(google_search),
    google_trend: network.firstUpper(google_trend),
    naver_search: network.firstUpper(naver_search),
  };
  sendAjaxRequest(url, params, network.setDataBind);
};

network.firstUpper = function (txt) {
  var boolValue = txt;
  var stringValue = boolValue.toString(); // boolean 값을 string으로 변환
  stringValue = stringValue.charAt(0).toUpperCase() + stringValue.slice(1); // 첫 글자 대문자로 변경
  return stringValue;
};

network.test = function (data, dx, dy) {
  let weightX = 0;
  let weightY = 0;
  for (let i = 0; i < data.length; i++) {
    if (i > 0 && i % 13 == 0) {
      weightX += 100;
      weightY += 100;
    }
    if (i % 13 == 0) {
      if (i == 0) {
        data[i].x = dx;
        data[i].y = dy;
      } else {
        data[i].x = dx + weightX;
        data[i].y = dy + weightY;
      }
    } else if (i % 13 == 1) {
      data[i].x = dx + (100 + weightX);
      data[i].y = dy;
    } else if (i % 13 == 2) {
      data[i].x = dx + (80 + weightX);
      data[i].y = dy + (30 + weightY);
    } else if (i % 13 == 3) {
      data[i].x = dx + (50 + weightX);
      data[i].y = dy + (60 + weightY);
    } else if (i % 13 == 4) {
      data[i].x = dx;
      data[i].y = dy + (80 + weightY);
    } else if (i % 13 == 5) {
      data[i].x = dx - (50 + weightX);
      data[i].y = dy + (60 + weightY);
    } else if (i % 13 == 6) {
      data[i].x = dx - (80 + weightX);
      data[i].y = dy + (30 + weightY);
    } else if (i % 13 == 7) {
      data[i].x = dx - (100 + weightX);
      data[i].y = dy;
    } else if (i % 13 == 8) {
      data[i].x = dx - (80 + weightX);
      data[i].y = dy - (30 + weightY);
    } else if (i % 13 == 9) {
      data[i].x = dx - (50 + weightX);
      data[i].y = dy - (60 + weightY);
    } else if (i % 13 == 10) {
      data[i].x = dx;
      data[i].y = dy - (80 + weightY);
    } else if (i % 13 == 11) {
      data[i].x = dx + (50 + weightX);
      data[i].y = dy - (60 + weightY);
    } else if (i % 13 == 12) {
      data[i].x = dx + (80 + weightX);
      data[i].y = dy - (30 + weightY);
    }
  }
};
// 랜덤 색상표 생성 함수
network.generateRandomColors = function (numColors) {
  const colors = [];

  // 무작위 RGB 색상 생성 함수
  function randomRGB() {
    const r = Math.floor(Math.random() * 256);
    const g = Math.floor(Math.random() * 256);
    const b = Math.floor(Math.random() * 256);
    return `rgb(${r}, ${g}, ${b})`;
  }

  // numColors 만큼의 무작위 색상 생성
  for (let i = 0; i < numColors; i++) {
    colors.push(randomRGB());
  }

  // RGB에서 16진수로 변환하여 배열 반환
  return colors.map((color) => {
    const [r, g, b] = color.slice(4, -1).split(", ");
    return `#${(+r).toString(16)}${(+g).toString(16)}${(+b).toString(16)}`;
  });
};
//text 바인딩해서 보여주기
function setGptTextBind(data) {
  console.log("gogogo");
  const element = document.getElementById("displayGPT");
  if (data.gptResponse) {
    element.innerHTML = data.gptResponse;
  } else {
    element.innerText = "조회 오류입니다.";
  }
}

// 이벤트 핸들러 함수를 배열로 정의합니다.
network.resizeHandlers = [network.networkChart.resize];
// 배열의 각 항목에 대해 addEventListener를 호출하여 이벤트 핸들러를 추가합니다.
network.resizeHandlers.forEach((handler) => {
  window.addEventListener("resize", handler);
});

function calculatePercentile(array, number) {
  console.log('array :', array)
  // remove 0 from the array 
  //array = array.filter(item => item !== 0);
  // First, sort the array in ascending order.
  array.sort((a, b) => a - b);
  // Then, find the rank of the number in the sorted array.
  let rank = array.indexOf(number);
  // If the number is not in the array, return -1.
  if (rank === -1) {
      return 0;
  }
  // Otherwise, calculate the percentile.
  let percentile = 100 * (rank) / array.length;
  return percentile;
};

// Node 크기를 계산하는 함수
network.getNodeSize = function (maxSize, value, maxValue) {
  const minSize = -30;
  if (value <= 30) {
    return 0; // 값이 30 이하인 경우 Node 크기 0 반환
  } else {
    // 가장 큰 값에 대한 비율 계산
    // 가장 큰 값이 너무 커서 로그화 하여봄
    const ratio = Math.log(value) / Math.log(maxValue);
    console.log(minSize + ratio * (maxSize - minSize));
    return minSize + ratio * (maxSize - minSize); // Node 크기 범위: 최소값 ~ 최대값
  }
};

network.setDataBind = function (data) {
  console.log(data);

  const canvasElement = document.querySelector("#chart-network-analysis > div:nth-child(1) > canvas");
  const canvasWidth = canvasElement.width;
  const canvasHeight = canvasElement.height;

  var legend = data.categories.map(function (a) {
    return a.name;
  });

  // 기본 데이터 정비
  for (let i = 0; i < data.nodes.length; i++) {
    //data.nodes[i].x = 0;
    //data.nodes[i].y = 0;
    data.nodes[i].category = data.nodes[i].category - 1;
  }

  // 카테고리별 위치 선정
  // let defaultX = canvasWidth / 2;
  // let defaultY = canvasHeight / 2;
  // let rowIdx = 0;
  // for (let i = 0; i < legend.length; i++) {
  //   const foundObj = data.nodes.filter((obj) => legend[obj.category] === legend[i]);
  //   defaultX = defaultX + 500;
  //   if (i % 5 == 0) {
  //     defaultX = rowIdx % 2 == 0 ? canvasWidth / 2 - 100 : canvasWidth / 2;
  //     defaultY = defaultY + 250;
  //     rowIdx++;
  //   }
  //   network.test(foundObj, defaultX, defaultY);
  // }

  // [force 속성]
  // center: 그래프 중심의 x, y 좌표를 설정합니다. 기본값은 ['50%', '50%'] 입니다.
  // repulsion: 노드 간의 전반적인 물리적인 충돌 강도를 설정합니다. 값이 높을수록 노드들이 서로 멀어집니다.
  // edgeLength: 노드 간의 최소 연결 길이를 설정합니다. 값이 작을수록 노드들이 서로 가까워집니다.
  // gravity: 중심점으로 끌어당기는 힘의 강도를 설정합니다. 값이 크면 중심점으로 모여집니다.
  // layoutAnimation: 레이아웃 애니메이션을 활성화합니다. 기본값은 true 입니다.
  // preventOverlap: 노드 간의 중복을 방지합니다. 기본값은 true 입니다.
  // coolDown: 알고리즘의 종료 조건 중 하나로, 노드들이 움직이지 않을 때까지 걸리는 시간입니다.
  // initLayout: 초기 레이아웃을 설정합니다. 'circular' 또는 'random' 값을 설정할 수 있습니다. 기본값은 'circular' 입니다.
  // nodes: 각 노드의 설정값들을 설정합니다. id, name, value, symbol, symbolSize, label, category 등의 설정값을 지정할 수 있습니다.
  // links: 각 링크의 설정값들을 설정합니다. source, target, value, lineStyle 등의 설정값을 지정할 수 있습니다.

  console.table(data.nodes);

  data.nodes.forEach((item, index) => {
    const maxValue = Math.max(...data.nodes.map((item) => item.vol)); // 주어진 값 중 가장 큰 값
    const currentValue = data.nodes[index]["vol"];
    data.nodes[index].symbolSize = network.getNodeSize(75, currentValue, maxValue);
  });

  console.table(data.nodes);

  network.networkChart.setOption(
    {
      title: {
        text: "",
      },
      tooltip: {
        show: true,
        formatter: function (params) {
          let rtnMsg = `<div style="font-size:14px;color:#666;font-weight:400;line-height:1;text-align:left;margin:0;">${params.name}</div>`;
          if ("vol" in params["data"]) {
            rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${params.color};margin-right:5px;"></span><span>검색량</span></p><span style="font-weight:900;float:right;">${addCommas(
              params["data"]["vol"]
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
      legend: [
        {
          data: legend,
          orient: "vertical",
          left: "left",
          textStyle: {
            color: "#858d98",
          },
        },
      ],
      series: [
        {
          type: "graph",
          layout: "force",
          animation: false,
          force: {
            layoutAnimation: false,
            initLayout: "random",
            gravity: 0.1,
            repulsion: 350,
            edgeLength: 100,

          },
          data: data.nodes,
          links: data.links,
          categories: data.categories,
          roam: true,
          label: {
            show: true,
            position: "right",
            formatter: "{b}",
          },
          labelLayout: {
            hideOverlap: true,
          },
          scaleLimit: {
            min: 0.4,
            max: 2,
          },
          lineStyle: {
            color: "source",
            curveness: 0.3,
          },
        },
      ],
      // color: network.generateRandomColors(data.categories.length),
    },
    true
  );
};
const displayGPTView = document.getElementById("displayGPT");
displayGPTView.innerText = "Chat GPT의 해석결과를 알고 싶으시면 버튼을 클릭하세요";

// 챗지피티 버튼 클릭
network.searchChatgpt = function () {
  if (!nwSearchKwd.value) {
    dapAlert("키워드를 입력해주세요.");
    return false;
  }
  if (!nwJumpNumber.value) {
    dapAlert("점프수를 선택해주세요.");
    return false;
  }
  if (!nwSearchVolumeLimit.value) {
    dapAlert("검색량 제한을 입력해주세요.");
    return false;
  }
  let url = "/keywordprod/getNetworkChatGpt";
  let google_search = document.getElementById("nwGoogleSearch").checked;
  let google_trend = document.getElementById("nwGoogleTrend").checked;
  let naver_search = document.getElementById("nwNaverSearch").checked;

  let params = {
    keyword: nwSearchKwd.value,
    steps: Number(nwJumpNumber.value),
    direction: nwSearchKwdChoice.value,
    gender: "",
    cutoff: Number(nwSearchVolumeLimit.value),
    google_search: network.firstUpper(google_search),
    google_trend: network.firstUpper(google_trend),
    naver_search: network.firstUpper(naver_search),
  };

  // $ajax({
  //   type: "POST",
  //   url: "/keywordprod/getNetworkChatGpt", // Django
  //   data: params,
  //   dataType: 'json',
  //   // success: function(response) {
  //   //   console.log('Success:', response);
  //   // },
  //   // error: function(error) {
  //   //   console.log('Error:', error);
  //   // },
  //   // complete: function(xhr, status) {
  //   //   console.log('Request completed with status:', status);
  //   // }
  //   success: function(response) {
  //     console.log("success :", response.gptResponse)
  //     if (response.gptResponse) {
  //         searchChatgptView.innerText = "Received GPT response: " + response.gptResponse;
  //     } else {
  //         searchChatgptView.innerText = "No GPT response.";
  //     }
  // },
  // error: function(error) {
  //     console.log(error);
  // }

  // })
  sendAjaxRequest(url, params, setGptTextBind);
};
