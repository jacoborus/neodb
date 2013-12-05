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
	 * Create folder for collection if not exists
	 * @param  {String}   name     name of collection
	 * @param  {Function} callback signature: error, collectionData
	 * @return {Object}            Collection data
	###

	addCollection : (name, callback) ->
		colPath = @dbPath + '/' + name
		col = {}
		# check if folder exists
		if fs.existsSync colPath
			addFile = (fileName, callback) ->
				console.log 'cargando archivos'
				console.log 'cargando: ' + fileName
				filePath = colPath + "/" + fileName
				fs.readFile filePath, (err, data) ->
					console.log JSON.parse data
					throw err if err
					col[fileName] = JSON.parse data
					callback()
			
			# read all files and then callback the collection object
			async.each fs.readdirSync(colPath), addFile, (err) ->
				console.log 'cargados todos los archivos'
				console.log  col
				callback null, col if callback
				col

		else
			fs.mkdir colPath, (err) ->
				callback err, {} if callback
				{}

	removeCollection : (collectionName, callback) ->
		deleteFolderRecursive @dbPath + '/' + collectionName


	cleanCollection : (name, callback) ->


	insertDoc : (collection, id, doc, callback) ->
		console.log doc
		route = @dbPath + '/' + collection + '/' + id
		console.log route
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