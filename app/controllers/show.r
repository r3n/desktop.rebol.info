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
			http://desktop.rebol.info/rebsites.r
		][
			as url! url-decode param
		][
			reject 404 %not-a-url.rsp
		]
	]

	get [
		require %rebtop/fetch.r
		item: fetch location

		switch item/disposition [
			index [
				require %display/link-up.r
				require %display/css-properties.r
				folder: item/content
				title: any [folder/title "Folder Content"]
			]

			script [
				meta: item/meta
				require %display/link-up.r
				require %markup/color-code.r
				render/template color-code item/source %script.rsp
			]

			redirect [
				require %display/link-up.r
				location: link-up/force item/target
				redirect-to :location
			]

			no-resource [reject 404 %no-resource.rsp]
			bad-address [reject 404 %not-resolved.rsp]
			no-header [reject 415 %not-rebol.rsp]
		]
	]

	get %.txt [
		require %rebtop/fetch.r
		item: fetch/text location

		switch/default item/disposition [
			redirect [
				require %display/link-up.r
				location: link-up item/target
				redirect-to :location
			]

			no-resource [reject 404 %no-resource.rsp]
			bad-address [reject 404 %not-resolved.rsp]
		][
			require %display/link-up.r
			require %text/urls.r
			render/template %text %text.rsp
		]
	]
]