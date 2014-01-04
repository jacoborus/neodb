
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

describe 'Nedb constructor', ->

	it 'return an object', ->
		db = new neodb()
		expect( db ).to.be.a 'object'
	it 'return an object with private property path false by default', ->
		db = new neodb()
		expect( db.getPath() ).to.equal false
	it 'return an object with property dbPath = "./something"', ->
		db = new neodb './something'
		expect( db.getPath() ).to.equal './something'
		#deleteFolderRecursive './something'


describe 'nedb#open', ->

	it 'insert a collection in database', ->
		db = new neodb()
		db.open 'Book', ->
			expect( db.drawers ).to.have.property 'Book'


describe 'Database#dropCollection', ->