// Generated by CoffeeScript 1.10.0
(function() {
  var DEFAULT_CONFIG, MECHANISMS, METHODS, Merge, Traf, Utils;

  Merge = require('merge');

  Utils = require('./utils');

  require('./backend/CSON/cson');

  require('./backend/CSON/cson-parser');

  require('./backend/YAML/js-yaml');

  require('./backend/JSON/json');

  require('./backend/CSV/csv');

  require('./backend/TSON/tson');

  require('./backend/XML/xml2js');

  DEFAULT_CONFIG = {
    backendOpts: {
      xml2js: {
        Parser: {},
        Builder: {
          headless: true
        }
      }
    },
    formats: {
      JSON: {
        backend: 'json',
        outputExtension: 'json',
        inputExtensions: {
          'json': {}
        }
      },
      CSON: {
        backend: 'cson-parser',
        outputExtension: 'cson',
        inputExtensions: {
          'cson': {}
        }
      },
      TSON: {
        backend: 'tson',
        outputExtension: 'tson',
        inputExtensions: {
          'tson': {}
        }
      },
      YAML: {
        backend: 'js-yaml',
        outputExtension: 'yml',
        inputExtensions: {
          'yaml': {},
          'yml': {}
        }
      },
      CSV: {
        backend: 'csv',
        outputExtension: 'csv',
        inputExtensions: {
          'csv': {
            delimiter: ','
          },
          'tsv': {
            delimiter: '\t'
          }
        }
      },
      XML: {
        backend: 'xml2js',
        outputExtension: 'xml',
        inputExtensions: {
          'xml': {}
        }
      }
    }
  };

  MECHANISMS = ['Sync', 'Async'];

  METHODS = ['parse', 'stringify'];

  module.exports = Traf = (function() {
    Traf.DEFAULT_CONFIG = DEFAULT_CONFIG;

    function Traf(opts) {
      var fn1, fnBase, i, j, len, len1, sync;
      if (opts == null) {
        opts = {};
      }
      this.config = Merge.recursive(DEFAULT_CONFIG, opts || {});
      this.formats = Merge.recursive(this.config.formats);
      Object.keys(this.formats).map((function(_this) {
        return function(formatName) {
          var format, mod;
          format = _this.formats[formatName];
          if (!('impl' in format)) {
            mod = require("./backend/" + formatName + "/" + format.backend);
            return format.impl = new mod(_this.config.backendOpts[format.backend] || {});
          }
        };
      })(this));
      for (i = 0, len = MECHANISMS.length; i < len; i++) {
        sync = MECHANISMS[i];
        fn1 = (function(_this) {
          return function(fnBase, sync) {
            var fn;
            fn = "" + fnBase + sync;
            return _this[fn] = function() {
              return this["_run" + sync].apply(this, [fn, arguments[0], arguments[1], arguments[2], arguments[3]]);
            };
          };
        })(this);
        for (j = 0, len1 = METHODS.length; j < len1; j++) {
          fnBase = METHODS[j];
          fn1(fnBase, sync);
        }
      }
    }

    Traf.prototype._runSync = function(fn, data, opts) {
      if (!opts) {
        throw new Error("Must specify opts");
      } else if (!opts.format) {
        throw new Error("Must specify opts.format");
      } else if (!(opts.format in this.formats)) {
        throw new Error("Unsupported format " + opts.format);
      } else if (!this.formats[opts.format].impl[fn]) {
        throw new Error("Backend " + opts.format + " does not support " + fn);
      }
      return this.formats[opts.format].impl[fn](data, opts);
    };

    Traf.prototype._runAsync = function(fn, data, opts, cb) {
      if (!opts) {
        return cb(new Error("Must specify opts"));
      } else if (!opts.format) {
        return cb(new Error("Must specify opts.format"));
      } else if (!(opts.format in this.formats)) {
        return cb(new Error("Unsupported format " + opts.format));
      } else if (!this.formats[opts.format].impl[fn]) {
        return cb(new Error("Backend " + opts.format + "/" + this.formats[opts.format] + " does not support " + fn));
      }
      return this.formats[opts.format].impl[fn](data, opts, cb);
    };

    Traf.prototype.parseFileSync = function(filename, opts) {
      opts || (opts = {});
      if (!opts.format) {
        this.guessFiletype(filename, opts);
        console.log(opts);
      }
      return this._runSync('parseFileSync', filename, opts);
    };

    Traf.prototype.parseFileAsync = function(filename, opts, cb) {
      var ref;
      throw new Error("FOO");
      if (typeof opts === 'function') {
        ref = [null, opts], opts = ref[0], cb = ref[1];
      }
      opts || (opts = {});
      if (!opts.format) {
        this.guessFiletype(filename, opts);
      }
      return this._runAsync('parseFileSync', filename, opts, cb);
    };

    Traf.prototype.guessFiletype = function(filename, opts) {
      var ext, format, formatName, k, ref, ref1, v;
      if (opts == null) {
        opts = {};
      }
      ext = Utils.getFileExtension(filename);
      ref = this.formats;
      for (formatName in ref) {
        format = ref[formatName];
        if (ext in format.inputExtensions) {
          ref1 = format.inputExtensions[ext];
          for (k in ref1) {
            v = ref1[k];
            opts[k] = v;
          }
          opts.format = formatName;
        }
      }
      return opts;
    };

    Traf.prototype.guessFilename = function(filename, opts) {
      if (opts == null) {
        opts = {};
      }
      if (!'format' in opts) {
        throw new Error("Must give opts.format to guess filename");
      } else if (!(opts.format in this.config.formats)) {
        throw new Error("Unsupported format: " + opts.format);
      }
      return Utils.changeFileExtension(filename, this.config.formats[opts.format].outputExtension);
    };

    return Traf;

  })();

  Traf.TRAF = new Traf();

}).call(this);
