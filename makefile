all: random-repo/output/Main/index.js


%/output/Main/index.js: %/src/Main.purs
	cd $* && \
		yarn bower install && \
		yarn pulp build


.PHONY: clean
clean:
	rm -rf random-repo/output
	rm -rf random-repo/bower_components
