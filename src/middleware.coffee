async = require 'async'


pres =
	save : 

class middleware

	save : ->
		async.series [ init, clean, validate, pre, proceed, post ], callback if callback

	remove : ->
		async.series [ pre, proceed, post ], callback if callback

	clean : ->
	validate : ->
	proceed : ->
		# check if inMemoryOnly
		# ...


	init : ->
	pre : ->
	post : ->



module.exports = middleware

# middleware is used for saving or removing documents
# 
# Middleware steps:
# - init
# - clean and validate
# - preprocess
# - process (save, remove, update)
# - post

