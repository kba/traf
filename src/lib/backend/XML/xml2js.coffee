BaseBackend = require '../base_backend'
Xml2Js = require 'xml2js'
module.exports = class Xml2JsBackend extends BaseBackend
	constructor: (opts) ->
		@parser = new Xml2Js.Parser(opts.Parser)
		@builder = new Xml2Js.Builder(opts.Builder)
		@.parseSync = null
		@.parseFileSync = null
	parseAsync: (str, opts, cb) -> @parser.parseString str, cb
	stringifySync : (data, opts) ->
		opts.xmldec or= {}
		return @builder.buildObject data
	# constructor: ->
	#   @.stringifySync = null
	#   @.stringifyAsync = null

