module.exports = function (dimensions) {
    dimensions = '' + dimensions; // cast to string

    function getWidthAndHeight(dimensions) {
        dimensions = /(\d*)x?((\d*))?/i.exec(dimensions);
        return {
            'viewportWidth':  parseInt(dimensions[1]),
            'viewportHeight': parseInt(dimensions[2] || 1500)
        };
    }

    var multipleDimensions = dimensions.split(',');

    if (multipleDimensions.length > 1) {
        return multipleDimensions.map(function (dimensions) {
            return getWidthAndHeight(dimensions);
        });
    }
    else {
        return getWidthAndHeight(dimensions);
    }
}