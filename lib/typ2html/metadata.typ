#import "sys-input.typ": query-input

#let normalize-url(base, path) = {
  let clean-base = str(base).trim("/", at: end)
  let clean-path = str(path).trim("/")
  if clean-path == "" {
    clean-base + "/"
  } else {
    clean-base + "/" + clean-path + "/"
  }
}

#let seo-tags(
  title: "",
  author: none,
  description: none,
  canonical-url: none,
  is-article: false,
  tags: (),
  category: "",
  published-time: none,
) = {
  let og-type = if is-article { "article" } else { "website" }

  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: og-type))

  if description != none and str(description) != "" {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  if canonical-url != none and str(canonical-url) != "" {
    html.elem("meta", attrs: (property: "og:url", content: canonical-url))
  }

  if author != none and str(author) != "" {
    html.meta(name: "author", content: author)
    if og-type == "article" {
      html.elem("meta", attrs: (property: "article:author", content: author))
    }
  }

  if tags.len() > 0 {
    html.meta(name: "keywords", content: tags.join(", "))
    if og-type == "article" {
      for tag in tags {
        html.elem("meta", attrs: (property: "article:tag", content: tag))
      }
    }
  }

  if og-type == "article" {
    if str(category) != "" {
      html.elem("meta", attrs: (property: "article:section", content: category))
    }
    if published-time != none and str(published-time) != "" {
      html.elem("meta", attrs: (property: "article:published_time", content: published-time))
    }
  }

  html.meta(name: "twitter:card", content: "summary")
}

#let metadata(
  title: "",
  author: query-input("author", default: none),
  description: none,
  lang: "zh",
  date: none,
  website-title: "",
  website-url: none,
  canonical-path: none,
  include-rss-link: false,
  feed-path: "/rss.xml",
  is-article: false,
  tags: (),
  category: "",
) = {
  html.meta(charset: "utf-8")
  html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
  html.meta(name: "color-scheme", content: "light dark")
  html.meta(name: "generator", content: "Typst")

  let page-title = if title != "" and website-title != "" {
    title + " / " + website-title
  } else if title != "" {
    title
  } else if website-title != "" {
    website-title
  } else {
    "Untitled Page"
  }
  html.title(page-title)

  let published-time = if type(date) == datetime {
    date.display("[year]-[month]-[day]")
  } else if type(date) == str and date != "" {
    date
  } else {
    none
  }

  if published-time != none {
    html.meta(name: "date", content: published-time)
  }

  if include-rss-link {
    let rss-title = if website-title != "" { website-title } else { page-title }
    html.link(
      rel: "alternate",
      type: "application/rss+xml",
      href: feed-path,
      title: rss-title + " RSS Feed",
    )
  }

  let resolved-page-path = if canonical-path != none {
    str(canonical-path)
  } else {
    str(query-input("page-path", default: ""))
  }

  let canonical-url = if website-url != none and str(website-url) != "" {
    normalize-url(website-url, resolved-page-path)
  } else {
    none
  }

  if canonical-url != none {
    html.link(rel: "canonical", href: canonical-url)
  }

  seo-tags(
    title: page-title,
    author: author,
    description: description,
    is-article: is-article,
    canonical-url: canonical-url,
    tags: tags,
    category: category,
    published-time: published-time,
  )

  if lang != "" {
    html.meta(name: "language", content: lang)
  }
}
