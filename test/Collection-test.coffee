
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

	it 'returns an object', ->
		col = new neodb.Collection('Books')
		expect( col ).to.be.an 'object'

	it 'inMemoryOnly is true by default', ->
		col = new neodb.Collection 'Books'
		expect( col.getInMemoryOnly() ).to.equal true

	it 'set inMemoryOnly as false if passed as option', ->
		col = new neodb.Collection 'Books', { inMemoryOnly: false }
		expect( col.getInMemoryOnly() ).to.equal false

	it 'schema is false by default', ->
		col = new neodb.Collection 'Books'
		expect( col.getSchema() ).to.equal false

	it 'detects pass callback instead options', ->
		col = new neodb.Collection 'Books', -> 'hey'
		expect( col.getInMemoryOnly() ).to.equal true

	it 'create a new virtual database if no one passed as option', ->
		col = new neodb.Collection 'Book'
		expect( col.getDb().Book ).to.equal col

	it 'inserts collection into its database', ->
		col = new neodb.Collection 'Books'
		expect( col.getDb() ).to.have.property 'Books'

	it 'if schema is passed, compiles into a validator'

	it 'create datastore, if inMemoryOnly is true it will be not persistant'

describe 'collection#Document', ->
