REBOL [
	Title: "Desktop MakeDoc Handler"
	Date: 18-Dec-2013
	Author: "Christopher Ross-Gill"
	Exports: []
]

contents: does [
	render/custom [markup: %contents.r]
]

title: has [title][
	either parse document [
		opt ['options skip]
		['sect1 | 'para] set title block!
		some [word! skip]
	][
		title
	][
		"Document"
	]
]

