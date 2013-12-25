/*
Model
=====

A *model* is .........
*/

var collection, model;

model = function(collection) {
	var Model;
	collection = collection;

	/**
			 * Extends Model with model data
			 * @param  {Object} data  models data
			 * @return {Object}       model itself
	*/
	function Model(data) {
		var x;
		data = data || {};
		for (x in data) {
			this[x] = data[x];
		}
	}

	/**
			 * Inserts model itself in collection
			 * @param  {Function} callback signature: err, insertedDoc
			 * @return {Object}            inserted model
	*/
	Model.prototype.insert = function(callback) {
		return collection.insert(doc, callback);
	};

	/**
			 * Remove model from its collection
			 * @param  {Function} callback signature: error
			 * @return {Object}            removedDoc
	*/
	Model.prototype.remove = function(callback) {
		if (this._id) {
			return collection.remove({
				id: this._id
			}, callback);
		} else {
			callback ? callback('Cannot remove, object is not in collection') : return {};
		}
	};

	/**
			 * Update the model in database after passing middleware
			 * @param  {Function} callback signature: error, replacedDoc
			 * @return {Object}            replaced model
	*/
	Model.prototype.update = function(callback) {
		if (this._id) {
			return collection.set(this._id, this, function(err, doc) {
				if (callback) {
					return callback(err, doc);
				} else {
					return doc;
				}
			});
		} else {
			if (callback) {
				callback('Cannot update, object is not in collection');
			}
		}
	};

	return Model;
};

module.exports = (function(){ return model;}) ();
