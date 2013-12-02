###
neodb
=====
###	
# get dependencies
require 'coffee-trace'
Database = require './Database'
Collection = require './Collection'
#Schema = require './Schema'

neodb = {}

# Assign classes
neodb.Database = Database neodb
neodb.Collection = Collection neodb
#neodb.Schema = Schema neodb

module.exports = neodb
