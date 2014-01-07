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
### Template

Template defines the shape, validation, relationships and behaviour of each collection and its documents.

Each key in your schema defines a property in every document of collections schema.

#### Field Types

The permitted fields are
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

Middleware is a stack of functions that runs when the input operations occurs. NeoDB have two middleware threads: **save** and **remove**.

Save middleware executes the next processes in order:

- Init
- Validaton
- Presave
- Save
- Postsave

Remove middlewate executes the next processes in order

- Preremove
- remove
- postremove

Init, presave, preremove, postsave and postremove are configurable functions that requires 2 arguments, first is for document target and second is a callback funcion to pass next step. You can set this functions with `middleware.set` method through `middleware drawer` property:

```js
drawer.middleware( 'presave', function (card, next) {
	// do something with card
	next(); // pass to next process 
});
```

Card have `_isNew : true` property, when it is inserted in his drawer for first time


### Virtuals


## API docs


- Neodb
	- open
	- close
	- clean
	- getPath
- Drawer
	- Card
	- insert
	- update
	- set
	- remove
	- removeById
	- get
	- find
	- findOne
	- clean
	- middleware
- Card **
	- _insert
	- _remove
	- _update
- Middleware
	- set
	- save
	- remove
- Query
	- comparators
	- operators
- Validator
- Template
	- getter
		- update
	- setter
- dbStore
	- open
	- remove
	- clean
- DataStore
	- save
	- remove
- Series
	- each
	- loop
- Virtuals


## Running Tests

To run the test suite, first invoke the following command within the repo, installing the development dependencies:

```
$ npm install
```

Then run the tests:

```
$ npm test
```