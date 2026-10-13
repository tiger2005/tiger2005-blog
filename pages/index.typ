#import "../config.typ": *
#import "../lib/typ2html/glyph-fourier.typ": glyph-sample-n, glyph-vectors

#let route-page-raw = query-input("route-page", default: none)
#let is-home = route-page-raw == none

#let posts = query-posts()
#let route-page-size = query-route-page-size(default: 10)
#let current-page = if is-home { 1 } else { calc.max(1, int(route-page-raw)) }
#let bounds = query-page-bounds(posts.len(), page: current-page, page-size: route-page-size)
#let total-pages = int(bounds.at("total-pages", default: 1))
#let start-index = int(bounds.at("start-index", default: 0))
#let end-index = int(bounds.at("end-index", default: -1))

#let post-date-text(post) = {
  let date-parts = post.date.split("-")
  if date-parts.len() == 3 {
    format-post-date(datetime(
      year: int(date-parts.at(0)),
      month: int(date-parts.at(1)),
      day: int(date-parts.at(2)),
    ))
  } else {
    post.date
  }
}

#let render-post-card(post) = {
  let date-text = post-date-text(post)
  html.elem("div", attrs: (
    class: "post-card",
    "data-post-url": post.url,
  ), {
    html.div(class: "post-title", {
      html.a(class: "post-card-link", href: post.url, post.title)
    })
    html.div(class: "post-description", {
      post.description
    })
    if post.tags.len() != 0 {
      html.div(class: "post-card-tags", {
        for tag in post.tags {
          render-tag-link(tag, href: "/tags/" + query-tag-slug-of(tag) + "/")
        }
      })
    }
    html.div(class: "post-date", {
      date-text
    })
  })
}

#show: template-page.with(
  title: "首页",
  description: "站点首页",
)

#if is-home {
  let piece-svgs = render-pieces()
  html.div(class: "hero-stage", {
    if piece-debug { render-piece-guide() }
    render-piece-grid()
    html.div(class: "social-hexes", {
      let r3 = calc.sqrt(3) / 2
      for (i, spec) in footer-links.enumerate() {
        let c = social-hex-centers.at(i)
        let cx = c.at(0) * r3
        let cy = c.at(1) / 2
        let left-pct = svg-num((cx + 5.196) / 10.392 * 100)
        let top-pct = svg-num((cy + 6) / 12 * 100)
        html.a(
          class: "social-hex",
          href: spec.at(0),
          target: "_blank",
          rel: ("noopener", "noreferrer"),
          style: "left:" + left-pct + "%;top:" + top-pct + "%;",
          {
            if spec.at(2).ends-with(".svg") {
              html.span(
                class: "social-hex-icon",
                style: "mask-image:url(\"/assets/icons/" + spec.at(2) + "\");",
              )
            } else {
              html.elem("img", attrs: (
                class: "social-hex-icon social-hex-img",
                src: "/assets/icons/" + spec.at(2),
                alt: spec.at(1),
              ))
            }
            html.elem("svg", attrs: (
              class: "social-hex-focus",
              viewBox: "0 0 100 100",
              preserveAspectRatio: "none",
            ), {
              html.elem("polygon", attrs: (
                points: "50 3 97 25 97 75 50 97 3 75 3 25",
                fill: "none",
                stroke: "var(--border-interactive)",
                "stroke-width": "2",
                "vector-effect": "non-scaling-stroke",
              ))
            })
          },
        )
      }
      html.elem("svg", attrs: (
        class: "social-hex-lines",
        xmlns: "http://www.w3.org/2000/svg",
        viewBox: "-5.196 -6 10.392 12",
        fill: "none",
      ), {
        for c in social-hex-centers {
          let cx = c.at(0) * r3
          let cy = c.at(1) / 2
          let pts = ((0, -1), (r3, -0.5), (r3, 0.5), (0, 1), (-r3, 0.5), (-r3, -0.5)).map(p => svg-num(cx + p.at(0)) + " " + svg-num(cy + p.at(1))).join(" ")
          html.elem("polygon", attrs: (
            points: pts,
            stroke: "gray",
            "stroke-width": "1",
            "vector-effect": "non-scaling-stroke",
          ))
        }
      })
    })
    for s in piece-svgs { s }
    html.div(class: "piece-frame", {
      html.elem("svg", attrs: (
        class: "hc-outline",
        xmlns: "http://www.w3.org/2000/svg",
        fill: "none",
      ), {
        html.elem("path", attrs: (
          class: "hc-outline-path",
          stroke: "gray", "stroke-width": "1", fill: "var(--layer1)",
        ))
      })
      html.span(class: "hero-counter-tag", "TIGER2005")
    })
    let side-specs = (
      (side: "left", idx: 5, scale: 0.34),
      (side: "left", idx: 4, scale: 0.42),
      (side: "left", idx: 3, scale: 0.52),
      (side: "left", idx: 2, scale: 0.66),
      (side: "left", idx: 1, scale: 0.82),
      (side: "right", idx: 5, scale: 0.34),
      (side: "right", idx: 4, scale: 0.42),
      (side: "right", idx: 3, scale: 0.52),
      (side: "right", idx: 2, scale: 0.66),
      (side: "right", idx: 1, scale: 0.82),
    )
    for spec in side-specs {
      html.elem("div", attrs: (
        class: "piece-frame side " + spec.side,
        "data-side": spec.side,
        "data-idx": str(spec.idx),
      ), {
        html.elem("svg", attrs: (
          class: "hc-outline",
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
        ), {
          html.elem("path", attrs: (
            class: "hc-outline-path",
            stroke: "gray", "stroke-width": "1", fill: "var(--layer1)",
          ))
        })
      })
    }
  })
  
  html.div(class: "home-placeholder")

  let glyph-json = ("{" + "\"n\":" + str(glyph-sample-n) + ",\"vectors\":[" + glyph-vectors.map(v => "[" + str(v.at(0)) + "," + str(v.at(1)) + "," + str(v.at(2)) + "]").join(",") + "]}").replace("\u{2212}", "-")

  if posts.len() == 0 {
    html.div(class: "error-block", "暂无文章")
  } else {
    let latest = posts.last()
    html.elem("section", attrs: (class: "home-writing", "aria-label": "最新内容"), {
      html.elem("script", attrs: (type: "application/json", id: "glyph-fourier-data"), glyph-json)

      html.div(class: "home-glyph-col", {
        html.div(class: "home-brand-glyph", {
          html.elem("canvas", attrs: (class: "glyph-canvas", "aria-hidden": "true"))
        })
      })

      html.div(class: "home-posts-col", {
        html.div(class: "archive-year-list home-feed", {
          html.elem("article", attrs: (class: "archive-entry home-latest"), {
            html.div(class: "archive-entry-date", latest.date)
            html.div(class: "archive-entry-main", {
              html.elem("h1", attrs: (class: "home-latest-title"), html.a(
                class: "home-latest-link",
                href: latest.url,
                latest.title,
              ))
              html.elem("p", attrs: (class: "home-latest-desc"), latest.description)
              if latest.tags.len() != 0 {
                html.div(class: "post-card-tags home-latest-tags", {
                  for tag in latest.tags {
                    render-tag-link(tag, href: "/tags/" + query-tag-slug-of(tag) + "/")
                  }
                })
              }
            })
          })

          let rest-start = posts.len() - 2
          let rest-end = calc.max(-1, rest-start - 8)
          for i in range(rest-start, rest-end, step: -1) {
            let post = posts.at(i)
            html.elem("article", attrs: (class: "archive-entry"), {
              html.div(class: "archive-entry-date", post.date)
              html.div(class: "archive-entry-main", {
                html.a(class: "archive-entry-link", href: post.url, post.title)
              })
            })
          }
        })
        html.div(class: "home-rest-all", {
          html.a(href: "/page/1/", "查看全部文章 →")
        })
      })
    })
  }

  let fmt-date-cn = d => {
    let p = d.split("-")
    p.at(0) + " 年 " + str(int(p.at(1))) + " 月 " + str(int(p.at(2))) + " 日"
  }
  let render-award-panel = (award, active) => html.elem("div", attrs: (class: "award-panel award-tier-" + award.tier + if active { " is-active" } else { "" }, "data-place-en": place-en-map.at(award.place, default: award.place), "data-date-num": award.date.replace("-", "")), {
    html.div(class: "award-panel-row", {
      html.div(class: "award-panel-id", {
        html.div(class: "award-panel-meta", fmt-date-cn(award.date))
        html.div(class: "award-panel-name", award.name)
        html.div(class: "award-panel-sub", {
          html.span(class: "award-panel-level", award.level)
          if award.at("rank", default: none) != none {
            html.span(class: "award-panel-rank", "#" + str(award.rank))
          }
          html.span(class: "award-panel-icons", {
            if award.tier != "iron" {
              if award.at("icon", default: "medal") == "cert" {
                html.elem("span", attrs: (class: "award-icon award-icon-cert", "aria-hidden": "true"))
              } else {
                html.elem("span", attrs: (class: "award-icon award-icon-medal", "aria-hidden": "true"))
              }
            }
            for _ in range(award.at("trophies", default: 0)) {
              html.elem("span", attrs: (class: "award-icon award-icon-trophy", "aria-hidden": "true"))
            }
          })
        })
      })
    })
  })

  let wheel-awards = oi-awards.rev().map(a => (..a, group: "OI")) + awards.rev().map(a => (..a, group: "XCPC"))
  let wheel-n = wheel-awards.len()
  let wheel-step = 360 / wheel-n
  let wheel-start = wheel-n - 1
  html.elem("section", attrs: (class: "home-awards", "aria-label": "竞赛奖项"), {
    let sx = v => str(v).replace("\u{2212}", "-")
    html.div(class: "home-awards-side", {
      let start-deg = 360 - wheel-start * wheel-step
      let latest = wheel-awards.at(wheel-start)
      html.div(class: "award-wheel-wrap", {
        html.span(class: "award-wheel-label award-wheel-label-place", place-en-map.at(latest.place, default: latest.place))
        html.span(class: "award-wheel-label award-wheel-label-pos", "No. " + str(wheel-start + 1))
        html.span(class: "award-wheel-label award-wheel-label-date", latest.date.replace("-", ""))
        html.elem("svg", attrs: (class: "award-wheel", viewBox: "-50 -50 100 100", "aria-hidden": "true"), {
          html.elem("g", attrs: (class: "award-wheel-rotor", style: "transform: rotate(" + str(start-deg) + "deg)"), {
            for i in range(wheel-n) {
              let a = i * wheel-step * 1deg
              let award = wheel-awards.at(i)
              let r2 = 39.5 + float(i) / float(wheel-n - 1) * 3.5
              html.elem("line", attrs: (
                class: "wheel-seg wheel-seg-" + award.tier + if i == wheel-start { " is-active" } else { "" },
                x1: sx(calc.sin(a) * 18),
                y1: sx(-calc.cos(a) * 18),
                x2: sx(calc.sin(a) * r2),
                y2: sx(-calc.cos(a) * r2),
              ))
            }
          })
        })
      })
    })
    
    html.div(class: "award-main", {
      html.elem("div", attrs: (class: "award-stage", "aria-live": "polite", "aria-roledescription": "轮播"), {
        for i in range(wheel-n) {
          render-award-panel(wheel-awards.at(i), i == wheel-start)
        }
      })
      let dot-init-x = -(wheel-n + wheel-start) * 22 - 5
      html.div(class: "award-dots", {
        html.elem("div", attrs: (class: "award-dots-track", style: "transform: translate(" + sx(dot-init-x) + "px, -50%)"), {
          for copy in range(3) {
            for i in range(wheel-n) {
              let award = wheel-awards.at(i)
              html.elem("button", attrs: (
                class: "award-dot award-dot-" + award.tier + if copy == 1 and i == wheel-start { " is-active" } else { "" },
                type: "button",
                tabindex: if copy == 1 and i == wheel-start { "0" } else { "-1" },
                "data-idx": str(i),
                "aria-label": "第 " + str(i + 1) + " 项：" + award.name,
                "aria-current": if copy == 1 and i == wheel-start { "true" } else { "false" },
              ))
            }
          }
        })
      })
    })
  })

  html.div(class: "home-vercount-line", {
    "本网站被 "
    html.span(id: "vercount_value_site_uv", "...")
    " 个人访问了 "
    html.span(id: "vercount_value_site_pv", "...")
    " 次。"
  })

  html.div(class: "home-motto", {
    "Lead "
    html.span(class: "home-motto-r", "my")
    html.span(class: "home-motto-g", "se")
    html.span(class: "home-motto-b", "lf")
    " into the unknown."
  })

} else {
  render-page-breadcrumb(items: (("/", "首页"),))

  heading[文章列表]

  if posts.len() == 0 {
    html.div(class: "error-block", {
      "暂无文章"
    })
  } else {
    html.div(class: "posts-grid", {
      for i in range(end-index, start-index - 1, step: -1) {
        render-post-card(posts.at(i))
      }
    })

    render-pagination-nav("/", current-page, total-pages, aria-label: "文章列表分页", always-paged: true)
  }
}
