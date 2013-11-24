
chai = require 'chai'
chai.should()

neodb = require '../src/neodb'

describe 'Model constructor', ->

	it 'return an object', ->
		Mod = neodb.Model()
		mod = new Mod()
		mod.should.be.a 'object'


