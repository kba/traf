Utils = require '../utils'
module.exports = class BaseBackend

	parseSyncFn : 'parse'
	stringifySyncFn : 'stringify'

	stringifySync : (data, opts) ->
		if opts.indent
			@impl()[@stringifySyncFn] data, null, indent
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
			data = @parseSync str
		catch e
			return cb e
		cb null, data

	parseFileSync : (filename, opts) ->
		if not Utils.isNodeJS
			throw new Error("parseFile only available in Node")
		Fs = require 'fs'
		opts.encoding or= 'utf8'
		opts.format or= @guessFormat filename, opts
		data = Fs.readFileSync filename, {encoding: opts.encoding}
		return @parseSync data, opts


	parseFileAsync : (filename, opts, cb) ->
		if not Utils.isNodeJS
			return cb new Error("parseFile only available in Node")
		Fs = require 'fs'
		opts.encoding or= 'utf8'
		opts.format or= @guessFormat filename, opts
		Fs.readFile filename, {encoding: opts.encoding}, (err, data) ->
			return cb err if err
			@parseAsync data, opts, cb

