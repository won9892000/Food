window.QUESTIONS = [
  {
    id: "q1",
    text: "지금은?",
    tag: "meal_time",
    options: [
      { label: "점심 🍱", value: "lunch",  tags: { meal_time: "lunch" } },
      { label: "저녁 🌙", value: "dinner", tags: { meal_time: "dinner" } },
      { label: "야식 🌃", value: "late",   tags: { meal_time: "late" } }
    ]
  },
  {
    id: "q2",
    text: "오늘 기분은?",
    tag: "mood",
    options: [
      { label: "스트레스 🤯",  value: "stress",  tags: { mood: "스트레스", spicy: 1, greasy: 1 } },
      { label: "힐링 🌿",      value: "healing", tags: { mood: "힐링", health_pref: "light", soup_pref: 1 } },
      { label: "기분좋음 😆",  value: "happy",   tags: { mood: "기분좋음", adventure: 1 } },
      { label: "귀찮음 😵‍💫",   value: "lazy",    tags: { mood: "귀찮음", time_budget: "10" } }
    ]
  },
  {
    id: "q3",
    text: "매운 거 가능?",
    tag: "spicy",
    options: [
      { label: "못먹음 🚫🌶",    value: 0, tags: { spicy: 0 } },
      { label: "약간 🌶",        value: 1, tags: { spicy: 1 } },
      { label: "매운거 좋아 🌶🌶",  value: 2, tags: { spicy: 2 } },
      { label: "매우 좋아 🌶🌶🌶", value: 3, tags: { spicy: 3 } }
    ]
  },
  {
    id: "q4",
    text: "국물 땡겨?",
    tag: "soup",
    options: [
      { label: "뜨끈 국물 최고 🍲",  value: "hot_soup",  tags: { soup: "Y", temperature: "hot" } },
      { label: "국물 없어도 됨 🍛",  value: "no_soup",   tags: { soup: "N" } },
      { label: "차가운 것도 좋음 🧊", value: "cold",      tags: { temperature: "cold" } }
    ]
  },
  {
    id: "q5",
    text: "밥 vs 면 vs 빵?",
    tag: "carb_base",
    options: [
      { label: "밥 🍚",       value: "rice",   tags: { carb_base: "rice" } },
      { label: "면 🍜",       value: "noodle", tags: { carb_base: "noodle" } },
      { label: "빵/샌드 🥪",  value: "bread",  tags: { carb_base: "bread" } },
      { label: "상관없음 🎲", value: "any",    tags: {} }
    ]
  },
  {
    id: "q6",
    text: "오늘은 든든 vs 가볍게?",
    tag: "health",
    options: [
      { label: "든든하게 💪", value: "heavy",    tags: { health: "heavy" } },
      { label: "가볍게 🪽",   value: "light",    tags: { health: "light" } },
      { label: "균형 ⚖️",    value: "balanced", tags: { health: "balanced" } }
    ]
  },
  {
    id: "q7",
    text: "기름진 건?",
    tag: "greasy",
    options: [
      { label: "담백이 좋아 🥗",   value: -1, tags: { greasy: -1 } },
      { label: "보통 🍛",          value: 0,  tags: { greasy: 0 } },
      { label: "기름져도 좋아 🍗", value: 1,  tags: { greasy: 1 } }
    ]
  },
  {
    id: "q8",
    text: "못 먹는 재료 있어?",
    tag: "avoid",
    multi: true,
    options: [
      { label: "해산물X 🦐🚫", value: "seafood", tags: { avoid: "seafood" } },
      { label: "유제품X 🥛🚫", value: "dairy",   tags: { avoid: "dairy" } },
      { label: "고기X 🥩🚫",   value: "meat",    tags: { avoid: "meat" } },
      { label: "밀가루X 🍞🚫", value: "gluten",  tags: { avoid: "gluten" } },
      { label: "없음 ✅",      value: "none",    tags: {} }
    ]
  }
];
