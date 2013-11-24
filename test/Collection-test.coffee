
expect = require("chai").expect
neodb = require '../src/neodb'
fs = require 'fs'

deleteFolderRecursive = (path) ->
	if fs.existsSync path
		fs.readdirSync(path).forEach (file,index) ->
			curPath = path + "/" + file
			if fs.statSync(curPath).isDirectory()
				deleteFolderRecursive curPath
			else
				fs.unlinkSync curPath
		fs.rmdirSync path

describe 'Collection#Constructor', ->

	it 'returns an Object', ->
		col = new neodb.Collection()
		expect( col ).to.be.an 'object'

	it 'returns an Object with name, database, dS, and inMemoryOnly properties if name passed', ->
		col = new neodb.Collection('Books')
		expect( col ).to.include.keys 'name', 'database', 'dS', 'inMemoryOnly', 'schema'

	it 'inMemoryOnly is false by default', ->
		col = new neodb.Collection 'Books'
		expect( col.inMemoryOnly ).to.equal false

	it 'set inMemoryOnly as true if passed as option', ->
		col = new neodb.Collection 'Books', { inMemoryOnly: true }
		expect( col.inMemoryOnly ).to.equal true

	it 'schema is false by default', ->
		col = new neodb.Collection 'Books'
		expect( col.schema ).to.equal false

	it 'detects pass callback instead options', ->
		col = new neodb.Collection 'Books', -> 'hey'
		expect( col.inMemoryOnly ).to.equal false

	it 'should have a data store (dS)', ->
		col = new neodb.Collection 'Books'
		expect( col ).to.have.property 'dS'

	it 'create a new virtual database if no one passed as option', ->
		col = new neodb.Collection 'Books'
		expect( col ).to.have.property 'database'

	it 'inserts collection into its database', ->
		col = new neodb.Collection 'Books'
		expect( col.database ).to.have.property 'Books'

	it 'if schema is passed, compiles into a validator'

	it 'create datastore, if inMemoryOnly is true it will be not persistant'

describe 'collection#Document', ->

	it 'should return a Document (object)', ->
		col = new neodb.Collection 'Book'
		doc = col.Document()
		expect( doc ).to.be.an 'object'