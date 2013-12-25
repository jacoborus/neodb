/*
Schema
======
*/


var Schema, anida, dots2obj, virtuals;

anida = function(padre, obj, i) {
	return padre[obj[i]];
};

dots2obj = function(obj) {
	var result;
	obj = obj.split('.');
	result = {};
	if (obj.length > 1) {
		return anida(result, obj, 0);
	}
};

virtuals = {
	set: {},
	get: {}
};


/**
	 * Create a new Schema and set it as `collection`.schema
	 * @param  {Object} schemaModel model structure
	 * @return {Object}              resultant schema of collection after extend the old one
*/

Schema = function (schemaModel) {
	if (this._validate(schemaModel)) {
		this._update(schemaModel);
	}
}

Schema.prototype._validate = function(schemaModel) {
	if (typeof schemaModel === 'object') {
		return true;
	} else {
		return false;
	}
};

Schema.prototype._clean = function(callback) {
	var prop, value;
	for (prop in this) {
		value = this[prop];
		if (typeof value !== 'function') {
			delete this[prop];
		}
	}
	return callback;
};

Schema.prototype._setVirtual = function(type, field, fn) {
	if (type === 'get' || 'set') {
		return virtuals[type][field] = fn;
	}
};

Schema.prototype._update = function(newSchema, callback) {
	var prop, value;
	for (prop in newSchema) {
		value = newSchema[prop];
		this[prop] = value;
	}
	if (callback) {
		return callback;
	}
};

Schema.prototype._set = function(newSchema, callback) {
	if (this.validate(newSchema)) {
		return this.clean(this.extend(newSchema, callback));
	}
};

module.exports = Schema;

