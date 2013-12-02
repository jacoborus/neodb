
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
		db = new neodb.Database()
		expect( db ).to.be.a 'object'
	it 'return an object with private property dbPath', ->
		db = new neodb.Database()
		expect( db.getPath ).to.equal ''
	it 'return an object with property route=false by default"', ->
		db = new neodb.Database()
		expect( db.route ).to.equal false
	it 'return an object with property route = "./something"', ->
		db = new neodb.Database './something'
		expect( db.route ).to.equal './something'
	it 'return an object with property route = false if it is created a inMemoryOnly database', ->
		db = new neodb.Database false
		expect( db.route ).to.equal false

describe 'Database#addCollection', ->

	it 'set this database as options.database', ->
		db = new neodb.Database()
		db.addCollection 'Books'
		expect( db['Books'].database ).to.equal db

	it 'overwrites options.inMemoryOnly if database is not persistant', ->
		db = new neodb.Database()
		db.addCollection 'Books', {inMemoryOnly: false}
		expect( db.Books.inMemoryOnly ).to.equal true

describe 'Database#dropCollection', ->