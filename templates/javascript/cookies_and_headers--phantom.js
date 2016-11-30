// ######################################################
// This is an example module provided by Wraith.
// Feel free to amend for your own requirements.
// ######################################################
module.exports = function (phantom, ready) {

    phantom.customHeaders = {
        'SOME-HEADER': 'fish'
    };

    phantom.addCookie({
        'name': 'ckns_policy',
        'value': '111',
        'domain': '.bbc.co.uk'
    });

    phantom.addCookie({
        'name': 'locserv',
        'value': '1#l1#i=6691484:n=Oxford+Circus:h=e@w1#i=8:p=London@d1#1=l:2=e:3=e:4=2@n1#r=40',
        'domain': '.bbc.co.uk'
    });

    phantom.open(phantom.url, function () {
        setTimeout(ready, 5000);
    });
}
