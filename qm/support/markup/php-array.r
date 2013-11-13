REBOL [
	Title: "Load PHP Array"
	Date: 14-Aug-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [load-php-array]
]

load-php-array: use [
	branch tree here emit val
	new-child neaten to-parent
	space comment comma number string block array value
][
	branch: make block! 10

	emit: func [val][here: insert/only here val]
	new-child: [(insert/only branch insert/only here here: copy [])]
	to-parent: [(here: take branch)]
	neaten: [
		(new-line/all head here true)
		(new-line/all/skip head here true 2)
	]

	comment: ["//" thru newline]

	space: use [space][
		space: charset " ^-^/^M"
		[any [space | comment]]
	]

	comma: [space #"," space]

	number: use [dg ex nm as-num][
		dg: charset "0123456789"
		ex: [[#"e" | #"E"] opt [#"+" | #"-"] some dg]
		nm: [opt #"-" some dg opt [#"." some dg] opt ex]

		as-num: func [val /num][
			num: load val

			all [
				parse val [opt "-" some dg]
				decimal? num
				num: to-issue val
			]

			num
		]

		[copy val nm (val: as-num val)]
	]

	string: use [ch dq es hx mp decode][
		ch: complement charset {\'}
		es: charset {'\/bfnrt}
		hx: charset "0123456789ABCDEFabcdef"
		mp: [#"^"" "^"" #"\" "\" #"/" "/" #"b" "^H" #"f" "^L" #"r" "^M" #"n" "^/" #"t" "^-"]

		decode: use [ch mk escape to-utf-char][
			to-utf-char: use [os fc en][
				os: [0 192 224 240 248 252]
				fc: [1 64 4096 262144 16777216 1073741824]
				en: [127 2047 65535 2097151 67108863 2147483647]

				func [int [integer!] /local char][
					repeat ln 6 [
						if int <= en/:ln [
							char: reduce [os/:ln + to integer! (int / fc/:ln)]
							repeat ps ln - 1 [
								insert next char (to integer! int / fc/:ps) // 64 + 128
							]
							break
						]
					]

					to-string to-binary char
				]
			]

			escape: [
				mk: #"\" [
					  es (mk: change/part mk select mp mk/2 2)
					| #"u" copy ch 4 hx (
						mk: change/part mk to-utf-char to-integer to-issue ch 6
					)
				] :mk
			]

			func [text [string! none!] /mk][
				either none? text [copy ""][
					all [parse/all text [any [to "\" escape] to end] text]
				]
			]
		]

		[#"'" copy val [any [some ch | #"\" [#"u" 4 hx | es]]] #"^'" (val: decode val)]
	]

	block: use [list][
		list: [space opt [value any [comma value]] space]

		[#"[" new-child list #"]" neaten/1 to-parent]
	]

	array: use [name list][
		name: [string space "=>" space (emit val)]
		list: [space opt [name value any [comma name value]] space]

		["array(" new-child list ")" neaten/2 to-parent]
	]

	value: [
		  "null" (emit none)
		| "true" (emit true)
		| "false" (emit false)
		| number (emit val)
		| string (emit val)
		| array | block
	]

	func [
		[catch] "Convert a PHP Array string to rebol data"
		source [string! binary! file! url!] "Array string"
		name [word!] "Find the Array assigned to this word"
	][
		tree: here: copy []
		name: rejoin ["$" form name " = "]

		if any [file? source url? source][
			if error? source: try [read (source)][
				throw :source
			]
		]

		unless parse/all source [
			thru name space array space to end
		][
			make error! "Not a valid ARRAY location."
		]

		pick tree 1
	]
]