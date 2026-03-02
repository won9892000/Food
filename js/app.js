(function () {
  "use strict";

  var answers = {};
  var currentQ = 0;
  var results = [];
  var excludeIds = [];
  var multiSelected = [];

  var screens = {
    home: document.getElementById("screen-home"),
    question: document.getElementById("screen-question"),
    result: document.getElementById("screen-result"),
    history: document.getElementById("screen-history")
  };

  function showScreen(name) {
    Object.keys(screens).forEach(function (k) {
      screens[k].classList.toggle("active", k === name);
    });
  }

  function startQuiz() {
    answers = {};
    currentQ = 0;
    excludeIds = [];
    multiSelected = [];
    renderQuestion();
    showScreen("question");
  }

  function renderQuestion() {
    var q = window.QUESTIONS[currentQ];
    var total = window.QUESTIONS.length;

    document.getElementById("q-progress").textContent = (currentQ + 1) + " / " + total;
    document.getElementById("progress-fill").style.width = ((currentQ + 1) / total * 100) + "%";

    document.getElementById("q-text").textContent = q.text;

    var character = document.getElementById("q-character");
    var faces = ["😊", "🤔", "😋", "😄"];
    character.textContent = faces[currentQ % faces.length];

    var optionsEl = document.getElementById("q-options");
    optionsEl.innerHTML = "";

    if (q.multi) {
      multiSelected = [];
      q.options.forEach(function (opt) {
        var btn = document.createElement("button");
        btn.className = "option-btn";
        btn.textContent = opt.label;
        btn.addEventListener("click", function () {
          if (opt.value === "none") {
            multiSelected = [];
            var allBtns = optionsEl.querySelectorAll(".option-btn");
            allBtns.forEach(function (b) { b.classList.remove("selected"); });
            btn.classList.add("selected");
          } else {
            var noneBtn = optionsEl.querySelector(".option-btn.selected");
            if (noneBtn && noneBtn.textContent.indexOf("없음") !== -1) {
              noneBtn.classList.remove("selected");
            }
            var idx = multiSelected.indexOf(opt.value);
            if (idx === -1) {
              multiSelected.push(opt.value);
              btn.classList.add("selected");
            } else {
              multiSelected.splice(idx, 1);
              btn.classList.remove("selected");
            }
          }
        });
        optionsEl.appendChild(btn);
      });

      var nextBtn = document.createElement("button");
      nextBtn.className = "next-btn";
      nextBtn.textContent = "다음 ➡️";
      nextBtn.addEventListener("click", function () {
        answers.avoid = multiSelected;
        showResults();
      });
      optionsEl.appendChild(nextBtn);
    } else {
      q.options.forEach(function (opt) {
        var btn = document.createElement("button");
        btn.className = "option-btn";
        btn.textContent = opt.label;
        btn.addEventListener("click", function () {
          applyTags(opt.tags);
          currentQ++;
          if (currentQ < window.QUESTIONS.length) {
            renderQuestion();
          } else {
            showResults();
          }
        });
        optionsEl.appendChild(btn);
      });
    }
  }

  function applyTags(tags) {
    Object.keys(tags).forEach(function (key) {
      answers[key] = tags[key];
    });
  }

  function showResults() {
    results = window.RecommendEngine.recommend(answers, excludeIds);
    renderResults();
    showScreen("result");
  }

  function renderResults() {
    var container = document.getElementById("result-cards");
    container.innerHTML = "";

    var reasonLine = document.getElementById("result-reason");
    var reasons = [
      "오늘은 이런 메뉴 어때요? 🍽️",
      "딱 맞는 메뉴를 찾았어요! ✨",
      "이 중에서 골라보세요! 😊"
    ];
    reasonLine.textContent = reasons[Math.floor(Math.random() * reasons.length)];

    results.forEach(function (r, i) {
      var card = document.createElement("div");
      card.className = "food-card";
      card.innerHTML =
        '<div class="food-emoji">' + r.food.emoji + '</div>' +
        '<div class="food-name">' + r.food.name + '</div>' +
        '<div class="food-reason">' + r.reason + '</div>' +
        '<div class="food-meta">' +
          '<span>💰 ' + formatBudget(r.food.budget_band) + '</span>' +
          '<span>⏱ ' + formatTime(r.food.time_budget) + '</span>' +
        '</div>' +
        '<div class="food-actions">' +
          '<button class="btn-choose" data-id="' + r.food.id + '">이거 먹을래! ✅</button>' +
          '<button class="btn-exclude" data-id="' + r.food.id + '">다른 거 🔄</button>' +
        '</div>';
      container.appendChild(card);
    });

    container.querySelectorAll(".btn-choose").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var fid = parseInt(btn.getAttribute("data-id"));
        window.RecommendEngine.saveChoice(fid);
        var food = window.FOODS.find(function (f) { return f.id === fid; });
        showConfirmation(food);
      });
    });

    container.querySelectorAll(".btn-exclude").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var fid = parseInt(btn.getAttribute("data-id"));
        excludeIds.push(fid);
        showResults();
      });
    });
  }

  function showConfirmation(food) {
    var container = document.getElementById("result-cards");
    container.innerHTML =
      '<div class="confirmation">' +
        '<div class="confirm-emoji">🎉</div>' +
        '<div class="confirm-text">오늘은 <strong>' + food.emoji + ' ' + food.name + '</strong>!</div>' +
        '<div class="confirm-sub">맛있게 드세요~ 😋</div>' +
      '</div>';
    document.getElementById("result-reason").textContent = "";

    document.getElementById("btn-retry").style.display = "none";
    var backBtn = document.createElement("button");
    backBtn.className = "primary-btn";
    backBtn.textContent = "홈으로 🏠";
    backBtn.addEventListener("click", function () {
      document.getElementById("btn-retry").style.display = "";
      showScreen("home");
    });
    container.appendChild(backBtn);
  }

  function formatBudget(band) {
    if (band === "any") return "가격 다양";
    return parseInt(band).toLocaleString() + "원 이하";
  }

  function formatTime(t) {
    if (t === "any") return "여유있게";
    return t + "분 이내";
  }

  function showHistory() {
    var history = window.RecommendEngine.getHistory();
    var container = document.getElementById("history-list");
    container.innerHTML = "";

    if (history.length === 0) {
      container.innerHTML = '<div class="empty-history">아직 선택한 음식이 없어요 🍽️</div>';
      showScreen("history");
      return;
    }

    history.forEach(function (h) {
      var food = window.FOODS.find(function (f) { return f.id === h.id; });
      if (!food) return;
      var date = new Date(h.date);
      var dateStr = (date.getMonth() + 1) + "/" + date.getDate() + " " +
        String(date.getHours()).padStart(2, "0") + ":" + String(date.getMinutes()).padStart(2, "0");

      var item = document.createElement("div");
      item.className = "history-item";
      item.innerHTML =
        '<span class="history-emoji">' + food.emoji + '</span>' +
        '<span class="history-name">' + food.name + '</span>' +
        '<span class="history-date">' + dateStr + '</span>';
      container.appendChild(item);
    });

    showScreen("history");
  }

  document.getElementById("btn-start").addEventListener("click", startQuiz);
  document.getElementById("btn-history").addEventListener("click", showHistory);
  document.getElementById("btn-retry").addEventListener("click", function () {
    excludeIds = excludeIds.concat(results.map(function (r) { return r.food.id; }));
    showResults();
  });
  document.getElementById("btn-back-home").addEventListener("click", function () {
    showScreen("home");
  });
  document.getElementById("btn-history-back").addEventListener("click", function () {
    showScreen("home");
  });

  showScreen("home");
})();
