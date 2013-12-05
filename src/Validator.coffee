

# middleware and validation steps:
# 
# - init
# - clean
# - fill default fields if needed
# - 


class Validator

	constructor : (schema)->
		validator = bake schema
		@create validator

	validate : (doc, callback) ->

	create : (schema, callback) ->
		for prop, value of newSchema
			@[prop] = value
		callback if callback
		true

	clean : (callback) ->
		for prop, value of @
			if typeof value isnt 'function'
				delete @[prop]
		callback

	update : (schema, callback) ->
		@clean @create schema, callback



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
			# it is an object or array
			if typeof obj is 'object'
				# it is an array
				if obj.length isnt undefined
					x[key]._type = valType.isArray
				# it is an objet with _type property
				else if obj._type?
					x[key]._required = obj._required if obj._required?
					x[key]._unique = obj._unique if obj._unique?

					if obj._default?
						if typeof obj._default is 'function'
							x[key]._default = obj._default
						else
							x[key]._default = () -> obj._default
					checkType obj._type, x[key], ->
						console.log 'error, no valid type'
				# has not _type property, it is an object
				else
					x[key]._type = valType.isObject
					# if have childs
					if not isEmptyObj obj
						# recursive
						x[key][c] = bake obj[c] for c of obj
			else
				console.log 'error, no object valid'
	# Return the object
	x



module.exports = Validator