console.log 'hey'
countryData = null
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
	
	console.log data
	countryData = data
	#displayTable()

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
d3.tsv 'data/countries.tsv', countriesCSVLoaded
