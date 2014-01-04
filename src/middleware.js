// private methods
var msgErr, validate, save, Store, store, series, genId, layers;

layers = {
	init : function (card, next) { next(); },
	presave : function (card, next) { next(); },
	postsave : function (card, next) { next(); },
	preremove : function (card, next) { next(); },
	postremove : function (card, next) { next(); },
}
validate = function (card, next) { next(); };

Store = require( './datastore' );

msgErr = function ( msg ) {
	this.msg = msg;
	this.name = "Error";
}


// Very custom async series function
series = function (fns, data, callback) {

	var iterate, len, cursor,
		data = data;

	len = fns.length;
	cursor = 0;
	
	iterate = function (err) {
		if (err) {
			return callback( err );
		} else {
			if (cursor === len-1) {
				callback( null, data );
			} else {
				cursor++;
				fns[cursor]( data, iterate );
			}
		}
	}
	fns[cursor]( data, iterate );
}

// Very custom async each series function
eachSeries = function ( arr, fns, callback) {

	var iterate, len, cursor,
		arr = arr;

	len = arr.length;
	cursor = 0;
	
	iterate = function (err) {
		if (err) {
			return callback( err );
		} else {
			if (cursor === len-1) {
				return callback( null, arr );
			} else {
				cursor++;
				series( fns, arr[cursor], iterate );
			}
		}
	}
	series( fns, arr[cursor], iterate );
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
		var data = [data];
	} else {
		var data = data;
	}
	for (i in data) {
		if (!data[i]._id) {
			data[i]._id = genId();
			data[i]._isNew = true;
			result.push( data[i] );
		}
	}
	eachSeries(
		result,
		[layers.init, validate, layers.presave, store.save, layers.postsave],
		callback
	);
};


Middleware.prototype.remove = function (ids, callback) {
	if (typeof ids !== 'number') {
		data = [ids];
	} else {
		data = ids
	}
	eachSeries(
		series,
		data,
		[layers.preremove, store.remove, layers.postremove],
		callback
	);
};


module.exports = Middleware;
