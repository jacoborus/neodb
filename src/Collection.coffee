###*
 * Collection
 * ==========
 * 
 * Collection uses a nedb dabase to store documents
 * 
###

util = require 'util'
genId = ->
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
		r = Math.random()*16|0
		v = if c is 'x' then r else (r&0x3|0x8)
		v.toString 16


Document = require './Document'
Doc = ->

name = undefined
database = undefined
inMemoryOnly = true
schema = false



class Collection

	###*
	 * Collection constructor
	 * @param  {String} name  					name of collection
	 * @param  {Object} database 				database to insert this new collection into, if `null` Collection will be treated as an orphan, but it will have a virtual database for itself
	 * @param  {Object} options 				Object with options
	 * @param  {Object} options.schema			Schema for validation and relationships
	 * @param  {Boolean} options.inMemoryOnly	if `true` collection is not persistant
	 * @param  {Object} options.initData 		data to initialize collection
	 * @param  {Function} callback 				signature error, collectionItself
	 *
	 * A Collection has the next private properties:
	 * - name
	 * - database: parent db
	 * - schema : for validations and relationships
	 * - inMemoryOnly: true if not persistant
	###
	constructor: (name, database, options, callback ) ->
		
		name = name
		database = database
		schema = false
		# set options and callback, even if options not passed as parameters
		if typeof options is 'function'
			callback = options
			opts = {}
		else opts = options or {}

		# set inMemoryOnly value if passed as option
		if opts.inMemoryOnly? and typeof opts.inMemoryOnly is 'boolean'
			inMemoryOnly = opts.inMemoryOnly
		else
			inMemoryOnly = true # default value

		# extend collection with initData
		opts.initData ?= {}
		for id, doc of opts.initData
			@[id] = doc

		# set database from options parameter, if database is not passed 
		# will create a new one and add this collection into it
		database[name] = @

		Doc = Document @


	Document : Doc


	# Only for testing purposes
	getDb : -> database
	getInMemoryOnly : -> inMemoryOnly
	getSchema : -> schema


	###*
	 * Adds a new schema to `Collection.schema` and compiles its validator
	 * @param {Object}   schemamodel structure model
	 * @param {Function} callback
	 * @return {Object} processed schema after extend the old one
	###

	setSchema : ->

	getSchema : ->

	updateSchema : ->


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
				if not inMemoryOnly
					datastore.insertDoc name, id, data, (err) ->
						@[id] = data if not err
						callback err if callback
				else
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


	###*
	 * Update a document by identifier
	 * @param {String}   id       id of object to update
	 * @param {Object}   newDoc   new fields for document
	 * @param {Function} callback signature: error, newDoc
	###

	set : (id, newDoc, callback) ->
		if @[id]
			delete newDoc._id
			for prop, value of newDoc
				if typeof value isnt 'function'
					@[id][prop] = value
			doc = new Doc @[id]
			callback null, doc if callback;
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
			result = []

			for id, doc of @ when typeof doc isnt 'function'
				ok = false
				for prop, value of query
					if query.hasOwnProperty prop
						if typeof value is 'object'

							for key of value
								if value.hasOwnProperty key
									ok = true if compare[key] value[key], doc[prop]
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


	###*
	 * Remove document by id from collection
	 * @param  {String}   id       id of target doc
	 * @param  {Function} callback signature: error, removedDocumentId
	 * @return {String}            removed document id
	###

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

