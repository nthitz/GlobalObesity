define ["jquery", "d3"], ($,d3) ->
	tooltip = null
	tooltipParts = {}
	stat = null
	hideTimeout = null
	diffBlockScale = d3.scale.linear().domain([0,100]).range([0,100])
	tooltipWidth = 300
	init = (selector) ->
		tooltip = d3.select(selector)
		tooltipParts.country = tooltip.append('div').attr('class','countryName')
		tooltipParts.avg = tooltip.append('div').attr('class','avgValue')
		block = tooltip.append('div').attr('class','blocks')

		tooltipParts.diff = block.append('div').attr('class','diff')
		tooltipParts.diffLbl = tooltipParts.diff.append('div').attr('class','lbl')
		tooltipParts.male = block.append('div').attr('class','male')
		tooltipParts.female = block.append('div').attr('class','female')
	setStat = (_stat) ->
		stat = _stat
	showTooltip = (d,i) ->
		clearTimeout(hideTimeout)
		#console.log('map tt show')
		#console.log(d)
		circle = d3.select('circle.id' + d.id)
		x = +circle.attr('cx')
		
		
		y = +circle.attr('cy')
		r = +circle.attr('r')
		x = 10
		y = 10
		r = 10
		tooltipParts.country.text(d.country)
		avg = d['avg' + stat]
		diff = d['diff' + stat]
		m = d['m' + stat]
		f = d['f' + stat]
		barOffset = 0
		l = tooltipWidth/2
		barWidth = diffBlockScale(Math.abs(diff))
		if diff < 0
			l -= barWidth
			tooltipParts.diff.classed('male',true)
			tooltipParts.diff.classed('female',false)
		else
			tooltipParts.diff.classed('male',false)
			tooltipParts.diff.classed('female',true)

		tooltipParts.diff.style('left', l + 'px').style('width',barWidth + 'px')
		tooltipParts.avg.text("Country Avg " + pctString(avg))
		tooltipParts.diffLbl.text(pctString(diff))
		tooltipParts.male.text(pctString(m))
		tooltipParts.female.text(pctString(f))
		ttWidth = $('.mapTooltip').width()
		tooltipY = y + r + 5
		tooltip.style('top', tooltipY + 'px').style('left',x - ttWidth/2 + 'px').style('opacity',1)
		#tooltipParts.avg.text(d.)
	pctString = (string) ->
		return Math.round(string * 10) / 10 + '%'
	hideTooltip = (d,i) ->
		return
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