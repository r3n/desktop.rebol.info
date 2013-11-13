REBOL [
	Title: "Rebol Desktop Directory Viewer"
	Date: 21-Oct-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %rebtop.rsp
]

event "before" does [
	require %markup/color-code.r
	require %rebtop/index.r

	link-up: func [location [url!]][
		join settings/home [%show? location]
	]

	title: "Rebtop Viewer"

	export [link-up]
]

event "after" does [
	response/template: any [response/template header/template]
]

route () to %folder [
	verify [
		location: either empty? param: request/query-string [
			http://www.rebol.com/view/public.r
		][
			as url! url-decode param
		][
			reject 404 %not-a-url.rsp
		]

		; resp: attempt [
		payload: do [
			require %external/rest.r
			attempt [read compose [scheme: 'rest url: (location) timeout: 5]]
		][
			reject 404 %not-resolve.rsp
		]

		payload/status = 200 [
			switch/default payload/status [
				301 302 303 307 308 [
					if all [
						payload/headers/location <> form location
						location: as url! payload/headers/location
					][
						location: link-up location
						redirect-to :location
					]
				]
			][
				reject 404 %not-connect.rsp
			]
		]


		meta: all [
			meta: attempt [load-header source: payload/content]
			take meta
		][
			reject 415 %not-rebol.rsp
		]
	]

	get [
		switch/default meta/type [
			index [
				folder: load-index location payload
				title: any [folder/title "Folder Content"]
			]
		][
			render/template color-code source %script.rsp
		]
	]
]