module.exports = Utils =

	## Test whether we're running in Node
	isNodeJS: (typeof process is 'object') and ("#{process}" is '[object process]')

	## get the file extension of a filename
	getFileExtension: (filename) ->
		filename.replace /^.*\./, ''

	## Change the extension of a filename
	changeFileExtension: (filename, newExt) ->
		ext = Utils.getFileExtension filename
		return filename.replace new RegExp("#{ext}$"), newExt

