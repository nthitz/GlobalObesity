define ["d3","jquery","lodash", "topojson", "map", "lists", "controls"], (d3,$,_,topojson,map,lists,controls) -> 
	
	countryData = null
	countryDataByName = null
	ranges = {}
	countryCodes = null
	codeLookup = {"code":{}, "country" :{},"alpha2":{}}
	initMain = () ->
		map.init('.map',loadCountryCodes)
		controls.init('.controls',redo)
		console.log this
		lists.init()
	redo = () ->
		stat = controls.getCurrentStat()
		map.countryCircles(ranges,stat)
		lists.showLists(stat)
	countriesCSVLoaded = (err, countryStats) ->
		numericCols = [
			"fObese","fOver", "mObese", "mOver",
		]
		filteredData = []
		for datum in countryStats
			include = true
			if datum['country'] is 'Ireland (Northern)'
				#unfortunately having Ireland and Northern Ireland is a bit problematic
				include = false
			for key in numericCols
				strVal = datum[key]
				numericVal = + strVal
				if numericVal is 0
					include = false
				datum[key] = numericVal
				datum[key + "Str"] = strVal

			datum['fTotal'] = datum['fObese'] + datum['fOver']
			datum['mTotal'] = datum['mObese'] + datum['mOver']
			if include
				filteredData.push(datum)
		numericCols.push 'fTotal'
		numericCols.push 'mTotal'

		countryStats = filteredData
		avgs = ['Total','Obese','Over']
		for avg in avgs
			numericCols.push 'avg' + avg
			numericCols.push 'diff' + avg
			for country in countryStats
				countryAvg = (country['f' + avg] + country['m' + avg]) / 2
				countryDiff = country['f' + avg] - country['m' + avg]
				country['avg' + avg] = countryAvg
				country['diff' + avg] = countryDiff

		for col in numericCols
			range = {
				min: Number.MAX_VALUE
				max: 0
			}
			for datum in countryStats
				dVal = datum[col]
				if dVal > range['max']
					range['max'] = dVal
				if dVal < range['min']
					range['min'] = dVal
			ranges[col] = range
		
		countryData = countryStats
		countryDataByName = {}
		for country in countryData
			countryDataByName[country.country] = country
		console.log countryData
		#displayTable()

		stat = 'Total'
		countryFeatureData = map.assignCountryData(countryStats, codeLookup)
		map.countryCircles(ranges,'Total')
		lists.assignData(countryFeatureData)
		lists.showLists(stat)
	displayTable = () ->
		data = countryData

		keys = Object.keys(data[0])
		data.sort (b,a) ->
			return (a['mTotal'] - a['fTotal']) - (b['mTotal'] - b['fTotal'])
		trs = d3.select('.container').append('table').selectAll('tr').data(data)
		trs.enter().append('tr')
		trs.selectAll('td').data((d) ->
			trData = []
			for key in keys
				trData.push(d[key])
			return trData
		).enter().append('td').text(String)
		d3.select('.container table').insert('tr',':first-child').selectAll('td').data(keys)
			.enter().append('td').text(String)
	loadCountryCodes = () ->
		d3.tsv "data/countryNumericCodes.tsv", numericCodesLoaded
	numericCodesLoaded = (err, codes) ->
		countryCodes = codes
		for code in codes
			codeLookup['code'][code['country-code']] = code
			codeLookup['country'][code['name']] = code
			codeLookup['alpha2'][code['alpha-2']] = code
		d3.csv 'data/countryCenters.csv', countryCentersLoaded
	countryCentersLoaded = (err, centers) ->
		for center in centers
			alpha2 = center['alpha2']
			if typeof codeLookup['alpha2'][alpha2] isnt 'undefined'
				codeLookup['alpha2'][alpha2]['Lat'] = +center['latitude']
				codeLookup['alpha2'][alpha2]['Long'] = +center['longitude']

		d3.tsv 'data/countries.tsv', countriesCSVLoaded
	initMain()
