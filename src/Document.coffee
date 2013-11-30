###
Document
========

A *document* is .........

###

_exports = (collection) ->
	class Document

		###
		Document#Constructor( `[data]` )
		--------------------------------

		Extends Document with `data`, which contains the document data.

		**Parameters:**

		- `[data] <Object>` by default {}. Data to be inserted as a document

		###

		# if data is null, document is empty
		constructor : (data = {}) ->
			for x of data
				@[x] = data[x]

		collection : collection

		###
		Document#insert( `[callback]` )
		-------------------------------

		Insert document in its collection.

		**Parameters:**

		- `[callback] <Function>` signature: error, new document

		**Returns:** `<Object|Array>` : inserted document|documents

		###

		insert : (callback) ->
			@collection.insert doc, callback


		###
		Document#drop( `[callback]` )
		-----------------------------

		Remove document from its collection.

		**Parameters:**

		- `[callback] <Function>` signature:  err, numRemoved

		###

		drop : (callback) ->
			if @_id
				@collection.drop {_id: @_id}, callback
			else
				callback 'Cannot remove, object is not in collection' if callback


		###
		Document#update( `[callback]` )
		-------------------------------

		Update the document in database passing middleware

		- `[callback] <Function>` signature: err, updatedDoc

		###

		update : (callback) ->
			if @_id
				@collection.update
					_id: @_id
					@
					{multi:false, upsert:false}
					(err, replaced)->
						if callback then callback err, replaced else replaced
			else if callback
				callback 'Cannot update, object is not in collection'



module.exports = _exports
