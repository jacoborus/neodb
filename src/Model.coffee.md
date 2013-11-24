
Model
========
	
	_exports = (neodb) ->

		(collection) ->

			class Model



Model#constructor( )
-------------------------------------

**Parameters:**

- **`collection`** `Object`: Collection to insert the Document when saved

Code:

				constructor: ->

				collection: collection

Model#insert( callback )
---------------------------

Insert document in its collection.

**Parameters:**

- **`callback`** is optional, signature: error, new Document

**Returns:** `Object` : document/s inserted

				insert : (doc, callback) ->
					@collection.insert doc, callback



Model#drop( callback )
-------------------------

Remove Document from its collection.
Parameters:

- `query` `Object`
- `callback` (optional)

**Returns:** **`callback`**, signature: error

				drop : (query, callback) ->
					@collection.drop query, callback



Model#prepare( callback )
------------------------
Extends Document with its own properties and make it pass the initialize process.
* `callback`

prepare : (callback) ->
	@_id = @elem._id if @elem._id
	@elem[x] = @[x] for x of @elem
	callback() if callback



Model#update( callback )
------------------------

Update the Document in database passing middleware

* `callback` is optional, signature: err, updated Document

				update : (query, doc, options, callback) ->
					@collection.update  query, doc, options, callback



	module.exports = _exports
