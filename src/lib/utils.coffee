module.exports = Utils =
	isNodeJS: (typeof process is 'object') and ("#{process}" is '[object process]')
	getFileExtension: (filename) ->
		filename.replace /^.*\./, ''
	changeFileExtension: (filename, newExt) ->
		ext = Utils.getFileExtension filename
		return filename.replace new RegExp("#{ext}$"), newExt

