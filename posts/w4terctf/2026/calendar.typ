#let get-calendar(months) = {
  set text(15pt)
  show raw: set text(font: ("IBM Plex Mono", "Jetbrains Mono", "Consolas", "Ubuntu Mono", "DejaVu Sans Mono"))

  let elem-background = (
    ("0123456789", yellow),
    ("ABCDEFGHIJKLMNOPQRSTUVWXY", olive),
    ("abcdefghijklmnopqrstuvwxy", lime),
    ("+-*/%", orange.darken(10%)),
    ("&|^<>", orange.lighten(30%)),
    (".$!?@#zZ", aqua),
    ("[]", eastern),
  )

  let start-date = 0

  let day_in_month = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

  let date-names = ("S", "M", "T", "W", "T", "F", "S")

  let month_name = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

  let date = 4

  let month-display = ()

  let table-block = (inner, ..settings) => {
    block(
      width: 18pt,
      height: 18pt,
      ..settings.named(),
      align(
        center + horizon,
        {
          if settings.pos().at(0, default: false) == true {
            set text(fill: white.darken(60%))
            inner
          } else {
            inner
          }
        }
      )
    )
  }

  let fallback = white.darken(20%)

  for i in range(12) {
    let codes = months.at(i)
    assert(codes.len() == day_in_month.at(i))
    let table-elems = ()
  
    let start = start-date
    while start != date {
      table-elems.push(table-block([]))
      start = calc.rem(start + 1, 7)
    }

    for day in range(1, day_in_month.at(i) + 1) {
      let fill = fallback
      for (code_set, color) in elem-background {
        if (codes.at(day - 1) != "\0" and code_set.contains(codes.at(day - 1))) {
          fill = color
          break
        }
      }

      if (codes.at(day - 1) == " ") {
        table-elems.push(table-block(raw("~"), true, fill: fill))
      } else {
        table-elems.push(table-block(raw(codes.at(day - 1)), fill: fill))
      }
      
      date = calc.rem(date + 1, 7)
    }

    month-display.push(
      align(
        center,
        grid(
          columns: 1,
          gutter: 10pt,
          {
            set text(16pt)
            raw(month_name.at(i))
          },
          table(
            columns: 7,
            inset: 1pt,
            stroke: 2pt,
            table.header(
              ..range(start-date, start-date + 7).map(x => table-block(raw(date-names.at(calc.rem(x, 7)))))
            ),
            ..table-elems
          )
        )
      )
    )
  }

  align(center + horizon,
    block(
      fill: white,
      inset: 10pt,
      grid(
        columns: 4,
        inset: 0pt,
        row-gutter: 8pt,
        column-gutter: 2pt,
        align: top,
        ..month-display
      )
    )
  )
}
