define ["d3",'mapTooltip'], (d3,mapTooltip) ->
    d3.selection.prototype.moveToFront = () ->
      return this.each(() ->
        this.parentNode.appendChild(this);
      );
    
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
    countryPaths = null
    countryCircleData = []
    circles = null
    countryLookups = {
        "Trinidad & Tobago" : "Trinidad and Tobago"
        "USA": "United States"
        "Uruguay  Self Report" : "Uruguay"
        "UAE" : "United Arab Emirates"
        "England"  : "United Kingdom"
        "Korea" : "South Korea"
    }
    init = (selector,loadedCallback) ->
        console.log(mapTooltip)
        mapTooltip.init()
        console.log loadedCallback
        console.log selector
        console.log d3
        svg = d3.select(selector).style('height',height+'px')
            .append('svg').attr('width',width).attr('height',height)
        g = svg.append('g')
        projection = d3.geo.mercator()
            .scale(80).translate([width / 2, height / 1.5]);
        path = d3.geo.path().projection(projection)
        console.log topojson
        d3.json("data/readme-world.json", (error, world) ->

            inited = true
            countryData = topojson.feature(world, world.objects.countries).features
                
            countryPaths = g.selectAll(".country").data( countryData )
                .enter().insert("path", ".graticule")
                .attr("class", "country")
                .attr("d", path)
            if loadedCallback isnt null
                loadedCallback()
        );
    assignCountryData = (data, codeLookup) ->
        countryCircleData = []
        for country in data
            countryName = country.country.replace(/\([^)]+\)/g,'').trim()
            if typeof countryLookups[countryName] isnt 'undefined'
                countryName = countryLookups[countryName]
            lookup = codeLookup['country']?[countryName]
            code = +lookup?['country-code']
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
                codedGeomData.Lat = lookup.Lat
                codedGeomData.Long = lookup.Long
                countryCircleData.push codedGeomData
        return countryCircleData
    countryCircles = (ranges, statistic) ->
        for country in countryCircleData
            p = projection([country.Long, country.Lat])
            country.center = p
        console.log "num circles " +countryCircleData.length
        min = ranges['avg' + statistic]['min']
        max = ranges['avg' + statistic]['max']
        diffMin = ranges['diff' + statistic]['min']
        diffMax = ranges['diff' + statistic]['max']
        femaleColor = d3.rgb(252, 141, 90)
        maleColor = d3.rgb(145,191, 219)
        neutralColor = d3.rgb(255,255,191)
        
        maleColorScale = d3.interpolateRgb(neutralColor, maleColor)
        femaleColorScale = d3.interpolateRgb(neutralColor, femaleColor)

        femaleColorNormalize = d3.scale.linear().domain([0,diffMax]).range([0,1])
        maleColorNormalize = d3.scale.linear().domain([diffMin,0]).range([1,0])

        circleScale = d3.scale.sqrt().domain([min,max]).range([3 ,20 * mapScale])
        circles = svg.selectAll('circle').data(countryCircleData)
        circles.enter().append('circle').attr('r',0)
            .attr('cx', (d) ->
                d.x = d.center[0]
            ).attr('cy', (d) ->
                d.y = d.center[1]
            ).attr('class',(d) ->
                d.country.replace(/[\s\(\)]/g,"_") + " id"+d.id

            ).style('fill', neutralColor.toString())
            .style('opacity',0.8)
        circles.transition().duration(1000).attr('r',(d) ->
            d.r = circleScale(d['avg' + statistic])
        ).style('fill',(d) ->
            value = d['diff' + statistic]
            if value < 0
                return maleColorScale(maleColorNormalize(value))
            else
                return femaleColorScale(femaleColorNormalize(value))
            

        )
        circles.on('mouseover', showTooltip).on('mouseout',hideTooltip)
        force = d3.layout.force().nodes(countryCircleData).links([]).size([width,height])
            .gravity(0)
            .charge((d) ->
                return -d.r 
            ).on('tick', forceTick)
        force.start()
        countryPaths.attr('class',(d) ->
            return 'country ' + d.country
        )
    forceTick = (e) ->
        k = .1 * e.alpha
        _.each countryCircleData, (circle, index) ->
            circle.x += (circle.center[0] - circle.x) * k
            circle.y += (circle.center[1] - circle.y) * k
        circles.attr('cx',(d) ->
            return d.x
        ).attr('cy', (d) ->
            return d.y
        )
    showTooltip = (d,i) ->
        console.log('show')
        that = d3.select('circle.id'+d.id)
        console.log(that)
        that.classed('hover',true)
        that.moveToFront()
        mapTooltip.showTooltip(d,i)
    hideTooltip = (d,i) ->
        console.log('hide');
        that = d3.select('circle.id'+d.id)

        that.classed('hover',false)
    return {
        init: init
        assignCountryData: assignCountryData
        countryCircles:countryCircles
        showTooltip: showTooltip
        hideTooltip:hideTooltip
    }