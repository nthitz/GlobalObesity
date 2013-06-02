define ["d3","jquery","lodash", "topojson", "map"], (d3,$,_,topojson,map) -> 
	
	countryData = null
	countryDataByName = null
	ranges = {}
	countryCodes = null
	codeLookup = {"code":{}, "country" :{}}
	initMain = () ->
		map.init('.map',loadCountryCodes)
	countriesCSVLoaded = (err, data) ->
		numericCols = [
			"fObese","fOver", "mObese", "mOver",
		]
		filteredData = []
		for datum in data
			include = true
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
		data = filteredData
		avgs = ['Total','Obese','Over']
		for country in data
			for avg in avgs
				countryAvg = (country['f' + avg] + country['m' + avg]) / 2
				country['avg' + avg] = countryAvg
		numericCols.push('fTotal')
		numericCols.push 'mTotal'
		numericCols.push 'avgTotal'
		numericCols.push 'avgObese'
		numericCols.push 'avgOver'
		for col in numericCols
			range = {
				min: Number.MAX_VALUE
				max: 0
			}
			for datum in data
				dVal = datum[col]
				if dVal > range['max']
					range['max'] = dVal
				if dVal < range['min']
					range['min'] = dVal
			ranges[col] = range
		
		countryData = data
		countryDataByName = {}
		for country in countryData
			countryDataByName[country.country] = country
		console.log countryData
		#displayTable()
		map.assignCountryData(data, codeLookup)
		map.countryCircles(ranges,'Total')
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
		d3.csv "data/countryNumericCodes.csv", numericCodesLoaded
	numericCodesLoaded = (err, codes) ->
		countryCodes = codes
		for code in codes
			codeLookup['code'][code['country-code']] = code
			codeLookup['country'][code['name']] = code

		d3.tsv 'data/countries.tsv', countriesCSVLoaded
	initMain()
