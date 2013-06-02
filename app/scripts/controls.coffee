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
		{id: "both", lbl: "Obese + Overweight", active: true}
		{id: "Obese", lbl: "Obese"}
		{id: "Over", lbl:"Over"}
	]
	regionOptions = null
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
			)
	setControlData = (data) ->

	return {
		init: init
		setControlData: setControlData
	}