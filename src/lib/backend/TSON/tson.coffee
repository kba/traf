BaseBackend = require '../base_backend'
module.exports = class TSONBackend extends BaseBackend
	impl : -> require 'tson'
	constructor: ->
		@.stringifySync = null
		@.stringifyAsync = null
