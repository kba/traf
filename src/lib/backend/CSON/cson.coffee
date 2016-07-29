BaseBackend = require '../base_backend'
module.exports = class CSONBackend extends BaseBackend
	impl : -> require 'cson'
