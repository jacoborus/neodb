
Database
========

	_exports = (neodb) ->
		
		class Database



Database#Constructor( [route] )
-------------------------------

Create and/or connect a database

- **`route`** `String` (optional): indicates the folder to save the database

If no `route` database is non persistant

			constructor: (@route = false) ->



Database#addCollection( collectionName, [options], [callback] )
-------------------------------------------------------------------------------

Adds a collection into Database[`collectionName`]

**Parameters:**

- **`collectionName`** `String`:name of collection will be inserted as `database[collectionName]`
- **`options`** `Object`:
	- **`schema`** `Object`: Schema for validation and relationships
	- **`inMemoryOnly`** `Boolean`: `false` by default, indicator of non persitant collection
- **`callback`** `Function`: (optional) signature: error, inserted collection

Code:

			addCollection: (collectionName, options, callback) ->

				if not options
					opts = {}
				else if typeof options is 'function'
					callback = options
					opts = {}
				else if typeof options is 'object'
					opts = options

				opts.database = @
				opts.inMemoryOnly = true if @route is false

				if collectionName and (typeof collectionName is 'string')
					@[collectionName] = new neodb.Collection collectionName, opts, callback
				else if callback
					callback 'collectionName not valid'			



Database#dropCollection( collectionName, [callback] )
-----------------------------------------------------

Drop a collection from Database

**Parameters:**

- **`collectionName`** `String`: name of collection to drop
- **`callback`** `Function`: (optional) signature: error, `String` name of collection

**Returns**:

- **`String`**: name of dropped collection if dropped
- **`false`**: if not collection dropped

.

dropCollection: (collectionName, callback) ->
	if collectionName? and typeof collectionName is 'string'
		if @[collectionName]?
			delete @[collectionName]
			callback(null, collectionName) if callback
			collectionName
		callback "No collection found: #{collectionName}" if callback
		false
	else
		callback 'Invalid collectionName' if callback
		false


Database#clean( callback )
--------------------------

Remove all documents of all collections in database

**Parameter:**

- **`callback`** `function`: no signature

Code:

clean: (callback) ->


	module.exports = _exports