class Validator

	constructor : (schema)->
		schema = schema

	validate : (doc, callback) ->

	clean : (callback) ->
		for prop, value of @
			if typeof value isnt 'function'
				delete @[prop]
		callback

	update : (newSchema, callback) ->
		for prop, value of newSchema
			@[prop] = value
		callback if callback



# comprueba si es un objeto vacío
isEmptyObj : (obj) ->
	for key in obj
		if hasOwnProperty.call(obj, key) then return false
	true 

# Property type validations
valType =
	
	isString : (obj) ->
		typeof obj is 'string'
	
	isNumber : (obj) ->
		typeof obj is 'number'
	
	isBoolean : (obj) ->
		typeof obj is 'boolean'
	
	isDate : (obj) ->
		obj instanceof Date and not isNaN(obj.valueOf())
	
	isObjectId : (obj) ->
		# check if is objectId
	
	isObject : (obj) ->
		(typeof obj is "object") and (obj isnt null)
	
	isArray : (obj) ->
		Object.prototype.toString.call obj is '[object Array]'

	isFree : -> true


checkType : (type, here, callback) ->
	switch tipo
		when String
			here._type = valType.isString
			break
		when Number
			here._type = valType.isNumber
			break
		when Boolean
			here._type = valType.isBoolean
			break
		when Date
			here._type = valType.isDate
			break
		when 'objectId'
			here._type = valType.isObjectId
			break
		when ''
			here._type = valType.isFree
			break
		else
			callback()

# generates validator
bake : (schema, ext) ->
	x = ext or {}
	for key, obj of schema
		x[key] ?= {}
		checkType obj, x[key], ->
			# si es un objeto o array
			if typeof obj is 'object'
				# si es un array
				if obj.length isnt undefined
					x[key]._type = valType.isArray
				# si es un objeto con type del ODM
				else if obj._type?
					x[key]._required = obj._required if obj._required?
					x[key]._default = obj._default if obj._default?
					x[key]._max = obj._max if obj._max?
					x[key]._min = obj._min if obj._min?
					x[key]._autoInc = obj._autoInc if obj._autoInc?
					x[key]._limit = obj._limit if obj._limit?
					x[key]._unique = obj._unique if obj._unique?

					if obj._default?
						if typeof obj._default is 'function'
							x[key]._default = obj._default
						else
							x[key]._default = () -> obj._default
					checkType obj._type, x[key], ->
						console.log 'error, no valid type'
				# no tiene type
				else
					x[key]._type = valType.isObject
					# si tiene hijos
					if not isEmptyObj obj
						x[key][c] = bake obj[c] for c of obj
			else
				console.log 'error, no object valid'
	# Return the object
	x



module.exports = Validator