###*
 * Collection
 * ==========
 * 
 * Collection uses a nedb dabase to store documents
 * 
###


nedb = require 'nedb'
neodbDocument = require './Document'

_export = (neodb) ->

	class Collection

		###*
		 * Collection constructor
		 * @param  {String} @name  					name of collection
		 * @param  {Object} options 				Object with options
		 * @param  {Object} options.database 		database to insert this new collection into, if `null` Collection will be treated as an orphan, but it will have a virtual database for itself
		 * @param  {Object} options.schema			Schema for validation and relationships
		 * @param  {Boolean} options.inMemoryOnly	if `true` collection is not persistant
		 * @param  {Function} callback 				signature error, collectionItself
		 * @return {Object}            				collection itself
		 *
		 * 		A Collection has the next structure:
		 * 		- name
		 * 		- database: parent db
		 * 		- schema : for validations and relationships
		 * 		- inMemoryOnly: true if not persistant
		 * 		- dS: data store
		###
		constructor: (@name, options, callback ) ->
			
			# set options and callback even options not passed as parameters
			if typeof options is 'function'
				callback = options
				opts = {}
			else opts = options or {}

			# set inMemoryOnly value if passed as option
			@inMemoryOnly = if opts.inMemoryOnly and (typeof opts.inMemoryOnly is 'boolean')
				opts.inMemoryOnly
			else false # default value

			@dS = ''
			@schema = false

			# set database from options parameter, if database is not passed 
			# will create a new one and add this collection into it
			if opts and opts.database
				@database = opts.database
			else 
				@database = new neodb.Database()
				@database[@name] = @

			# create datastore, if inMemoryOnly is true it will be not persistant
			if (opts.inMemoryOnly and opts.inMemoryOnly is true) or @database.route is false
				@dS = new nedb()
			else
				@dS = new nedb
					filename : @database.route + '/' + @name
					autoload : true

		###*
		 * Document model
		 * @type {Function}
		###
		Document : neodbDocument @

		###
		Collection#addSchema( `schemaModel` )
		-----------------------------------

		Adds a new schema to `Collection.schema` and compiles its validator

		Parameters:

		- `schemamodel <Object>` schema model for documents

		Returns proccessed schema

		###

		addSchema : (schemamodel, callback) ->
		#@schema = bake @, schema, callback


		###*
		 * Insert new document/s in collection
		 * @param  {Object||Array}   docs     document/s to be stored
		 * @param  {Function} callback signature: error, insertedDocuments
		 * @return {Object}            inserted document
		###
		insert : (docs, callback) ->

			@dS.insert docs, (err, newDocs) =>
				if err
					callback err
				# si hemos guardado un único documento
				else if newDocs.length is undefined
					modelo = new @Doc newDocs
				else # si hemos guardado múltiples documentos
					modelo = for obj in newDocs
						new @Doc obj
				callback null, modelo if callback


		###*
		 * Find documents in collection
		 * @param  {Object}   query    nedb query object
		 * @param  {Function} callback signature: err, doc/s
		 * @return {Object||Array}            doc/docs
		###
		find : (query, callback) ->
			@dS.find query, (err, result) =>
				if err
					if callback then callback err else {}
				else
					docs = for doc in result
						new @Doc doc
					if callback then callback null, docs else docs


		###*
		 * Return the first document of a search
		 * @param  {Object}   query    a nedb query formatted
		 * @param  {Function} callback signature: error, resultDocument
		 * @return {Object}            resultDocument
		###
		findOne : (query, callback) ->

			@dS.findOne query, (err, doc) =>
				if err
					if callback then callback err else undefined
				else
					if callback then callback null, new @Doc doc else doc

		###*
		 * Find a document by identifier
		 * @param  {String}   id       
		 * @param  {Function} callback signature: error, resultDocument
		 * @return {Object}            resultDocument
		###
		findById : (id, callback) ->
					
			@dS.findOne {_id: id}, (err, doc) =>
				if err
					if callback then callback err else null
				else
					if callback then callback null, new @Doc doc else doc

		###
		Collection#update( `query`, `update`, `[options]`, `[callback]` )
		-----------------------------------------------------------------
		###
		update : (query, update, options, callback) ->
			@dS.update query, update, options, callback

		###
		Collection#drop( `query`, `[callback]` )
		----------------------------------------
		###
		drop : (query, callback) ->
			@dS.remove query, {}, callback

		###
		Collection#ensureIndex( `options`, `[callback]` )
		-------------------------------------------------
		###
		# ensureIndex : (options, callback) ->

		# @dS.ensureIndex options, callback

###
Collection#clean( `[callback]` )
--------------------------------

Remove all documents of collection

**Parameters:**

- `callback <Function>` (optional): signature: err, numRemoved

**Returns:**  `<String>` collection name
###


module.exports = _export
