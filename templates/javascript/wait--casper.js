// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (casper, ready) {
    // make Wraith wait a bit longer before taking the screenshot
    casper.wait(2000, ready); // you MUST call the ready() callback for Wraith to continue
}