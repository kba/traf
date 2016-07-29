BaseBackend = require '../base_backend'
module.exports = class CsonBackend extends BaseBackend
	impl : -> require 'cson'
