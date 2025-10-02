// Special page with no margin
#set page(
	margin: (
		top: 0cm,
		bottom: 1.5cm,
		left: 1.5cm,
		right: 1.5cm
	),

	header: none,
	header-ascent: 0pt,
)

// Macro create faded version of background logo
#let overlay(img, color) = layout(bounds => {
	let size = measure(img, ..bounds)
	img
	place(top + left, block(..size, fill: color))
})

#place(center + horizon, move(dy: 40pt, overlay(image("../../assets/logo/Polytech.png", height: 220mm), white.transparentize(4%))))

// Set default text for page
#set text(
	size: 20pt,
	weight: "black",
	fill: rgb(22, 73, 120),
)

// Center all content
#set align(center)

// Top logos
#grid(
	columns: (1fr, 1fr),
	align: (left + horizon, right + horizon),

	image("../../assets/logo/Polytech Sorbonne.png", height: 30mm),
	image("../../assets/logo/Sciences Sorbonne Universite.png", height: 60mm),
)

#place(center + horizon, move(dy: 85pt, [
	// Page title
	#text(weight: "black", size: 48pt)[Rapport de stage]

	#v(8mm)

	// Internship title
	#text(weight: "medium", size: 28pt)[Ingénieur stagiaire : Protocole CAN\ et développement FPGA]

	#v(8mm)

	// Coordinator
	#text(weight: "bold", size: 18pt)[Tuteur : M. Ahmed Ghouili]\
	#text(weight: "bold", size: 18pt)[Tuteur pédagogique : M. Thibault Hilaire]

	// Date
	#text(weight: "medium", size: 18pt)[Avril - Août 2025]

	#v(5mm)

	// Separator
	#line(length: 30mm)

	#v(5mm)

	// Author
	#text(weight: "bold", size: 20pt)[Valentin Le Lièvre]

	#v(8mm)

	// Logos
	#move(dx: 30pt, grid(
		columns: (auto, auto, auto),
		align: center + horizon,
		gutter: 20mm,

		image("../../assets/logo/IonSat.png", height: 38mm),
		image("../../assets/logo/CSEP.png", height: 38mm),
		move(dx: -30pt, image("../../assets/logo/École_polytechnique.png", height: 50mm))
	))
]))