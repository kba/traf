Utils = require '../utils'
Async = require 'async'
module.exports = class BaseBackend

	parseSyncFn : 'parse'
	stringifySyncFn : 'stringify'

	stringifySync : (data, opts) ->
		if 'indent' of opts
			@impl()[@stringifySyncFn] data, null, opts.indent
		else
			@impl()[@stringifySyncFn] data

	parseSync: (str, opts) ->
		@impl()[@parseSyncFn] str

	stringifyAsync : (data, opts, cb) ->
		try
			str = @stringifySync data, opts
		catch e
			return cb e
		cb null, str

	parseAsync: (str, opts, cb) ->
		try
			data = @parseSync str, opts
		catch e
			return cb e
		cb null, data

	parseFileSync : (filename, opts) ->
		if not Utils.isNodeJS
			throw new Error("parseFileSync only available in Node")
		Fs = require 'fs'
		opts.encoding or= 'utf8'
		data = Fs.readFileSync filename, {encoding: opts.encoding}
		return @parseSync data, opts

	parseFileAsync : (filename, opts, cb) ->
		if not Utils.isNodeJS
			return cb new Error("parseFileAsync only available in Node")
		Fs = require 'fs'
		opts.encoding or= 'utf8'
		opts.extensions or= []
		candidates = opts.extensions.map (ext) -> "#{filename}.#{ext}"
		candidates.unshift filename
		Async.detect candidates, (candidate, done) ->
			Fs.access candidate, (err) ->
				return done err if err
				return done null, candidate
		, (err, candidate) =>
			if err
				return cb new Error "Could not determine actual filename of #{filename} (tried: #{candidates})."
			opts.format or= @guessFormat candidate, opts
			Fs.readFile candidate, {encoding: opts.encoding}, (err, data) =>
				return cb err if err
				console.log @
				@parseAsync data, opts, cb

	stringifyFileSync: (data, opts, cb) ->
		if not Utils.isNodeJS
			throw new Error("stringifyFile only available in Node")
		if 'filename' not of opts
			throw new Error("Must pass 'filename' to stringifyFileSync")
		str = @stringifySync data, opts
		Fs.writeFileSync opts.filename, data

	stringifyFileAsync: (data, opts, cb) ->
		if not Utils.isNodeJS
			return cb new Error("stringifyFile only available in Node")
		if 'filename' not of opts
			return cb new Error("Must pass 'filename' to stringifyFileAsync")
		@stringifyAsync data, opts, (err, str) ->
			return cb err if err
			Fs.writeFile opts.filename, str, (err) ->
				return cb err if err
				return cb null


