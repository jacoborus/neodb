
/*
Neodb
========

Database explanation
.....
*/

var Collection, Datastore, Neodb, datastore, dbPath;

Datastore = require('./datastore');
Collection = require('./collection');
// private variables
dbPath = false;
datastore = false;


/**
	 * Create and/or connect a database
	 * @param  {String||Boolean} path   by default `false`, indicates the folder to save the database
	 * If no `path` database is non persistant
*/

var Neodb = function (path) {}
	if (path == null) {
		path = false;
	}
	dbPath = path;
	if (dbPath) {
		datastore = new Datastore(dbPath);
	}
};


_datastore = function() {
	return datastore;
};
/**
	 * Adds a collection into Database[`collectionName`]
	 * @param {String} collectionName       name of collection will be inserted as `database[collectionName]`
	 * @param {Object} [options]
	 * @param {Object} [options.Schema]     schema for validation and relationships
	 * @param {Boolean} [options.inMemoryOnly]  indicator of non persitant collection
	 * @param {Function} [callback]         signature: error, insertedDocument
*/

Neodb.prototype.addCollection = function( collectionName, options, callback ){
	var collection, opts,
		_this = this;
	if (collectionName && (typeof collectionName === 'string')) {
		if (typeof options === 'function') {
			callback = options;
		}
		opts = options || {};
		if (dbPath === false) {
			opts.inMemoryOnly = true;
		}
		if (dbPath && !opts.inMemoryOnly) {
			return datastore.addCollection(collectionName, function(err, colData) {
				var collection;
				if (!err) {
					opts.initData = colData;
					collection = new Collection(collectionName, _this, opts);
					if (callback) {
						return callback(null, collection);
					} else {
						return collection;
					}
				}
			});
		} else {
			collection = new Collection(collectionName, this, opts);
			if (callback) {
				return callback(null, collection);
			} else {
				return collection;
			}
		}
	} else {
		if (callback) {
			return callback('collectionName not valid');
		} else {
			return console.log('collectionName not valid');
		}
	}
};

Neodb.prototype.dropCollection = function( collectionName, callback ){};
/**
	 * @return {String} path to database folder
*/

Neodb.prototype.getPath = function() {
	return dbPath;
};
/**
	 * Remove all documents of all collections in database
	 * @param  {Function} [callback]  async callback
	 * @return {Number}               number of documents removed
*/

Neodb.prototype.clean = function(callback) {};



module.exports = (function() {
	return Neodb;
})();
