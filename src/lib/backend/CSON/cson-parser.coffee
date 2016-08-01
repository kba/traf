BaseBackend = require '../base_backend'
module.exports = class CsonParserBackend extends BaseBackend
	impl : -> require 'cson-parser'
