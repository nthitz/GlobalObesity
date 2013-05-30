console.log 'hey'
countriesCSVLoaded = (err, data) ->
	numericCols = [
		"fObese","fOver", "mObese", "mOver",
	]
	for datum in data
		for key in numericCols
			strVal = datum[key]
			numericVal = + strVal
			datum[key] = numericVal
			datum[key + "Str"] = strVal
		datum['fTotal'] = datum['fObese'] + datum['fOver']
		datum['mTotal'] = datum['mObese'] + datum['mOver']

	keys = Object.keys(data[0])
	console.log keys
	console.log data
	data.sort (b,a) ->
		return (a['mTotal'] - a['fTotal']) - (b['mTotal'] - b['fTotal'])
		return (a['mObese'] - a['fObese']) - (b['mObese'] - b['fObese'])
		comparator = 'mObese'
		return a[comparator]  - b[comparator]
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
