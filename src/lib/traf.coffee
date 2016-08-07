Merge = require 'merge'
Utils = require './utils'

require './backend/CSON/cson'
require './backend/CSON/cson-parser'
require './backend/YAML/js-yaml'
require './backend/JSON/json'
require './backend/CSV/csv'
require './backend/TSON/tson'
require './backend/XML/xml2js'

DEFAULT_CONFIG =
	backendOpts:
		xml2js:
			Parser: {}
			Builder:
				headless: true
	formats:
		JSON:
			backend: 'json'
			outputExtension: 'json'
			inputExtensions: 'json': {}
		CSON:
			# backend: 'cson'
			backend: 'cson-parser'
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
		XML:
			backend: 'xml2js'
			outputExtension: 'xml'
			inputExtensions: 'xml': {}


MECHANISMS = ['Sync', 'Async']
METHODS = ['parse', 'stringify']

module.exports = class Traf

	@DEFAULT_CONFIG: DEFAULT_CONFIG

	constructor : (opts={}) ->
		@config = Merge.recursive DEFAULT_CONFIG, (opts or {})
		# console.log @config.formats.CSON
		@formats = Merge.recursive @config.formats
		Object.keys(@formats).map (formatName) =>
			format = @formats[formatName]
			mod = require "./backend/#{formatName}/#{format.backend}"
			format.impl = new mod(@config.backendOpts[format.backend] or {})
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
			# console.log @formats[opts.format].impl[fn]
			throw new Error("Backend #{opts.format} does not support #{fn}")
		# console.log "impls:", @formats[opts.format]
		@formats[opts.format].impl[fn](data, opts)

	_runAsync: (fn, data, opts, cb) ->
		unless opts
			return cb new Error("Must specify opts")
		else unless opts.format
			return cb new Error("Must specify opts.format")
		else if opts.format not of @formats
			return cb new Error("Unsupported format #{opts.format}")
		else if not @formats[opts.format].impl[fn]
			return cb new Error("Backend #{opts.format}/#{@formats[opts.format]} does not support #{fn}")
		@formats[opts.format].impl[fn](data, opts, cb)

	parseFileSync : (filename, opts) ->
		if not Utils.isNodeJS
			throw new Error("parseFileSync only available in Node")
		Fs = require 'fs'
		opts or= {}
		opts.extensions or= []
		candidates = opts.extensions.map (ext) -> "#{filename}.#{ext}"
		candidates.unshift filename
		# console.log candidates
		for candidate in candidates
			try
				Fs.accessSync candidate
			catch e
				continue
			unless opts.format
				opts.format = @guessFiletype candidate, opts
			return @_runSync 'parseFileSync', candidate, opts
		throw new Error "Could not determine actual filename of #{filename}, tried #{candidates}"

	parseFileAsync : (filename, opts, cb) ->
		if typeof opts is 'function'
			[opts, cb] = [null, opts]
		opts or= {}
		unless opts.format
			@guessFiletype filename, opts
		@_runAsync 'parseFileAsync', filename, opts, cb

	guessFiletype : (filename, opts={}) ->
		ext = Utils.getFileExtension filename
		for formatName, format of @formats
			if ext of format.inputExtensions
				opts[k] = v for k,v of format.inputExtensions[ext]
				opts.format = formatName
				return formatName

	guessFilename : (filename, opts={}) ->
		if not 'format' of opts
			throw new Error("Must give opts.format to guess filename")
		else if opts.format not of @config.formats
			throw new Error("Unsupported format: #{opts.format}")
		return Utils.changeFileExtension filename, @config.formats[opts.format].outputExtension

Traf.TRAF = new Traf()
