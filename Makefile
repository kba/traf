SRC = $(shell find src/lib -name '*.coffee')
LIB = $(SRC:src/lib/%.coffee=lib/%.js)

lib: $(LIB)

lib/%.js: src/lib/%.coffee
	@mkdir -p $(dir $@)
	coffee -c -p -b $< > "$@"

init:
	npm install

clean:
	@rm -rf lib

browserify: dist/traf.js

dist/traf.js: lib
	@mkdir -p dist
	browserify -d -s traf -o dist/traf.js lib/traf.js 

rebuild: clean init $(LIB)

