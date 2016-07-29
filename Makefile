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

browserify: lib
	cd lib && browserify -d -s traf -o traf-browserify.js traf.js 

rebuild: clean init $(LIB)

