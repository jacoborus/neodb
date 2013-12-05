
chai = require 'chai'
chai.should()
sinon = require 'sinon'

neodb = require '../src/neodb'

describe 'Document constructor', ->

	it 'return an object', ->
		col = new neodb.Collection 'Book'
		doc = new col.Document()
		doc.should.be.a 'object'

