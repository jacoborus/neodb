
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

describe 'Drawer#Constructor', ->

	it 'returns an Object', ->
		db = new neodb()
		drawer = db.open 'Book'
		expect( db.drawers['Book'] ).to.be.an 'object'

	it 'have a property Card that is a class (function)', ->
		db = new neodb()
		db.open 'Book'
		expect( db.drawers['Book'].Card ).to.be.a 'function'

describe 'drawer#Document', ->
