
#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  jel-codes: none,
  keywords: none,
  cols: 1,
  margin: (x: 2.5cm, y: 2.5cm),
  paper: "a4",
  lang: "en",
  region: "US",
  font: "New Computer Modern",
  fontsize: 12pt,
  title-size: 1.5em,
  subtitle-size: 1.5em,
  heading-family: "New Computer Modern",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )
  set par(
    spacing: .75em,
    first-line-indent: 1.5em,
    justify: true
  )
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set math.equation(block: true)
  show math.equation: set block(above: 2.5em, below: 2em)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]
  }

  if authors != none {
    v(2em)
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #text(size: 1.2em)[#author.name] \
            #text(style: "italic")[#author.affiliation] \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    v(1em)
    if abstract-title != none {
      align(center)[#text(weight: "semibold")[#abstract-title]]
    }
    align(center)[
      #block(width: 90%)[
        #align(left)[#abstract]
      ]
    ]
  }

  if jel-codes != none {
    v(1em)
    block[
      #text(style: "italic")[JEL classification: ] #jel-codes.join(", ")
    ]
  }

  if keywords != none {
    if jel-codes == none {
      v(1em)
    }
    block[
      #text(style: "italic")[Keywords: ] #keywords.join(", ")
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    pagebreak()
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  pagebreak()

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#set bibliography(
  title: "References",
  style: "chicago-author-date"
)

