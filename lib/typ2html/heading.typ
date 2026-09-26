#import "html-guard.typ": html-guard

#let heading-anchor-counter = counter("heading-anchor")

#let template-headings(content) = {
  html-guard(() => {
    show heading: it => {
      heading-anchor-counter.step()
      let id = "heading-" + str(heading-anchor-counter.get().at(0))
      let tag = "h" + str(it.level + 1)

      html.elem(tag, attrs: (id: id), {
        html.elem("a", attrs: (
          class: "heading-anchor",
          href: "#" + id,
          "aria-label": "跳转到此标题",
        ), {
          html.elem("span", attrs: (class: "heading-anchor-icon", "aria-hidden": "true"))
          html.span(class: "heading-anchor-text", "跳转到……")
        })
        it.body
      })
    }
    content
  }, fallback: () => content)
}
