module.exports = function (browserEngine, ready) {
    browserEngine.evaluate(function () {
        document.body.innerHTML = '&nbsp;';
        document.body.style['background-color'] = 'red';
    });
    ready();
}