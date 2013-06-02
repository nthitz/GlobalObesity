define [], ->
	tooltip = null
	init = (selector) ->
		tooltip = d3.select(selector).append('div').attr('class','tooltip')
	showTooltip = (d,i) ->
		console.log('map tt show')

	return {
		init: init
		showTooltip: showTooltip
	}