// 先生・職員データ(学校生活ガイドブック P.104-105より)

const List<Map<String, String>> teacherData = [
  // 役職
  {"category": "役職", "name": "岡本 比呂志", "title": "学園長・理事長(創立者)", "dept": "", "photo": "assets/images/teachers/okamoto_hiroshi.png"},
  {"category": "役職", "name": "佐藤 直子", "title": "校長", "dept": "", "photo": "assets/images/teachers/sato_naoko.png"},
  {"category": "役職", "name": "増田 力", "title": "学園長補佐・総務部長", "dept": "", "photo": "assets/images/teachers/masuda.png"},
  {"category": "役職", "name": "花井 伸也", "title": "教育主幹", "dept": "", "photo": "assets/images/teachers/hanai.png"},
  {"category": "役職", "name": "渡邊 俊仁", "title": "副校長", "dept": "", "photo": "assets/images/teachers/watanabe.png"},
  {"category": "役職", "name": "坂本 裕子", "title": "副校長・就職部長", "dept": "", "photo": "assets/images/teachers/sakamoto.png"},
  // ビジネスカレッジ教員
  {"category": "ビジネスカレッジ教員", "name": "川原先生", "title": "教頭", "dept": "国際観光・通訳ガイド学科長", "photo": "assets/images/teachers/kawahara.png"},
  {"category": "ビジネスカレッジ教員", "name": "山口先生", "title": "入試センター部長", "dept": "国際観光・通訳ガイド学科", "photo": "assets/images/teachers/yamaguchi.png"},
  {"category": "ビジネスカレッジ教員", "name": "真田先生", "title": "教務課長", "dept": "ビジネス起業経営学科長", "photo": "assets/images/teachers/sanada.png"},
  {"category": "ビジネスカレッジ教員", "name": "小嶋先生", "title": "教務主任", "dept": "ビジネス起業経営学科", "photo": "assets/images/teachers/kojima_b.png"},
  {"category": "ビジネスカレッジ教員", "name": "後藤先生", "title": "", "dept": "営業マネジメント学科長", "photo": "assets/images/teachers/goto.png"},
  {"category": "ビジネスカレッジ教員", "name": "杉本先生", "title": "", "dept": "営業マネジメント学科", "photo": "assets/images/teachers/sugimoto.png"},
  {"category": "ビジネスカレッジ教員", "name": "横川先生", "title": "", "dept": "国際観光・通訳ガイド学科", "photo": "assets/images/teachers/yokokawa.png"},
  // ITカレッジ教員
  {"category": "ITカレッジ教員", "name": "小笠原先生", "title": "教頭", "dept": "AIデザイン学科", "photo": "assets/images/teachers/ogasawara.png"},
  {"category": "ITカレッジ教員", "name": "北村先生", "title": "ITカレッジ教務部長", "dept": "生成AI・デジタルクリエイター学科", "photo": "assets/images/teachers/kitamura.png"},
  {"category": "ITカレッジ教員", "name": "柳谷先生", "title": "広報募集部長", "dept": "アプリ・Web制作学科", "photo": "assets/images/teachers/yanagiya.png"},
  {"category": "ITカレッジ教員", "name": "小島先生", "title": "", "dept": "生成AI・デジタルクリエイター学科長", "photo": "assets/images/teachers/kojima_it.png"},
  {"category": "ITカレッジ教員", "name": "小松先生", "title": "", "dept": "電子機器組込みソフトウェア学科長", "photo": "assets/images/teachers/komatsu.png"},
  {"category": "ITカレッジ教員", "name": "石田先生", "title": "教務主任", "dept": "電子機器組込みソフトウェア学科", "photo": "assets/images/teachers/ishida.png"},
  {"category": "ITカレッジ教員", "name": "岡先生", "title": "", "dept": "アプリ・Web制作学科", "photo": "assets/images/teachers/oka.png"},
  {"category": "ITカレッジ教員", "name": "初野先生", "title": "", "dept": "アプリ・Web制作学科長", "photo": "assets/images/teachers/hatsuno.png"},
  {"category": "ITカレッジ教員", "name": "熊谷先生", "title": "", "dept": "AIデザイン学科", "photo": "assets/images/teachers/kumagai.png"},
  {"category": "ITカレッジ教員", "name": "山崎先生", "title": "", "dept": "AIデザイン学科長", "photo": "assets/images/teachers/yamazaki.png"},
  {"category": "ITカレッジ教員", "name": "丸山先生", "title": "AI教育特任教授", "dept": "", "photo": "assets/images/teachers/maruyama.png"},
  {"category": "ITカレッジ教員", "name": "岡本先生", "title": "AI教育特任講師", "dept": "", "photo": "assets/images/teachers/okamoto_ai.png"},
  // 事務部
  {"category": "事務部", "name": "下唐湊先生", "title": "管理部長", "dept": "", "photo": "assets/images/teachers/shimotoso.png"},
  {"category": "事務部", "name": "兼松先生", "title": "就職部・総務部長代理 管理部長代理", "dept": "", "photo": "assets/images/teachers/kanematsu.png"},
  {"category": "事務部", "name": "佐藤 光将先生", "title": "広報募集部", "dept": "", "photo": "assets/images/teachers/sato_terumasa.png"},
  {"category": "事務部", "name": "KIEN先生", "title": "学生課長", "dept": "", "photo": "assets/images/teachers/kien.png"},
  {"category": "事務部", "name": "牧先生", "title": "事務", "dept": "", "photo": "assets/images/teachers/maki.png"},
  {"category": "事務部", "name": "馬橋先生", "title": "事務", "dept": "", "photo": "assets/images/teachers/umahashi.png"},
  {"category": "事務部", "name": "松永先生", "title": "事務", "dept": "", "photo": "assets/images/teachers/matsunaga.png"},
];