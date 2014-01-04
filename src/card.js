/*
Model
=====

A *card* is .........
*/

module.exports = function (drawer) {

	/**
	 * Extends Model with card data
	 * @param  {Object} data  cards data
	 * @return {Object}       card itself
	*/
	var Model = function (data) {
		var x;
		data = data || {};
		for (x in data) {
			this[x] = data[x];
		}
	};

	/**
	 * Inserts card itself in drawer
	 * @param  {Function} callback signature: err, insertedDoc
	 * @return {Object} inserted card
	*/
	Model.prototype._insert = function (callback) {
		drawer.insert( this, callback );
	};

	/**
	 * Remove card from its drawer
	 * @param  {Function} callback signature: error
	 * @return {Object}            removedDoc
	*/
	Model.prototype._remove = function (callback) {
		if (this._id) {
			drawer.remove({
				id: this._id
			}, callback);
		} else if (callback) return callback( 'Cannot remove, object is not in drawer' );
	};

	/**
	 * Update the card in database after passing middleware
	 * @param  {Function} callback signature: error, replacedDoc
	 * @return {Object}            replaced card
	*/
	Model.prototype._update = function(callback) {
		if (this._id) {
			drawer.set(this._id, this, function (err, doc) {
				if (callback) return callback( err, doc );
			});
		} else if (callback) return callback( 'Cannot update, the card still is not in drawer' );
	};

	return Model;
};
