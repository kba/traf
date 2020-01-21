BaseBackend = require '../base_backend'
module.exports = class TsonBackend extends BaseBackend
	impl : -> require 'tson'
	constructor: ->
		super()
		@.stringifySync = null
		@.stringifyAsync = null
