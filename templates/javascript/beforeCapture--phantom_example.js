module.exports = function (phantom) {

    /* you may want to test some interaction on the page */
    phantom.evaluate(function(){
        var a = document.querySelector('.ns-panel__hotspot--2');
        var e = document.createEvent('MouseEvents');
        e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        a.dispatchEvent(e);
        waitforload = true;
    });

    /* or you may want to see how your page looks without JavaScript */
    // phantom.settings.javascriptEnabled = false;
    // phantom.open(phantom.page.url);

}