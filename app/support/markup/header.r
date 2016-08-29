Rebol [
	Title: "Load Header"
	Date: 13-Nov-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [script? load-header]
]

system/standard/script: make system/standard/script [Type: none]

script?: use [space id mark type][
	space: charset " ^-"
	id: [
		any space mark: 
		any ["[" mark: (mark: back mark) any space]
		copy type ["Rebol" | "Red" opt "/System" | "World" | "Topaz" | "Freebell"] (
			type: first find [
				"Rebol" "Red" "Red/System" "World" "Topaz" "Freebell"
			] type
		)
		any [space | newline | crlf]
		"[" to end
	]

	func [source [string! binary!] /language][
		if all [
			parse/all source [
				some [
					id break |
					(mark: none)
					thru newline ; opt #"^M"
				]
			]
			mark
		][either language [type][mark]]
	]
]

load-header: func [[catch] source [string! binary!] /local header][
	source: to string! source
	unless header: script? source [make error! "Source does not contain header."]
	header: find next header "["
	unless header: attempt [load/next header][make error! "Header is incomplete."]
	while [mark: find header/1 any-function!][change mark "No functions here!"]
	reduce [construct/with header/1 system/standard/script header/2]
]
