###*
 * Collection
 * ==========
 * 
 * Collection is an natural javascript object with documents
 * 
###

util = require 'util'
Document = require './document'

genId = ->
	'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
		r = Math.random()*16|0
		v = if c is 'x' then r else (r&0x3|0x8)
		v.toString 16

Doc = ->

collectionName = ''
db = undefined
inMemoryOnly = false
schema = false

class Collection

	###*
	 * Collection constructor
	 * @param  {String} collectionName			name of collection
	 * @param  {Object} database 				database to insert this new collection into, if `null` Collection will be treated as an orphan, but it will have a virtual database for itself
	 * @param  {Object} options 				Object with options
	 * @param  {Boolean} options.inMemoryOnly	if `true` collection is not persistant
	 * @param  {Object} options.schema			Schema for validation and relationships
	 * @param  {Object} options.initData 		data to initialize collection
	 * @param  {Function} callback 				signature error, collectionItself
	###
	constructor: (name, database, options) ->
		
		# set private properties
		collectionName = name
		db = database
		opts = options or {}
		inMemoryOnly = opts.inMemoryOnly if opts.inMemoryOnly

		# extend collection with initData
		opts.initData ?= {}
		for id, doc of opts.initData
			@[id] = doc

		# create document model
		Doc = Document @
		# add collection to database
		db[collectionName] = @

	# returns document model
	Document : (-> Doc)()


	# Only for testing purposes
	getDb : -> database
	getInMemoryOnly : -> inMemoryOnly


	###*
	 * Adds a new schema to `Collection.schema` and compiles its validator
	 * @param {Object}   schemamodel structure model
	 * @param {Function} callback
	 * @return {Object} processed schema after extend the old one
	###

	setSchema : (newSchema, callback) ->
		if typeof newSchema is 'object'
			schema = newSchema
			if callback then callback null, schema else schema
		else
			if callback then callback 'not valid schema' else false


	# returns actual schema
	getSchema : (-> schema)()

	updateSchema : ->


	###*
	 * Insert new document/s in collection
	 * @param  {Object||Array}   	docs     document/s to be stored
	 * @param  {Function} callback 	signature: error, insertedDocumentsIds
	 * @return {Array}            	list of inserted document ids
	###

	insert : (data, callback) ->
		if typeof data is 'object'
			# insert one document
			if data.length is undefined
				id = genId()
				if inMemoryOnly
					@[id] = data
					if callback then callback null, [id] else [id]
				else
					db._datastore().insertDoc collectionName, id, data, (err) ->
						if err
							if callback then callback err else []
						else
							@[id] = data
							if callback then callback null, [id] else [id]

			# insert multiple documents
			else if typeof data.length is 'number'
				if inMemoryOnly
					ids = []
					for i in data
						ids[i] = genId()
						@[ids[i]] = data[i]
					if callback then callback null, ids else ids
				else
					
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
				if callback then callback null, doc else doc
			else if callback then callback 'document not found' else null
		else if callback then callback 'not valid identifier' else null


	###*
	 * Clean a document by identifier and sets its new data
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
			if callback then callback null, doc else doc
		else
			if callback then callback 'Document not found' else null


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
							if (typeof value is 'string') or (typeof value is 'number') or (typeof value is 'boolean')
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


module.exports = Collection

