
expect = require('chai').expect
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

describe 'Database constructor', ->

	it 'return an object', ->
		db = new neodb()
		expect( db ).to.be.a 'object'
	it 'return an object with private property dbPath false by default', ->
		db = new neodb()
		expect( db.getPath() ).to.equal false
	it 'return an object with property dbPath = "./something"', ->
		db = new neodb './something'
		expect( db.getPath() ).to.equal './something'
		deleteFolderRecursive './something'


describe 'Database#addCollection', ->

	it 'insert a collection in database', ->
		db = new neodb()
		db.addCollection 'Book'
		expect( db['Book'].getDb() ).to.equal db

	it 'overwrites options.inMemoryOnly if database is not persistant', ->
		db = new neodb.Database()
		db.addCollection 'Books', {inMemoryOnly: false}
		expect( db.Books.getInMemoryOnly() ).to.equal true

describe 'Database#dropCollection', ->