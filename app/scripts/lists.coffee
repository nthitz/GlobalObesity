define ["map"] , (map) ->
	initListArray = [
		{var: "avg", order: 'd', title: "Most %stat% countries"}
		{var: "diff", order: "a", title: "Countries with more male %stat% than female"}
		{var: "diff", order: "d", title: "Countries with more female %stat% than male"}
		{var: "avg", order: "a", title: "Least %stat% countries"}
	]
	lists = []
	listData = []
	countryData = null
	titles = null;
	uls = null
	init = () ->
		listData = initListArray
		lists = d3.select('.viz').selectAll('.list').data(listData)
		lists.enter().append('div').attr('class','list')
		titles = lists.append('div').attr('class','list-title')
		uls = lists.append('ol')
	assignData = (data) ->
		countryData = data
	showLists = (statistic) ->
		for list in listData
			list.data = []
			for datum in countryData
				newData = _.extend({}, datum)
				newData.listVar = newData[list['var'] + statistic]
				list.data.push(newData)
			list.data.sort((a,b) ->
				aVal = a[list['var'] + statistic]
				bVal = b[list['var'] + statistic]
				if list['order'] is 'a'
					return aVal - bVal
				else if list['order'] is 'd'
					return bVal - aVal
			)
			
		titles.text((d) ->
			title = d.title
			title = title.replace('%stat%',statistic)
			return title
		)
		lis = uls.selectAll('li').data((d) ->
			return d.data
		)
		lis.enter().append('li')
		lis.text((d,i) ->

			dispVar = Math.round(d.listVar * 100) / 100
			return d.displayName + " " + dispVar
		)
		lis.on('mouseover',liHover).on('mouseout',liStopHover)
	liHover = (d,i) ->
		map.showTooltip(d,i)
	liStopHover = (d,i) ->
		map.hideTooltip(d,i)

	return {init: init, assignData:assignData, showLists: showLists}