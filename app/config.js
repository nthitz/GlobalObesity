requirejs.config({
    baseUrl: './scripts/',
    shim: {
        d3: {
            exports: 'd3'
        }
    },
    paths: {
        jquery: '../bower_components/jquery/jquery',
        modernizr: '../bower_components/modernizr',
        topojson: '../bower_components/topojson/topojson',
        d3: '../bower_components/d3/d3',
        lodash: '../bower_components/lodash/lodash'
    }
});