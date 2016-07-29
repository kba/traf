BaseBackend = require '../base_backend'
module.exports = class CsonSafeBackend extends BaseBackend
	impl : -> require 'cson-safe'
