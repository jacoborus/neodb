
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
var store = function ( drawerPath, data ) {
	path = drawerPath || false;
	Cards = data;
}


/**
 * save card in drawer, and in file too if persistant
 * @param  {Object}   card 
 * @param  {Function} cb   signature: err
 */

store.prototype.save = function (card, cb) {
	var id = card._id;
	console.log(card);
	delete card._id;
	delete card._isNew;
	if (path) {
		console.log('hay path: ' + path);
		var fPath = path + '/' + id;
		fs.writeFile( fPath, JSON.stringify( card ), function (err) {
			console.log('grabando en disco...');
			if (err) {
				console.log('hubo un error');
				console.log(err);
				return cb( err );
			} else {
				console.log('pues debería haber grbado en disco');
				Cards[id] = card;
				return cb();
			}
		});
	} else {
		console.log('no hay path');
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
		var fPath = path + '/' + ids;
		fs.unlinkSync( fPath );
		delete Cards[id];
		return cb();
	} else {
		delete Cards[ids];
		return cb();
	}
};


module.exports = store;
