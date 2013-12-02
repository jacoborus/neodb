###*
 * Collection
 * ==========
 * 
 * Collection uses a nedb dabase to store documents
 * 
###

Document = require './Document'
Doc = ->

genId = ->
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
		r = Math.random()*16|0
		v = if c is 'x' then r else (r&0x3|0x8)
		v.toString 16

name = undefined
inMemoryOnly = true
database = undefined
schema = undefined

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
		 * A Collection has the next private properties:
		 * - name
		 * - database: parent db
		 * - schema : for validations and relationships
		 * - inMemoryOnly: true if not persistant
		###
		constructor: (name, options, callback ) ->
			
			# set options and callback even options not passed as parameters
			if typeof options is 'function'
				callback = options
				opts = {}
			else opts = options or {}

			# set inMemoryOnly value if passed as option
			inMemoryOnly = if opts.inMemoryOnly and (typeof opts.inMemoryOnly is 'boolean')
				opts.inMemoryOnly
			else false # default value

			schema = false

			# set database from options parameter, if database is not passed 
			# will create a new one and add this collection into it
			if opts and opts.database
				database = opts.database
			else 
				database = new neodb.Database()
				database[name] = @

			# create datastore, if inMemoryOnly is true it will be not persistant
			if (opts.inMemoryOnly and opts.inMemoryOnly is true) or database.getPath() is ''
				inMemoryOnly = true

			Doc = Document @


		###*
		 * Adds a new schema to `Collection.schema` and compiles its validator
		 * @param {Object}   schemamodel structure model
		 * @param {Function} callback
		 * @return {Object} processed schema after extend the old one
		###
		addSchema : (schemamodel, callback) ->
			#@schema = bake @, schema, callback


		###*
		 * Insert new document/s in collection
		 * @param  {Object||Array}   docs     document/s to be stored
		 * @param  {Function} callback signature: error, insertedDocuments
		 * @return {Object}            inserted document
		###
		insert : (data, callback) ->
			if typeof data is 'object'
				# save one document
				if data.length is undefined
					id = genId()
					@[id] = data
					doc = new Doc @[id]
					callback null, doc if callback
					doc
				# save multiple documents
				else if typeof data.length is 'number'
					ids = []
					for i in data
						ids[i] = genId()
						@[ids[i]] = data[i]
					docs = @findByIds ids
					callback null, docs if callback
					docs

		###*
		 * Find a document by identifier
		 * @param  {String}   id       
		 * @param  {Function} callback signature: error, resultDocument
		 * @return {Object}            resultDocument
		###
		get : (id, callback) ->
			if typeof id is 'string'
				if @[id]
					doc = new Doc @[id]
					callback null, doc if callback
					doc
				else
					callback null, {} if callback
					{}
			else
				callback 'not valid identifier' if callback
				{}

		set : (id, newDoc, callback) ->
			if @[id]
				delete newDoc._id
				for prop, value of newDoc
					if typeof value isnt 'function'
						@[id][prop] = value
				doc = new Doc @[id]
				callback null, doc if callback
				doc
			else
				callback 'Document not found' if callback
				false
		###*
		 * Find documents in collection
		 * @param  {Object}   query    nedb query object
		 * @param  {Function} callback signature: err, doc/s
		 * @return {Object||Array}            doc/docs
		###
		find : (query = false, callback) ->
			queryOn = false
			for prop of query
				queryOn = true
				break
			if (query is false) or (queryOn is false)
				callback null, @ if callback
				@
			else if typeof query isnt 'object'
				callback 'Bad query'
			else
				ops =
					$eq : (a, b) -> a is b
					$gt : (a, b) -> a > b
					$gte : (a, b) -> a >= b
					$lt : (a, b) -> a < b
					$lte : (a, b) -> a <= b
					$ne : (a, b) -> a isnt b

				result = []

				for id, doc of @ when typeof doc isnt 'function'
					ok = false
					for prop, value of query
						if query.hasOwnProperty prop
							if typeof value is 'object'

								for key of value
									if value.hasOwnProperty key
										ok = true if ops[key] value[key], doc[prop]
										break
								break if ok is false
							
							else
								if typeof value is ('string' or 'number' or 'boolean')
									ok = true if value is doc[prop]

					if ok is true
						dev = {}
						for prop, value of @[id]
							dev[prop] = @[id][prop]
						dev._id = id
						result.push new Doc dev

				callback null, result if callback
				result


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
					if callback then callback null, new Doc doc else doc

		###
		Collection#update( `query`, `update`, `[options]`, `[callback]` )
		-----------------------------------------------------------------
		###
		###*
		 * Update documents that match into query with update data
		 * @param  {Object}   query    nedb query formatted query
		 * @param  {Object}   update   data to update matched documents
		 * @param  {Boolean}   multi  allows the modification of several documents
		 * @param  {Function} callback signature: err, numReplaced
		 * @return {Object||Array}            updated document
		###

		update : (query, update, callback)->
			@find query, (err, docs) ->
				#for doc in docs
				# extend docs with update

		###*
		 * Remove document from collection
		 * @param  {Object}   query    nedb query formatted query
		 * @param  {Function} callback signature: err, numRemoved
		 * @return {Number}            numRemoved
		###

		remove : (query, callback) ->
			@find query, (err, docs) =>
				for doc in docs
					delete @[doc._id]
				callback null, docs.length if callback
				docs.length

		removeById : (id, callback) ->
			if typeof id is 'string' and @[id]
				delete @id
				callback null, id if callback
				id
			else
				callback 'Document not found' if callback
				0


		###*
		 * Remove all documents of collection
		 * @param  {Function} callback numRemoved
		 * @return {Number}            numRemoved
		###
		clean : (callback) ->


module.exports = _export
