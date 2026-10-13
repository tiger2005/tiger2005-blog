#import "html-guard.typ": html-guard

#let pagination-page-href(base-path, page, always-paged: false) = {
  let base = str(base-path)
  let current = calc.max(1, int(page))
  if current == 1 and not always-paged {
    base
  } else {
    base + "page/" + str(current) + "/"
  }
}

#let should-show-page(page, current, total, side-window) = {
  page == 1 or page == total or calc.abs(page - current) <= side-window
}

#let render-pagination-page-item(base-path, page, current, always-paged: false) = {
  html-guard(() => {
    if page == current {
      html.span(
        class: "pagination-nav-page is-current",
        aria-current: "page",
        str(page)
      )
    } else {
      html.a(
        class: "pagination-nav-page",
        href: pagination-page-href(base-path, page, always-paged: always-paged),
        aria-label: "转到第 " + str(page) + " 页",
        str(page)
      )
    }
  })
}

#let render-pagination-nav-variant(base-path, current-page, total-pages, side-window, aria-label, variant-class, always-paged: false) = {
  let current = calc.max(1, int(current-page))
  let total = calc.max(1, int(total-pages))

  let visible-pages = range(1, total + 1).filter(page => should-show-page(page, current, total, side-window))

  html-guard(() => {
    html.nav(
      class: "pagination-nav " + variant-class,
      aria-label: aria-label,
    {
      if current > 1 {
        html.a(
          class: "pagination-nav-button pagination-nav-prev",
          href: pagination-page-href(base-path, current - 1, always-paged: always-paged),
          aria-label: "上一页"
        )
      } else {
        html.span(
          class: "pagination-nav-button pagination-nav-prev is-disabled",
          aria-disabled: true
        )
      }

      for i in range(0, visible-pages.len()) {
        let page = int(visible-pages.at(i))
        if i > 0 {
          let previous = int(visible-pages.at(i - 1))
          if page - previous > 1 {
            html.span(class: "pagination-nav-ellipsis", "…")
          }
        }

        render-pagination-page-item(base-path, page, current, always-paged: always-paged)
      }

      if current < total {
        html.a(
          class: "pagination-nav-button pagination-nav-next",
          href: pagination-page-href(base-path, current + 1, always-paged: always-paged),
          aria-label: "下一页",
        )
      } else {
        html.span(
          class: "pagination-nav-button pagination-nav-next is-disabled",
          aria-disabled: true
        )
      }
    })
  })
}

// 同时输出宽版与窄版分页，交由 CSS 根据布局宽度切换显示。
// always-paged 为 true 时，第一页也指向 base-path 下的 page/1/（用于主页文章列表）。
#let render-pagination-nav(base-path, current-page, total-pages, aria-label: "分页导航", always-paged: false) = {
  let pages = calc.max(1, int(total-pages))
  if pages <= 1 {
    none
  } else {
    html-guard(() => {
      html.div(class: "pagination-nav-wrapper", {
        render-pagination-nav-variant(base-path, current-page, pages, 2, aria-label + "（大）", "pagination-nav-wide", always-paged: always-paged)
        render-pagination-nav-variant(base-path, current-page, pages, 1, aria-label + "（中）", "pagination-nav-medium", always-paged: always-paged)
        render-pagination-nav-variant(base-path, current-page, pages, 0, aria-label + "（小）", "pagination-nav-compact", always-paged: always-paged)
      })
    })
  }
}