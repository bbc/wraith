module.exports = function (casper) {
    casper.evaluate(function () {
        document.body.innerHTML = '&nbsp;';
        document.body.style['background-color'] = 'red';
    });
}