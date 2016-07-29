BaseBackend = require '../base_backend'
CsvParseAsync = require 'csv-parse'
CsvStringifyAsync = require 'csv-stringify'
CsvParseSync = require 'csv-parse/lib/sync'
CsvStringifySync = require 'csv-stringify/lib/sync'
module.exports = class CSVBackend extends BaseBackend

	matchExtension : (ext) ->
		if ext is 'csv'
			return separator: ','
		else if ext is 'tsv'
			return separator: '\t'

	parseSync: (str, opts) -> CsvParseSync str, opts

	stringifySync : (data, opts) -> CsvStringifySync data, opts

	parseAsync: (str, opts, cb) -> CsvParseAsync str, opts, cb

	stringifyAsync : (data, opts, cb) -> CsvStringifyAsync data, opts, cb

