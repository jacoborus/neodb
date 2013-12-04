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
inMemoryOnly = true
database = undefined
schema = false


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
			if opts.inMemoryOnly? and typeof opts.inMemoryOnly is 'boolean'
				inMemoryOnly = opts.inMemoryOnly
			else
				inMemoryOnly = true # default value

			schema = false

			# set database from options parameter, if database is not passed 
			# will create a new one and add this collection into it
			if opts and opts.database
				database = opts.database
			else 
				database = new neodb.Database()
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



# stolen from nedb

###*
 * Get a value from object with dot notation
 * @param {Object} obj
 * @param {String} field
###
getDotValue = (obj, field) ->
	fieldParts = if typeof field is 'string' then field.split('.') else field

	# field cannot be empty so that means we should return undefined so that nothing can match
	return undefined if not obj

	return obj if fieldParts.length is 0

	return obj[fieldParts[0]] if fieldParts.length is 1
	
	if util.isArray obj[fieldParts[0]]
		# If the next field is an integer, return only this item of the array
		i = parseInt fieldParts[1], 10
		if typeof i is 'number' and not isNaN i
			return getDotValue obj[fieldParts[0]][i], fieldParts.slice 2
		# Return the array of values
		objs = []
		for i in [o..(obj[fieldParts[0]].length)]
			objs.push getDotValue obj[fieldParts[0]][i], fieldParts.slice 1
		return objs
	else
		return getDotValue obj[fieldParts[0]], fieldParts.slice 1


areThingsEqual = (a, b) ->

	# Strings, booleans, numbers, null
	return (a is b) if (a is null) or (typeof a is ('string' or 'boolean' or 'number')) or (b is null) or (typeof b is ('string' or 'boolean' or 'number'))
	
	# Dates
	if (util.isDate(a) || util.isDate(b))
		return util.isDate(a) and util.isDate(b) and a.getTime() is b.getTime()

	# Arrays (no match since arrays are used as a $in)
	# undefined (no match since they mean field doesn't exist and can't be serialized)
	return false if util.isArray(a) or util.isArray(b) or (a is undefined) or (b is undefined)

	# General objects (check for deep equality)
	# a and b should be objects at this point
	try
		aKeys = Object.keys a
		bKeys = Object.keys b
	catch e
		return false

	return false if aKeys.length isnt bKeys.length

	top = aKeys.length
	for i in [0..top]
		if bKeys.indexOf(aKeys[i]) is -1
			return false
		if not areThingsEqual a[aKeys[i]], b[aKeys[i]]
			return false
	
	return true


###*
 * Check that two values are comparable
###
areComparable = (a, b) ->
	return false if (typeof a isnt 'string' and typeof a isnt 'number' and not util.isDate(a) and
		typeof b isnt 'string' and typeof b isnt 'number' and not util.isDate(b))

	return false if typeof a isnt typeof b

	return true;



###*
 * Arithmetic and comparison operators
 * @param {Native value} a Value in the object
 * @param {Native value} b Value in the query
 ###

compare =
	$lt : (a, b) ->
		areComparable(a, b) and a < b

	$lte : (a, b) ->
		areComparable(a, b) and a <= b

	$gt : (a, b) ->
		areComparable(a, b) and a > b

	$gte : (a, b) ->
		areComparable(a, b) and a >= b

	$ne : (a, b) ->
		return true if not a
		not areThingsEqual a, b

	$in : (a, b) ->
		throw "$in operator called with a non-array" if not util.isArray b
		top = b.length
		for i in [0..top]
			return true if areThingsEqual a, b[i]
		false

	$exists : (value, exists) ->
		if exists or exists is '' then exists = true else exists = false
		if value is undefined then return not exists else return exists
	
	$regex : (a, b) ->
		throw "$regex operator called with non regular expression" if not util.isRegExp b
		if typeof a isnt 'string'
			return false
		else
			return b.test a



operators =

	###*
	 * Match any of the subqueries
	 * @param {Model} obj
	 * @param {Array of Queries} query
	###

	$or : (obj, query) ->

		throw "$or operator used without an array" if not util.isArray query

		len = query.length
		for i in [0..len]
			return true if match obj, query[i]
		false


	###*
	 * Match all of the subqueries
	 * @param {Model} obj
	 * @param {Array of Queries} query
	###

	$and : (obj, query) ->

		throw "$and operator used without an array" if !util.isArray query

		len = query.length
		for i in [0..len]
			return false if not match obj, query[i]
		true


	###*
	 * Inverted match of the query
	 * @param {Model} obj
	 * @param {Query} query
	###

	$not : (obj, query) ->
		return not match obj, query



###*
 * Tell if a given document matches a query
 * @param {Object} obj Document to check
 * @param {Object} query
###

match = (obj, query) ->

	# Primitive query against a primitive type
	# This is a bit of a hack since we construct an object with an arbitrary key only to dereference it later
	# But I don't have time for a cleaner implementation now
	if isPrimitiveType obj or isPrimitiveType query
		return matchQueryPart { needAKey: obj }, 'needAKey', query
		
	# Normal query
	queryKeys = Object.keys query
	len = queryKeys.length
	for i in [0..len]
		queryKey = queryKeys[i]
		queryValue = query[queryKey]
	
		if queryKey[0] is '$'
			throw "Unknown logical operator " + queryKey if not logicalOperators[queryKey]
			return false if not logicalOperators[queryKey] obj, queryValue
		else
			return false if not matchQueryPart obj, queryKey, queryValue

	return true


###*
 * Match an object against a specific { key: value } part of a query
 * if the treatObjAsValue flag is set, don't try to match every part separately, but the array as a whole
###

matchQueryPart = (obj, queryKey, queryValue, treatObjAsValue) ->
	objValue = getDotValue obj, queryKey

	# Check if the value is an array if we don't force a treatment as value
	if util.isArray objValue && not treatObjAsValue
		# Check if we are using an array-specific comparison function
		if queryValue isnt null and typeof queryValue is 'object' and not util.isRegExp queryValue
			keys = Object.keys queryValue
			keyLen = keys.length
			for i in [0..keyLen]
				return matchQueryPart(obj, queryKey, queryValue, true) if arrayComparisonFunctions[keys[i]]


		# If not, treat it as an array of { obj, query } where there needs to be at least one match
		objLen = objValue.length
		for i in [0..objLen]
			return true if matchQueryPart { k: objValue[i] }, 'k', queryValue   # k here could be any string
		false


	# queryValue is an actual object. Determine whether it contains comparison operators
	# or only normal fields. Mixed objects are not allowed
	if queryValue isnt null and typeof queryValue('object') && not util.isRegExp queryValue
		keys = Object.keys queryValue
		firstChars = _.map keys, (item) ->
			item[0]
		dollarFirstChars = _.filter firstChars, (c) ->
			c is '$'

		if dollarFirstChars.length isnt 0 and dollarFirstChars.length isnt firstChars.length
			throw "You cannot mix operators and normal fields"

		# queryValue is an object of this form: { $comparisonOperator1: value1, ... }
		if dollarFirstChars.length > 0
			keyLen2 = keys.length
			for i in [0..keyLen2]
				throw "Unknown comparison function " + keys[i] if not comparisonFunctions[keys[i]]

				return false if not comparisonFunctions[keys[i]] objValue, queryValue[keys[i]]
			return true

	# Using regular expressions with basic querying
	return comparisonFunctions.$regex(objValue, queryValue) if util.isRegExp queryValue
	# queryValue is either a native value or a normal object
	# Basic matching is possible
	return false if not areThingsEqual objValue, queryValue

	return true
