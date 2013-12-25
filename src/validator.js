
var Validator, valType;

Validator = function (schema) {
	var validator;
	validator = bake(schema);
	this.create(validator);
}

Validator.prototype.validate = function(doc, callback) {};

Validator.prototype.create = function(schema, callback) {
	var prop, value;
	for (prop in newSchema) {
		value = newSchema[prop];
		this[prop] = value;
	}
	if (callback) {
		callback;
	}
	return true;
};

Validator.prototype.clean = function(callback) {
	var prop, value;
	for (prop in this) {
		value = this[prop];
		if (typeof value !== 'function') {
			delete this[prop];
		}
	}
	return callback;
};

Validator.prototype.update = function(schema, callback) {
	return this.clean(this.create(schema, callback));
};



isEmptyObj: function(obj) {
	var key, _i, _len;
	for (_i = 0, _len = obj.length; _i < _len; _i++) {
		key = obj[_i];
		if (hasOwnProperty.call(obj, key)) {
			return false;
		}
	}
	return true;
}


valType = {
	isString: function(obj) {
		return typeof obj === 'string';
	},
	isNumber: function(obj) {
		return typeof obj === 'number';
	},
	isBoolean: function(obj) {
		return typeof obj === 'boolean';
	},
	isDate: function(obj) {
		return obj instanceof Date && !isNaN(obj.valueOf());
	},
	isObjectId: function(obj) {},
	isObject: function(obj) {
		return (typeof obj === "object") && (obj !== null);
	},
	isArray: function(obj) {
		return Object.prototype.toString.call(obj === '[object Array]');
	},
	isFree: function() {
		return true;
	}
};

checkType = function(type, here, callback) {
	switch (tipo) {
		case String:
			here._type = valType.isString;
			break;
		case Number:
			here._type = valType.isNumber;
			break;
		case Boolean:
			here._type = valType.isBoolean;
			break;
		case Date:
			here._type = valType.isDate;
			break;
		case 'objectId':
			here._type = valType.isObjectId;
			break;
		case '':
			here._type = valType.isFree;
			break;
		default:
			return callback();
	}
};

bake = function(schema, ext) {
	var key, obj, x;
	x = ext || {};
	for (key in schema) {
		obj = schema[key];
		if (x[key] == null) {
			x[key] = {};
		}
		checkType(obj, x[key], function() {
			var c, _results;
			if (typeof obj === 'object') {
				if (obj.length !== void 0) {
					return x[key]._type = valType.isArray;
				} else if (obj._type != null) {
					if (obj._required != null) {
						x[key]._required = obj._required;
					}
					if (obj._unique != null) {
						x[key]._unique = obj._unique;
					}
					if (obj._default != null) {
						if (typeof obj._default === 'function') {
							x[key]._default = obj._default;
						} else {
							x[key]._default = function() {
								return obj._default;
							};
						}
					}
					return checkType(obj._type, x[key], function() {
						return console.log('error, no valid type');
					});
				} else {
					x[key]._type = valType.isObject;
					if (!isEmptyObj(obj)) {
						_results = [];
						for (c in obj) {
							_results.push(x[key][c] = bake(obj[c]));
						}
						return _results;
					}
				}
			} else {
				return console.log('error, no object valid');
			}
		});
	}
	return x;
}

module.exports = Validator;
