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
		)
	)

	body
}