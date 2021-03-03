var y = 500;
var GoOn = 1;

$.fn.scrollBottom = function() {
	return $(document).height() - this.scrollTop() - this.height();
};


function SlideUp(){
	let obj = document.getElementById("movement");
	GoOn=0;
	y -=20;
	obj.style.height = y+"px";
	if (y>20)
		obj.style.height = y;
	else
		window.clearInterval(event3);
	if (y==20)
		GoOn=1;
	scroll();
}
function SlideDown() {
	let obj = document.getElementById("movement");
	y +=20;
	GoOn=0;
	obj.style.height = y+"px";
	if (y<460)
		obj.style.height = y;
		
	else
		window.clearInterval(event4);
	if (y==460)
		GoOn=1;
}

function Sliding(){
	if(y>20 & GoOn)
		event3 = window.setInterval("SlideUp()",20);
	else if(y == 20 && GoOn)
		event4 = window.setInterval("SlideDown()",20);
}

function scroll()
{
	let textarea = document.getElementById("movement");
	textarea.scrollBottom();
}