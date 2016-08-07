# traf
Transform between various data serialization formats

[Demo](https://kba.github.io/traf/demo.html)

<!-- BEGIN-MARKDOWN-TOC -->
* [Installation](#installation)
	* [npm](#npm)
	* [bower](#bower)
* [Usage](#usage)
	* [CLI](#cli)
	* [Node JS](#node-js)
	* [Browser](#browser)
* [Code organization](#code-organization)
	* [Formats](#formats)
	* [Backends](#backends)
	* [Method suffixes](#method-suffixes)
		* [`Sync`](#sync)
		* [`Async`](#async)
* [Supported formats](#supported-formats)
* [API](#api)
	* [`parseSync(str, opts)`](#parsesyncstr-opts)
	* [`parseAsync(str, opts, cb)`](#parseasyncstr-opts-cb)
	* [`stringifySync(data, opts)`](#stringifysyncdata-opts)
	* [`stringifyAsync(data, opts, cb)`](#stringifyasyncdata-opts-cb)
	* [`parseFileSync(filename, opts)`](#parsefilesyncfilename-opts)
	* [`parseFileAsync(filename, opts, cb)`](#parsefileasyncfilename-opts-cb)
	* [`stringifyFileSync(data, opts)`](#stringifyfilesyncdata-opts)
	* [`stringifyFileAsync(data, opts, cb)`](#stringifyfileasyncdata-opts-cb)
	* [`guessFiletype(filename, opts={})`](#guessfiletypefilename-opts---)
	* [`guessFilename(filename, opts)`](#guessfilenamefilename-opts)

<!-- END-MARKDOWN-TOC -->

## Installation

### npm

```
npm install traf
```

### bower

```
bower install https://github.com/kba/traf
```

## Usage

### CLI

Install the package globally (`npm install -g traf`)

<!-- BEGIN-EVAL echo '```';coffee src/bin/cli.coffee;echo '```' -->
```
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
```

<!-- END-EVAL -->


### Node JS

```js
var t = new(require('traf'))();
console.log(t.parseSync("- 'foo'", {"format": "YAML"}));
```

### Browser

```html
<script src="./path/to/traf.js"></script>
<!-- or -->
<script src="https://kba.github.io/traf/dist/traf-latest.js"></script>
<script>
var t = new traf();
console.log(parseSync("- 'foo'", {"format": "YAML"}));
</script>
```

## Code organization

### Formats

A format is a set of rules how to serialize and deserialize data.

Every format has a subfolder in [`./src/lib/backend`](./lib/backends).

### Backends

Every format has one or more backends, extending the [Backend base
class](./src/lib/backend/base_backend.coffee).

### Method suffixes

All functions are suffixed with the mechanism to execute them:

#### `Sync`

Method takes argument and options and returns the result or
throws an exception.

```js
try {
  data = traf.parseSync(str, {"format": "JSON"})
  // do stuff with data
} catch (e) {
  // handle error
}
```

#### `Async`

Method takes argument, options and returns a callback with arguments
err and result.

```js
traf.parseAsync(str, {"format":"JSON"}, function(err, data) {
  if (err) {
    // handle error
  }
  // handle data
});
```

## Supported formats

<!-- BEGIN-RENDER doc/format_matrix.pug -->
<table>
  <thead>
    <tr>
      <th colspan="2"></th>
      <th colspan="2"><code>parse</code></th>
      <th colspan="2"><code>stringify</code></th>
      <th colspan="2"><code>parseFile</code></th>
      <th colspan="2"><code>stringifyFile</code></th>
    </tr>
    <tr>
      <th>Format</th>
      <th>Backend</th>
      <th><a href="#parsesyncstr-opts"><code>sync</code></a></th>
      <th><a href="#parseasyncstr-opts-cb"><code>async</code></a></th>
      <th><a href="#stringifysyncdata-opts"><code>sync</code></a></th>
      <th><a href="#stringifyasyncdata-opts-cb"><code>async</code></a></th>
      <th><a href="#parsefilesyncfilename-opts"><code>sync</code></a></th>
      <th><a href="#parsefileasyncfilename-opts-cb"><code>async</code></a></th>
      <th><a href="#stringifyfilesyncdata-opts"><code>sync</code></a></th>
      <th><a href="#stringifyfileasyncdata-opts-cb"><code>async</code></a></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>JSON</td>
      <td><a href="./src/lib/backend/JSON/json.coffee">json</a></td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
    </tr>
    <tr>
      <td rowspan="2">CSON</td>
      <td><a href="./src/lib/backend/CSON/cson-safe.coffee">cson-safe</a></td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
      <td>✓
      </td>
      <td>≈
      </td>
    </tr>
    <tr>
      <td><a href="./src/lib/backend/CSON/cson.coffee">cson</a></td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
    </tr>
    <tr>
      <td>TSON</td>
      <td><a href="./src/lib/backend/TSON/tson.coffee">tson</a></td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✗
      </td>
      <td>✗
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✗
      </td>
      <td>✗
      </td>
    </tr>
    <tr>
      <td>XML</td>
      <td><a href="./src/lib/backend/XML/xml2js.coffee">xml2js</a></td>
      <td>✗
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✗
      </td>
      <td>✓
      </td>
      <td>✗
      </td>
      <td>✓
      </td>
    </tr>
    <tr>
      <td>YAML</td>
      <td><a href="./src/lib/backend/YAML/js-yaml.coffee">js-yaml</a></td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
    </tr>
    <tr>
      <td>CSV</td>
      <td><a href="./src/lib/backend/CSV/csv.coffee">csv</a></td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
      <td>✓
      </td>
    </tr>
  </tbody>
</table>
<p><strong>Legend</strong>:
  <ul class="inline">
    <li>✓ : Supported
    </li>
    <li>≈ : Supported by wrapping the sync call
    </li>
    <li>✓ : Not Supported
    </li>
  </ul>
</p>

<!-- END-RENDER -->

## API

### `parseSync(str, opts)`
### `parseAsync(str, opts, cb)`

Load a file in any of the [supported serialization
formats](#supported-formats).

Options:

* **`format`**: Input format

### `stringifySync(data, opts)`
### `stringifyAsync(data, opts, cb)`

Serializes the data passed to a string.

Options:

* **`format`**: Output format

### `parseFileSync(filename, [opts])`
### `parseFileAsync(filename, [opts], cb)`

Options:

* `format`: Input format
* `extensions`: List of extensions to add to the filename in case it does not exist.

By default, input format is determined by [extension](#extension-map).

Not available in the browser version.

### `stringifyFileSync(data, opts)`
### `stringifyFileAsync(data, opts, cb)`

Serializes the data passed to a string and writes it to a file.

Options:

* **`filename`**: The filename to write to
* `format`: If not given explicitly, determined by extension.

### `guessFiletype(filename, opts={})`

Guess parser options by looking at the filename.

Will add information to `opts`, at least the `format` if it was
recognized and possibly further options that can be guessed from
the filename.

```js
console.log(traf.guessFilename('foo.json'))
// {"format":"JSON"}
console.log(traf.guessFilename('foo.tsv'))
// {"format":"CSV", "delimiter": "\t"}
```

### `guessFilename(filename, opts)`

Guess output filename by changing the extension to the
`outputExtension` of the `format` in `opts`.

