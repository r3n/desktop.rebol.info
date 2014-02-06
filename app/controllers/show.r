REBOL [
	Title: "Rebol Desktop Directory Viewer"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %rebtop.rsp
]

event "after" does [
	; adds a template to the 'rejected views
	title: any [title header/title]
	response/template: any [response/template header/template]
]

route () to %folder [
	verify [
		location: either empty? param: request/query-string [
			; http://www.rebol.com/view/public.r
			http://desktop.rebol.info/index.r
		][
			as url! url-decode param
		][
			reject 404 %not-a-url.rsp
		]

		all [
			require %rebtop/fetch.r
			item: fetch location
			item/disposition = 'ok
		][
			switch item/disposition [
				no-resource [reject 404 %no-resource.rsp]
				bad-address [reject 404 %not-resolved.rsp]
				redirect [
					require %display/link-up.r
					location: link-up/as item/target any [request/format 'index]
					redirect-to :location
				]
			]
		]
	]

	get [
		either item/load-index [
			require %display/link-up.r
			require %display/css-properties.r
			folder: item/content
			images?: false
			title: any [folder/title "Folder Content"]
		][
			reject 415 %not-rebol.rsp
		]
	]

	get %.r [
		either item/load-source [
			meta: item/meta
			require %display/link-up.r
			require %markup/color-code.r
			render/template color-code item/source %script.rsp
		][
			reject 415 %not-rebol.rsp
		]
	]

	get %.txt [
		require %display/link-up.r
		require %text/urls.r
		item/clean-source
		render/template %text %text.rsp
	]

	get %.rmd [
		require %makedoc/makedoc.r
		render/template make-doc/custom item/clean-source  [
			model: wrt://system/makedoc/model.r
			template: wrt://system/makedoc/makedoc.rsp
		] "<%= yield %>"
	]
]