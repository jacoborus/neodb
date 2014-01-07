
/**
 * Drawer
 *
*/

// get dependencies
var Validator = require( './validator' ),
	Card = require( './card' ),
	Middleware = require( './middleware' ),
	Template = require( './template' ),
	comparator = require( './query' );

// private arguments
var drawer = {},
	memOnly = false,
	schema = false,
	validator,
	middleware;

// private methods
var genId = function() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ){
		var r, v;
		r = Math.random() * 16 | 0;
		v = c === 'x' ? r : r & 0x3 | 0x8;
		return v.toString(16);
	});
};

msgErr = function ( msg ) {
	this.msg = msg;
	this.name = "Error";
}



/**
 * Drawer constructor
 * @param  {String} name      name of drawer
 * @param  {Object} options         Object with options
 * @param  {Boolean} options.inMemoryOnly if `true` drawer is not persistant
 * @param  {Object} options.schema      Schema for validation and relationships
 * @param  {Object} options.initData    data to initialize drawer
*/

var Drawer = function (path, opts) {

	if (path && (typeof path === 'string')) {
	
		var id, initData,
			opts = opts || {};

		// private properties
		memOnly = opts.memOnly || false;
		drawer = opts.initData || {};
		middleware = new Middleware( path, drawer );

		// public methods
		this.Card = new Card( this );
		this.middleware = middleware.set;

	} else {
		throw new msgErr( "Drawer name not valid" );
	}
}



/**
 * Template Setter Getter
 */

Object.defineProperty( Drawer.prototype, "template", Template );



/**
 * Insert new card/s in drawer
 * @param  {Object||Array}    docs     card/s to be stored
 * @param  {Function} callback  signature: error, insertedCards
*/

Drawer.prototype.insert = function (data, callback) {

	if (callback) {
		var result = [],
			_this = this;
	}

	middleware.save( data, function (err, cards) {
		if (callback) {
			if (err) {
				if (callback) callback( err );
			} else {
				// create cards with data
				for (card in cards) { result.push( new _this.Card( card ));	};
				// callback
				callback( null, result );
			}
		}
	});
};



/**
 * Find a card by identifier
 * @param  {String}   id       
 * @param  {Function} callback signature: error, resultcard
 * @return {Object}            resultcard
*/

Drawer.prototype.findById = Drawer.prototype.get = function( id, callback ){

	if (typeof id === 'string') {

		if (this[id]) {

			if (callback) callback( null, new this.Card( this[id] ));

		} else if (callback) callback( 'Card not found' );

	} else if (callback) callback( 'Not valid identifier' );
};



/**
 * Find cards in drawer
 * @param  {Object}   query    nedb query object
 * @param  {Function} callback signature: err, doc/s
 * @return {Object||Array}            doc/docs
*/

Drawer.prototype.find = function(query, callback) {
	var dev, doc, id, key, ok, prop, queryOn, result, value, _ref;
	query = query || false;
	queryOn = false;

	// check for empty query
	for (prop in query) {
		queryOn = true;
		break;
	}
	// if not query return all cards
	if ((query === false) || (queryOn === false)) {
		if (callback) {
			callback( null, drawer );
		}
	} else if (typeof query !== 'object') {
		callback( 'Bad query' );
	} else {
		result = [];
		for (id in drawer) {
			card = drawer[id];
			if (typeof card == 'function') {
				continue;
			}
			ok = false;
			for (prop in query) {
				value = query[prop];
				if (query.hasOwnProperty( prop )) {
					if (typeof value === 'object') {
						for (key in value) {
							if (value.hasOwnProperty(key)) {
								if (comparator[key]( value[key], card[prop] )) {
									ok = true;
								}
								break;
							}
						}
						if (ok === false) {
							break;
						}
					} else {
						if (typeof value === ('string' || 'number' || 'boolean')) {
							if (value === card[prop]) {
								ok = true;
							}
						}
					}
				}
			}
			if (ok === true) {
				dev = {};
				_ref = this[id];
				for (prop in _ref) {
					value = _ref[prop];
					dev[prop] = this[id][prop];
				}
				dev._id = id;
				result.push( new this.Card( dev ));
			}
		}
		if (callback) {
			return callback( null, result );
		}
	}
};



/**
 * Return the first card of a search
 * @param  {Object}   query    a nedb query formatted
 * @param  {Function} callback signature: error, resultcard
 * @return {Object}            resultcard
*/

Drawer.prototype.findOne = function (query, callback) {
	var _this = this;
	this.dS.findOne( query, function (err, card) {
		if (err) {
			if (callback) calllback( err );
		} else {
			if (callback) callback( null, new _this.Card( card ));
		}
	});
};



/**
 * Update cards that match into query with update data
 * @param  {Object}   query    nedb query formatted query
 * @param  {Object}   update   data to update matched cards
 * @param  {Boolean}   multi  allows the modification of several cards
 * @param  {Function} callback signature: err, numReplaced
 * @return {Object||Array}            updated card
*/

Drawer.prototype.update = function (query, update, callback) {
	this.find( query, function( err, docs ){} );
};



/**
 * Remove card from drawer
 * @param  {Object}   query    nedb query formatted query
 * @param  {Function} callback signature: err, numRemoved
 * @return {Number}            numRemoved
*/

Drawer.prototype.remove = function (query, callback) {

	var _this = this;

	this.find( query, function (err, docs) {

		var doc, i, len;

		for (i = 0, len = docs.length; i < len; i++) {
			doc = docs[i];
			delete _this[doc.id];
		}

		if (!callback) return docs.length;
		callback( null, docs.length );
	});
};



/**
 * Remove card by id from drawer
 * @param  {String}   id       id of target doc
 * @param  {Function} callback signature: error, removedcardId
 * @return {String}            removed card id
*/

Drawer.prototype.removeById = function (id, callback) {

	if (typeof id === 'string' && this[id]) {

		delete this.id;

		if (callback) return callback( null, id );

	} else if (callback) return callback( 'card not found' );
};



/**
 * Remove all cards of drawer
 * @param  {Function} callback numRemoved
 * @return {Number}            numRemoved
*/

Drawer.prototype.clean = function (callback) {};



module.exports = Drawer;
