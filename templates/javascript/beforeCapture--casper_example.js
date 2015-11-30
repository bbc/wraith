module.exports = function (casper) {

    /* you may want to test some interaction on the page */
    casper.wait(2000, function() {
        casper.click('.ns-panel__hotspot--2');
    });

    /* or you may want to see how your page looks without JavaScript */
    // casper.options.pageSettings.javascriptEnabled = false;
    // casper.thenOpen(casper.page.url);

}