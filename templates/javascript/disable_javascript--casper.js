// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (casper, ready) {
    // disable JavaScript
    casper.options.pageSettings.javascriptEnabled = false;

    // reload the page without JS enabled
    casper.thenOpen(casper.page.url);
}