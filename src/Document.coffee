###
Document
========

A *document* is .........

###

_exports = (collection) ->
	class Document

		###*
		 * Extends Document with document data
		 * @param  {Object} data 	documents data
		 * @return {Object}     	document itself
		###
		constructor : (data = {}) ->
			for x of data
				@[x] = data[x]


		collection : collection


		###*
		 * Inserts document itself in collection
		 * @param  {Function} callback signature: err, insertedDoc
		 * @return {Object}            inserted document
		###
		insert : (callback) ->
			@collection.insert doc, callback


		###*
		 * Remove document from its collection
		 * @param  {Function} callback signature: error
		 * @return {Object}            removedDoc
		###
		drop : (callback) ->
			if @_id
				@collection.drop {_id: @_id}, callback
			else
				callback 'Cannot remove, object is not in collection' if callback


		###*
		 * Update the document in database after passing middleware
		 * @param  {Function} callback signature: error, replacedDoc
		 * @return {Object}            replaced document
		###
		update : (callback) ->
			if @_id
				@collection.update
					_id: @_id
					@
					{multi:false, upsert:false}
					(err, replaced)->
						if callback then callback err, replaced else replaced
			else callback 'Cannot update, object is not in collection' if callback


module.exports = _exports
