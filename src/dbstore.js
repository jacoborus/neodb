
//private methods
var fs = require('fs'),
	series = require('./series');

// private properties
var path = false;


/**
 * Store constructor
 * @param  {String} dbPath Path to database folder
 */

var store = function (dbPath) {
	if (dbPath) {
		path = dbPath;
		if (!fs.existsSync( path )){
			fs.mkdir( path );
		}
	}
}


/**
 * Load selected folder (collection) or create one if not exists
 * @param  {String}   name     name of collection
 * @param {Boolean} memOnly indicator of persistant drawer
 * @param  {Function} callback signature: error, collectionData
 * @return {Object}            Drawer data
*/

store.prototype.open = function( name, memOnly, callback ){
	var drawer = {}, addFile, dPath;
	if (typeof memOnly === 'function') {
		callback = memOnly;
		memOnly = false;
	}
	dPath = path + '/' + name;

	if ( fs.existsSync( dPath )){

		addFile = function (fileName, next) {
			var filePath = dPath + "/" + fileName;
			fs.readFile( filePath, function (err, data) {
				if (err) {
					next(err);
				} else {
					drawer[fileName] = JSON.parse(data);
					return next();
				}
			});
		};

		series.each( addFile, fs.readdirSync(dPath), function( err ){
			if (callback) {
				return callback( null, drawer );
			}
		});

	} else if (!memOnly) {
		fs.mkdir( dPath, function (err) {
			if (callback){
				callback( err, drawer );
			}
		});
	}
};


store.prototype.clean = function (name, callback) {};


module.exports = store;
