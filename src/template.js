/*
Template
======
*/

// private methods
var deep, update;

deep = function (destination, source, callback) {
	for (var property in source) {
		if (typeof source[property] === "object" &&	source[property] !== null ) {

			destination[property] = destination[property] || {};
			this( destination[property], source[property] );

		} else if (source[property] === null) {
			delete destination[property];
		} else {
			destination[property] = source[property];
		}
	}
	return callback( destination );
};


update = function (newTemplate, callback) {
	deep( template, newTemplate, callback );
};


// private properties
var template = {};

module.exports = {

	/**
	 * Get schema
	 * @return {Object} drawer schema
	 */
	get: function() {
		var result = {},
			prop;
		for (prop in template) {
			if (prop !== '_update') {
				result[prop] = template[prop];
			}
		}
		delete result._update;
		return result;
	},

	/**
	 * Set new template
	 * @param {Object} val new template
	 */
	set: function (val) {
		val._update = update;
		template = val;
	}
}
