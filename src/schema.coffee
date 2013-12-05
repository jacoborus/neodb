###
Schema
======
###

class Schema

	###*
	 * Create a new Schema and set it as `collection`.schema
	 * @param  {Object} schemaModel model structure
	 * @return {Object}              resultant schema of collection after extend the old one
	###
	constructor: (schemaModel) ->
		if @validate schemaModel
			@update schemaModel

	validate : (schemaModel) ->
		if typeof schemaModel is 'object' then true else false

	clean : (callback) ->
		for prop, value of @
			if typeof value isnt 'function'
				delete @[prop]
		callback


	update : (newSchema, callback) ->
		for prop, value of newSchema
			@[prop] = value
		callback if callback

	set : (newSchema, callback) ->
		if @validate newSchema
			@clean @extend newSchema, callback


module.exports = Schema