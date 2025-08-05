// Heading config

#let apply(
	header-settings : (text: "Header text", logos: []),
	body,
) = {
	set page(
		header: grid(
			columns: (1fr, auto),
			rows: 60pt,

			gutter: 15pt,
			align: left + horizon,

			// Content
			par(justify: false, first-line-indent: 0pt)[#header-settings.text],
			header-settings.logos
		),

		margin: (
			top: 4cm,
			bottom: 2.5cm,
			left: 2.5cm,
			right: 2.5cm
		),

		header-ascent: 20pt,
	)

	body
}