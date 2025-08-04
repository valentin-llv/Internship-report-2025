// Footer config

#let apply(
	footer-settings: (text: "Footer text"),
	body
) = {
	set page(
		footer: context grid(
			columns: (1fr, auto),
			align: left + horizon,

			// Content
			footer-settings.text,
			counter(page).display( // Page counter, aligned right
				"1 sur 1",
				both: true,
			)
		)
	)

	counter(page).update(1)

	body
}