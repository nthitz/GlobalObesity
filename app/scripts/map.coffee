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
	projectionFull = null
	projectionOrthogrpahic = null
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
	projections = {
		"all": {p: d3.geo.mercator().scale(80).translate([width / 2, height / 2]).rotate([0,0]).center([0,0]), angle: 180}
		"america": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([100,-10]).center([0,0]).clipAngle(90), angle: 90}
		"africa": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([-0,0]).center([0,0]).clipAngle(90), angle: 90}
		"emed": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([-13,85]).clipAngle(90), angle: 90}
		"europe": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([-10,10]).clipAngle(90), angle: 90}
		"seasia": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([-10,10]).clipAngle(90), angle: 90}
		"wpacific": {p: d3.geo.orthographic().scale(250).translate([width / 2, height / 2]).rotate([-10,10]).clipAngle(90), angle: 90}
		
	}
	curProjection = null
	init = (selector,loadedCallback) ->
		console.log(mapTooltip)
		d3.select(selector).append('div').attr('class','mapTooltip')
		mapTooltip.init('.mapTooltip')
		console.log loadedCallback
		console.log selector
		console.log d3
		svg = d3.select(selector).style('height',height+'px')
			.append('svg').attr('width',width).attr('height',height)
		g = svg.append('g')
		curProjection = projections.all
		path = d3.geo.path().projection(curProjection.p)
		###
		d3.select(selector).append('input').attr('type','button').on('click',->
			console.log svg.selectAll('.country')
			svg.selectAll(".country").transition()
				.duration(1000)
				#.attr('d',d3.geo.path().projection(projectionOrthogrpahic))
				.attrTween("d", (d) ->

					t = projectionTween(projectionFull, projections.africa,90)(d)
					return t
				);
		)
		###
		d3.json("data/data.json", (error, world) ->

			inited = true
			countryData = topojson.feature(world, world.objects.countries).features
				
			countryPaths = g.selectAll(".country").data( countryData )
				.enter().insert("path", ".graticule")
				.attr("class", "country")


				.attr("d", path)
			if loadedCallback isnt null
				console.log 'no callback'
				#loadedCallback()
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
				#console.log countryName + " " + code
			else
				_.extend(codedGeomData, country)
				codedGeomData.Lat = lookup.Lat
				codedGeomData.Long = lookup.Long
				countryCircleData.push codedGeomData
		return countryCircleData
	countryCircles = (ranges, statistic,region) ->
		console.log 'circles '
		console.log region
		region = region.id
		statistic = statistic.id
		countryPathTween = 0
		if curProjection isnt projections[region]
			countryPathTween = 1000
		console.log region
		console.log projections[region]
		countryPaths.transition().duration(countryPathTween)
			.attrTween("d",projectionTween(curProjection.p, projections[region].p, curProjection.angle, projections[region].angle))
		curProjection = projections[region]
		
		return
		
		mapTooltip.setStat(statistic)
		console.log 'country circles ' + region
		for country in countryCircleData
			p = curProjection.p([country.Long, country.Lat])
			country.center = p
			
			if region is 'all'
				country.visible = true
			else if region is country.region
				country.visible = true
			else
				country.visible = false
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
			).style('fill', neutralColor.toString())

		circles.transition().duration(1000).attr('class',(d) ->
			d.country.replace(/[\s\(\)]/g,"_") + " id"+d.id
		).attr('r',(d) ->
			d.r = circleScale(d['avg' + statistic])
		).style('fill',(d) ->
			value = d['diff' + statistic]
			if value < 0
				return maleColorScale(maleColorNormalize(value))
			else
				return femaleColorScale(femaleColorNormalize(value))
			

		).style('opacity',(d) ->
			if d.visible
				return 0.8
			else
				return 0
		)

		circles.on('mouseover', showTooltip).on('mouseout',hideTooltip)
		
		force = d3.layout.force().nodes(countryCircleData).links([]).size([width,height])
			.gravity(0)
			.charge((d) ->
				return -d.r
				if d.visible
					return -d.r
				else
					return 0.001
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
		return
		that = d3.select('circle.id'+d.id)
		that.classed('hover',true)
		#that.moveToFront()
		mapTooltip.showTooltip(d,i)
	hideTooltip = (d,i) ->
		that = d3.select('circle.id'+d.id)

		that.classed('hover',false)


	projectionTween = (projection0, projection1,clipAngle0, clipAngle1) ->
		return (d) ->
			t = 0;
			r = d3.interpolate(projection0.rotate(), projection1.rotate());
			#center = d3.interpolate(projection0.center(),projection1.center())
			
			project = (λ, φ) ->
				λ *= 180 / Math.PI
				φ *= 180 / Math.PI;
				p0 = projection0([λ, φ])
				p1 = projection1([λ, φ]);
				return [(1 - t) * p0[0] + t * p1[0], (1 - t) * -p0[1] + t * -p1[1]];
			projection = d3.geo.projection(project)
				.scale(1)
				.translate([width / 2, height / 2]);
			###
			path = d3.geo.path()
				.projection(projection);
			###
			ortho = null
			if clipAngle1 is 90 and clipAngle0 is 90
				ortho = d3.geo.orthographic().scale(250).translate([width/2,height/2])
			else
				ortho = projection
			path2 = d3.geo.path()
				.projection(ortho)
			(_) ->
				t = _;
				angle = clipAngle0 * (1-t) + clipAngle1 * t
				ortho.clipAngle(angle)

				#rotationX = rotation0[0] * (1-t) + rotation1[0] * t
				#rotationY = rotation0[1] * (1-t) + rotation1[1] * t
				#projection.rotate([rotationX, rotationY])
				if clipAngle0 is clipAngle1
					ortho.rotate(r(t))
				#projection.center(center(t))
				#projection.rotate(projection1.rotate())

				p = path2	(d)
				if typeof p is 'undefined'
					return 'M0,0 z'
				return p;
		
	  

	return {
		init: init
		assignCountryData: assignCountryData
		countryCircles:countryCircles
		showTooltip: showTooltip
		hideTooltip:hideTooltip
	}