###
Document
========

A *document* is .........

###
collection = ''

_exports = (collection) ->

	collection = collection
	class Document

		###*
		 * Extends Document with document data
		 * @param  {Object} data 	documents data
		 * @return {Object}     	document itself
		###
		constructor : (data = {}) ->
			for x of data
				@[x] = data[x]


		###*
		 * Inserts document itself in collection
		 * @param  {Function} callback signature: err, insertedDoc
		 * @return {Object}            inserted document
		###
		insert : (callback) ->
			collection.insert doc, callback


		###*
		 * Remove document from its collection
		 * @param  {Function} callback signature: error
		 * @return {Object}            removedDoc
		###
		remove : (callback) ->
			if @_id
				collection.remove {id: @_id}, callback
			else
				if callback then callback 'Cannot remove, object is not in collection' else {}


		###*
		 * Update the document in database after passing middleware
		 * @param  {Function} callback signature: error, replacedDoc
		 * @return {Object}            replaced document
		###
		update : (callback) ->
			if @_id
				collection.set @_id, @, (err, doc)->
					if callback then callback err, doc else doc
			else
				callback 'Cannot update, object is not in collection' if callback


module.exports = _exports
