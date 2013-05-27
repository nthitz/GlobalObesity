var fs = require('fs');
var _ = require('underscore');
var dirs = ['africa','america','emed','europe','seasia','wpacific'];
var dir = null;
var dirIndex = 0;
var numFolderOn = 0;
var dataPath = "data/";
var lists = [
	{path:"countries", attr:"country"},
	{path:"ages",attr:"age"},
	{path:"femaleObese",attr:"fObese"},
	{path:"femaleOverweight", attr:"fOver"},
	{path:"maleObese", attr:"mObese"},
	{path:"maleOverweight",attr:"mOver"},
	{path:"samplesizes",attr:"size"},
	{path:"years",attr:"years"}
]
var dataToLoad = "null";
var countries = [];
loadFolder()
function loadFolder() {
	console.log(dirIndex);
	dir = dirs[dirIndex];
	if(typeof dir === 'undefined') {

		allCountriesLoaded();
		return;
	}
	dataToLoad = [];
	_.each(lists, function(list) {
		dataToLoad.push(_.extend({},list));
	})
		//console.log(dataToLoad);
	loadNextData(dir);
}
function allCountriesLoaded() {
	output = "";
	var keys = Object.keys(countries[0]);
	_.each(keys, function(key, keyIndex) {
		output += key;
		if(keyIndex != keys.length - 1) {
			output += ',';
		}
	})
	output += "\n";
	_.each(countries, function(country) {
	//	console.log(country.country);
		ln = "";
		_.each(keys, function(key, keyIndex) {
			ln += country[key].trim();
			if(keyIndex != keys.length - 1) {
				ln += ',';
			}
		})
		output += ln +"\n";
	})

	console.log(output);
	fs.writeFile(dataPath + "countries.csv", output);

}
function loadNextData(dir) {
	var numData = dataToLoad.length;
	for(var i = 0 ; i < numData; i++) {
		//console.log(list);
		var list = dataToLoad[i];
		 if(typeof list['data'] === 'undefined') {
			var listPath = dataPath+dir+"/"+list['path'] + '.list';
			console.log(listPath);
			fs.readFile(listPath, 'utf8', loadList)
			return;
		}
	}
	dataLoaded();
}
function dataLoaded() {
	var dataObjects = [];
	_.each(dataToLoad[0].data,function(data) {
		dataObjects.push({})
	})
	_.each(dataToLoad, function(list, listIndex) {
		_.each(list.data, function(dataVal, dataIndex) {
			dataObjects[dataIndex][list.attr] = dataVal;
		})
	})
	//console.log(dataObjects);
	_.each(dataObjects, function(data) {
		data.region = dirs[dirIndex];
		countries.push(data);
	})
	dirIndex++;
	loadFolder();
}
function loadList(err, listData) {
	if(err !== null) {
		console.log(err);
		return;
	}
	//console.log(listData);
	var numData = dataToLoad.length;
	for(var i = 0 ; i < numData; i++) {
		var list = dataToLoad[i];
		if(typeof list['data'] === 'undefined') {
			list['data'] = listData.split("\n");
			break;
		}
	}

	loadNextData(dir);		

}