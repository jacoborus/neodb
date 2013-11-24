
Document
========

A *document* is .........

Code:

	_exports = (neodb) ->

		(Model) ->
	
			class Document extends Model


Document#Constructor( [data] )
-------------------------------------

Extends Document with `data`, which contains the document data.
Parameters:

- `data` `Object`: (by default {}) Data to be inserted as a document

Code:

				# if is an empty document fill @data with {}
				constructor: (data) ->
					data = {} if not data?
					for x of data
						@[x] = data[x]



Document#insert( callback )
---------------------------

Insert document in its collection.
Parameters:

- `callback` is optional, signature: error, new document
Returns:
- `Object` : document/s inserted

Code:

				insert : (callback) ->
					super @, callback



Document#drop( callback )
-------------------------

Remove document from its collection.
**Parameters:**

- `callback` (optional)

**Returns:** `callback`, signature: error

Code:

				drop : (callback) ->
					if @_id
						super {_id: @_id}, callback
					else
						errorMsg = 'Cannot remove, object is not in collection'
						if callback then callback errorMsg else errorMsg



Document#prepare( callback )
----------------------------

Extends document with its own properties and make it pass the initialize process.



Document#update( callback )
---------------------------

Update the document in database passing middleware

- `callback` (optional) signature: err, updatedDoc

Code:

				update : (callback) ->
					if @_id
						super
							_id: @_id
							@
							{multi:false, upsert:false}
							(err, replaced)->
								if callback then callback err, replaced else replaced
					else
						if callback then callback 'Cannot update, object is not in collection' else 'false'



	module.exports = _exports
