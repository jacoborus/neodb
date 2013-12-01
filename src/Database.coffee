###
Database
========

Database explanation
.....
###
_exports = (neodb) ->
	class Database
		

		###*
		 * Create and/or connect a database
		 * @param  {String||Boolean} route 	by default `false`, indicates the folder to save the database
		 * @return {Object} 				database itself
		 * If no `route` database is non persistant
		###
		constructor: (@route = false) ->


		###*
		 * Adds a collection into Database[`collectionName`]
		 * @param {String} collectionName 			name of collection will be inserted as `database[collectionName]`
		 * @param {Object} [options]
		 * @param {Object} [options.Schema]			schema for validation and relationships
		 * @param {Boolean} [options.inMemoryOnly]	indicator of non persitant collection
		 * @param {Function} [callback]    			signature: error, insertedDocument
		###
		addCollection: (collectionName, options, callback) ->

			if not options
				opts = {}
			else if typeof options is 'function'
				callback = options
				opts = {}
			else if typeof options is 'object'
				opts = options

			opts.database = @
			opts.inMemoryOnly = true if @route is false

			if collectionName and (typeof collectionName is 'string')
				@[collectionName] = new neodb.Collection collectionName, opts, callback
			else if callback
				callback 'collectionName not valid'			


		###*
		 * Remove all documents of all collections in database
		 * @param  {Function} [callback] 	async callback
		 * @return {Number}            		number of documents removed
		###
		clean: (callback) ->


module.exports = _exports