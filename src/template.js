/*
Template
======
*/

// private methods
/**
	 * Create a new Template and set it as `drawer`.template
	 * @param  {Object} templateModel model structure
	 * @return {Object}              resultant template of drawer after extend the old one
*/
var update = function (newTemplate, callback) {
	var prop, value;
	for (prop in newTemplate) {
		this[prop] = newTemplate[prop];
	}
	validator = Validator( _this );
};


module.exports = {
	get: function() {
		var result = {},
			prop;
		for (prop in this._template) {
			result[prop] = template[prop];
		}
		delete result._update;
		return result;
	},
	set: function (val) {
		validator = Validator( val );

		_this = this;
		val._update = update;

		this._template = val;
	}
}
