#define ["d3",'mapTooltip'], (d3,mapTooltip) ->
class Map
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
	projectionName = "mercator"
	curRotation = null
	dotForce = null
	mapTooltip = new MapTooltip()
	countryLookups = {
		"Trinidad & Tobago" : "Trinidad and Tobago"
		"USA": "United States"
		"Uruguay  Self Report" : "Uruguay"
		"UAE" : "United Arab Emirates"
		"England"  : "United Kingdom"
		"Korea" : "South Korea"
	}
	projectionLookup = {
		"mercator": d3.geo.mercator().scale(70).translate([width/2, height/2])
		"orthographic": d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90)
	}
	projections = {
		"all": {name: "mercator", p:d3.geo.mercator().scale(70).translate([width/2, height/2]).clipAngle(180)}
		"america": {name: "orthographic", angle: 90, rotate:[100,-10], p:d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate([100,-10])}
		"africa": {name: "orthographic", angle: 90, rotate:[-10,0], p:d3.geo.orthographic().scale(240).translate([width/2, height/2]).clipAngle(90).rotate([-10,0])}
		"emed": {name: "orthographic", angle: 90, rotate:[-30,-20], p:d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate([-30,-20])}
		"europe": {name: "orthographic", angle: 90, rotate:[0,-40], p:d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate([0,-40])}
		"seasia": {name: "orthographic", angle: 90, rotate:[-100,-20], p:d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate([-100,-20])}
		"wpacific": {name: "orthographic", angle: 90, rotate:[-150,20], p:d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate([-150,20])}
		
	}
	curProjection = null
	init: (selector,loadedCallback) ->
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
		console.log projectionLookup.mercator
		path = d3.geo.path().projection(projectionLookup.mercator)
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
				loadedCallback()
		);
	assignCountryData: (data, codeLookup) ->
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
	countryCircles: (ranges, statistic,region) ->
		console.log 'circles '
		console.log region
		region = region.id
		statistic = statistic.id
		newProjection = projections[region]
		curRotation = [0,0]
		console.log newProjection
		if curProjection.p isnt newProjection.p
			console.log 'tween'
			console.log curProjection
			console.log newProjection
			countryPaths.transition().duration(1000)
				.attrTween("d",projectionTween(curProjection, newProjection))
		
		
		curProjection = newProjection
		###
		if newProjection.name isnt projectionName
			if newProjection.name is 'orthographic'
				console.log 'rotating to '
				console.log newProjection.rotate
				curRotation = newProjection.rotate
				transitionToOrthographic(newProjection.rotate)
			else if newProjection.name is 'mercator'
				transitionToMercator()
		else
			#same projection type
			if newProjection.name is 'orthographic'
				transitionRotation(newProjection.rotate)
		###
		###
		countryPathTween = 0
		if curProjection isnt projections[region]
			countryPathTween = 1000
		console.log region
		console.log projections[region]

		countryPaths.transition().duration(countryPathTween)
			.attrTween("d",projectionTween(curProjection.p, projections[region].p, curProjection.angle, projections[region].angle))
		curProjection = projections[region]
		###
		
		mapTooltip.setStat(statistic)
		
		dotProjection = null
		if newProjection.name is 'mercator'
			dotProjection = projectionLookup[newProjection.name]
		else if newProjection.name is 'orthographic'
			dotProjection = d3.geo.orthographic().scale(250).translate([width/2, height/2]).clipAngle(90).rotate(newProjection.rotate)
		console.log 'country circles ' + region
		for country in countryCircleData
			p = null

			p = dotProjection([country.Long, country.Lat])
			country.center = p
			
			if region is 'all'
				country.visible = true
			else if region is country.region
				country.visible = true
			else
				country.visible = false
		console.log "num circles " +countryCircleData.length
		console.log ranges
		###
		min = ranges['avg' + statistic]['min']
		max = ranges['avg' + statistic]['max']
		diffMin = ranges['diff' + statistic]['min']
		diffMax = ranges['diff' + statistic]['max']
		###
		min = ranges['avg'][0]
		max = ranges['avg'][1]
		diffMin = ranges['diff'][0]
		diffMax = ranges['diff'][1]
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
			d.country.replace(/[\s\(\)]/g,"_") + " id"+d.id + " " + (if d.visible then "visible" else "hidden")
		).attr('r',(d) ->
			r = circleScale(d['avg' + statistic])
			if r < 0
				r = 0
			d.r = r

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


		circles.on('mouseover', @showTooltip).on('mouseout',@hideTooltip)
		
		dotForce = d3.layout.force().nodes(countryCircleData).links([]).size([width,height])
			.gravity(0)
			.charge((d) ->
				return -d.r
				if d.visible
					return -d.r
				else
					return 0.001
			).on('tick', forceTick)
		dotForce.start()
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
	showTooltip:(d,i) ->
		that = d3.select('circle.id'+d.id)
		that.classed('hover',true)
		#that.moveToFront()
		mapTooltip.showTooltip(d,i)
	hideTooltip: (d,i) ->
		that = d3.select('circle.id'+d.id)

		that.classed('hover',false)
		mapTooltip.hideTooltip(d,i)
	transitionRotation = (rotation) ->
		countryPaths.transition().duration(400).delay(10)
			.attrTween("d",rotationTween( curRotation, rotation))
		setTimeout(() ->
			dotForce.start()
		,400)
	transitionToOrthographic = (finalRotation) ->
		transToOrthDur = 500
		countryPaths.transition().duration(transToOrthDur)
			.attrTween("d",projectionTween(projectionLookup.mercator, projectionLookup.orthographic, 180, 90))
		projectionName = "orthographic"
		
		setTimeout(() ->
			dotForce.start()
			countryPaths.transition().duration(400).delay(10)
				.attrTween("d",rotationTween([0,0], finalRotation))
		,transToOrthDur + 50)
	transitionToMercator = () ->
		console.log projectionLookup.mercator
		backToAfricaDur = 500
		countryPaths.transition().duration(backToAfricaDur)
			.attrTween("d",rotationTween(curRotation, [0,0]))

		setTimeout(() ->
			dotForce.start()
			countryPaths.transition().duration(400)
				.attrTween("d",projectionTween(projectionLookup.orthographic, projectionLookup.mercator, 90, 180))
		, backToAfricaDur + 50)
		projectionName = "mercator"
	rotationTween = (r0, r1) ->
		return (d) ->
			r = d3.interpolate(r0,r1);
			t = 0
			projection = projectionLookup.orthographic
			p = d3.geo.path().projection(projection)
			(_) ->
				t = _
				projection.rotate(r(t))
				if typeof p is 'undefined'
					return 'M0,0 z'
				return p(d)
	projectionTween = (projectionA, projectionB,clipAngle0, clipAngle1) ->
		return (d) ->
			t = 0;
			aType = projectionA.name
			bType = projectionB.name
			projection0 = projectionA.p
			projection1 = projectionB.p
			ta = projection0.translate()
			tb = projection1.translate()
			ra = projection0.rotate()
			rb = projection1.rotate()
			ca = projection0.center()
			cb = projection1.center()
			scaleA = projection0.scale()
			scaleB = projection1.scale()
			clipA = projection0.clipAngle()
			clipB = projection1.clipAngle()
			#r = d3.interpolate(projection0.rotate(), projection1.rotate());
			#center = d3.interpolate(projection0.center(),projection1.center())
			
			startP = null
			endP = null
			startP = d3.geo[aType]().scale(scaleA).clipAngle(clipA)
			endP = d3.geo[bType]().scale(scaleB).clipAngle(clipB)

			project = (λ, φ) ->
				λ *= 180 / Math.PI
				φ *= 180 / Math.PI;
				p0 = startP([λ, φ])
				p1 = endP([λ, φ]);
				return [(1 - t) * p0[0] + t * p1[0], (1 - t) * -p0[1] + t * -p1[1]];
			raw = (λ, φ) ->
				pa = projection0([λ *= 180 / Math.PI, φ *= 180 / Math.PI])
				pb = projection1([λ, φ]);
				return [(1 - t) * pa[0] + t * pb[0], (t - 1) * pa[1] - t * pb[1]];
			
			projection = d3.geo.projection(project)
				.scale(1)
				.translate([width / 2, height / 2]);
			###
			path = d3.geo.path()
				.projection(projection);
			###
			path2 = d3.geo.path()
				.projection(projection)
			(_) ->
				t = _;
				projection.center([(1 - t) * ca[0] + t * cb[0], (1 - t) * ca[1] + t * cb[1]])
				projection.translate([(1 - t) * ta[0] + t * tb[0], (1 - t) * ta[1] + t * tb[1]])
				projection.rotate([(1 - t) * ra[0] + t * rb[0], (1 - t) * ra[1] + t * rb[1]])

				#projection.scale((1 - t) * scaleA + t * scaleB)
				#projection.scale()
				angle = clipA * (1-t) + clipB * t
				projection.clipAngle(angle)

				#rotationX = rotation0[0] * (1-t) + rotation1[0] * t
				#rotationY = rotation0[1] * (1-t) + rotation1[1] * t
				#projection.rotate([rotationX, rotationY])
				#if clipAngle0 is clipAngle1
				#ortho.rotate(r(t))
				#projection.center(center(t))
				#projection.rotate(projection1.rotate())

				p = path2	(d)
				if typeof p is 'undefined'
					return 'M0,0 z'
				return p;
	interpolatedProjection = (a, b) ->
		raw =(λ, φ) ->
			pa = a([λ *= 180 / Math.PI, φ *= 180 / Math.PI])
			pb = b([λ, φ]);
			return [(1 - α) * pa[0] + α * pb[0], (α - 1) * pa[1] - α * pb[1]];
	
		projection = d3.geo.projection(raw).scale(1)
		center = projection.center
		translate = projection.translate
		α = null
		projection.alpha = (_) ->
			if !arguments.length then return α;
			α = +_;
			ca = a.center()
			cb = b.center()
			ta = a.translate()
			tb = b.translate()
			center([(1 - α) * ca[0] + α * cb[0], (1 - α) * ca[1] + α * cb[1]]);
			translate([(1 - α) * ta[0] + α * tb[0], (1 - α) * ta[1] + α * tb[1]]);
			return projection;
		delete projection.scale;
		delete projection.translate;
		delete projection.center;
		return d3.geo.path().projection(projection)
		return projection.alpha(0);

	
###
	return {
		init: init
		assignCountryData: assignCountryData
		countryCircles:countryCircles
		showTooltip: showTooltip
		hideTooltip:hideTooltip
	}
	###
window.Map = Map