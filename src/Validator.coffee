class Validator

	constructor : (schema)->
		schema = schema


val =

	# comprueba si es un objeto vacío
	isEmptyObj : (obj) ->
		for key in obj
			if hasOwnProperty.call(obj, key) then return false
		true 

	# Valida tipos
	
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

	chekatipo : (compara, aqui, cb) ->
		switch compara
			when String
				aqui.type = 'string'
				break
			when Number
				aqui.type = 'number'
				break
			when Boolean
				aqui.type = 'boolean'
				break
			when Date
				aqui.type = 'date'
				break
			when 'objectId'
				aqui.type = 'objectId'
				break
			when null
				aqui.type = 'free'
				break
			else cb()

	# Primero compilamos el esquema
	# Añade la validación de tipos al modelo
	bake : (schema, ext) ->
		x = ext or {}
		for key of schema
			obj = schema[key]
			# si es null borramos el objeto
			if obj is null
				delete x[key] if x[key]?
			else
				x[key] ?= {}
				chekatipo obj, x[key], ->
					# si es un objeto
					if typeof obj is 'object'
						# si es un array
						if obj.length isnt undefined
							x[key].type = 'array'
						# si es un objeto con type del ODM
						else if obj.type?
							x[key].required = obj.required if obj.required?
							x[key].default = obj.default if obj.default?
							x[key].max = obj.max if obj.max?
							x[key].min = obj.min if obj.min?
							x[key].autoInc = obj.autoInc if obj.autoInc?
							x[key].limit = obj.limit if obj.limit?
							x[key].unique = obj.unique if obj.unique?

							if obj.default?
								if typeof obj.default is 'function'
									x[key].default = obj.default
								else
									x[key].default = () -> obj.default
							chekatipo obj.type, x[key], ->
								console.log 'error, no valid type'
						# no tiene type
						else
							x[key].type = 'object'
							# si tiene hijos
							if emptyObj obj
								x[key].childs = {}
								x[key].childs[c] = bake obj[c] for c of obj
					else
						console.log 'error, no object valid'
		# Return the object
		x



module.exports = Validator