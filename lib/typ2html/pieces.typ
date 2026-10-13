#import "pieces-reference.typ": piece-reference

#let piece-debug = false
// 焦点构件：none 表示六个构件全部实色绘制；
// 设为 0..5 时，只有该构件实色绘制，便于逐一对着淡背景描点。
#let piece-focus = none

#let piece-colors = ("#444FC3", "#58AC59", "#D73A34")

#let piece-vb = "-5.196 -6 10.392 12"

// 用户整数坐标 → 屏幕坐标
#let k4 = calc.sqrt(3) / 4
#let to-screen = p => (p.at(0) * k4, p.at(1) * 0.25)

// 数字与坐标格式化
#let svg-num = v => {
  let r = calc.round(float(v), digits: 3)
  if calc.abs(r) < 0.0005 { r = 0.0 }
  str(r).replace("−", "-")
}

#let points-str = pts => {
  pts.map(p => {
    let s = to-screen(p)
    svg-num(s.at(0)) + " " + svg-num(s.at(1))
  }).join(" ")
}

// 染色路径：六边形外扩 w 的单一闭合区域
#let fill-path(A, V, w) = {
  let Ac = to-screen(A)
  let S = V.map(to-screen)
  let n = S.len()
  // 每条棱的外法向（屏幕空间，棱中点指向远离中心的一侧）
  let normals = ()
  for i in range(n) {
    let p = S.at(i)
    let q = S.at(calc.rem(i + 1, n))
    let tx = q.at(0) - p.at(0)
    let ty = q.at(1) - p.at(1)
    let L = calc.sqrt(tx * tx + ty * ty)
    let nx = -ty / L
    let ny = tx / L
    let mx = (p.at(0) + q.at(0)) / 2 - Ac.at(0)
    let my = (p.at(1) + q.at(1)) / 2 - Ac.at(1)
    if nx * mx + ny * my < 0 { nx = -nx; ny = -ny }
    normals.push((nx, ny))
  }
  // 有向面积判断环绕方向，决定顶点圆弧的 sweep 标志
  let area2 = 0
  for i in range(n) {
    let p = S.at(i)
    let q = S.at(calc.rem(i + 1, n))
    area2 += p.at(0) * q.at(1) - q.at(0) * p.at(1)
  }
  let sweep = if area2 > 0 { "1" } else { "0" }
  let pt = (i, j) => svg-num(S.at(i).at(0) + w * normals.at(j).at(0)) + " " + svg-num(S.at(i).at(1) + w * normals.at(j).at(1))
  let ws = svg-num(w)
  let parts = ("M " + pt(0, 0),)
  for i in range(n) {
    let j = calc.rem(i + 1, n)
    parts.push("L " + pt(j, i))
    parts.push("A " + ws + " " + ws + " 0 0 " + sweep + " " + pt(j, j))
  }
  parts.join(" ") + " Z"
}

// 单个方块的投影
#let hex-verts = A => (
  (A.at(0) + 2, A.at(1) + 2),
  (A.at(0) + 2, A.at(1) - 2),
  (A.at(0), A.at(1) - 4),
  (A.at(0) - 2, A.at(1) - 2),
  (A.at(0) - 2, A.at(1) + 2),
  (A.at(0), A.at(1) + 4),
)

#let edge-pts = (A, V) => (
  (V.at(0), V.at(1)),
  (V.at(1), V.at(2)),
  (V.at(2), V.at(3)),
  (V.at(3), V.at(4)),
  (V.at(4), V.at(5)),
  (V.at(5), V.at(0)),
  (A, V.at(0)),
  (A, V.at(1)),
  (A, V.at(2)),
  (A, V.at(3)),
  (A, V.at(4)),
  (A, V.at(5)),
)

#let svg-block(
  axis: 0,
  half: 0,
  a: 0,
  b: 0,
  m: "000000000000",
  fill: "#000000",
  vb: piece-vb,
  stroke-width: 0.04,
) = {
  let A = (a, b)
  let V = hex-verts(A)
  let edges = edge-pts(A, V)
  html.elem("svg", attrs: (
    class: "piece",
    "data-axis": str(axis),
    "data-half": str(half),
    viewBox: vb,
    preserveAspectRatio: "xMidYMid meet",
    xmlns: "http://www.w3.org/2000/svg",
  ), {
    // 纯色染色区
    html.elem("path", attrs: (
      d: fill-path(A, V, stroke-width / 2),
      fill: fill,
    ))
    // 黑色棱
    for (i, seg) in edges.enumerate() {
      if m.slice(i, i + 1) == "1" {
        let sa = to-screen(seg.at(0))
        let sb = to-screen(seg.at(1))
        html.elem("line", attrs: (
          x1: svg-num(sa.at(0)),
          y1: svg-num(sa.at(1)),
          x2: svg-num(sb.at(0)),
          y2: svg-num(sb.at(1)),
          stroke: "black",
          "stroke-width": str(stroke-width),
          "stroke-linecap": "round",
        ))
      }
    }
  })
}

// 六个 U 型构件拆成 30 个方块
#let piece-defs = (
  // d=-3
  (d: -3, axis: 0, half: 0, a: 4, b: 0, m: "110010000111", s: "101100001001"),
  (d: -3, axis: 1, half: 0, a: -2, b: 6, m: "001011011100", s: "101100001001"),
  (d: -3, axis: 2, half: 0, a: -2, b: -6, m: "101100110001", s: "011001011000"),
  // d=-2
  (d: -2, axis: 0, half: 0, a: 2, b: -2, m: "011111101010", s: "111010010001"),
  (d: -2, axis: 0, half: 0, a: 4, b: 4, m: "101110001100", s: "100000001001"),
  (d: -2, axis: 1, half: 0, a: -4, b: 4, m: "111010110000", s: "101010010001"),
  (d: -2, axis: 1, half: 0, a: 0, b: 4, m: "111101101010", s: "011101001001"),
  (d: -2, axis: 2, half: 0, a: -2, b: -2, m: "110111101010", s: "000001010010"),
  (d: -2, axis: 2, half: 0, a: 0, b: -8, m: "101011000011", s: "111101011110"),
  // d=-1
  (d: -1, axis: 0, half: 0, a: 4, b: 8, m: "100011100100", s: "100111101010"),
  (d: -1, axis: 1, half: 0, a: -6, b: 2, m: "001110010010", s: "001110010010"),
  (d: -1, axis: 2, half: 0, a: 2, b: -10, m: "111000001001", s: "111100001111"),
  // d=0
  (d: 0, axis: 0, half: 0, a: 2, b: 6, m: "011110101010", s: "100101000011"),
  (d: 0, axis: 0, half: 1, a: -2, b: -6, m: "110101100001", s: "011001011000"),
  (d: 0, axis: 1, half: 0, a: -4, b: 0, m: "111001101010", s: "000001010010"),
  (d: 0, axis: 1, half: 1, a: 4, b: 0, m: "010111000110", s: "101100001001"),
  (d: 0, axis: 2, half: 0, a: 2, b: -6, m: "100111101010", s: "001001101010"),
  (d: 0, axis: 2, half: 1, a: -2, b: 6, m: "011101011000", s: "101100001001"),
  // d=1
  (d: 1, axis: 0, half: 1, a: -4, b: -8, m: "011100001001", s: "111100011000"),
  (d: 1, axis: 1, half: 1, a: 6, b: -2, m: "110001100100", s: "110101100001"),
  (d: 1, axis: 2, half: 1, a: -2, b: 10, m: "000111010010", s: "100111101010"),
  // d=2
  (d: 2, axis: 0, half: 1, a: -4, b: -4, m: "100100001001", s: "000101000000"),
  (d: 2, axis: 0, half: 1, a: -2, b: 2, m: "110011100100", s: "101000010011"),
  (d: 2, axis: 1, half: 1, a: 0, b: -4, m: "001111010010", s: "001000010010"),
  (d: 2, axis: 1, half: 1, a: 4, b: -4, m: "010010100100", s: "010000000111"),
  (d: 2, axis: 2, half: 1, a: 0, b: 8, m: "001001010010", s: "100111011001"),
  (d: 2, axis: 2, half: 1, a: 2, b: 2, m: "111100001001", s: "100100001100"),
  // d=3
  (d: 3, axis: 0, half: 1, a: -4, b: 0, m: "000110101010", s: "000001010010"),
  (d: 3, axis: 1, half: 1, a: 2, b: -6, m: "011000101010", s: "001001101010"),
  (d: 3, axis: 2, half: 1, a: 2, b: 6, m: "100001101010", s: "100101000011"),
)

#let guide-line = (p1, p2, width: 0.015, opacity: 0.35) => {
  let s1 = to-screen(p1)
  let s2 = to-screen(p2)
  html.elem("line", attrs: (
    x1: svg-num(s1.at(0)), y1: svg-num(s1.at(1)),
    x2: svg-num(s2.at(0)), y2: svg-num(s2.at(1)),
    stroke: "#808080",
    "stroke-width": str(width),
    "stroke-opacity": str(opacity),
  ))
}

#let guide-text(p, s, anchor: "start", baseline: "alphabetic") = {
  let sp = to-screen(p)
  html.elem("text", attrs: (
    x: svg-num(sp.at(0)), y: svg-num(sp.at(1)),
    "font-size": "0.24",
    fill: "#808080",
    "font-family": "'IBM Plex Mono', 'Courier New', monospace",
    "text-anchor": anchor,
    "dominant-baseline": baseline,
  ), s)
}

#let render-piece-guide() = {
  let elems = ()

  // 淡成品参考图
  for r in piece-reference {
    let color = piece-colors.at(r.axis)
    for poly in r.polys {
      elems.push(html.elem("polygon", attrs: (
        points: points-str(poly),
        fill: color,
        "fill-opacity": "0.18",
      )))
    }
    for seg in r.lines {
      let sa = to-screen(seg.at(0))
      let sb = to-screen(seg.at(1))
      elems.push(html.elem("line", attrs: (
        x1: svg-num(sa.at(0)), y1: svg-num(sa.at(1)),
        x2: svg-num(sb.at(0)), y2: svg-num(sb.at(1)),
        stroke: "black",
        "stroke-width": "0.04",
        "stroke-opacity": "0.22",
        "stroke-linecap": "round",
      )))
    }
  }

  // 视图框边界
  {
    let c1 = to-screen((-12, -24))
    let c2 = to-screen((12, 24))
    elems.push(html.elem("rect", attrs: (
      x: svg-num(c1.at(0)), y: svg-num(c1.at(1)),
      width: svg-num(c2.at(0) - c1.at(0)),
      height: svg-num(c2.at(1) - c1.at(1)),
      fill: "none",
      stroke: "#808080",
      "stroke-width": "0.015",
      "stroke-opacity": "0.45",
    )))
  }

  // 整数辅助网格
  for a in range(-12, 13) {
    if calc.even(a) {
      elems.push(guide-line((a, -24), (a, 24)))
    } else {
      elems.push(guide-line((a, -24), (a, 24), width: 0.012, opacity: 0.15))
    }
  }
  for b in range(-24, 25) {
    if calc.even(b) {
      elems.push(guide-line((-12, b), (12, b)))
    } else {
      elems.push(guide-line((-12, b), (12, b), width: 0.012, opacity: 0.15))
    }
  }

  // 坐标轴与箭头
  elems.push(guide-line((-12, 0), (12, 0), width: 0.03, opacity: 0.75))
  elems.push(guide-line((0, -24), (0, 24), width: 0.03, opacity: 0.75))
  elems.push(html.elem("polygon", attrs: (
    points: points-str(((12, 0), (11.3, -0.36), (11.3, 0.36))),
    fill: "#808080", "fill-opacity": "0.75",
  )))
  elems.push(html.elem("polygon", attrs: (
    points: points-str(((0, -24), (-0.21, -22.8), (0.21, -22.8))),
    fill: "#808080", "fill-opacity": "0.75",
  )))

  // 刻度数字与轴名
  for a in range(-12, 13) {
    if calc.even(a) and a != 0 {
      elems.push(guide-text((a, 1.5), str(a), anchor: "middle"))
    }
  }
  for b in range(-24, 25) {
    if calc.rem(b, 4) == 0 and b != 0 {
      elems.push(guide-text((0.6, b), str(b), baseline: "central"))
    }
  }
  elems.push(guide-text((11.4, 1.5), "a", anchor: "middle"))
  elems.push(guide-text((0.6, -23.6), "b", baseline: "central"))

  html.elem("svg", attrs: (
    class: "piece-guide",
    viewBox: piece-vb,
    preserveAspectRatio: "xMidYMid meet",
    xmlns: "http://www.w3.org/2000/svg",
  ), {
    for g in elems { g }
  })
}

// 产出实色构件 svg
#let piece-focus-keys = ((1, 1), (2, 1), (0, 1), (1, 0), (0, 0), (2, 0))

#let render-pieces() = {
  let kept = piece-defs.filter(d => {
    if not (piece-debug and piece-focus != none) { return true }
    let key = piece-focus-keys.at(piece-focus)
    return d.axis == key.at(0) and d.half == key.at(1)
  })
  let make-group = (members, axis, half, extra: none) => {
    let cls = if extra == none { "piece-group" } else { "piece-group " + extra }
    html.elem("div", attrs: (
      class: cls,
      "data-axis": str(axis),
      "data-half": str(half),
    ))[
      #for d in members {
        svg-block(
          axis: d.axis,
          half: d.half,
          a: d.a,
          b: d.b,
          m: d.m,
          fill: piece-colors.at(d.axis),
        )
      }
    ]
  }
  let red-down = kept.filter(d => d.axis == 2 and d.half == 1)
  let red-split = red-down.filter(d => d.d == 0)
  let red-rest = red-down.filter(d => d.d != 0)

  let out = ()
  let g00 = kept.filter(d => d.axis == 0 and d.half == 0)
  let g10 = kept.filter(d => d.axis == 1 and d.half == 0)
  let g20 = kept.filter(d => d.axis == 2 and d.half == 0)
  let g01 = kept.filter(d => d.axis == 0 and d.half == 1)
  let g11 = kept.filter(d => d.axis == 1 and d.half == 1)
  if g00.len() > 0 { out.push(make-group(g00, 0, 0)) }
  if g10.len() > 0 { out.push(make-group(g10, 1, 0)) }
  if g20.len() > 0 { out.push(make-group(g20, 2, 0)) }
  if red-split.len() > 0 { out.push(make-group(red-split, 2, 1, extra: "piece-split")) }
  if g01.len() > 0 { out.push(make-group(g01, 0, 1)) }
  if g11.len() > 0 { out.push(make-group(g11, 1, 1)) }
  if red-rest.len() > 0 { out.push(make-group(red-rest, 2, 1)) }
  out
}

// 六边形格点
#let social-hex-centers = (
  (-4, 14), (-2, 14), (0, 14), (2, 14), (4, 14),
  (-5, 17), (-3, 17), (-1, 17), (1, 17), (3, 17), (5, 17),
)
#let in-social-hex(m, n) = {
  let covered = false
  for c in social-hex-centers {
    let dm = m - c.at(0)
    let dn = n - c.at(1)
    if calc.abs(dm) <= 1 and calc.abs(dm - dn) <= 2 and calc.abs(dm + dn) <= 2 {
      covered = true
    }
  }
  covered
}
#let render-piece-grid = () => {
  let dots = ()
  let m = -19
  while m <= 19 {
    let n = -33
    while n <= 33 {
      if calc.rem(calc.abs(m + n), 2) == 0 and 3 * m * m + n * n <= 1024 and not in-social-hex(m, n) {
        let d2 = 3 * m * m + n * n
        let alpha = if d2 == 0 { 1.0 } else { calc.min(1.0, 16.0 / d2) }
        let s = to-screen((2 * m, 2 * n))
        dots.push(html.elem("circle", attrs: (
          cx: svg-num(s.at(0)), cy: svg-num(s.at(1)),
          r: "0.06",
          "fill-opacity": svg-num(alpha),
        )))
      }
      n += 1
    }
    m += 1
  }
  html.elem("svg", attrs: (
    class: "piece-grid",
    xmlns: "http://www.w3.org/2000/svg",
    viewBox: piece-vb,
    fill: "none",
  ), {
    for d in dots { d }
  })
}
