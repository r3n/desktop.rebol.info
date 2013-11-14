REBOL [
	Title: "CSS Properties"
	Date: 13-Nov-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [form-property]
]

form-color: func [value [tuple!]][
	rejoin either value/4 [
		["rgba(" value/1 "," value/2 "," value/3 "," either integer? value: value/4 / 255 [value][round/to value 0.01] ")"]
	][
		["rgb(" value/1 "," value/2 "," value/3")"]
	]
]

form-url: func [value [url! file!]][
	rejoin ["url('" value "')"]
]

form-property: func ['property [set-word!] values [any-type!]][
	rejoin collect [
		keep mold property
		foreach value reduce envelop values [
			keep " "
			keep switch/default type?/word value [
				url! [form-url value]
				tuple! [form-color value]
			][
				form value
			]
		]
		keep ";"
	]
]