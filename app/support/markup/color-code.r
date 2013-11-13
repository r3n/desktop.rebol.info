REBOL [
	Title: "Color Code"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [script? load-header color-code form-property]
]

system/standard/script: make system/standard/script [Type: none]

script?: use [space id mark type][
	space: charset " ^-"
	id: [
		any space mark: 
		any ["[" mark: (mark: back mark) any space]
		copy type ["REBOL" | "Red" opt "/System" | "Topaz" | "Freebell"]
		any space
		"[" to end
	]

	func [source [string! binary!] /language][
		if all [
			parse/all source [
				some [
					id break |
					(mark: none)
					thru newline opt #"^M"
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
	reduce [construct/with header/1 system/standard/script header/2]
]

color-code: use [out emit whitelist emit-var emit-header rule value][
	out: none
	emit: func [data][
		data: reduce envelop data until [append out take data empty? data]
	]

	whitelist: [
		  "reb4.me"
		| ["chat." | "www." |] "stackoverflow.com"
		| opt "www." "re" opt "-" "bol"
		| "curl."
		| opt "www." "github." ["io" | "com"] "/"
		| "opensource.org"
	]

	emit-var: func [value start stop /local type][
		either none? :value [type: "cmt"][
			if path? :value [value: first :value]
			type: either word? :value [
				any [
					all [find [Rebol Red Topaz Freebell] value "rebol"]
					all [value? :value any-function? get :value "function"]
					all [value? :value datatype? get :value "datatype"]
					"word"
				]
			][
				any [replace to-string type?/word :value "!" ""]
			]
		]

		value: either all [
			url? value
			parse/all value [
				"http" opt "s" "://" whitelist to end
			]
		][
			rejoin [
				"-[" {-a class=-|} {-dt-url-} {|- href=-|} "-" value "-" {|--} "]-" copy/part start stop "-[" {-/a-} "]-"
			]
		][
			copy/part start stop
		]

		either type [ ; (Done this way so script can color itself.)
			emit [
				"-[" {-var class=-|} {-dt-} type {-} {|--} "]-"
				value
				"-[" "-/var-" "]-"
			]
		][
			emit value
		]
	]

	rule: use [str new rule hx percent][
		hx: charset "0123456789abcdefABCDEF"
		
		percent: use [dg nm sg sp ex][
			dg: charset "0123456789"
			nm: [dg any [some dg | "'"]]
			sg: charset "-+"
			sp: charset ".,"
			ex: ["E" opt sg some dg]

			[opt sg [nm opt [ex | sp nm opt ex] | sp nm opt ex] "%"]
		]

		rule: [
			some [
				str:
				some [" " | tab] new: (emit copy/part str new) |
				[crlf | newline] (emit "^/") |
				#";" [thru newline | to end] new:
					(emit-var none str new) |
				[#"[" | #"("] (emit first str) rule |
				[#"]" | #")"] (emit first str) break |
				[8 hx | 4 hx | 2 hx] #"h" new:
					(emit-var 0 str new) |
				percent new: (emit-var 0.1 str new) |
				skip (
					; probe str
					set [value new] load/next str
					emit-var :value str new
				) :new
			]
		]

		[
			rule [end | str: to end (emit str)]
		]
	]

	func [
		[catch] "Return color source code as HTML."
		text [string!] "Source code text"
	][
		out: make binary! 3 * length? text

		unless text: script? detab text [
			make error! "Not a REBOL script."
		]

		emit [
			"-[" {-var class=-|} {-dt-preamble-} {|--} "]-"
			copy/part head text text
			"-[" "-/var-" "]-"
		] 
		parse/all text [rule]
		out: sanitize to string! out

		foreach [from to] reduce [ ; (join avoids the pattern)
			; "&" "&amp;" "<" "&lt;" ">" "&gt;" "^(A9)2" "&copy;2"
			join "-[" "-" "<" join "-" "]-" ">" join "-|" "-" {"}
		][
			replace/all out from to
		]

		insert out {<pre class="code rebol">}
		append out {</pre>}
	]
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