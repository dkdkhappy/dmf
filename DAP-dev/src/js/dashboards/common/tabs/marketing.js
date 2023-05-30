let mktg = {};
mktg.onloadStatus = false; // 화면 로딩 상태
mktg.onLoadEvent = function () {
  var chart = echarts.init(document.getElementById("word-cloud"));

  var option = {
    tooltip: {},
    series: [
      {
        type: "wordCloud",
        gridSize: 2,
        sizeRange: [12, 50],
        rotationRange: [-90, 90],
        shape: "pentagon",
        width: 600,
        height: 400,
        drawOutOfBound: true,
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
        data: [
          {
            name: "Sam S Club",
            value: 10000,
            textStyle: {
              color: "black",
            },
            emphasis: {
              textStyle: {
                color: "red",
              },
            },
          },
          {
            name: "Macys",
            value: 6181,
          },
          {
            name: "Amy Schumer",
            value: 4386,
          },
          {
            name: "Jurassic World",
            value: 4055,
          },
          {
            name: "Charter Communications",
            value: 2467,
          },
          {
            name: "Chick Fil A",
            value: 2244,
          },
          {
            name: "Planet Fitness",
            value: 1898,
          },
          {
            name: "Pitch Perfect",
            value: 1484,
          },
          {
            name: "Express",
            value: 1112,
          },
          {
            name: "Home",
            value: 965,
          },
          {
            name: "Johnny Depp",
            value: 847,
          },
          {
            name: "Lena Dunham",
            value: 582,
          },
          {
            name: "Lewis Hamilton",
            value: 555,
          },
          {
            name: "KXAN",
            value: 550,
          },
          {
            name: "Mary Ellen Mark",
            value: 462,
          },
          {
            name: "Farrah Abraham",
            value: 366,
          },
          {
            name: "Rita Ora",
            value: 360,
          },
          {
            name: "Serena Williams",
            value: 282,
          },
          {
            name: "NCAA baseball tournament",
            value: 273,
          },
          {
            name: "Point Break",
            value: 265,
          },
        ],
      },
    ],
  };

  chart.setOption(option);

  // Network Chart 데이터
  var graph = {
    nodes: [
      { id: 0, name: "Google", symbolSize: 100 },
      { id: 1, name: "Naver", symbolSize: 100 },
      { id: 2, name: "2", symbolSize: 30 },
      { id: 3, name: "3", symbolSize: 20 },
      { id: 4, name: "4", symbolSize: 10 },
    ],
    edges: [
      { source: 0, target: 1 },
      { source: 0, target: 2 },
      { source: 0, target: 3 },
      { source: 0, target: 4 },
      { source: 1, target: 2 },
      { source: 1, target: 3 },
      { source: 1, target: 4 },
      { source: 2, target: 3 },
      { source: 2, target: 4 },
      { source: 3, target: 4 },
    ],
  };

  // Network Chart 설정
  var graph_option = {
    title: {
      text: "Network Chart Example",
    },
    tooltip: {},
    series: [
      {
        type: "graph",
        layout: "force",
        symbolSize: 50,
        roam: true,
        label: {
          show: true,
        },
        force: {
          repulsion: 200,
        },
        data: graph.nodes,
        links: graph.edges,
      },
    ],
  };

  // Network Chart를 표시할 div 요소 가져오기
  var chartDom = document.getElementById("network-chart");

  // ECharts 객체 생성
  var network_myChart = echarts.init(chartDom);

  // 그래프 그리기
  network_myChart.setOption(graph_option);

  window.onresize = chart.resize;
  mktg.onloadStatus = true; // 화면 로딩 상태
};
