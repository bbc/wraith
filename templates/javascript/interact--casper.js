// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (casper, ready) {
    // test interaction on the page
    casper.wait(2000, function() {
        casper.click('.ns-panel__hotspot--2');
        ready();
    });
}