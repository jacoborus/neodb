###
Neodb
========

Database explanation
.....
###

Datastore = require './datastore'
Collection = require './collection'

# private variables
dbPath = false
datastore = false

class Neodb

	###*
	 * Create and/or connect a database
	 * @param  {String||Boolean} path 	by default `false`, indicates the folder to save the database
	 * If no `path` database is non persistant
	###
	constructor: (path = false) ->
		# save path
		dbPath = path
		if dbPath
			datastore = new Datastore dbPath


	###*
	 * Adds a collection into Database[`collectionName`]
	 * @param {String} collectionName 			name of collection will be inserted as `database[collectionName]`
	 * @param {Object} [options]
	 * @param {Object} [options.Schema]			schema for validation and relationships
	 * @param {Boolean} [options.inMemoryOnly]	indicator of non persitant collection
	 * @param {Function} [callback]    			signature: error, insertedDocument
	###
	addCollection: (collectionName, options, callback) ->

		if collectionName and (typeof collectionName is 'string')
			
			if not options
				opts = {}
			else if typeof options is 'function'
				callback = options
				opts = {}
			else if typeof options is 'object'
				opts = options

			opts.database = @
			opts.inMemoryOnly = true if dbPath is false

			if dbPath and not opts.inMemoryOnly
				datastore.addCollection collectionName, (err, colData) ->
					if not err
						opts.colData = colData
						return @[collectionName] = new Collection collectionName, @, opts, callback
			else
				return @[collectionName] = new Collection collectionName, @, opts, callback
		else if callback
			callback 'collectionName not valid'			

	dropCollection : (collectionName, callback) ->

	###*
	 * set database folder path
	 * @param {String} path relative route to database folder path
	 * @return {String} relative path to database folder
	###
	setPath : (path) ->
		if typeof path is 'string'
			dbPath = path
		else ''


	###*
	 * @return {String} path to database folder
	###
	getPath : ->
		dbPath

	###*
	 * Remove all documents of all collections in database
	 * @param  {Function} [callback] 	async callback
	 * @return {Number}            		number of documents removed
	###
	clean: (callback) ->


module.exports = Neodb