Rebol [
	Title: "Link-Up"
	Date: 24-Nov-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [link-up]
]

show: func [target [none! url!] /with suffix [file!]][
	rejoin [qm/settings/home %show any [suffix ""] %? target]
]

link-up: func [location [url! email!] /as suffix [file! word!] /directive type [word!]][
	any [
		switch type [
			folder [show location]
			link [location]
		]

		switch suffix [
			%.r %.txt %.rmd %.rhd [
				show/with location suffix
			]

			index [
				show location
			]
		]

		if email? location [
			to url! join "mailto:" location
		]

		switch suffix: suffix? location [
			%.r %.reb %.red %.reds %.topaz [
				show/with location %.r
			]

			%.txt %.rmd %.rhd [show/with location suffix]
		]

		location
	]
]
