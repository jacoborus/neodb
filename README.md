neodb
=====


**NOT READY FOR USE**

NeoDB is an experimental database for node.js projects, it's written in javascript. This database is not intended for high concurrency input data tasks or large storage projects, but fits perfect with typical blogs and portfolios.

NeoDB saves database and drawers in folders, and its documents/cards in json files named as their ids.

## Main features

- Only-in-memory, persistant or mixed databases
- Only-in-memory or persistant collections
- Object document modeling aka schemas
- MongoDB query style


## Installation

```
npm install neodb
```

## Quick start

**Coffeescript**

```coffee
# get dependency
neodb = require 'neodb'

# Create/add database passing db path as argument
db = new neodb './mydb'

# Create/add a drawer
db.open 'Books'
Books = db.drawers.Books

# Insert a card
Books.insert
	title:'El Quijote'
	author:'Cervantes'
	year: 1605

# Insert some documents
Books.insert [
	title:'The Lord of the Rings'
	author:'JRR Tolkien'
	year: 1954
,
	title:'JavaScript: The Good Parts'
	author:'Douglas Crockford'
	year: 2008
]

# find a single document
quijote = {}

Books.findOne {title: 'El Quijote'}, (err, card) ->
	# do something with card
	quijote = card

# edit it
quijote.year = 2024

# update it
quijote._update (err, doc) ->
	# do something async

# find documents with mongodb query style
Books.find {year: {$gt: 1900}}, (err, docs) ->
	# docs is an array with Lord of rings and Javascript....
	console.log docs
```


**Javascript**

```js
// get dependency
var neodb = require('neodb');

// Create/add database passing db path as argument
var db = new neodb('./mydb');

// Create/add a collection
db.open('Books');
Books = db.drawers.Books

// Insert a document (this returns the document itself)
Books.insert({
	title:'El Quijote',
	author:'Cervantes',
	year: 1605
});

// Insert some documents (this returns an array of inserted documents)
Books.insert([
	{
		title:'The Lord of the Rings'
		author:'JRR Tolkien'
		year: 1954
	},
	{
		title:'JavaScript: The Good Parts',
		author:'Douglas Crockford',
		year: 2008
	}
]);

// find a single document
var quijote = {};
Books.findOne({title: 'El Quijote'}, function(err, doc){
	quijote = doc;
});

// edit it
quijote.year = 2024;

// update it
quijote._update( function (err, doc) {
	// do something async
}

// find documents with mongodb query style
Books.find({year: {$gt: 1900}}, function (err, docs) {
	// docs is an array with Lord of rings and Javascript....
	console.log docs
})
```


## Guide

### Cabinet
### Drawer
### Card
### Schema

Schema defines the shape, validation, relationships and behaviour of each collection and its documents.

Each key in your schema defines a property in every document of collections schema.

#### Schema Types

The permitted SchemaTypes are
- String
- Number
- Boolean
- Date
- Array
- Object
- ObjectId

### Relationships
### Population
### Queries
### Validation
### Middleware

## API docs

- NeoDB
	- constructor(path)
	- open(drawerName, options, callback)
	- close(drawerName)
	- clean(drawerName)
	- Drawer class

- Drawer
	- constructor
	- async methods
		- insert
		- search
		- searchById
		- searchOne
		- update
		- remove
		- removeById
		- clean
	- sync methods
		- set
		- find
		- findById
		- findOne


		- addTemplate

- Card
	- constructor
	- _insert(callback)
	- _remove(callback)
	- _update(callback)

- Template
	- _update(newTemplate)
	- _set(newTemplate)

- Validator
	- validate(object)
	- update(template)

- Query
	- comparator
	- operator

- Middleware
	- set(step, fn)

- CabStore
	- openDrawer(name, callback)
	- removeDrawer(name, callback)
	- cleanDrawer(name, callback)

- DrawerStore
	- insertCard
	- insertCards
	- updateCard
	- updateCards
	- removeCard
	- removeCards


## Running Tests

To run the test suite, first invoke the following command within the repo, installing the development dependencies:

```
$ npm install
```

Then run the tests:

```
$ npm test
```
