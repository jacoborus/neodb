
chai = require 'chai'
chai.should()
sinon = require 'sinon'

neodb = require '../src/neodb'

describe 'Document constructor', ->

	it 'return an object', ->
		doc = new neodb.Document()
		doc.should.be.a 'object'

