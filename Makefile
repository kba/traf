SRC = $(shell find src/lib -name '*.coffee')
LIB = $(SRC:src/lib/%.coffee=lib/%.js)

RM = rm -r
MKDIR = mkdir -pv
COFFEE_COMPILE = coffee -c -p -b

all: lib dist bin

lib: $(LIB)

lib/%.js: src/lib/%.coffee
	@$(MKDIR) $(dir $@)
	$(COFFEE_COMPILE) $< > "$@"

dist: dist/traf.js

dist/traf.js: lib
	@$(MKDIR) dist
	browserify -d -s traf -o dist/traf.js lib/traf.js 

bin: bin/cli.js

bin/cli.js: src/bin/cli.coffee
	@$(MKDIR) bin
	$(COFFEE_COMPILE) $< > $@
	sed -i "1i #!/usr/bin/env node" $@
	chmod a+x $@

clean:
	$(RM) -rf lib dist bin

rebuild:
	$(MAKE) clean
	$(RM) node_modules
	npm install
	$(MAKE) all


