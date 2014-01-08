/*
Card
=====

A *card* is .........
*/

module.exports = function (drawer) {

	/**
	 * Extends Card with card data
	 * @param  {Object} data  cards data
	 * @return {Object}       card itself
	*/

	var Card = function (data, id) {
		var x;
		data = data || {};
		for (x in data) {
			this[x] = data[x];
		}
		if (id && typeof id === 'string') {
			this._id = id;
			this._isNew = false;
		}
	};


	Card.prototype._id = false;
	Card.prototype._isNew = true;

							
	/**
	 * Inserts card itself in drawer
	 * @param  {Function} callback signature: err, insertedDoc
	 * @return {Object} inserted card
	*/

	Card.prototype._insert = function (callback) {
		drawer.insert( this, callback );
	};


	/**
	 * Remove card from its drawer
	 * @param  {Function} callback signature: error
	 * @return {Object}            removedDoc
	*/

	Card.prototype._remove = function (callback) {

		if (this._id) {
			drawer.remove({ id: this._id }, callback);

		} else if (callback) return callback( 'Cannot remove, object is not in drawer' );
	};


	/**
	 * Update the card in database after passing middleware
	 * @param  {Function} callback signature: error, replacedDoc
	 * @return {Object}            replaced card
	*/

	Card.prototype._update = function (callback) {
		
		if (this._id) {
			var prop;
			drawer.insert( this._id, this, function (err, doc) {
				if (err) {
					if (callback) callback( err );
				} else {
					this = doc[0];
					if (callback) {
						callback( err, this );
					}
				}
			});

		} else if (callback) return callback( 'Cannot update, the card still is not in drawer' );
	};

	return Card;
};
