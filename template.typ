#let script-size = 8pt
#let footnote-size = 8.5pt
#let small-size = 9.25pt
#let normal-size = 11pt
#let large-size = 12pt


#let project(
  title: "",
  subtitle: none,
  abstract: [],
  authors: (),
  date: none,
  documenttype: none,
  keywords: none,
  disclosure: none,
  language: "en",
  fontfamily: "Linux Libertine",
  papersize: "a4",
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(numbering: "1", 
            number-align: center,
            paper: papersize,
            margin: 33mm)
  set text(font: fontfamily, 
            lang: language, 
            size: normal-size)

  // Set paragraph spacing.
  show par: set block(above: 0.58em, below: 0.58em)


  // Set Heading styles
  show heading: it => {
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    // Level 1 headings are centered and bold.
    // The other ones are run-in.
    set text(size: normal-size, weight: "bold")
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      set align(center)
      set text(size: normal-size)
      v(15pt, weak: true)
      number
      it.body
      v(normal-size, weak: true)
    } else if it.level == 2 {
      set text(size: normal-size)
      v(normal-size, weak: true)
      number
      it.body
      v(normal-size, weak: true)
      } else {
      v(11pt, weak: true)
      number
      let styled = if it.level == 2 { strong } else { emph }
      styled(it.body + [. ])
      h(7pt, weak: true)
    }
  }

  // Bibliography

  set bibliography(title: "References", style: "apa")
  show bibliography: set block(spacing: 0.58em)
  show bibliography: set par(first-line-indent: 0em)

  // Title Page
  align(center)[
    #if documenttype != none [
    #smallcaps(lower(documenttype)) \ ]
    #text(1.5em, title) \
    #if subtitle != none [
    #text(1.2em, subtitle) \ ]
    #v(1em, weak: true)
  ]

  // utility function: go through all authors and check their affiliations
  // purpose is to group authors with the same affiliations
  // returns a dict with two keys: 
  // "authors" (modified author array)
  // "affiliations": array with unique affiliations
  let parse_authors(authors) = {
    let affiliations = ()
    let parsed_authors = ()
    let corresponding = ()
    let pos = 0
    for author in authors {
      if "affiliation" in author {
        if author.affiliation not in affiliations {
          affiliations.push(author.affiliation)
        }
        pos = affiliations.position(a => a == author.affiliation)
        author.insert("affiliation_parsed", pos)
      } else {
        // if author has no affiliation, just use the same as the previous author
        author.insert("affiliation_parsed", pos)
      }
      parsed_authors.push(author)
      if "corresponding" in author {
        if author.corresponding {
          corresponding = author
        }
      }
    }
    (authors: parsed_authors, 
     affiliations: affiliations,
     corresponding: corresponding)
  }

  // utility function to turn a number into a letter
  // simulates footnotes
  let number2letter(num) = {
    "abcdefghijklmnopqrstuvwxyz".at(num)
  }

  let authors_parsed = parse_authors(authors)

  // List Authors
  pad(
    top: 0.3em,
    bottom: 0.3em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors_parsed.authors.len()),
      gutter: 1em,
      ..authors_parsed.authors.map(author => align(center)[
        #author.name#super[#number2letter(author.affiliation_parsed)] \
      ]),
    ),
  )

  let affiliation_counter = counter("affiliation_counter")

  align(center)[
    #for affiliation in authors_parsed.affiliations [
      #super(affiliation_counter.display("a"))#h(1pt)#emph(affiliation) #affiliation_counter.step() \
    ]
    #v(1em, weak: true)
    #date
    #v(2em, weak: true)

  ]


  set par(justify: true)

  // Abstract & Keywords
  heading(outlined: false, numbering: none, text(11pt, weight: "regular", [Abstract]))
  align(center)[
    #block(width: 90%, [
      #align(left)[
        #abstract \
        #v(1em, weak: true)
        #if keywords != none [
        #emph("Keywords: ") #keywords
        ]
      ]
      ]
    )
  ]

  let orcid(height: 10pt, o) = [
    #box(height: height, baseline: 10%, image("assets/orcid.svg") ) #link("https://orcid.org/" + o)
  ]

  // Author Note
  heading(outlined: false, numbering: none, text(11pt, weight: "bold", [Author Note]))

  // ORCID IDs
  for author in authors_parsed.authors [
    #author.name #orcid(author.orcid) \ 
  ]
  // Disclosures and Acknowledgements
  if disclosure != none [
    #disclosure \
  ] else [
    We have no conflicts of interest to disclose. \ ]

  // Contact Information
  [Correspondence concerning this article should be addressed to 
   #authors_parsed.corresponding.name, 
   #authors_parsed.corresponding.postal, 
   Email: #link("mailto:" + authors_parsed.corresponding.email, authors_parsed.corresponding.email)
   ]

  pagebreak()

  // Main body.
  set par(justify: true,
          first-line-indent: 2em)

  body
}
