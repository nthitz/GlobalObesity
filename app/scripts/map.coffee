define ["d3"], (d3) ->
    console.log(d3)
    console.log('what')
    mapScale = 0.666
    width = 960 * mapScale
    height = 500 * mapScale
    console.log width + " " + height
    svg = null
    projection = null
    path = null
    inited = false
    countryData = null
    countryLookups = {
        "Trinidad & Tobago" : "Trinidad and Tobago"
        "USA": "United States"
        "Uruguay  Self Report" : "Uruguay"
        "UAE" : "United Arab Emirates"
        "England"  : "United Kingdom"
        "Korea" : "South Korea"
    }
    init = (selector,loadedCallback) ->
        console.log loadedCallback
        console.log selector
        console.log d3
        svg = d3.select(selector).append('svg').attr('width',width).attr('height',height)
        g = svg.append('g')
        projection = d3.geo.mercator()
            .scale(100).translate([width / 2, height / 1.8]);
        path = d3.geo.path().projection(projection)
        console.log topojson
        d3.json("data/readme-world.json", (error, world) ->

            inited = true
            countryData = topojson.feature(world, world.objects.countries).features
            for countryFeature in countryData
                countryFeature.center = path.centroid(countryFeature)
            g.selectAll(".country").data( countryData )
                .enter().insert("path", ".graticule")
                .attr("class", "country")
                .attr("d", path)
            if loadedCallback isnt null
                loadedCallback()
        );
    assignCountryData = (data, codeLookup) ->
        for country in data
            countryName = country.country.replace(/\([^)]+\)/g,'').trim()
            if typeof countryLookups[countryName] isnt 'undefined'
                countryName = countryLookups[countryName]
            code = +codeLookup['country'][countryName]?['country-code']
            country.displayName = countryName
            if isNaN code
                #console.error 'couldn\'t find iso code for ' + countryName
                continue
            codedGeomData = null
            for geomData in countryData
                if geomData.id is code
                    codedGeomData = geomData
                    break
            if codedGeomData is null
                console.log countryName + " " + code
            else
                _.extend(codedGeomData, country)
                console.log codedGeomData


            #console.log code
    countryCircles = (ranges, statistic) ->
        console.log ranges
        

    return {init: init, assignCountryData: assignCountryData, countryCircles:countryCircles}