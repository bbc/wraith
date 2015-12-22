module.exports = function (casper, ready) {

    /* you may want to test some interaction on the page */
    casper.wait(2000, function() {
        casper.click('.ns-panel__hotspot--2');
    });

    /* or you may need to make Wraith wait a bit longer before taking the screenshot */
    casper.wait(2000, ready); // you MUST call the ready() callback for Wraith to continue

    /* or you may want to see how your page looks without JavaScript */
    // casper.options.pageSettings.javascriptEnabled = false;
    // casper.thenOpen(casper.page.url);

}