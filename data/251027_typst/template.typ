#let article(
  paper: "a4",
  margin: (x: 25mm, y: 25mm),
  leading: .85em,
  spacing: 1em,
  first-line-indent: 1.5em,
  heading-numbering: "1.1.1 ",
  lang: "en",
  font: "TeX Gyre Termes",
  fontsize: 12pt,
  page-numbering: "1",
  figure-below: 2.5em,
  equation-numbering: "(1)",
  equation-above: 2.5em,
  equation-below: 2em,
  footnote-numbering: "1",
  title: none,
  title-size: 1.5em,
  authors: none,
  size-l: 1.2em,
  date: none,
  abstract: none,
  jel-codes: none,
  keywords: none,
  doc
) = {
  set page(
    paper: paper,
    margin: margin
  )
  set par(
    leading: leading,
    spacing: spacing,
    first-line-indent: first-line-indent,
    justify: true
  )
  set heading(
    numbering: heading-numbering
  )
  show heading: it => block(
    below: leading
  )[ #it ]
  set text(
    lang: lang,
    font: font,
    size: fontsize
  )
  set page(numbering: page-numbering)
  show figure: set place(clearance: figure-below)
  show figure: set figure(placement: top)
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  show figure.caption: it => context[
    #text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering) #it.separator] #it.body
  ]
  set table(
    stroke: none
  )
  set footnote(numbering: "*")
  set math.equation(
    block: true,
    numbering: equation-numbering
  )
  show math.equation: set block(
    above: equation-above,
    below: equation-below
  )
  
  if title != none {
    align(center)[
      #text(size: title-size)[#title]
    ]
  }

  if authors != none {
    v(1.5em)
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
        align(center)[
          #text(size: size-l)[#author.name] \
          #text(style: "italic")[#author.affiliation] \
          #link("mailto:" + author.email)]
      ),
    )
  }

  if date != none {
    align(center)[
      #block(inset: 1em)[
        #text(size: size-l)[#date]
      ]
    ]
  }

  if abstract != none {
    v(1.5em)
    set par(leading: 0.65em)
    align(center)[
      #text(weight: "semibold")[Abstract]
    ]
    align(center)[
      #block(width: 90%)[
        #align(left)[#abstract]
      ]
    ]
  }

  if jel-codes != none {
    v(1em)
    block[
      #text(weight: "bold", style: "italic")[JEL classification: ] #jel-codes.join(", ")
    ]
  }

  if keywords != none {
    if jel-codes == none { v(1em) }
    block[
      #text(weight: "bold", style: "italic")[Keywords: ] #keywords.join(", ")
    ]
  }
  
  pagebreak()
  counter(footnote).update(0)
  set footnote(numbering: footnote-numbering)

  set bibliography(
    title: "References",
    style: "chicago-author-date.csl"
  )
  show bibliography: set par(
    leading: .65em,
    spacing: 1.2em,
  )
  
  doc
}
