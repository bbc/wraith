module.exports = function (browserEngine) {
    browserEngine.evaluate(function () {
        document.body.innerHTML = '&nbsp;';
        document.body.style['background-color'] = 'red';
    });
}