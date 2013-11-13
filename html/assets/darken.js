
var setShade = function(shade) {
	document.body.className = shade == 'dark' ? 'script dark' : 'script';
}

var setCookie = function(name,value) {
	document.cookie = name + "=" + value + "; path=/";
}

document.addEventListener('keyup', function(event) {
	if(event.keyCode == 68) {
		setShade('dark');
		setCookie('shade','dark');
	}
	else if(event.keyCode == 76) {
		setShade('light');
		setCookie('shade','light');
	}
});

window.addEventListener('load', function () {
	var cookie, cookies = document.cookie.split(';');
	while (cookie = cookies.pop()) {
		if (cookie.trim().match(/shade=dark/)) {setShade('dark');}
		else if (cookie.trim().match(/shade=light/)) {setShade('light');}
	}
})