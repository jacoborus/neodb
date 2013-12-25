
var async, collection, middleware, pres;

async = require('async');

pres = {
	save: function(next) {},
	remove: function(next) {}
};

collection = '';


middleware = function (collectionOwner) {
	collection = collectionOwner;
}

middleware.prototype.setInit = function(initFn) {
	return this.init = initFn;
};

middleware.prototype.save = function() {
	if (callback) {
		return async.series([init, clean, validate, presave, proceed, post], callback);
	}
};

middleware.prototype.remove = function() {
	if (callback) {
		return async.series([pre, proceed, post], callback);
	}
};

middleware.prototype.clean = function() {};

middleware.prototype.validate = function() {};

middleware.prototype.proceedSave = function() {};

middleware.prototype.init = function(doc, next) {
	return next();
};

middleware.prototype.pre = function() {};

middleware.prototype.post = function() {};

module.exports = middleware;

