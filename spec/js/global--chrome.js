var callback = arguments[arguments.length-1];
(function () {
    document.body.innerHTML = "&nbsp;";
    document.body.style['background-color'] = 'red';
    callback();
})();
