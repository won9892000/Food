window.RecommendEngine = (function () {
  "use strict";

  function getHistory() {
    try {
      return JSON.parse(localStorage.getItem("food_history") || "[]");
    } catch (_) {
      return [];
    }
  }

  function saveChoice(foodId) {
    var history = getHistory();
    history.unshift({ id: foodId, date: new Date().toISOString() });
    if (history.length > 100) history = history.slice(0, 100);
    localStorage.setItem("food_history", JSON.stringify(history));
  }

  function recentFoodIds(days) {
    var cutoff = Date.now() - days * 86400000;
    return getHistory()
      .filter(function (h) { return new Date(h.date).getTime() > cutoff; })
      .map(function (h) { return h.id; });
  }

  function recommend(answers, excludeIds) {
    excludeIds = excludeIds || [];
    var foods = window.FOODS.slice();

    var avoidList = answers.avoid || [];
    var recent3 = recentFoodIds(3);

    var filtered = foods.filter(function (f) {
      if (excludeIds.indexOf(f.id) !== -1) return false;

      for (var i = 0; i < avoidList.length; i++) {
        if (f.avoid_tags.indexOf(avoidList[i]) !== -1) return false;
      }

      if (answers.meal_time && f.meal_time.indexOf(answers.meal_time) === -1) return false;

      if (answers.spicy === 0 && f.spicy >= 2) return false;

      return true;
    });

    var scored = filtered.map(function (f) {
      var score = 0;

      if (typeof answers.spicy === "number") {
        var diff = Math.abs(f.spicy - answers.spicy);
        score += (3 - diff) * 2.0;
      }

      if (answers.carb_base && answers.carb_base !== "any") {
        if (f.carb_base === answers.carb_base) score += 3 * 1.2;
        else if (f.carb_base === "none") score += 1;
      }

      if (answers.health) {
        if (f.health === answers.health) score += 2 * 1.0;
      }

      if (typeof answers.greasy === "number") {
        var gDiff = Math.abs(f.greasy - answers.greasy);
        score += (2 - gDiff) * 1.0;
      }

      if (answers.soup === "Y" && f.soup === "Y") score += 2;
      if (answers.soup === "N" && f.soup === "N") score += 1;

      if (answers.temperature) {
        if (f.temperature === answers.temperature) score += 1.5;
        else if (f.temperature === "any") score += 0.5;
      }

      if (answers.mood && f.mood_fit.indexOf(answers.mood) !== -1) score += 2;

      if (answers.time_budget === "10" && f.time_budget === "10") score += 1.5;

      if (recent3.indexOf(f.id) !== -1) score -= 5;

      return { food: f, score: score };
    });

    scored.sort(function (a, b) { return b.score - a.score; });

    var topN = scored.slice(0, Math.min(10, scored.length));

    var picked = weightedRandomPick(topN, 3);

    return picked.map(function (p) {
      return {
        food: p.food,
        score: p.score,
        reason: buildReason(p.food, answers)
      };
    });
  }

  function weightedRandomPick(items, count) {
    if (items.length <= count) return items.slice();

    var minScore = items[items.length - 1].score;
    var shifted = items.map(function (it) {
      return { food: it.food, score: it.score, w: Math.max(it.score - minScore + 1, 0.1) };
    });

    var results = [];
    var used = {};
    for (var i = 0; i < count; i++) {
      var totalW = 0;
      for (var j = 0; j < shifted.length; j++) {
        if (!used[shifted[j].food.id]) totalW += shifted[j].w;
      }
      var r = Math.random() * totalW;
      var cumul = 0;
      for (var k = 0; k < shifted.length; k++) {
        if (used[shifted[k].food.id]) continue;
        cumul += shifted[k].w;
        if (cumul >= r) {
          results.push(shifted[k]);
          used[shifted[k].food.id] = true;
          break;
        }
      }
    }
    return results;
  }

  function buildReason(food, answers) {
    var parts = [];

    if (answers.temperature === "hot" && food.temperature === "hot") parts.push("따뜻한");
    if (answers.temperature === "cold" && food.temperature === "cold") parts.push("시원한");
    if (answers.soup === "Y" && food.soup === "Y") parts.push("국물 있는");
    if (answers.health === "light" && food.health === "light") parts.push("가벼운");
    if (answers.health === "heavy" && food.health === "heavy") parts.push("든든한");
    if (answers.mood === "스트레스" && food.mood_fit.indexOf("스트레스") !== -1) parts.push("스트레스 해소에 딱인");
    if (answers.mood === "힐링" && food.mood_fit.indexOf("힐링") !== -1) parts.push("힐링에 좋은");

    if (parts.length === 0) {
      var defaults = [
        "오늘 딱 맞는",
        "취향에 어울리는",
        "이런 날 생각나는"
      ];
      parts.push(defaults[Math.floor(Math.random() * defaults.length)]);
    }

    return parts.join(" ") + " 메뉴예요! 😋";
  }

  return {
    recommend: recommend,
    saveChoice: saveChoice,
    getHistory: getHistory
  };
})();
