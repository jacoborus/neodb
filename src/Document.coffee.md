
Document
========

A *document* is an object linked to a with prototype functions 

	_exports = (neodb) ->
		neodb = neodb

		(Model) ->
	
			class Document extends Model


Document#Constructor( [data] )
-------------------------------------

Extends Document with `data`, which contains the document data.
Parameters:

- **`data`** `Object`: (by default {}) Data to be inserted as a document

**Returns** 

				# if is an empty document fill @data with {}
				constructor: (data) ->
					data = {} if not data?
					for x of data
						@[x] = data[x]



Document#insert( callback )
---------------------------

Insert document in its collection.
Parameters:

- **`callback`** is optional, signature: error, new document
Returns:
- **`Object`** : document/s inserted

Code:

				insert : (callback) ->
					super @, callback



Document#drop( callback )
-------------------------

Remove document from its collection.
**Parameters:**

- **`callback`** (optional)

**Returns:** `callback`, signature: error

				drop : (callback) ->
					if @_id
						super {_id: @_id}, callback
					else
						errorMsg = 'Cannot remove, object is not in collection'
						if callback then callback errorMsg else errorMsg



Document#prepare( callback )
------------------------

Extends document with its own properties and make it pass the initialize process.

**Parameters:**

- **`callback`**

prepare : (callback) ->
	@_id = @elem._id if @elem._id
	@elem[x] = @[x] for x of @elem
	callback() if callback



Document#update( callback )
------------------------

Update the document in database passing middleware
* `callback` is optional, signature: err, updated document

				update : (callback) ->
					# @prepare =>
					if @_id
						super
							_id: @_id
							@
							{multi:false, upsert:false}
							(err, replaced)->
								callback err,replaced if callback
					else
						callback 'Cannot update, object is not in collection'



	module.exports = _exports
