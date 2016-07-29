Traf = require '../lib/traf'
Test = require 'tape'

config1 =
	formats:
		CSON:
			backend: 'cson'

testSerialize = ->
	fixtures =
		aoaNum:
			data : [['1','2','3']]
			str:
				JSON: '[["1","2","3"]]'
				YAML: "- - '1'\n  - '2'\n  - '3'\n"
				CSON: '''[
					[
						"1"
						"2"
						"3"
					]
				]'''
				TSON: '[["1","2","3"]]'
				CSV: '1,2,3\n'
		arrayOfObjectas:
			data : [foo: 1]
			str:
				JSON: '[{"foo":1}]'
				YAML: '- foo: 1\n'
				CSON: '''
			[
				{
					foo: 1
				}
			]
			'''
				TSON: '[{ foo: 1 } ]'

	isNotSupported = (e) -> e.message.match 'does not support'

	for fixtureName, fixture of fixtures
		for format of fixture.str
			do (format, fixture) -> Test "Testing #{format} / #{fixtureName}", (t) ->
				traf = new Traf(config1)
				data = fixture.data
				formatStr = fixture.str[format]
				t.deepEquals traf.parseSync(formatStr, format:format), data, "#{format}.parseSync"
				try
					t.equals traf.stringifySync(data, format:format), formatStr, "#{format}.stringifySync"
				catch e
					throw e unless isNotSupported e
					t.skip "Not supported"
				traf.parseAsync formatStr, format:format, (err, parsed) ->
					t.deepEquals parsed, data, "#{format}.parseAsync"
					traf.stringifyAsync data, {format:format}, (err, str) ->
						if err and isNotSupported err
							t.skip "Not supported"
						else
							t.equals str, formatStr, "#{format}.stringifyAsync"
						t.end()

testGuess = -> Test 'filename heuristics', (t) ->
	traf = new Traf()
	t.deepEquals traf.guessFiletype('foo.cson'), {format: 'CSON'}, 'guessed CSON filename'
	t.deepEquals traf.guessFiletype('foo.tsv'), {delimiter:'\t', format: 'CSV'}, 'guessed TSV filename'
	t.end()

testParseFile = -> Test 'parseFile', (t) ->
	traf = new Traf()
	t.deepEquals traf.parseFileSync(__dirname + '/sample1.json'), {foo:1}, 'parseFile JSON'
	t.end()


testSerialize()
testGuess()
testParseFile()
