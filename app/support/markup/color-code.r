REBOL [
	Title: "Color Code"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [color-code]
]

require %markup/header.r

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

	emit-var: func [value start stop /local type out][
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

		out: sanitize copy/part start stop

		either all [
			url? value
			parse/all value [
				"http" opt "s" "://" whitelist to end
			]
		][
			rejoin [
				{<a class="dt-url" href="} out {">} out {</a>}
			]
		][
			either type [
				emit [{<var class="dt-} type {">} out {</var>}]
			][
				emit out
			]
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

		unless head? text [
			emit [
				{<var class="dt-preamble">}
				sanitize copy/part head text text
				"</var>"
			] 
		]

		parse/all text [rule]

		insert out {<pre class="code rebol">}
		append out {</pre>}
	]
]
