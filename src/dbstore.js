
//private methods
var fs = require('fs'),
	async = require('async'),
	deleteFolderRecursive;

deleteFolderRecursive = function( path ){
	if (fs.existsSync( path )) {
		fs.readdirSync( path ).forEach( function( file, index ){
			var curPath = path + "/" + file;
			fs.statSync( curPath ).isDirectory() ? deleteFolderRecursive( curPath ) : fs.unlinkSync( curPath );
		});
		fs.rmdirSync( path );
	}
};


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
					throw err;
				}
				drawer[fileName] = JSON.parse(data);
				return next();
			});
		};
		async.each( fs.readdirSync(dPath), addFile, function( err ){
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


/**
 * Remove collection and carduments (folder and files)
 * @param  {String}   collectionName name of collection to remove
 * @param  {Function} callback       signature: err, numRemovedCards
*/

store.prototype.remove = function (name, callback) {
	var total = 0,
		dPath = path + '/' + name;
	if (fs.existSync( dPath)) {
		fs.readdirSync( dPath ).forEach( function (file, index) {
			var fPath = dPath + "/" + file;
			fs.unlinkSync( fPath );
			total++;
		});
		fs.rmdirSync( dPath );
		if (callback) {
			callback( null, total );
		}
	} else if (callback) {
		callback( 'Drawer not found' );
	}
};


store.prototype.clean = function (name, callback) {};


module.exports = store;
