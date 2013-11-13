REBOL [
	Title: "Rebol Index Parser"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'module
	Exports: [load-index]
]

parse-url: func [url [url!] /local out][
	out: context [user: pass: host: port-id: path: target: scheme: none]
	net-utils/URL-Parser/parse-url/set-scheme out url
]

load-index: get in context [
	host: meta: folder: icon: none

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
		icons: none
	]

	icon!: context [
		type:      ; 'file 'folder 'email
		item:
		name:
		text:
		over:
		stats:     ; [size date]
		info:
		image:
		edge:
		; folder:    ; sub-folder object
		stretch: none
		link: does [
			case [
				type = 'folder [
					link-up item
				]
				find [%.r %.reb] suffix? item [
					link-up item
				]
				true [item]
			]
		]
		icon: does [
			any [
				image
				join settings/home/assets/icons/(
					switch/default type [
						folder email [form type]
						link service ["html"]
					][
						switch/default suffix? item [
							%.r %.reb ["rebol"]
							%.rip %.zip ["package"]
							%.txt %.text ["text"]
							%.htm %.html ["html"]
							%.jpg %.png %.gif %.bmp ["image"]
							%.doc %.dot %.rtf ["ms-word"]
							%.xls %.csv ["ms-excel"]
							%.pdf ["pdf"]
						][
							either email? item ["email"]["default"]
						]
					]
				) %.png
			]
		]
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
		| 'gradient pair! tuple! tuple!
		| 'gradcol pair! tuple! tuple!
		| 'gradmul pair! tuple! tuple!
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
				url! email! [path]
				word! [join settings/home/assets/icons/(path) %.png]
						  ; ^^^ This should perhaps be determined by the View
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
			(folder: make folder! [icons: copy [] effects: copy []])

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
						| set value [file! | url!] (folder/image: resolve value)
						; | set value path! (if 'view-root = first :value [folder/image: value])
						| set value tuple! (folder/color: value)
						| set value into [
							any [
								  set value ['fit | 'aspect | 'extend | 'tile] (folder/stretch: value)
								| ['gradient | 'gradmul | 'gradcol] copy value [opt pair! tuple! tuple!] (
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
				(icon: make icon! [text: folder/text over: folder/over])
				set value ['file | 'folder | 'link | 'service] (icon/type: value)
				some [
					  set value [file! | url! | email!] (
						icon/item: resolve value
						if all [
							icon/type = 'folder
							#"/" = last icon/item
						][
							icon/item: join icon/item %index.r
						]
					)  ; | 'goto | 'help | 'console | 'quit
					| set value string! (icon/name: value)
					| set value tuple!  (icon/text: value)
					| set value into [integer! [date! | none]] (icon/stats: value)
					; | set value path! (if 'view-root = first :value [icon/item: value])
					| 'info set value string! (icon/info: value)
					| 'edge (icon/edge: true)
					| 'icon set value [file! | url! | word!] (icon/image: resolve value)
					| into [
						any [
							  set value ['fit | 'aspect | 'extend | 'tile] (icon/stretch: value)
							| unsupported-effects
						]
					]
				]
				(
					if none? icon/name [icon/name: to-string icon/item]
					; if none? icon/image [icon/image: resolve icon/type]
					append folder/icons icon
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
] 'load-index
