define [], ->
	tooltip = null
	tooltipParts = {}
	stat = null
	init = (selector) ->
		tooltip = d3.select(selector).append('div').attr('class','tooltip')
		tooltipParts.country = tooltip.append('div').attr('class','countryName')
		tooltipParts.avg = tooltip.append('div').attr('class','avgValue')
		tooltipParts.diff = tooltip.append('div').attr('class','diff')
		tooltipParts.male = tooltip.append('div').attr('class','male')
		tooltipParts.female = tooltip.append('div').attr('class','female')
	setStat = (_stat) ->
		stat = _stat
	showTooltip = (d,i) ->
		console.log('map tt show')
		console.log(d)
		circle = d3.select('circle.id' + d.id)
		x = circle.attr('cx')
		y = circle.attr('cy')
		tooltipParts.country.text(d.country)
		avg = d['avg' + stat]
		diff = d['diff' + stat]
		m = d['m' + stat]
		f = d['f' + stat]
		tooltipParts.avg.text(avg)
		tooltipParts.diff.text(diff)
		tooltipParts.male.text(m)
		tooltipParts.female.text(f)
		#tooltipParts.avg.text(d.)

	return {
		init: init
		showTooltip: showTooltip
		setStat : setStat
	}