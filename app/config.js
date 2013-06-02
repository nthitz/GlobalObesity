requirejs.config({
    baseUrl: './scripts/',
    
    paths: {
        jquery: '../bower_components/jquery/jquery',
        modernizr: '../bower_components/modernizr',
        topojson: '../bower_components/topojson/topojson',
        d3: '../bower_components/d3/d3.min',
        lodash: '../bower_components/lodash/dist/lodash.compat'
    },
    
    shim: {
        d3: {
            exports: 'd3'
        }
    }
    
});