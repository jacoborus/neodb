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


	###*
	 * Create folder for collection if not exists
	 * @param  {String}   name     name of collection
	 * @param  {Function} callback signature: error
	 * @return {Object}            Collection data
	###

	addCollection : (name, callback) ->
		colPath = @dbPath + '/' + name
		col = {}
		# check if folder exists
		if fs.existsSync colPath
			
			addFile = (fileName)->
				filePath = colPath + "/" + fileName
				fs.readFile filePath, (err, data) ->
					throw err if err
					col[fileName] = JSON.parse(data)
			
			# read all files and then callback the collection object
			async.each fs.readdirSync(colPath), addFile, (err) ->
				callback null, col
				col

		else
			fs.mkdir colPath, (err) ->
				callback err, {} if callback
				{}

	removeCollection : (collectionName, callback) ->
		deleteFolderRecursive @dbPath + '/' + collectionName


	cleanCollection : (name, callback) ->


	insertDoc : (doc, callback) ->
		fs.writeFile(filename, data, [options], callback)
		fs.readFile '/path/to/some/file.txt', (err, data) ->
			throw err if err
			console.log data


	insertDocs : (docs, callback)->
		for colName, col of docs
			for id, doc of col
				archive.append doc, { name: colName + '/' + id }


	updateDoc : (doc, callback) ->


	updateDocs : (docs, callback) ->


	removeDoc : (id, callback) ->


	removeDocs : (ids, callback) ->



module.exports = datastore