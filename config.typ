#import "lib/typ2html/typ2html.typ" : *
#import "lib/typ2html/sys-input.typ" : query-input

#let current-file-type = str(query-input("file-type", default: "pages"))
#let current-page-path = str(query-input("page-path", default: "")).trim("/")
#let current-source-prefix = if current-file-type == "posts" { "posts" } else { "pages" }
#let current-source-path = if current-page-path == "" {
  current-source-prefix
} else {
  current-source-prefix + "/" + current-page-path
} + "/index.typ"

#let footer-links = (
  ("https://www.luogu.com.cn/user/60864", "洛谷", "brands/luogu.ico"),
  ("https://codeforces.com/profile/tiger2005", "Codeforces", "brands/codeforces.png"),
  ("https://atcoder.jp/users/tiger2005", "AtCoder", "brands/atcoder.png"),
  ("https://loj.ac/u/tiger2005", "LibreOJ", "brands/libreoj.ico"),
  ("https://uoj.ac/user/profile/tiger2005", "UOJ", "brands/uoj.png"),
  ("https://github.com/tiger2005", "GitHub", "brands/github.svg"),
  ("https://www.zhihu.com/people/tiger2005", "知乎", "brands/zhihu.ico"),
  ("https://space.bilibili.com/350620554", "B 站", "brands/bilibili.png"),
  ("https://osu.ppy.sh/users/16296188", "osu!", "brands/osu.ico"),
  ("https://leetcode.cn/u/tiger2005/", "力扣", "brands/leetcode.ico"),
  ("https://www.nowcoder.com/users/79994129", "牛客", "brands/nowcoder.ico"),
)

#let footer-content = html-guard(() => {
  html.div(
    class: "footer-content",
    {
      html.div(class: "footer-flex-outer", {
        html.div(class: "footer-flex-block", {
          html.div(
            link("https://codeforces.com/profile/tiger2005")[Codeforces]
          )
          html.div(
            link("https://atcoder.jp/users/tiger2005")[AtCoder]
          )
          html.div(
            link("https://loj.ac/u/tiger2005")[LibreOJ]
          )
          html.div(
            link("https://uoj.ac/user/profile/tiger2005")[UOJ]
          )
          html.div(
            link("https://github.com/tiger2005")[GitHub]
          )
          html.div(
            link("https://osu.ppy.sh/users/16296188")[osu!]
          )
        })
        html.div(class: "footer-flex-block", {
          html.div(
            link("https://www.luogu.com.cn/user/60864")[洛谷]
          )
          html.div(
            link("https://www.zhihu.com/people/tiger2005")[知乎]
          )
          html.div(
            link("https://space.bilibili.com/350620554")[B 站]
          )
          html.div(
            link("https://leetcode.cn/u/tiger2005/")[力扣]
          )
          html.div(
            link("https://www.nowcoder.com/users/79994129")[牛客]
          )
        })
      })
      html.div(class: "footer-flex-block", {
        html.div({
          "本页由 "
          link("https://typst.app/")[Typst]
          " 于 " + datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日") + "生成。"
        })
        html.div({
          "本博客使用 "
          link("https://github.com/tiger2005/carbon-typst-blog")[Carbon Typst Blog]
          " 搭建。"
        })
        html.div({
          "本页面被访问了 "
          link("https://vercount.one/", {
            html.span(id: "vercount_value_page_pv", "...")
          })
          " 次。"
        })
        html.div(
          link("https://github.com/tiger2005/tiger2005-blog/blob/master/" + current-source-path)[查看本页源代码]
        )
        html.div(
          link("/rss.xml")[RSS 订阅]
        )
      })
    }
  )
})

#let tag-options = (
  "矩阵链乘积问题": ("preset": "blue", "icon": "/assets/icons/data-bin.svg"),
  "图论": ("preset": "cyan", "icon": "/assets/icons/concept.svg"),
  "数据结构": ("preset": "teal", "icon": "/assets/icons/parent-child.svg"),
  "数论": ("preset": "purple", "icon": "/assets/icons/calculation.svg"),
  "动态规划": ("preset": "magenta", "icon": "/assets/icons/app-connectivity.svg"),
  "线性代数": ("preset": "red", "icon": "/assets/icons/matrix.svg"),
  "字符串": ("preset": "green", "icon": "/assets/icons/array--strings.svg"),
  "模拟费用流": ("preset": "cyan", "icon": "/assets/icons/flow--modeler--reference.svg"),
  "Lean": ("preset": "purple", "icon": "/assets/icons/square-fill.svg"),
  "Typst": ("preset": "teal", "icon": "/assets/icons/pen.svg"),
  "CTF": ("preset": "green", "icon": "/assets/icons/flag.svg"),
  "NOI 系列真题": ("preset": "cool-gray", "icon": "/assets/icons/notebook.svg")
)

#let awards = (
  (date: "2026-04-26", place: "南阳", name: "第 11 届中国大学生程序设计竞赛总决赛", tier: "bronze", level: "铜牌", rank: 41, trophies: 0),
  (date: "2026-02-02", place: "杭州", name: "第 50 届 ICPC 国际大学生程序设计竞赛东亚区决赛", tier: "gold", level: "金牌", rank: 12, trophies: 0),
  (date: "2025-11-30", place: "重庆", name: "第 11 届 CCPC 中国大学生程序设计竞赛重庆站", tier: "gold", level: "金牌", rank: 4, trophies: 0),
  (date: "2025-11-09", place: "南京", name: "第 50 届 ICPC 国际大学生程序设计竞赛亚洲区域赛南京站", tier: "gold", level: "金牌", rank: 19, trophies: 0),
  (date: "2025-11-02", place: "武汉", name: "第 50 届 ICPC 国际大学生程序设计竞赛亚洲区域赛武汉站", tier: "gold", level: "季军", rank: 3, trophies: 1),
  (date: "2025-05-11", place: "广州", name: "第 10 届中国大学生程序设计竞赛总决赛", tier: "gold", level: "金牌", rank: 8, trophies: 0),
  (date: "2024-12-28", place: "西安", name: "第 49 届 ICPC 国际大学生程序设计竞赛东亚区决赛", tier: "gold", level: "金牌", rank: 13, trophies: 0),
  (date: "2024-11-17", place: "上海", name: "第 49 届 ICPC 国际大学生程序设计竞赛亚洲区域赛上海站", tier: "gold", level: "季军", rank: 5, trophies: 1),
  (date: "2024-11-10", place: "重庆", name: "第 10 届 CCPC 中国大学生程序设计竞赛重庆站", tier: "gold", level: "冠军", rank: 1, trophies: 1),
  (date: "2024-10-27", place: "成都", name: "第 49 届 ICPC 国际大学生程序设计竞赛亚洲区域赛成都站", tier: "gold", level: "金牌", rank: 7, trophies: 0),
  (date: "2024-09-19", place: "阿斯塔纳", name: "第 48 届 ICPC 国际大学生程序设计竞赛世界总决赛", tier: "iron", level: "参赛", rank: 18, trophies: 0),
  (date: "2024-01-13", place: "上海", name: "第 48 届 ICPC 国际大学生程序设计竞赛东亚区决赛", tier: "silver", level: "银牌", rank: 32, trophies: 0),
  (date: "2023-11-26", place: "合肥", name: "第 48 届 ICPC 国际大学生程序设计竞赛亚洲区域赛合肥站", tier: "gold", level: "金牌", rank: 11, trophies: 0),
  (date: "2023-11-12", place: "深圳", name: "第 9 届 CCPC 中国大学生程序设计竞赛深圳站", tier: "gold", level: "金牌", rank: 11, trophies: 0),
)

#let oi-awards = (
  (date: "2022-01-22", place: "广州", name: "2022 年全国青少年信息学奥林匹克竞赛冬令营", tier: "bronze", level: "铜牌"),
  (date: "2021-11-20", place: "广州", name: "2021 年全国青少年信息学奥林匹克联赛", tier: "gold", level: "一等奖"),
  (date: "2021-10-23", place: "广州", name: "2021 年 CCF 非专业级软件能力认证（提高级）", tier: "gold", level: "一等奖", icon: "cert"),
  (date: "2021-02-01", place: "广州", name: "2021 年全国青少年信息学奥林匹克竞赛冬令营", tier: "gold", level: "金牌"),
  (date: "2020-12-05", place: "广州", name: "2020 年全国青少年信息学奥林匹克联赛", tier: "gold", level: "一等奖"),
  (date: "2020-11-07", place: "广州", name: "2020 年 CCF 非专业级软件能力认证（提高级）", tier: "gold", level: "一等奖", icon: "cert"),
  (date: "2020-08-15", place: "广州", name: "2020 年亚洲与太平洋地区信息学奥林匹克竞赛", tier: "silver", level: "银牌"),
  (date: "2019-11-16", place: "广州", name: "2019 年 CCF 非专业级软件能力认证（提高级）", tier: "silver", level: "二等奖", icon: "cert"),
  (date: "2018-11-10", place: "广州", name: "2018 年全国青少年信息学奥林匹克联赛（普及组）", tier: "gold", level: "一等奖"),
  (date: "2017-11-11", place: "广州", name: "2017 年全国青少年信息学奥林匹克联赛（普及组）", tier: "silver", level: "二等奖"),
)

#let place-en-map = (
  "南阳": "Nanyang", "杭州": "Hangzhou", "重庆": "Chongqing",
  "南京": "Nanjing", "武汉": "Wuhan", "广州": "Guangzhou",
  "西安": "Xi'an", "上海": "Shanghai", "成都": "Chengdu",
  "阿斯塔纳": "Astana", "合肥": "Hefei", "深圳": "Shenzhen",
)

#let giscus-config = (
  repo: "tiger2005/tiger2005-blog-giscus",
  "repo-id": "R_kgDOUa9KCw",
  category: "Announcements",
  "category-id": "DIC_kwDOUa9KC84DFmvP",
  mapping: "pathname",
  strict: "0",
  "reactions-enabled": "1",
  "emit-metadata": "0",
  "input-position": "top",
  lang: "zh-CN",
  // loading: "lazy",
)

#let render-tag-link = render-tag-link.with(tag-options: tag-options)
#let render-tag-card = render-tag-card.with(tag-options: tag-options)

#let templates = make-templates(
  site-title: "tiger2005 的随笔",
  header-links: (
    "/": "首页",
    "/page/1/": "文章",
    "/categories/": "分类",
    "/tags/": "标签",
    "/archive/": "归档",
    "/about/": "关于",
  ),
  title: "Typst Blog",
  lang: "zh",
  footer-content: footer-content,
  tag-options: tag-options,
  giscus-config: giscus-config,
  custom-css: (
    "/assets/custom.css",
  ),
  custom-script: (
    "/assets/custom.js",
    "/assets/glyph-fourier.js",
    "/assets/award-wheel.js",
    "/assets/home-stats.js",
  )
)

#let template-page = templates.page
#let template-post(..args) = {
  set page(height: auto, width: 30cm)
  set text(16pt, font: ("IBM Plex Sans SC"), lang: "zh")
  show raw: text.with(font: ("IBM Plex Mono", "IBM Plex Sans SC", "DejaVu Sans Mono"))
  show math.equation: set text(16pt)
  set table(inset: 8pt)
  set grid(inset: 8pt)

  (templates.post)(..args)
}

#let choice(a, b, c, d) = context {
  html-guard(() => {
    html.ol(type: "A", {
      html.li(a)
      html.li(b)
      html.li(c)
      html.li(d)
    })
  }, fallback: () => enum(numbering: "A.", a, b, c, d))
}
