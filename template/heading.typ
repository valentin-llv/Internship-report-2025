#let apply(
  doc
) = {
	// h1 styling
	show heading.where(level: 1): he => {
		set text(
			size: 20pt,
			weight: "black",
			fill: rgb(22, 73, 120),
		)

		pagebreak()
		he
		v(10pt)
	}

	// h2 styling
	show heading.where(level: 2): he => {
		set text(
			size: 18pt,
			weight: "medium",
			fill: rgb(22, 73, 120),
		)

		he
		v(8pt)
	}

	// h3 styling
	show heading.where(level: 3): he => {
		set text(
			size: 16pt,
			weight: "regular",
			fill: rgb(22, 73, 120),
		)

		he
		v(6pt)
	}

	// h4 styling
	show heading.where(level: 4): he => {
		set text(
			size: 14pt,
			weight: "regular",
			fill: black,
		)

		he
		v(6pt)
	}

	doc
}