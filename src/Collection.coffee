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


		###
		Collection#Constructor( `name`, `[options]`, `[callback]` )
		------------------------------------------------------------

		A Collection has the next structure:

		- name
		- database: parent db
		- schema : for validations and relationships
		- inMemoryOnly: true if not persistant
		- dS: data store

		**Parameters:**

		- `name <String>`: collection will be inserted as `database[name]` if `database` is passed
		- `[options] <Object>`:
			- `database <Object|null>` database to insert this new collection into, if `null` 
			Collection will be treated as an orphan, but it will have a virtual database for itself
			- `schema <Object|null>` Schema for validation and relationships
			- `inMemoryOnly <Boolean>` if `true` collection is not persistant, by default is false.
		- `[callback] <Function>` signature error, collectionItself
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


		###
		Collection#Document( `[data]` )
		-------------------------------

		Creates a new document for Collection.

		**Parameters:**

		- `[data] <Object>` data to fill new returned document

		Document will be created empty if `data` is empty or not passed.

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


		###
		Collection#insert( `docs`, `[callback]` )
		-----------------------------------------

		Insert new document/s in Collection

		**Parameters:**

		- `docs <Object|Array>` document/s to be stored
		- `[callback] <Function>`: is optional, signature: error, documents inserted

		Returns documents inserted
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


		###
		Collection#find( `query`, `[callback]` )
		----------------------------------------

		**Parameters:**

		- `query <Object>`
		- `[callback] <Function>`

		**Returns** `callback`, signature: err, documents
		###
		find : (query, callback) ->
			@dS.find query, (err, result) =>
				if err
					if callback then callback err else {}
				else
					docs = for doc in result
						new @Doc doc
					if callback then callback null, docs else docs


		###
		Collection#findOne( `query`, `[callback]` )
		-------------------------------------------

		**Parameters:**

		- `query <Object>` a nedb query formatted
		- `[callback] <Function>` optional, signature: error, resultDocument

		**Returns** an `Object`, the document itself
		###
		findOne : (query, callback) ->

			@dS.findOne query, (err, doc) =>
				if err
					if callback then callback err else undefined
				else
					if callback then callback null, new @Doc doc else doc


		###
		Collection#findById( `id`, `[callback]` )
		-----------------------------------------

		**Params**:

		- `id`: `_id` of target document
		- `callback`: optional, signature: error, result document

		**Returns** an `Object`, the document itself
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
