module.exports = function (browserEngine) {
    browserEngine.evaluate(function(){
        var a = document.querySelector('.ns-panel__hotspot--2');
        var e = document.createEvent('MouseEvents');
        e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        a.dispatchEvent(e);
        waitforload = true;
    });
}