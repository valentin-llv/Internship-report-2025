// Load and apply template
#import "../template/template.typ" as template
#show: template.apply

// Disable heading outlined
#set heading(outlined: false)

/* Page de garde */
#include "before/cover-page.typ"

// Enable heading
#show: template.heading.apply

/* Abstract (anglais) */
#include "before/abstract-en.typ"

/* Abstract (français) */
#include "before/abstract-fr.typ"

/* Remerciements */
#include "before/acknowledgements.typ"

/* Sommaire */
#outline(title: [Sommaire], depth: 3)

/* Abreviations */
#include "before/abbreviations.typ"

/*

	Set header and footer

*/

#show: template.header.apply.with(
	header-settings: (
		text: text(size: 14pt)[Développement hardware FPGA pour le satellite IonSat],
		logos: grid(
				columns: (auto, auto),
				gutter: 13pt,

				// Content
				image("../assets/logo/Polytech Sorbonne.png", height: 18mm),
				image("../assets/logo/Sciences Sorbonne Universite.png", height: 30mm),
			)
	)
)

#show: template.footer.apply.with(
	footer-settings: (
		text: "Rapport de stage ingénieur de 4ème année - Valentin Le Lièvre"
	)
)

// Enable heading numbering
#set heading(numbering: "1.1 - ")

// Enable heading outlined
#set heading(outlined: true)

/*

	Introduction

*/
#include "content/introduction.typ"


/*

	Technical content

*/
#include "content/content.typ"


/*

	Conclusion

*/
#include "content/conclusion.typ"

/* Disable heading numbering */
#set heading(numbering: none)

/* Bibliographie */
#include "end/bibliography.typ"

/* Annexe 1 : auto-evaluation */
#include "end/annexe-1.typ"

/* Autres annexes */
#include "end/annexes.typ"