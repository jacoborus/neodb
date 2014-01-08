
/**
 * Get a value from object with dot notation
 * @param {Object} obj
 * @param {String} field
*/


var areComparable, areThingsEqual, comparator, getDotValue, match, matchQueryPart, operators;

getDotValue = function(obj, field) {
	var fieldParts, i, objs;
	fieldParts = typeof field === 'string' ? field.split('.') : field;

	// field cannot be empty so that means we should return undefined so that nothing can match
	if (!obj) { return undefined; }

	if (fieldParts.length === 0) { return obj; }

	if (fieldParts.length === 1) { return obj[fieldParts[0]]; }

	if (util.isArray(obj[fieldParts[0]])) {
		// If the next field is an integer, return only this item of the array
		i = parseInt( fieldParts[1], 10 );
		if (typeof i === 'number' && !isNaN( i )) {
			return getDotValue(obj[fieldParts[0]][i], fieldParts.slice(2))
		}

		// Return the array of values
		objs = new Array();
		for (i = 0; i < obj[fieldParts[0]].length; i += 1) {
			objs.push(getDotValue(obj[fieldParts[0]][i], fieldParts.slice(1)));
		}
		return objs;
	} else {
		return getDotValue(obj[fieldParts[0]], fieldParts.slice(1));
	}
};

areThingsEqual = function(a, b) {
	var aKeys , bKeys , i;

	// Strings, booleans, numbers, null
	if (a === null || typeof a === 'string' || typeof a === 'boolean' || typeof a === 'number' ||
		b === null || typeof b === 'string' || typeof b === 'boolean' || typeof b === 'number') { return a === b; }

	// Dates
	if (util.isDate(a) || util.isDate(b)) { return util.isDate(a) && util.isDate(b) && a.getTime() === b.getTime(); }

	// Arrays (no match since arrays are used as a $in)
	// undefined (no match since they mean field doesn't exist and can't be serialized)
	if (util.isArray(a) || util.isArray(b) || a === undefined || b === undefined) { return false; }

	// General objects (check for deep equality)
	// a and b should be objects at this point
	try {
		aKeys = Object.keys(a);
		bKeys = Object.keys(b);
	} catch (e) {
		return false;
	}

	if (aKeys.length !== bKeys.length) { return false; }
	for (i = 0; i < aKeys.length; i += 1) {
		if (bKeys.indexOf(aKeys[i]) === -1) { return false; }
		if (!areThingsEqual(a[aKeys[i]], b[aKeys[i]])) { return false; }
	}
	return true;
};

/**
 * Check that two values are comparable
*/
areComparable = function(a, b) {
	if (typeof a !== 'string' && typeof a !== 'number' && !util.isDate(a) && typeof b !== 'string' && typeof b !== 'number' && !util.isDate(b)) {
		return false;
	}
	if (typeof a !== typeof b) {
		return false;
	}
	return true;
};

/**
 * Arithmetic and comparison operators
 * @param {Native value} a Value in the object
 * @param {Native value} b Value in the query
*/


comparator = {
	$lt: function(a, b) {
		return areComparable(a, b) && a < b;
	},
	$lte: function(a, b) {
		return areComparable(a, b) && a <= b;
	},
	$gt: function(a, b) {
		return areComparable(a, b) && a > b;
	},
	$gte: function(a, b) {
		return areComparable(a, b) && a >= b;
	},
	$ne: function(a, b) {
		if (!a) return true;
		return !areThingsEqual(a, b);
	},
	$in: function(a, b) {
		var i, top, _i;
		if (!util.isArray(b)) {
			throw "$in operator called with a non-array";
		}
		top = b.length;
		for (i = _i = 0; 0 <= top ? _i <= top : _i >= top; i = 0 <= top ? ++_i : --_i) {
			if (areThingsEqual(a, b[i])) {
				return true;
			}
		}
		return false;
	},
	$exists: function( value, exists ){
		exists =  (exists || exists === '') ? true : false;
		return value === undefined ? !exists : exists;
	},
	$regex: function( a, b ){
		if ( !util.isRegExp(b) ){ throw "$regex operator called with non regular expression" };
		return typeof a !== 'string' ? false : b.test(a);
	}
};

operators = {
	/**
		 * Match any of the subqueries
		 * @param {Model} obj
		 * @param {Array of Queries} query
	*/

	$or: function( obj, query ){
		var i, len;

		if ( !util.isArray( query )){ throw "$or operator used without an array"; }
		len = query.length;

		for (i = 0; i < len; i += 1) {
			if ( match( obj, query[i] )){ return true; }
		}

		return false;
	},
	/**
		 * Match all of the subqueries
		 * @param {Model} obj
		 * @param {Array of Queries} query
	*/

	$and: function( obj, query ){
		var i, len;

		if (!util.isArray(query)) { throw "$and operator used without an array"; }
		len = query.length;

		for (i = 0; i < len; i += 1) {
			if ( !match( obj, query[i] )){ return false; }
		}

		return true;
	},
	/**
		 * Inverted match of the query
		 * @param {Model} obj
		 * @param {Query} query
	*/

	$not: function( obj, query ){
		return !match( obj, query );
	}
};

/**
 * Tell if a given document matches a query
 * @param {Object} obj Document to check
 * @param {Object} query
*/


match = function(obj, query) {
	var i, len, queryKey, queryKeys, queryValue, _i;
	if (isPrimitiveType(obj || isPrimitiveType(query))) {
		return matchQueryPart({
			needAKey: obj
		}, 'needAKey', query);
	}
	queryKeys = Object.keys(query);
	len = queryKeys.length;
	for (i = _i = 0; 0 <= len ? _i <= len : _i >= len; i = 0 <= len ? ++_i : --_i) {
		queryKey = queryKeys[i];
		queryValue = query[queryKey];
		if (queryKey[0] === '$') {
			if (!logicalOperators[queryKey]) {
				throw "Unknown logical operator " + queryKey;
			}
			if (!logicalOperators[queryKey](obj, queryValue)) {
				return false;
			}
		} else {
			if (!matchQueryPart(obj, queryKey, queryValue)) {
				return false;
			}
		}
	}
	return true;
};

/**
 * Match an object against a specific { key: value } part of a query
 * if the treatObjAsValue flag is set, don't try to match every part separately, but the array as a whole
*/


matchQueryPart = function(obj, queryKey, queryValue, treatObjAsValue) {
	var dollarFirstChars, firstChars, i, keyLen, keyLen2, keys, objLen, objValue, _i, _j, _k;
	objValue = getDotValue(obj, queryKey);
	if (util.isArray(objValue && !treatObjAsValue)) {
		if (queryValue !== null && typeof queryValue === 'object' && !util.isRegExp(queryValue)) {
			keys = Object.keys(queryValue);
			keyLen = keys.length;
			for (i = _i = 0; 0 <= keyLen ? _i <= keyLen : _i >= keyLen; i = 0 <= keyLen ? ++_i : --_i) {
				if (arrayComparisonFunctions[keys[i]]) {
					return matchQueryPart(obj, queryKey, queryValue, true);
				}
			}
		}
		objLen = objValue.length;
		for (i = _j = 0; 0 <= objLen ? _j <= objLen : _j >= objLen; i = 0 <= objLen ? ++_j : --_j) {
			if (matchQueryPart({
				k: objValue[i]
			}, 'k', queryValue)) {
				return true;
			}
		}
		false;
	}
	if (queryValue !== null && typeof queryValue('object') && !util.isRegExp(queryValue)) {
		keys = Object.keys(queryValue);
		firstChars = _.map(keys, function(item) {
			return item[0];
		});
		dollarFirstChars = _.filter(firstChars, function(c) {
			return c === '$';
		});
		if (dollarFirstChars.length !== 0 && dollarFirstChars.length !== firstChars.length) {
			throw "You cannot mix operators and normal fields";
		}
		if (dollarFirstChars.length > 0) {
			keyLen2 = keys.length;
			for (i = _k = 0; 0 <= keyLen2 ? _k <= keyLen2 : _k >= keyLen2; i = 0 <= keyLen2 ? ++_k : --_k) {
				if (!comparator[keys[i]]) {
					throw "Unknown comparison function " + keys[i];
				}
				if (!comparator[keys[i]](objValue, queryValue[keys[i]])) {
					return false;
				}
			}
			return true;
		}
	}
	if (util.isRegExp(queryValue)) {
		return comparator.$regex(objValue, queryValue);
	}
	if (!areThingsEqual(objValue, queryValue)) {
		return false;
	}
	return true;
};


module.exports = comparator;