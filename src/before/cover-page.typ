#let overlay(img, color) = layout(bounds => {
	let size = measure(img, ..bounds)
	img
	place(top + left, block(..size, fill: color))
})

#set page(
	margin: 0mm,
)

#align(center + horizon, move(dy: -50pt, overlay(image("../../assets/logo/Polytech.png", height: 150mm), white.transparentize(20%))))