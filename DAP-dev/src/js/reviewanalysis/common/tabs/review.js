let reviewAnalysisReview = {};
reviewAnalysisReview.onloadStatus = false; // 화면 로딩 상태

reviewAnalysisReview.setDataBinding = function () {
  if (Object.keys(reviewAnalysisReview.topicRadarTpicType).length > 0) {
    reviewAnalysisReview.topicRadarTpicTypeUpdate();
  }
  if (Object.keys(reviewAnalysisReview.viewReviewBarProd).length > 0) {
    reviewAnalysisReview.viewReviewBarProdUpdate();
  }
};

reviewAnalysisReview.topicRadarTpicTypeUpdate = function () {
  if (reviewAnalysisReview.reviewGridSearchTopic) {
    let rawData = reviewAnalysisReview.topicRadarTpicType;
    let dataList = [];
    rawData.forEach((data) => {
      dataList.push({ value: data.tpic_type, label: data.tpic_type });
    });
    reviewAnalysisReview.reviewGridSearchTopic.setChoices(dataList, "value", "label", true);
    reviewAnalysisReview.reviewGridSearchTopic.setChoiceByValue("전체");
  }
};

// chat gpt 라인 이름 보여주기 
const reviewDisplayGPTView = document.getElementById("reviewGptDisplay");
reviewDisplayGPTView.innerText = "Chat GPT의 해석결과를 알고 싶으시면 버튼을 클릭하세요";


reviewAnalysisReview.topicRadarTpicTypeSubUpdate = function () {
  if (reviewAnalysisReview.reviewGridSearchDetailTopic) {
    let rawData = reviewAnalysisReview.topicRadarTpicTypeSub;
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
    reviewAnalysisReview.reviewGridSearchDetailTopic.setChoices(dataList, "value", "label", true);
  }
};

reviewAnalysisReview.viewReviewBarProdUpdate = function () {
  if (reviewAnalysisReview.reviewGridSearchProd) {
    let rawData = reviewAnalysisReview.viewReviewBarProd;
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
    reviewAnalysisReview.reviewGridSearchProd.setChoices(dataList, "value", "label", true);
  }
};

reviewAnalysisReview.reviewUpdate = function () {
  let rawData = reviewAnalysisReview.review;
  let keysToExtract = ["prod_nm", "tpic_item", "revw_chn", "revw_eng", "revw_kor", "revw_type"];
  let filterData = [];
  for (var i = 0; i < rawData.length; i++) {
    filterData.push(keysToExtract.map((key) => rawData[i][key]));
  }
  reviewAnalysisReview.reviewListGrid.updateConfig({ data: filterData }).forceRender();
};

/* 리뷰 리스트 */
if (document.getElementById("reviewList")) {
  reviewAnalysisReview.reviewListGrid = new gridjs.Grid({
    sort: true,
    columns: [
      {
        name: "제품명",
        width: "350px",
      },
      {
        name: "토픽",
        width: "200px",
      },
      {
        name: "중국어",
        width: "300px",
      },
      {
        name: "영어",
        width: "300px",
      },
      {
        name: "한국어",
        width: "300px",
      },
      {
        name: "긍·부정",
        width: "100px",
      },
    ],
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
    language,
    pagination: {
      limit: 10,
    },
    data: [],
  }).render(document.getElementById("reviewList"));
}
reviewAnalysisReview.onLoadEvent = function (initData) {
  flatpickr("#reviewViewer", {
    locale: "ko", // locale for this instance only
    defaultDate: `${initData.fr_dt} ~ ${initData.to_dt}`,
    mode: "range",
  });

  /* 토픽 옵션 */
  const topicOption = {
    searchEnabled: false,
    shouldSort: false,
    placeholder: true,
    placeholderValue: "토픽을 선택하세요.  ",
  };

  /* 세부 토픽 옵션 */
  const topicSubOption = {
    searchEnabled: false,
    shouldSort: false,
    removeItemButton: true,
    classNames: {
      removeButton: "remove",
    },
    placeholder: true,
    placeholderValue: "세부 토픽을 선택하세요.  ",
  };

  /* 제품 옵션 */
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
  /* 제품 옵션 */
  const defaultOption = {
    searchEnabled: false,
    shouldSort: false,
  };

  const reviewGridSearchTopic = document.getElementById("reviewGridSearchTopic");
  const reviewGridSearchDetailTopic = document.getElementById("reviewGridSearchDetailTopic");
  const reviewGridSearchProd = document.getElementById("reviewGridSearchProd");
  const choicesCmTrendSelect = document.getElementById("choicesCmTrendSelect");

  if (reviewGridSearchTopic) {
    reviewGridSearchTopic.addEventListener("change", function (e) {
      reviewAnalysisReview.reviewGridSearchDetailTopic.removeActiveItems();
      if (e.target.value != "전체") {
        reviewAnalysisReview.reviewGridSearchDetailTopic.enable();
        let dataList = ["topicRadarTpicTypeSub" /* 3. 토픽별/제품별 히트맵 overview - 토픽 세부주제 선택 SQL */];
        let params = {
          params: { TPIC_TYPE: `'${reviewGridSearchTopic.value}'` },
          menu: "reviewanalysis/common",
          tab: "review",
          dataList: dataList,
        };
        getData(params, function (data) {
          reviewAnalysisReview.topicRadarTpicTypeSub = {};
          /* 3. 토픽별/제품별 히트맵 overview - 토픽 세부주제 선택 SQL */
          if (data["topicRadarTpicTypeSub"] != undefined) {
            reviewAnalysisReview.topicRadarTpicTypeSub = data["topicRadarTpicTypeSub"];
            reviewAnalysisReview.topicRadarTpicTypeSubUpdate();
          }
        });
      } else {
        reviewAnalysisReview.reviewGridSearchDetailTopic.disable();
      }
    });
  }

  if (!reviewAnalysisReview.reviewGridSearchTopic && reviewGridSearchTopic) {
    reviewAnalysisReview.reviewGridSearchTopic = new Choices(reviewGridSearchTopic, topicOption);
  }
  if (!reviewAnalysisReview.reviewGridSearchDetailTopic && reviewGridSearchDetailTopic) {
    reviewAnalysisReview.reviewGridSearchDetailTopic = new Choices(reviewGridSearchDetailTopic, topicSubOption);
    reviewAnalysisReview.reviewGridSearchDetailTopic.disable();
  }
  if (!reviewAnalysisReview.reviewGridSearchProd && reviewGridSearchProd) {
    reviewAnalysisReview.reviewGridSearchProd = new Choices(reviewGridSearchProd, prodOption);
  }
  if (!reviewAnalysisReview.choicesCmTrendSelect && choicesCmTrendSelect) {
    reviewAnalysisReview.choicesCmTrendSelect = new Choices(choicesCmTrendSelect, defaultOption);
  }

  let reviewDownload = document.querySelector(".reviewDownload");
  if (reviewDownload) {
    reviewDownload.addEventListener("click", function () {
      let rawData = reviewAnalysisReview.review;
      if (!rawData || rawData.length == 0) {
        dapAlert("다운로드할 데이터가 없습니다.");
        return false;
      } else {
        let keysToExtract = ["prod_nm", "tpic_item", "revw_chn", "revw_eng", "revw_kor", "revw_type"];
        let filterData = [];
        for (var i = 0; i < rawData.length; i++) {
          filterData.push(keysToExtract.map((key) => rawData[i][key]));
        }
        const keyMap = {
          0: "제품명",
          1: "토픽",
          2: "중국어",
          3: "영어",
          4: "한국어",
          5: "긍·부정",
        };
        const result = filterData.map((arr) => {
          return arr.reduce((obj, val, i) => {
            obj[keyMap[i]] = val;
            return obj;
          }, {});
        });
        // 엑셀 워크북 생성
        const wb = XLSX.utils.book_new();
        // 시트 생성
        const ws = XLSX.utils.json_to_sheet(result);
        // 워크북에 시트 추가
        XLSX.utils.book_append_sheet(wb, ws, "Sheet1");
        // 엑셀 파일 다운로드
        XLSX.writeFile(wb, `${fileNameToTime("review")}.xlsx`);
      }
    });
  }
  let reviewGridSearchBtn = document.getElementById("reviewGridSearchBtn");
  if (reviewGridSearchBtn) {
    reviewGridSearchBtn.addEventListener("click", function () {
      let topic = reviewAnalysisReview.reviewGridSearchTopic.getValue();
      let topicSub = reviewAnalysisReview.reviewGridSearchDetailTopic.getValue();
      let prodId = reviewAnalysisReview.reviewGridSearchProd.getValue();

      let topicValue = topic.value;
      let topicItemValue = "";
      let prodValue = "";

      if (topicValue === "토픽선택" && topicSub.length === 0) {
        dapAlert("세부 토픽을 선택해 주세요.");
        return false;
      }

      if (prodId.length == 0) {
        dapAlert("제품을 선택해 주세요.");
        return false;
      }

      topicItemValue = topicSub.map((item) => item.value).join(",");
      prodValue = prodId.map((item) => item.value).join(",");

      let dataList = ["review"];
      const datePicker = document.getElementById("reviewViewer");
      const choicesCmTrend = document.getElementById("choicesCmTrendSelect");
      let params = {
        params: {
          FR_DT: `'${datePicker.value.substring(0, 10)}'`,
          TO_DT: `'${datePicker.value.slice(-10)}'`,
          TPIC_TYPE: `'${topicValue}'`,
          REVW_TYPE: `'${choicesCmTrend.value}'`,
          TPIC_ITEM: `'${topicItemValue}'`,
          PROD_ID: `'${prodValue}'`,
        },
        menu: "reviewanalysis/common",
        tab: "review",
        dataList: dataList,
      };

      getData(params, function (data) {
        reviewAnalysisReview.review = {};
        if (data["review"] != undefined) {
          reviewAnalysisReview.review = data["review"];
          reviewAnalysisReview.reviewUpdate();
        }
      });
    });
  }


  let dataList = ["topicRadarTpicType" /* 토픽 대주제 선택 SQL */, "viewReviewBarProd" /* 제품 선택 SQL */];

  let params = {
    params: {},
    menu: "reviewanalysis/common",
    tab: "review",
    dataList: dataList,
  };

  getData(params, function (data) {
    window.scrollTo(0, 0);
    Object.keys(data).forEach((key) => {
      reviewAnalysisReview[key] = data[key];
    });
    reviewAnalysisReview.setDataBinding();
  });

  reviewAnalysisReview.onloadStatus = true; // 화면 로딩 상태
};


let reviewChatGPTSearchBtn = document.getElementById("reviewChatGPTSearchBtn");
  if (reviewChatGPTSearchBtn) {
    reviewChatGPTSearchBtn.addEventListener("click", function () {
      let topic = reviewAnalysisReview.reviewGridSearchTopic.getValue();
      let topicSub = reviewAnalysisReview.reviewGridSearchDetailTopic.getValue();
      let prodId = reviewAnalysisReview.reviewGridSearchProd.getValue();

      let topicValue = topic.value;
      let topicItemValue = "";
      let prodValue = "";
      console.log('product 이름 : ', prodValue);
      if (topicValue === "토픽선택" && topicSub.length === 0) {
        dapAlert("세부 토픽을 선택해 주세요.");
        return false;
      }

      if (prodId.length == 0) {
        dapAlert("제품을 선택해 주세요.");
        return false;
      }

      topicItemValue = topicSub.map((item) => item.value).join(",");
      prodValue = prodId.map((item) => item.value).join(",");

      let dataList = ["review"];
      const datePicker = document.getElementById("reviewViewer");
      const choicesCmTrend = document.getElementById("choicesCmTrendSelect");
      let url = '/reviewanalysis/getReviewSummaryChatGpt'
      let params = {
        params: {
          FR_DT: `'${datePicker.value.substring(0, 10)}'`,
          TO_DT: `'${datePicker.value.slice(-10)}'`,
          TPIC_TYPE: `'${topicValue}'`,
          REVW_TYPE: `'${choicesCmTrend.value}'`,
          TPIC_ITEM: `'${topicItemValue}'`,
          PROD_ID: `'${prodValue}'`,
        },
        menu: "reviewanalysis/common",
        tab: "review",
        dataList: dataList,
      };

      sendAjaxRequest(url, params, reviewGptCommentBind);
      // getData(params, function (data) {
      //   reviewAnalysisReview.review = {};
      //   if (data["review"] != undefined) {
      //     reviewAnalysisReview.review = data["review"];
      //     // sendAjaxRequest(url, params, setGptCommentBind)
      //   }
      // });
    });
  }


function reviewGptCommentBind(data) {
  console.log("gogogo");
  const element = document.getElementById("reviewGptDisplay");
  if (data.gptResponse) {
    element.innerHTML = data.gptResponse;
  } else {
    element.innerText = "조회 오류입니다.";
  }
}