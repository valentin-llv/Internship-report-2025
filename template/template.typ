#import "header.typ" as header
#import "footer.typ" as footer
#import "heading.typ" as heading

// Template apply
#let apply(
	body
) = {
	set page(
		paper: "a4",

		margin: (
			top: 2.5cm,
			bottom: 2.5cm,
			left: 2.5cm,
			right: 2.5cm
		),
	)

	// Set paragraphe indentation
	set par(
		first-line-indent: (amount: 20pt, all: true),
		justify: true,
	)

	// Table of contents
	show outline: outline => {
		set par(first-line-indent: 0pt)
		outline
	}
	
	// Force all images to have rounded corners
	show image : image => block(radius: 4pt, clip: true, image)

	// Write TODOs in red
	show "TODO" : el => text(fill: red)[#el]

	body
}