var e = document.createElement('link')
e.setAttribute('href', 'http://localhost/erlang-doc-fix.css')
e.setAttribute('rel', 'stylesheet')
document.head.appendChild(e)

var list = document.querySelectorAll('a')
for (var i = 0; i < list.length; ++i) {
	var item = list[i]
	var name = item.getAttribute('name')
	if (name && /-\d+$/.test(name)) {
		console.log(item)
		var parent = item.parentElement
		parent.classList.add('function')
	}
}
