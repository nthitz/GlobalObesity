define [], ->
	regions = [
		{id: "africa", lbl:"Africa"}
		{id: "america", lbl: "Americas"}
		{id: "emed", lbl:"Eastern Mediterranean"}
		{id: "europe", lbl: "Europe"}
		{id: "seasia", lbl: "SE Asia"}
		{id: "wpacific", lbl: "Western Pacific"}
	]
	stats = [
		{id: "Total", lbl: "Obese + Overweight", active: true}
		{id: "Obese", lbl: "Obese"}
		{id: "Over", lbl:"Over"}
	]
	regionOptions = null
	currentStat = 'Total'
	currentRegion = 'all'
	init = (selector) ->
		regionList = d3.select(selector).append('ul').attr('class','region')
		regionOptions = []
		regionOptions.push({
			id: "all", lbl:"All", active: true
		})
		for region in regions
			region.active = false;
			regionOptions.push(region)
		regionList.selectAll('li').data(regionOptions)
			.enter().append('li').classed('active',(d) ->
				return d.active
			).text((d) ->
				return d.lbl
			)
		for stat in stats
			if typeof stat.active is 'undefined'
				stat.active = false
		statList = d3.select(selector).append('ul').attr('class','stat')
		statList.selectAll('li').data(stats)
			.enter().append('li')
			.text((d) ->
				return d.lbl
			).classed('active',(d) ->
				return d.active
			)

		d3.selectAll('ul').selectAll('li').on('click', clickOption)
	clickOption = (d,i) ->
		if d3.select(this).classed('active')
			return
		console.log d
		console.log i
		parent = $(this).parent().get(0)
		parentClass = $(parent).attr('class')
		data = null
		if parentClass is 'region'
			data = regionOptions
			currentRegion = d.id
		else if parentClass is 'stat'
			data = stats
			currentStat = d.id
		for datum in data
			datum.active = false
		d.active = true
		d3.select(parent).selectAll('li').classed('active',(d) ->
			return d.active
		)
		console.log(currentStat + " " + currentRegion)

	return {
		init: init
		setControlData: () ->

	}