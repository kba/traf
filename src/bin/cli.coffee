Traf = require '../lib/traf'
Fs = require 'fs'
args = process.argv.slice(2)

log = (level, msg, data) ->
	if data
		msg += " " + traf.stringifySync data, {format: 'CSON'}
	console.log "[#{level.toUpperCase()}] #{msg}"

usage = ->
	console.log """
	Usage: traf [options...] <input-file> [<output-file>]

	Transform between different serialization formats

	Options:
	    -h --help                   Show this help
	    -i --input-format FORMAT    Input format
	    -o --output-format FORMAT   Output format
	    -f --force                  Overwrite existing files
	    -I --indent INDENT          Indent data with INDENT spaces per level

	Arguments:
	    <input-file>    Input filename.
	                    Can be '-' to read from STDIN. Specify input format then.
	    <output-file>   Output filename.
	                    If omitted, derive output filename from input filename.
	                    Can be '-' to write to STDOUT. Specify output format then.
	"""
	process.exit()

error = (err) ->
	log 'error', "ERROR: #{err}"
	process.exit 1

#
# Parse options
#
opts =
	parse: {}
	stringify: {}
parse_opts = ->
	while args.length and args[0].match /^-/
		log 'debug', "Parsing arg #{args[0]}"
		switch args[0]
			when '-h', '--help'
				usage()
			when '-i', '--input-format'
				opts.parse.format = args[1].toUpperCase()
				args.shift()
			when '-o', '--output-format'
				opts.stringify.format = args[1].toUpperCase()
				args.shift()
			when '-f', '--force'
				opts.force = true
			when '-I', '--indent'
				opts.stringify.indent = parseInt args[1]
				args.shift()
			when '-'
				return
			else
				error "Unknown option #{args[0]}"
		args.shift()

parse_opts args

# TODO parse options
traf = new Traf()

#
# Parse argument
#
usage() if args.length == 0
if args[0] is '-'
	log 'debug', 'Reading from STDIN ...'
	if not opts.parse.format
		error "Must specify input format when reading from STDIN"
	process.stdin.resume()
	process.stdin.setEncoding 'utf-8'
	readStream = process.stdin
else
	log 'debug', "Reading from #{args[0]} ..."
	if not opts.parse.format
		guessed = {}
		traf.guessFiletype(args[0], guessed)
		log 'debug', "Guessed parse options:", guessed
		if 'format' not of guessed
			error "Could not determine input format: #{args[0]}"
		opts.parse.format = guessed.format
	readStream = Fs.createReadStream args[0]

if args[1] is '-'
	if not opts.stringify.format
		error "Must specify output format when writing to STDOUT"
	process.stdout.setEncoding 'utf-8'
	writeStream = process.stdout
else
	if not args[1]
		if args[0] is '-'
			error "Cannot derive output filename when reading from STDIN"
		if not opts.stringify.format
			error "Cannot derive output filename without output format given"
		args[1] = traf.guessFilename args[0], opts.stringify
	else
		if not opts.stringify.format
			guessed = {}
			traf.guessFiletype args[1], guessed
			log 'debug', "Guessed stringify options:", guessed
			if 'format' not of guessed
				error "Could not determine output format: #{args[1]}"
			opts.stringify[k] = v for k,v of guessed when k not of opts.stringify
	if Fs.existsSync args[1] and not opts.force
		error "File exists: #{args[1]}. Use -f to overwrite"
	writeStream = Fs.createWriteStream args[1]

str = ''
readStream.on 'error', error
writeStream.on 'error', error
readStream.on 'data', (chunk) -> str += chunk.toString()
readStream.on 'end', ->
	log 'debug', '... finished reading data'
	log 'debug', 'Parse options:', opts.parse
	log 'debug', 'Stringify options:', opts.stringify
	traf.parseAsync str, opts.parse, (err, data) ->
		return error err if err
		traf.stringifyAsync data, opts.stringify, (err, converted) ->
			return error err if err
			writeStream.write converted.toString()
		# console.log data
