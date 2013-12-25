
var async, datastore, deleteFolderRecursive, fs;

fs = require('fs');
async = require('async');

deleteFolderRecursive = function(path) {
	if (fs.existsSync(path)) {
		fs.readdirSync(path).forEach(function(file, index) {
			var curPath;
			curPath = path + "/" + file;
			if (fs.statSync(curPath).isDirectory()) {
				return deleteFolderRecursive(curPath);
			} else {
				return fs.unlinkSync(curPath);
			}
		});
		return fs.rmdirSync(path);
	}
};

datastore = function( dbPath ){
	this.dbPath = dbPath != null ? dbPath : __dirname + './neodb';
	if (!fs.existsSync(this.dbPath)) {
		fs.mkdir(this.dbPath);
	}
}

/**
	 * Load selected folder (collection) or create one if not exists
	 * @param  {String}   name     name of collection
	 * @param  {Function} callback signature: error, collectionData
	 * @return {Object}            Collection data
*/


datastore.prototype.addCollection = function(name, callback) {
	var addFile, col, colPath;
	colPath = this.dbPath + '/' + name;
	if ( fs.existsSync( colPath )){
		col = {};
		addFile = function( fileName, next ){
			var filePath = colPath + "/" + fileName;
			fs.readFile(filePath, function(err, data) {
				if (err) {
					throw err;
				}
				col[fileName] = JSON.parse(data);
				return next();
			});
		};
		async.each(fs.readdirSync(colPath), addFile, function(err) {
			if (callback) {
				callback(null, col);
			}
			return col;
		});
	} else {
		fs.mkdir( colPath, function( err ){
			if ( callback ){
				callback( err, {} );
			} else {
				return {};
			}
		});
	}
};

/**
	 * Remove collection and documents (folder and files)
	 * @param  {String}   collectionName name of collection to remove
	 * @param  {Function} callback       signature: numRemovedDocs
	 * @return {Number}                  num of removed documents
*/


datastore.prototype.removeCollection = function(collectionName, callback) {
	var total;
	if (fs.existSync(this.dbPath + '/' + collectionName)) {
		total = 0;
		fs.readdirSync(path).forEach(function(file, index) {
			var curPath = path + "/" + file;
			total++;
			fs.unlinkSync(curPath);
		});
		fs.rmdirSync(path);
		if (callback) {
			callback( total );
		} else {
			return total;
		}
	}
};

datastore.prototype.cleanCollection = function(name, callback) {};

datastore.prototype.insertDoc = function(collection, id, doc, callback) {
	var route = this.dbPath + '/' + collection + '/' + id;
	fs.writeFile(route, JSON.stringify(doc), callback);
};

datastore.prototype.insertDocs = function(docs, callback) {
	var col, colName, doc, id;
	for (colName in docs) {
		col = docs[colName];
		for (id in col) {
			doc = col[id];
			archive.append( doc, { name: colName + '/' + id});
		}
	}
};

datastore.prototype.updateDoc = function(doc, callback) {};

datastore.prototype.updateDocs = function(docs, callback) {};

datastore.prototype.removeDoc = function(id, callback) {};

datastore.prototype.removeDocs = function(ids, callback) {};


module.exports = (function() { 
	return Datastore;
})();
