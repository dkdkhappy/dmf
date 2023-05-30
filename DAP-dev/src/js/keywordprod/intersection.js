let intersection = {};

/* keyword analysis */
let ifSearchKwd1 = document.getElementById("ifSearchKwd1");
let ifSearchKwd2 = document.getElementById("ifSearchKwd2");

let ifJumpNumber = document.getElementById("ifJumpNumber");
if (document.getElementById("ifJumpNumber")) {
  if (!intersection.ifJumpNumber) {
    intersection.ifJumpNumber = new Choices(ifJumpNumber, {
      searchEnabled: false,
      shouldSort: false,
    });
  }
}

intersection.handlePaste = function (event) {
  let clipboardData = event.clipboardData || window.clipboardData;
  let pastedData = clipboardData.getData("text");
  let regex = /^\d+$/; // 정규식을 사용하여 숫자만 허용
  if (!regex.test(pastedData)) {
    event.preventDefault(); // 붙여넣기를 취소
  }
};

let ifSearchVolumeLimit = document.getElementById("ifSearchVolumeLimit");
if (document.getElementById("ifSearchVolumeLimit")) {
    ifSearchVolumeLimit.addEventListener("input", (event) => {
    let inputValue = event.target.value;
    let sanitizedValue = inputValue.replace(/[^0-9]/g, "");
    event.target.value = sanitizedValue;
  });
}

/***************************************************************************************************************/
/************************************************* Intersection Chart ******************************************/
/***************************************************************************************************************/

keywordprod.getNetworkChartIntersectionSize = () => {
    const ele = document.getElementById("network-chart-intersection");
    const eleWidth = ele.offsetWidth;
    const eleHeight = ele.offsetHeight;

    const nodeSymSize = (eleWidth * 0.15).toFixed(2);
    const symSize = (eleWidth * 0.1).toFixed(2);
    const repul = (eleWidth * 0.8).toFixed(2);

    function getRepul(eleWidth) {
        if (eleWidth > 900) {
          return 1300;
        }
    
        if (eleWidth > 600) {
          return 950;
        }
    
        return Math.round(repul);
    }
    const xAxis = eleWidth * 0.33;
    const yAxis = eleHeight / 2;

    let params = {
        nodeSymbolSize: nodeSymSize > 120 ? 120 : Math.round(nodeSymSize),
        symbolSize: symSize > 75 ? 75 : Math.round(symSize),
        x: xAxis,
        y: yAxis,
        repulsion: getRepul(eleWidth),
    };

    return {
        nodeSymbolSize: nodeSymSize > 120 ? 120 : Math.round(nodeSymSize),
        symbolSize: symSize > 75 ? 75 : Math.round(symSize),
        x: xAxis,
        y: yAxis,
        repulsion: getRepul(eleWidth),
    };
};

let calcSetting = keywordprod.getNetworkChartIntersectionSize();

keywordprod.intersectionChartUpdate = () => {
    let rawData = keywordprod.intersectionChart;
    let keywdOneVolSum = 0;
    let keywdTwoVolSum = 0;
    for (const node2 of rawData) {
        if (node2.node_key === "keywdOne") {
            keywdOneVolSum += node2.vol;
        } else if (node2.node_key === "keywdTwo") {
            keywdTwoVolSum += node2.vol;
        }
    }
    let oColor = "#4285F4"; // keywdOne 노드 컬러
    let tColor = "#00C43B"; // keywdTwo 노드 컬러
    let cColor = "#FBBC05"; // 공통 노드 컬러

    keywordprod.graph = {
        nodes: [
            {
                id: "0",
                name: "keywdOne",
                symbolSize: calcSetting.nodeSymSize,
                category: 0,
                x: calcSetting.x,
                y: calcSetting.y,
                g_vol: keywdOneVolSum,
                fixed: true,
                itemStyle: {
                    color: oColor,
                },
            },
            {
                id: "1",
                name: "keywdTwo",
                symbolSize: calcSetting.nodeSymSize,
                category: "1",
                x: calcSetting.x + calcSetting.x,
                y: calcSetting.y,
                n_vol: keywdTwoVolSum,
                fixed: true,
                itemStyle: {
                    color: tColor,
                },
            },
        ],
        edges: [],
    };

    const nodeKey2 = [...new Set(rawData.map((item) => item.kwrd_nm))];
    // 키워드1 : 0
    // 키워드2 : 1
    let index = 2;
    nodeKey2.forEach((node) => {
    let filterData = rawData.filter((item) => item.kwrd_nm == node);
    filterData.forEach((data) => {
        if (filterData.length == 1) {
            if (data["node_key"] == "keywdOne") {
                keywordprod.graph.nodes.push({
                    id: index.toString(),
                    name: data["kwrd_nm"],
                    g_vol: data["vol"],
                    g_rank: data["rank"],
                    symbolSize: calcSetting.symSize,
                    category: "0",
                    itemStyle: {
                        color: oColor,
                    },
                });
                keywordprod.graph.edges.push({
                    source: index.toString(),
                    target: "0",
                });
                index++;
            } else if (data["node_key"] == "keywdTwo") {
                keywordprod.graph.nodes.push({
                    id: index.toString(),
                    name: data["kwrd_nm"],
                    n_vol: data["vol"],
                    n_rank: data["rank"],
                    symbolSize: calcSetting.symSize,
                    category: "1",
                    itemStyle: {
                        color: tColor,
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
                return node.node_key === "keywdOne";
            });
            var naverNode = filterData.find(function (node) {
                return node.node_key === "keywdTwo";
            });
            keywordprod.graph.nodes.push({
                id: index.toString(),
                name: data["kwrd_nm"],
                g_vol: googleNode["vol"],
                g_rank: googleNode["rank"],
                n_vol: naverNode["vol"],
                n_rank: naverNode["rank"],
                symbolSize: calcSetting.symSize,
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
    keywordprod.intersectionChart.setOption(
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
                    repulsion: calcSetting.repul,
                    //edgeLength: 100,
                },
            },
        ],
    },
    true
    );

    keywordprod.chartResize();
};

keywordprod.networkChartIntersectionOption = {
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
            symbolSize: calcSetting.symSize,
            categories: [
                {
                    name: "keywdOne",
                },
                {
                    name: "keywdTwo",
                },
                {
                    name: "keywdCommon",
                },
            ],
            roam: true,
            label: {
                show: true,
            },
            force: {
                repulsion: calcSetting.repul,
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
keywordprod.getNodesSize = function (maxSize, value, maxValue) {
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
const networkChartIntersectionDom = document.getElementById("network-chart-intersection");
keywordprod.networkChartIntersection = echarts.init(networkChartIntersectionDom);
keywordprod.networkChartIntersection.setOption(keywordprod.networkChartIntersectionOption);
  
keywordprod.chartResize = () => {
    keywordprod.networkChart.resize();
    const calcReSetting = keywordprod.getNetworkChartSize();
  
    if (!keywordprod.graph) {
        return;
    }

    keywordprod.graph.nodes.forEach((ele, index) => {
        if (ele.name.includes("keywdOne") || ele.name.includes("keywdTwo")) {
            keywordprod.graph.nodes[index].x = ele.name.includes("keywdOne") ? calcReSetting.xAxis : calcReSetting.xAxis * 2;
            keywordprod.graph.nodes.forEach((item, index) => {
                if (item.fixed) {
                    keywordprod.graph.nodes[index].symSize = calcReSetting.nodeSymSize;
                } else {
                    if (keywordprod.graph.nodes[index].hasOwnProperty("o_vol") && keywordprod.graph.nodes[index].hasOwnProperty("t_vol")) {
                        const maxVal = Math.max(...keywordprod.intersectionChart.map((item) => item.vol)); // 주어진 값 중 가장 큰 값
                        const currentVal = Math.max(...[keywordprod.graph.nodes[index]["o_vol"], keywordprod.graph.nodes[index]["t_vol"]]);
                        keywordprod.graph.nodes[index].symSize = keywordprod.getNodeSize(calcReSetting.symSize, currentVal, maxVal);
                    } else if (keywordprod.graph.nodes[index].hasOwnProperty("o_vol")) {
                        const maxVal = Math.max(...keywordprod.intersectionChart.filter((item) => item.node_key == "keywdOne").map((item) => item.vol)); // 주어진 값 중 가장 큰 값
                        const currentVal = keywordprod.graph.nodes[index]["o_vol"];
                        keywordprod.graph.nodes[index].symSize = keywordprod.getNodeSize(calcReSetting.symSize, currentVal, maxVal);
                    } else if (keywordprod.graph.nodes[index].hasOwnProperty("t_vol")) {
                        const maxVal = Math.max(...keywordprod.intersectionChart.filter((item) => item.node_key == "keywdTwo").map((item) => item.vol)); // 주어진 값 중 가장 큰 값
                        const currentVal = keywordprod.graph.nodes[index]["t_vol"];
                        keywordprod.graph.nodes[index].symSize = keywordprod.getNodeSize(calcReSetting.symSize, currentVal, maxVal);
                    }
                }
            });
            // 데이터 바꿔치기
            const option = {
                tooltip: {
                    show: true,
                    formatter: function (params) {
                        let rtnMsg = `<div style="font-size:14px;color:#666;font-weight:400;line-height:1;text-align:left;margin:0;">${params.name}</div>`;
                        if ("o_vol" in params["data"]) {
                            rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#4285F4"};margin-right:5px;"></span><span>구글 검색량</span></p><span style="font-weight:900;float:right;">${addCommas(
                                params["data"]["o_vol"]
                            )}</span></div>`;
                        }
                        if ("o_rank" in params["data"]) {
                            rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#4285F4"};margin-right:5px;"></span><span>구글 키워드 랭킹</span></p><span style="font-weight:900;float:right;">${addCommas(
                                params["data"]["o_rank"]
                            )}</span></div>`;
                        }
                        if ("t_vol" in params["data"]) {
                            rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#00C43B"};margin-right:5px;"></span><span>네이버 검색량</span></p><span style="font-weight:900;float:right;">${addCommas(
                                params["data"]["t_vol"]
                            )}</span></div>`;
                        }
                        if ("t_rank" in params["data"]) {
                            rtnMsg += `<div style="margin: 10px 0 0;line-height:1;display:flex;justify-content:space-between;"><p style="margin:0 20px 0 0;"><span style="display:inline-block;width:10px;border-radius:50%;height:10px;background-color:${"#00C43B"};margin-right:5px;"></span><span>네이버 키워드 랭킹</span></p><span style="font-weight:900;float:right;">${addCommas(
                                params["data"]["t_rank"]
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
                            repulsion: calcReSetting.repul,
                        },
                    },
                ],
            };
            keywordprod.networkChartIntersection.setOption(option, true);
        }
    });
};

keywordprod.networkChartIntersection.on("click", function (params) {
    if (params.componentType === "series" && params.seriesType === "graph") {
        if (params.dataType === "node" && !["keywrd", "GOOGLE"].includes(params.data["name"])) {
            keywordprod.removeData = keywordprod.networkChartIntersection.getOption().series[0].data.filter((obj) => obj.id !== params.data["id"]);
                keywordprod.networkChartIntersection.setOption({
                series: [
                    {
                        type: "graph",
                        data: keywordprod.removeData,
                        links: keywordprod.networkChartIntersection.getOption().series[0].links,
                    },
                ],
            });
        }
    }
});

let resizeEvent;
window.addEventListener("resize", function () {
  // window의 크기가 변경된 후 500 밀리초 후에 실행될 코드 작성
  clearTimeout(resizeEvent);
  resizeEvent = setTimeout(function () {
    keywordprod.chartResize();
  }, 500);
});