neodb
=====


**NOT READY FOR USE**

Experimental interface to access embedded nedb databases. In early development

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
	- Database#Constructor
	- Database#addCollection
	- Database#clean

- Collection
	- Collection#Constructor
	- Collection#addSchema
	- Collection#insert
	- Collection#find
	- Collection#findOne
	- Collection#findById
	- Collection#update
	- Collection#drop
	- Collection#ensureindex
	- Collection#clean

- Model
	- Model#constructor
	- Model#insert
	- Model#drop
	- Model#update

- Document
	- Document#constructor
	- Document#insert
	- Document#drop
	- Document#update

- Schema
	-
