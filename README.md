neodb
=====


**NOT READY FOR USE**

NeoDB is an experimental database for node.js projects, it's written in coffeescript/javascript. This database is not intended for high concurrency input data tasks or large storage projects, but fits perfect with typical blogs and portfolios.

NeoDB saves database and collections in folders, and its documents in json files named as their ids.

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

```js
// get dependency
var neodb = require('neodb');

// Create/add database passing db path as argument
var db = new neodb('./mydb');

// Create/add a collection
db.addCollection('Book');

// Insert a document (this returns the document itself)
db.Book.insert({
	title:'El Quijote',
	author:'Cervantes',
	year: 1605
});
// Insert some documents (this returns an array of inserted documents)
db.Book.insert([
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
var quijote = db.Book.findOne({title: 'El Quijote'});

// edit it
quijote.year = 2024;

// update it
quijote.update( function (err, doc) {
	// do something async
}

// find documents with mongodb query style
db.Book.find({year: {$gt: 1900}}, function (err, docs) {
	// docs is an array with Lord of rings and Javascript....
	console.log docs
})
```


```coffee
# get dependency
neodb = require 'neodb'
# Create/add database passing db path as argument
db = new neodb './mydb'
# Create/add a collection
db.addCollection 'Book'
# Insert a document (this returns the document itself)
db.Book.insert
	title:'El Quijote'
	author:'Cervantes'
	year: 1605
# Insert some documents (this returns an array of inserted documents)
db.Book.insert [
	title:'The Lord of the Rings'
	author:'JRR Tolkien'
	year: 1954
,
	title:'JavaScript: The Good Parts'
	author:'Douglas Crockford'
	year: 2008
]

# find a single document
quijote = db.Book.findOne {title: 'El Quijote'}
# edit it
quijote.year = 2024
# update it
quijote.update (err, doc) ->
	# do something async

# find documents with mongodb query style
db.Book.find {year: {$gt: 1900}}, (err, docs) ->
	# docs is an array with Lord of rings and Javascript....
	console.log docs
```






## Guide

### DataBase
### Collection
### Document
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

- Database
	- constructor
	- addCollection
	- clean

- Collection
	- constructor
	- addSchema
	- insert
	- find
	- findOne
	- findById
	- update
	- remove
	- removeById
	- clean

- Document
	- constructor
	- insert
	- remove
	- update

- Schema
	-


## Running Tests

To run the test suite, first invoke the following command within the repo, installing the development dependencies:

```
$ npm install
```

Then run the tests:

```
$ npm test
```
