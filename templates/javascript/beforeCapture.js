module.exports = function (casper) {
    casper.wait(2000, function() {
        casper.click('.ns-panel__hotspot--2');
    });
}