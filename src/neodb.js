
/*
Neodb
========

Database explanation
.....
*/
var Store = require( './dbstore' ),
	Drawer = require( './drawer' );

var msgErr = function( msg ) {
   this.msg = msg;
   this.name = "Error";
}

// private variables
var path = false,
	store = false;

/**
	 * Create and/or connect a database
	 * @param  {String||Boolean} path   by default `false`, indicates the folder to save the database
	 * If no `path` database is non persistant
*/

var Neodb = function (dbPath) {
	path = dbPath || false;
	if (path) {
		store = new Store( path );
	}
	this.drawers = {};
};


/**
 * return path to database
 * @return {String} 
 */

Neodb.prototype.getPath = function () { return path; };


/**
	 * Adds a collection into Database[`name`]
	 * @param {String} name       name of drawer will be inserted as `database[name]`
	 * @param {Object} [options]
	 * @param {Object} [options.template]     schema for validation and relationships
	 * @param {Boolean} [options.memOnly]  indicator of non persitant drawer
	 * @param {Function} [callback]         signature: error, insertedCard
*/

Neodb.prototype.open = function (name, options, callback) {
	var opts,
		_this = this;
	if (name && (typeof name === 'string')) {

		// if no options
		if (typeof options === 'function') {
			callback = options;
		}
		opts = options || {};

		// force in memory only drawer if cabinet is in memory only
		if (path === false) {
			opts.memOnly = true;
		}

		// add drawer to cabinet
		if (path && !opts.memOnly) {
			// if drawer is persistant read folder
			store.open( name, opts.memOnly, function (err, data) {
				if (!err) {
					opts.initData = data;
					// create drawer and add it to the cabinet
					_this.drawers[name] = new Drawer( path + '/' + name, opts );
					if (callback) {
						return callback( null, _this.drawers[name] );
					}
				} else {
					callback( err );
				}
			});
		} else {
			// just create a drawer and add it to the cabinet if in memory only drawer 
			this.drawers[name] = new Drawer( name, opts );
			if (callback) {
				return callback( null, this.drawers[name] );
			}
		}
	} else if (callback) {
		return callback( 'collectionName not valid' );
	}
};

Neodb.prototype.close = function (collectionName) {};

/**
	 * Remove all documents of all collections in database
	 * @param  {Function} [callback]  async callback
	 * @return {Number}               number of documents removed
*/

Neodb.prototype.clean = function (callback) {};


module.exports = Neodb;
