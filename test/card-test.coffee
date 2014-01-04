
expect = require("chai").expect
neodb = require '../src/neodb'
fs = require 'fs'


neodb = require '../src/neodb'

describe 'Card constructor', ->

	it 'return an object', ->
		db = new neodb()
		db.open 'Book', (err, data) ->
			Books = db.drawers.Book
			card = new Books.Card()
			expect( card ).to.be.a 'object'

