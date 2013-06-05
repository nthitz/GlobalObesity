define ["jquery", "d3"], ($,d3) ->
	tooltip = null
	tooltipParts = {}
	stat = null
	hideTimeout = null
	init = (selector) ->
		tooltip = d3.select(selector)
		tooltipParts.country = tooltip.append('div').attr('class','countryName')
		tooltipParts.avg = tooltip.append('div').attr('class','avgValue')
		tooltipParts.diff = tooltip.append('div').attr('class','diff')
		tooltipParts.male = tooltip.append('div').attr('class','male')
		tooltipParts.female = tooltip.append('div').attr('class','female')
	setStat = (_stat) ->
		stat = _stat
	showTooltip = (d,i) ->
		clearTimeout(hideTimeout)
		console.log('map tt show')
		console.log(d)
		circle = d3.select('circle.id' + d.id)
		x = +circle.attr('cx')
		y = +circle.attr('cy')
		r = +circle.attr('r')
		tooltipParts.country.text(d.country)
		avg = d['avg' + stat]
		diff = d['diff' + stat]
		m = d['m' + stat]
		f = d['f' + stat]
		tooltipParts.avg.text("Country Avg " + avg + "%")
		tooltipParts.diff.text(diff)
		tooltipParts.male.text(m)
		tooltipParts.female.text(f)
		ttWidth = $('.mapTooltip').width()
		tooltipY = y + r + 5
		tooltip.style('top', tooltipY + 'px').style('left',x - ttWidth/2 + 'px').style('opacity',1)
		#tooltipParts.avg.text(d.)
	hideTooltip = (d,i) ->
		clearTimeout(hideTimeout)
		hideTimeout = setTimeout(() ->
			tooltip.style('opacity',0)
		, 200)
	return {
		init: init
		showTooltip: showTooltip
		hideTooltip: hideTooltip
		setStat : setStat

	}