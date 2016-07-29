module.exports =
	isNodeJS: (typeof process is 'object') and ("#{process}" is '[object process]')
	getFileExtension: (filename) ->
		filename.replace /^.*\./, ''
