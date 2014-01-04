/*
Template
======
*/

// private methods
/**
 * Create a new Template and set it as `drawer`.template
 * @param  {Object} templateModel model structure
*/
var update = function (newTemplate, callback) {
	var prop, value;
	for (prop in newTemplate) {
		template[prop] = newTemplate[prop];
	}

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
