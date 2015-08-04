module.exports = function () {
    return function (casper) {
        casper.wait(2000, function() {
            casper.click('.orb-nav .istats-notrack');
        });
    }
}