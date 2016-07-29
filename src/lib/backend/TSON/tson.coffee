BaseBackend = require '../base_backend'
module.exports = class TsonBackend extends BaseBackend
	impl : -> require 'tson'
	constructor: ->
		@.stringifySync = null
		@.stringifyAsync = null
