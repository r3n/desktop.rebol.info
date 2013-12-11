REBOL [
	Title: "Desktop Fetcher"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [fetch]
]

; need to separate fetch function from content-sniffer.

parse-url: func [url [url!] /local out][
	out: context [user: pass: host: port-id: path: target: scheme: none]
	net-utils/URL-Parser/parse-url/set-scheme out url
]

host: meta: folder: item: none

folder!: context [
	title: "Index"
	summary: none
	updated:
	expires:
	notice:
	image:
	color:
	text:
	over:
	stretch: grid:
	effects:
	items: none
]

item!: context [
	type:      ; 'file 'folder 'email
	target:
	name:
	text:
	over:
	stats:     ; [size date]
	info:
	icon:
	edge:
	; folder:    ; sub-folder object
	stretch: none
	rebol?: false
]

unsupported-effects: [
	  'blur | 'sharpen | 'emboss
	| 'flip pair!
	| 'clip | 'crop pair! pair!
	| 'rotate integer!
	| 'reflect pair!
	| 'invert
	| 'luma integer!
	| 'contrast integer!
	| 'tint integer!
	| 'grayscale
	| 'colorize tuple!
	| 'multiply tuple!
	| 'difference tuple!
	; | 'gradient pair! tuple! tuple!
	; | 'gradcol pair! tuple! tuple!
	; | 'gradmul pair! tuple! tuple!
	| 'key [tuple! | integer!]
	| 'shadow pair!
	| 'draw block!
	| 'arrow opt tuple! opt decimal!
	| 'cross opt tuple!
	| 'oval opt tuple!
	| 'round opt pair! opt tuple! opt integer! opt integer!
	| 'grid opt pair! opt pair! opt tuple! opt integer! opt pair!
	| 'alphamul integer!
]

resolve: use [clean][
	clean: func [path][
		either find/match path "/" [path][
			any [
				attempt [clean-path host/path/:path]
				%/index.r
			]
		]
	]

	func [path [file! url! word! email!]][
		switch type?/word path [
			url! word! email! [path]
			file! [
				rejoin [
					to url! host/scheme "://" host/host
					either host/port-id [join ":" host/port-id][""]
					clean path
				]
			]
		]
	]
]

rule: use [value][
	[
		(folder: make folder! [items: copy [] effects: copy []])

		any [
			  'title   set value string! (folder/title: value)
			| 'summary set value string! (folder/summary: value)
			| 'updated set value date!   (folder/updated: value)
			| 'expires set value date!   (folder/expires: value)
			| 'notice  set value string! (folder/notice: value)
			| 'text-color set value tuple! (folder/text: value)
				[set value tuple! (folder/over: value) | (folder/over: folder/text)]
			| 'backdrop [
				some [
					  set value 'tile (folder/stretch: 'tile)
					| set value [file! | url!] (
						folder/image: resolve value
						folder/stretch: any [folder/stretch 'fit]
					)
					; | set value path! (if 'view-root = first :value [folder/image: value])
					| set value tuple! (folder/color: value)
					| set value into [
						any [
							  set value ['fit | 'aspect | 'extend | 'tile] (folder/stretch: value)
							| ['gradient | 'gradmul | 'gradcol] copy value [opt pair! tuple! tuple!] (
								folder/stretch: 'fit
								unless pair? value/1 [insert value 1x1]
								append folder/effects context [
									type: 'gradient
									direction: value/1
									from: value/2
									thru: value/3
								]
							)
							| unsupported-effects | skip
						]
					]
				]
			]
		]

		any [
			(item: make item! [text: folder/text over: folder/over])
			set value ['file | 'folder | 'link | 'service] (item/type: value)
			some [
				  set value [file! | url! | email!] (
					item/target: resolve value
					if all [
						item/type = 'folder
						#"/" = last item/target
					][
						item/target: join item/target %index.r
					]
				)  ; | 'goto | 'help | 'console | 'quit
				| set value string! (item/name: value)
				| set value tuple!  (item/text: value)
				| set value into [integer! [date! | none]] (item/stats: value)
				; | set value path! (if 'view-root = first :value [item/target: value])
				| 'info set value string! (item/info: value)
				| 'edge (item/edge: true)
				| 'icon set value [file! | url! | word!] (item/icon: resolve value)
				| into [
					any [
						  set value ['fit | 'aspect | 'extend | 'tile] (item/stretch: value)
						| unsupported-effects
					]
				]
			]
			(
				if none? item/name [item/name: to string! item/target]
				item/icon: any [
					item/icon
					case [
						find [folder email] item/type [item/type]
						find [link service] item/type ['html]
						email? item/target ['email]
						url? item/target [
							switch/default suffix? item/target [
								%.r %.reb ['rebol]
								%.rip %.zip ['package]
								%.txt %.text ['text]
								%.htm %.html ['html]
								%.jpg %.png %.gif %.bmp ['image]
								%.doc %.dot %.rtf ['ms-word]
								%.xls %.csv ['ms-excel]
								%.pdf ['pdf]
							]['default]
						]
					]
				]
				; if none? item/image [item/image: resolve item/type]
				append folder/items item
			)
			| none skip
		]
	]
]

load-index: func [location [url!] payload [object!] /local source][
	host: parse-url location
	host/path: join %/ any [host/path ""]
	meta: take load-header payload/content
	source: attempt [load payload/content]

	if parse any [source []] rule [
		folder
	]
]

fetch: func [location [url!] /text][
	context [
		disposition: target: payload: source: meta: content: none

		target: :location

		if verify [
			payload: all [
				require %external/rest.r
				attempt [read compose [scheme: 'rest url: (location) timeout: 5]]
			][
				disposition: 'bad-address
			]

			payload/status = 200 [
				switch/default payload/status [
					301 302 303 307 308 [
						disposition: either all [
							payload/headers/location <> form location
							target: any [
								as url! payload/headers/location
								all [
									; this be a hack--whole module should be more cohesive
									host: parse-url target
									target: as file! payload/headers/location
									resolve target
								]
							]
						][
							'redirect
						][
							'no-resource
						]
					]
				][
					disposition: 'no-resource
				]
			]

			all [
				require %text/clean.r
				source: clean payload/content
			][
				disposition: 'no-header
			]

			meta: all [
				require %markup/header.r
				meta: attempt [load-header source]
				take meta
			][
				disposition: 'no-header
			]

			meta/type = 'index [
				disposition: 'script
			]
		][
			disposition: 'index
			content: load-index location payload
		]
	]
]