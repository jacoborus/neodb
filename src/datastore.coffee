fs = require 'fs'
async = require 'async'

# remove folder
deleteFolderRecursive = (path) ->
	if fs.existsSync path
		fs.readdirSync(path).forEach (file,index) ->
			curPath = path + "/" + file
			# recurse
			if fs.statSync(curPath).isDirectory()
				deleteFolderRecursive curPath
			else # delete file
				fs.unlinkSync curPath
		fs.rmdirSync path


class datastore

	constructor : (@dbPath = __dirname + './neodb') ->
		if not fs.existsSync @dbPath
			fs.mkdir @dbPath



	###*
	 * Load selected folder (collection) or create one if not exists
	 * @param  {String}   name     name of collection
	 * @param  {Function} callback signature: error, collectionData
	 * @return {Object}            Collection data
	###

	addCollection : (name, callback) ->
		colPath = @dbPath + '/' + name
		# check if folder exists
		if fs.existsSync colPath
			col = {}
			# iteration. Load files
			addFile = (fileName, next) ->
				filePath = colPath + "/" + fileName
				fs.readFile filePath, (err, data) ->
					throw err if err
					col[fileName] = JSON.parse data
					next()
			
			# read all files and then callback the collection object
			async.each fs.readdirSync(colPath), addFile, (err) ->
				callback null, col if callback
				col
		# create folder if not exists
		else
			fs.mkdir colPath, (err) ->
				callback err, {} if callback
				{}

	###*
	 * Remove collection and documents (folder and files)
	 * @param  {String}   collectionName name of collection to remove
	 * @param  {Function} callback       signature: numRemovedDocs
	 * @return {Number}                  num of removed documents
	###
	removeCollection : (collectionName, callback) ->
		if fs.existSync @dbPath + '/' + collectionName
			total = 0
			fs.readdirSync(path).forEach (file,index) ->
				curPath = path + "/" + file
				total++
				fs.unlinkSync curPath
			fs.rmdirSync path
			if total then callback total else total

	cleanCollection : (name, callback) ->


	insertDoc : (collection, id, doc, callback) ->
		route = @dbPath + '/' + collection + '/' + id
		fs.writeFile route, JSON.stringify(doc), callback


	insertDocs : (docs, callback)->
		for colName, col of docs
			for id, doc of col
				archive.append doc, { name: colName + '/' + id }


	updateDoc : (doc, callback) ->


	updateDocs : (docs, callback) ->


	removeDoc : (id, callback) ->


	removeDocs : (ids, callback) ->



module.exports = datastore