REBOL [
	Title: "Link-Up"
	Date: 24-Nov-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [link-up]
]

prefix: func [target [block! file!]][
	join qm/settings/home target
]

link-up: func [location [url! email!] /force][
	case [
		force [prefix [%show? location]]
		email? location [location]
		find [%.r %.reb %.red %.reds %.topaz] suffix? location [
			prefix [%show? location]
		]
		find [%.txt] suffix? location [
			prefix [%show.txt? location]
		]
		true [location]
	]
]
