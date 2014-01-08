
//private methods
var fs = require('fs'),
	async = require('async');


// private properties
var path = false,
	Cards;


/**
 * Store constructor
 * @param  {String} drawerPath Path to drawer folder
 */
var store = function (drawerPath, data) {
	path = drawerPath || false;
	Cards = data;
}



/**
 * save card in drawer, and in file too if persistant
 * @param  {Object}   card 
 * @param  {Function} cb   signature: err
 */

store.prototype.save = function (card, cb) {

	var id, field,
		file = {};
	// save id for use later
	id = card._id;
	// remove meta properties
	for (field in card) {
		if (card.hasOwnProperty( field )) {
			file[field] = card[field];
		}
	}
	
	// with persistante mode
	if (path) {
		var fPath = path + '/' + id;
		fs.writeFile( fPath, JSON.stringify( file ), function (err) {
			if (err) {
				cb( err );
			} else {
				Cards[id] = file;
				cb();
			}
		});
	// memOnly mode
	} else {
		Cards[id] = file;
		return cb();
	}
};



/**
 * Remove file and card from drawer
 * @param  {String}   id 
 * @param  {Function} cb signature: err
 */

store.prototype.remove = function (id, cb) {

	if (path) {
		var fPath = path + '/' + id;
		fs.unlinkSync( fPath );
	}
	delete Cards[id];
	return cb();
};



module.exports = store;
