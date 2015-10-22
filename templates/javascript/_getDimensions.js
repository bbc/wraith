module.exports = function (dimensions) {
    dimensions = /(\d*)x?((\d*))?/i.exec(dimensions);
    return {
        'viewportWidth':  parseInt(dimensions[1]),
        'viewportHeight': parseInt(dimensions[2] || 1500)
    };
}