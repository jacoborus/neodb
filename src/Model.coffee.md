
Model
========
	
	_exports = (neodb) ->
		(collection) ->
			class Model



Model#constructor( )
-------------------------------------

**Parameters:**

- `collection` `Object`: Collection to insert the Document when saved

Code:

				constructor: ->

				collection: collection



Model#insert( callback )
---------------------------

Insert document in its collection.

**Parameters:**

- `callback` is optional, signature: error, new Document

**Returns:** `Object` : document/s inserted

Code:

				insert : (doc, callback) ->
					@collection.insert doc, callback



Model#drop( callback )
-------------------------

Remove Document from its collection.
Parameters:

- `query` `Object`
- `callback` (optional)

**Returns:** **`callback`**, signature: error

Code:

				drop : (query, callback) ->
					@collection.drop query, callback



Model#update( callback )
------------------------

Update the Document in database passing middleware

- `callback` is optional, signature: err, updated Document

Code:

				update : (query, doc, options, callback) ->
					@collection.update  query, doc, options, callback



	module.exports = _exports
