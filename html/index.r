REBOL [
	Title: "Rebol Desktop Project"
	Date: 13-Dec-2013
	Author: "Christopher Ross-Gill"
	Type: 'index
]

title "The Rebol Desktop Project"
backdrop 140.160.140 [
	gradient 0x0 200.180.120 150.170.150 grid 150.170.150
]
; summary ""

file " About " %readme.txt icon read
info "About this site"

folder "Sites" %rebsites.r icon site
info "World Wide Reb Sites"

link "Source" https://github.com/revault/desktop.rebol.info
info "This project's source on GitHub"

link "Chat" http://rebolsource.net/go/chat-faq
icon http://cdn.sstatic.net/stackoverflow/img/apple-touch-icon.png
info "[Rebol and Red]"

link "Rebol" http://rebol.com/
info "Home of Rebol"

link "Red" http://red-lang.org
info "Home of Red"