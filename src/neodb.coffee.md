
neodb
=====
	
	# get dependencies
	Database = require './Database'
	Collection = require './Collection'
	Document = require './Document'
	Model = require './Model'
	#Schema = require './Schema'

	neodb = {}

	# Assign classes
	neodb.Database = Database neodb
	neodb.Collection = Collection neodb
	neodb.Document = Document neodb
	neodb.Model = Model neodb
	#neodb.Schema = Schema neodb

	module.exports = neodb
