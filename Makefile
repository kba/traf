SRC = $(shell find src/lib -name '*.coffee')
LIB = $(SRC:src/lib/%.coffee=lib/%.js)
VERSION = $(shell node -pe 'require("./package.json").version')

RM = rm -rf
MKDIR = mkdir -pv
COFFEE_COMPILE = coffee -c -p -b

all: lib bin

lib: $(LIB)

lib/%.js: src/lib/%.coffee
	@$(MKDIR) $(dir $@)
	$(COFFEE_COMPILE) $< > "$@"

bin: bin/cli.js

bin/cli.js: src/bin/cli.coffee
	@$(MKDIR) bin
	$(COFFEE_COMPILE) $< > $@
	sed -i "1i #!/usr/bin/env node" $@
	chmod a+x $@

clean:
	$(RM) -rf lib bin

rebuild:
	$(MAKE) clean
	$(RM) node_modules
	npm install
	$(MAKE) all

browserify: gh-pages/dist/traf-$(VERSION).js gh-pages/index.html
	cd gh-pages && git commit dist index.html -m "Rebuilt $(VERSION)" && git push

gh-pages:
	git clone -b gh-pages https://github.com/kba/traf gh-pages

gh-pages/index.html: $(wildcard gh-pages/dist/*.js)
	$(RM) $@
	cd gh-pages/dist; \
		ln -sf $$(ls *.js|tail -n1) traf-latest.js; \
		for i in *.js;do \
			echo "<p><a href='./dist/$$i'>$$i</a> ($$(du -Dh $$i|cut -f1))</p>" >> ../index.html; \
		done

gh-pages/dist/traf-$(VERSION).js: gh-pages lib
	browserify -d -s traf -o $@ lib/traf.js 

