neodb
=====


**NOT READY FOR USE**

Experimental nodejs database

## Installation

	npm install neodb


## Usage

js
```javascript
// Get dependency
var neodb = require('neodb');
```
coffee
```coffeescript
# Get dependency
neodb = require 'neodb'
```

## Quick start


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
