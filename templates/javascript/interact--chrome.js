var callback = arguments[arguments.length-1];
var a = document.querySelector('.some-class');
a && a.click();
setTimeout(callback, 2000);
