

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
