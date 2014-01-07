// private methods
var msgErr, validate, save, Store, store, loop, genId, layer;

Store = require( './datastore' );
series = require( './series' );

layer = {
	init : function (card, next) { next(); },
	presave : function (card, next) { next(); },
	postsave : function (card, next) { next(); },
	preremove : function (card, next) { next(); },
	postremove : function (card, next) { next(); },
}

validate = function (card, next) { next(); };

msgErr = function ( msg ) {
	this.msg = msg;
	this.name = "Error";
}


genId = function() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ){
		var r, v;
		r = Math.random() * 16 | 0;
		v = c === 'x' ? r : r & 0x3 | 0x8;
		return v.toString(16);
	});
};


// private properties


/**
 * Middleware constructor
 * @param {String} drawerOwner name of drawer container
 */

var Middleware = function (path, data) {
	store = new Store( path, data );
}


/**
 * Set middleware layer function
 * @param {String}   name layer name
 * @param {Function} fn   middleware layer function
 */

Middleware.prototype.set = function (name, fn) {

	if (name === ('init' || 'presave' || 'postsave' || 'preremove' || 'postremove') && typeof fn === 'function') {
		layer[name] = fn;
	} else {
		throw new msgErr( "Incorrect Middleware layer name or function" );
	};
};


Middleware.prototype.save = function (data, callback) {

	var result = [];

	if (typeof data !== 'number') {
		data = [data];
	}

	for (i in data) {
		if (!data[i]._id) {
			data[i]._id = genId();
			data[i]._isNew = true;
			result.push( data[i] );
		}
	}

	series.eachEach(
		[layer.init, validate, layer.presave, store.save, layer.postsave],
		result,
		callback
	);
};



Middleware.prototype.remove = function (ids, callback) {

	if (typeof ids !== 'number') {
		ids = [ids];
	}
	series.eachEach(
		[layer.preremove, store.remove, layer.postremove],
		data,
		callback
	);
};


module.exports = Middleware;
