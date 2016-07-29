BaseBackend = require '../base_backend'
YAML = require('js-yaml')
module.exports = class YAMLBackend extends BaseBackend
	impl : -> require 'js-yaml'
	parseSyncFn : 'safeLoad'
	stringifySyncFn : 'safeDump'
