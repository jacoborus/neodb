
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

	// save id for use later
	var id = card._id;
	// remove meta properties
	delete card._id;
	delete card._isNew;
	// with persistante mode
	if (path) {
		var fPath = path + '/' + id;
		fs.writeFile( fPath, JSON.stringify( card ), function (err) {
			if (err) {
				cb( err );
			} else {
				Cards[id] = card;
				cb();
			}
		});
	// memOnly mode
	} else {
		Cards[id] = card;
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
