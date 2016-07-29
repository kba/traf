Merge = require 'merge'
Utils = require './utils'

require './backend/CSON/cson'
require './backend/CSON/cson-safe'
require './backend/YAML/js-yaml'
require './backend/JSON/json'
require './backend/CSV/csv'
require './backend/TSON/tson'

DEFAULT_CONFIG =
	formats:
		JSON:
			backend: 'json'
			outputExtension: 'json'
			inputExtensions: 'json': {}
		CSON:
			# backend: 'cson'
			backend: 'cson-safe'
			outputExtension: 'cson'
			inputExtensions: 'cson': {}
		TSON:
			backend: 'tson'
			outputExtension: 'tson'
			inputExtensions: 'tson': {}
		YAML:
			backend: 'js-yaml'
			outputExtension: 'yml'
			inputExtensions: 'yaml': {}, 'yml': {}
		CSV:
			backend: 'csv'
			outputExtension: 'csv'
			inputExtensions: 'csv': {delimiter:','}, 'tsv': {delimiter:'\t'}


MECHANISMS = ['Sync', 'Async']
METHODS = ['parse', 'stringify']

module.exports = class Traf

	@DEFAULT_CONFIG: DEFAULT_CONFIG

	constructor : (opts={}) ->
		@config = Merge.recursive DEFAULT_CONFIG, (opts or {})
		@formats = Merge.recursive @config.formats
		Object.keys(@formats).map (formatName) =>
			format = @formats[formatName]
			if 'impl' not of format
				format.impl = new(require "./backend/#{formatName}/#{format.backend}")
		for sync in MECHANISMS
			for fnBase in METHODS
				do (fnBase, sync) =>
					fn = "#{fnBase}#{sync}"
					@[fn] = ->
						@["_run#{sync}"].apply(@, [fn, arguments[0], arguments[1], arguments[2], arguments[3]])

	_runSync: (fn, data, opts) ->
		unless opts
			throw new Error("Must specify opts")
		else unless opts.format
			throw new Error("Must specify opts.format")
		else if opts.format not of @formats
			throw new Error("Unsupported format #{opts.format}")
		else if not @formats[opts.format].impl[fn]
			throw new Error("Backend #{opts.format} does not support #{fn}")
		return @formats[opts.format].impl[fn](data, opts)

	_runAsync: (fn, data, opts, cb) ->
		unless opts
			return cb new Error("Must specify opts")
		else unless opts.format
			return cb new Error("Must specify opts.format")
		else if opts.format not of @formats
			return cb new Error("Unsupported format #{opts.format}")
		else if not @formats[opts.format].impl[fn]
			return cb new Error("Backend #{opts.format}/#{@formats[opts.format]} does not support #{fn}")
		return @formats[opts.format].impl[fn](data, opts, cb)

	parseFileSync : (filename, opts) ->
		opts or= {}
		unless opts.format
			@guessFiletype filename, opts
		@_runSync 'parseFileSync', filename, opts

	parseFileAsync : (filename, opts, cb) ->
		opts or= {}
		unless opts.format
			@guessFiletype filename, opts
		@_runAsync 'parseFileSync', filename, opts, cb

	guessFiletype : (filename, opts={}) ->
		ext = Utils.getFileExtension filename
		for formatName, format of @formats
			if ext of format.inputExtensions
				opts[k] = v for k,v of format.inputExtensions[ext]
				opts.format = formatName
		return opts
