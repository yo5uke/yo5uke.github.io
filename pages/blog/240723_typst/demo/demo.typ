// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
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
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
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
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

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
#let brand-color = (
  background: rgb("#ffffff"),
  black: rgb("#111111"),
  coral-pink: rgb("#f3969a"),
  dark: rgb("#343a40"),
  foreground: rgb("#454955"),
  gray: rgb("#454955"),
  gray-dark: rgb("#343a40"),
  gray-light: rgb("#f0f0f0"),
  light: rgb("#f0f0f0"),
  mint: rgb("#78c2ad"),
  mint-dark: rgb("#4a8573"),
  mint-light: rgb("#e6f4ef"),
  primary: rgb("#78c2ad"),
  purple: rgb("#7d12ba"),
  white: rgb("#ffffff")
)
#set page(fill: brand-color.background)
#set text(fill: brand-color.foreground)
#set table.hline(stroke: (paint: brand-color.foreground))
#set line(stroke: (paint: brand-color.foreground))
#let brand-color-background = (
  background: color.mix((brand-color.background, 15%), (brand-color.background, 85%)),
  black: color.mix((brand-color.black, 15%), (brand-color.background, 85%)),
  coral-pink: color.mix((brand-color.coral-pink, 15%), (brand-color.background, 85%)),
  dark: color.mix((brand-color.dark, 15%), (brand-color.background, 85%)),
  foreground: color.mix((brand-color.foreground, 15%), (brand-color.background, 85%)),
  gray: color.mix((brand-color.gray, 15%), (brand-color.background, 85%)),
  gray-dark: color.mix((brand-color.gray-dark, 15%), (brand-color.background, 85%)),
  gray-light: color.mix((brand-color.gray-light, 15%), (brand-color.background, 85%)),
  light: color.mix((brand-color.light, 15%), (brand-color.background, 85%)),
  mint: color.mix((brand-color.mint, 15%), (brand-color.background, 85%)),
  mint-dark: color.mix((brand-color.mint-dark, 15%), (brand-color.background, 85%)),
  mint-light: color.mix((brand-color.mint-light, 15%), (brand-color.background, 85%)),
  primary: color.mix((brand-color.primary, 15%), (brand-color.background, 85%)),
  purple: color.mix((brand-color.purple, 15%), (brand-color.background, 85%)),
  white: color.mix((brand-color.white, 15%), (brand-color.background, 85%))
)
#let brand-logo-images = (
  icon: (
    path: "assets\\icons\\favicon.ico"
  ),
  icon-r: (
    path: "assets\\icons\\abe-r.png"
  )
)
#set text(weight: 400, )
#set par(leading: 0.85em)
#show heading: set text(font: ("Zen Kaku Gothic New",), weight: 700, )
#show heading: set par(leading: 0.5em)
#show raw.where(block: false): set text(font: ("Fira Code",), weight: 400, fill: rgb("#d86a85"), )
#show raw.where(block: false): content => highlight(fill: rgb("#fcf7f8"), content)
#show raw.where(block: true): set text(font: ("Fira Code",), weight: 400, size: 0.95*12pt, )
#show link: set text(weight: 400, fill: rgb("#78c2ad"), )

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: doc => article(
  title: [Typst demo],
  authors: (
    ( name: [Yosuke Abe],
      affiliation: [OSIPP],
      email: [] ),
    ),
  date: [July 23, 2024],
  lang: "en",
  abstract: [Here is an abstract.

],
  abstract-title: "Abstract",
  font: ("Zen Maru Gothic",),
  fontsize: 12pt,
  heading-family: ("Zen Kaku Gothic New",),
  heading-weight: 700,
  heading-color: rgb("#454955"),
  heading-line-height: 0.5em,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

#strong[Keywords:] Keyword 1, Keyword 2, Keyword 3…

= Section 1
<section-1>
You can plot a figure like #ref(<fig-cars>, supplement: [Figure])

```r
plot(cars)
```

#figure([
#box(image("demo_files/figure-typst/fig-cars-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Plot of cars
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-cars>


#pagebreak()
= Section 2
<section-2>
== Subsection
<subsection>
You can also write mathematical expressions like #ref(<eq-panel>, supplement: [Equation]).

#math.equation(block: true, numbering: "(1)", [ $ Y_(i t) = delta D_(i t) + u_i + epsilon_(i t) \, quad t = 1 \, 2 \, dots.h \, T $ ])<eq-panel>

 
  
#set bibliography(style: "../../../../styles/csl/chicago-author-date.csl") 


#bibliography("../../../../references.bib")

