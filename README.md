# traf
Transform between various data serialization formats

<!-- BEGIN-MARKDOWN-TOC -->
* [Code organization](#code-organization)
	* [Method suffixes](#method-suffixes)
		* [`Sync`](#sync)
		* [`Async`](#async)
	* [load(filename, opts)](#loadfilename-opts)
* [Supported formats](#supported-formats)
	* [JSON](#json)
	* [CSON](#cson)
	* [TSON](#tson)
	* [YAML](#yaml)
	* [CSV](#csv)
* [Extension Map](#extension-map)

<!-- END-MARKDOWN-TOC -->

## Code organization

### Backends

Every format has a subfolder in [`./lib/backends`](./lib/backends).

Every format has one or more backends, extending the [Backend base
class](#module-backend-base).

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


### `parseSync(str, opts)`
### `parseAsync(str, opts, cb)`

Load a file in any of the [supported serialization
formats](#supported-formats).


### `parseFileSync(filename, opts)`
### `parseFileAsync(filename, opts, cb)`

By default, input format is determined by [extension](#extension-map).

### `stringifySync(data, opts)`
### `stringifyAsync(data, opts, cb)`



## Supported formats

### JSON

### CSON

### TSON

### YAML

### CSV
