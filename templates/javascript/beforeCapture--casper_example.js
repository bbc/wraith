module.exports = function (browserEngine) {
    browserEngine.wait(2000, function() {
        browserEngine.click('.ns-panel__hotspot--2');
    });
}