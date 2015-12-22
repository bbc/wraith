module.exports = function (phantom, ready) {

    /* you may want to test some interaction on the page */
    phantom.evaluate(function(){
        var a = document.querySelector('.ns-panel__hotspot--2');
        var e = document.createEvent('MouseEvents');
        e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        a.dispatchEvent(e);
        waitforload = true;
    });

    /* or you may need to make Wraith wait a bit longer before taking the screenshot */
    setTimeout(ready, 1000); // you MUST call the ready() callback for Wraith to continue

    /* or you may want to see how your page looks without JavaScript */
    // phantom.settings.javascriptEnabled = false;
    // phantom.open(phantom.page.url);

    // You can place custom headers here, example below.
    // page.customHeaders = {

    //      'X-Candy-OVERRIDE': 'https://api.live.bbc.co.uk/'

    //  };

    // If you want to set a cookie, just add your details below in the following way.

    // phantom.addCookie({
    //     'name': 'ckns_policy',
    //     'value': '111',
    //     'domain': '.bbc.co.uk'
    // });
    // phantom.addCookie({
    //     'name': 'locserv',
    //     'value': '1#l1#i=6691484:n=Oxford+Circus:h=e@w1#i=8:p=London@d1#1=l:2=e:3=e:4=2@n1#r=40',
    //     'domain': '.bbc.co.uk'
    // });

}