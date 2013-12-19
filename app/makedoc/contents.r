REBOL [
	Title: "Table of Contents HTML Emitter"
	Type: 'emitter
]

;-- Helpers
require %text/wordify.r

feed: does [emit newline]

;-- Paragraph States
initial: [
	sect1: (
		feed emit <div class="sidebar hidden-print">
		feed emit <ul class="nav">
		feed emit [{<li><a href="#} wordify form-para data {">}] emit-inline data emit {</a></li>}
	)
	in-sect1
	(feed emit </ul> feed emit </div>)
]

in-sect1: [
	sect1: continue return
	sect2: (emit <ul>) continue in-sect2 (feed emit </ul>)
]

in-sect2: [
	sect2: (emit [{<li><a href="#} wordify form-para data {">}] emit-inline data emit {</a></li>})
	default: continue return
]

;-- Inline States
inline: [
	<p> ()
	default: continue paragraph
]

in-code?: 0

paragraph: [
	:string! (emit value)
	<b> (emit <b>) in-bold (emit </b>)
	<u> (emit <em>) in-underline (emit </em>)
	<i> (emit <i>) in-italic (emit </i>)
	<q> (emit <q>) in-qte (emit </q>)
	<dfn> (emit <dfn>) in-dfn (emit </dfn>)
	<del> (emit <del>) in-del (emit </del>)
	<ins> (emit <ins>) in-ins (emit </ins>)
	<cite> (emit <cite>) in-cite (emit </cite>)
	<var> <code>
		(if 0 = in-code? [emit <code>] ++ in-code?) in-code
		(-- in-code? if 0 = in-code? [emit </code>])
	<apos> (emit "&#8216;") </apos> (emit "&#8217;")
	<quot> (emit "&#8220;") </quot> (emit "&#8221;")
	<initial> (emit <span class="initial">) in-initial (emit </span>)
	<br> <br/> <br /> (emit <br/>)
	<sb> (cursor/mark hold "[") in-link? (emit/at-mark release cursor/unmark)
	</sb> (emit "]")
	:integer! :char! (emit ["&#" to integer! value ";"])
	</> ()
	default: (emit "[???]")
]

in-link?: inherit paragraph [
	</sb> (hold "]") in-link (emit release)
]

in-link: [
	:paren! (
		change stack reduce [</a> make-smarttag join [a] value]
	) return return
	default: continue return return
]

in-bold: inherit paragraph [</b> return </> continue return]

in-underline: inherit paragraph [</u> return </> continue return]

in-italic: inherit paragraph [</i> return </> continue return]

in-qte: inherit paragraph [</q> return </> continue return]

in-dfn: inherit paragraph [</dfn> return </> continue return]

in-del: inherit paragraph [</del> return </> continue return]

in-ins: inherit paragraph [</ins> return </> continue return]

in-cite: inherit paragraph [</cite> return </> continue return]

in-code: inherit paragraph [
	</var> </code> return
	<apos> </apos> (emit "'")
	<quot> </quot> (emit {"})
	</> continue return
]

in-initial: inherit paragraph [</initial> return </> continue return]
