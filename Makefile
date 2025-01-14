.PHONY: all build format edit demo clean

src?=0
dst?=5
graph?=sportvoeux6.txt
OPAM_DEPENDENCIES=lablgtk

all: build

install-deps:
	@echo "\n   📦  CHECKING DEPENDENCIES  📦 \n"
	opam install $(OPAM_DEPENDENCIES) --deps-only --yes

build:
	@make install-deps
	@echo "\n   🚨  COMPILING  🚨 \n"
	dune build src/ftest.exe
	ls src/*.exe > /dev/null && ln -fs src/*.exe .

format:
	ocp-indent --inplace src/*

edit:
	code . -n

demo: build
	@echo "\n   ⚡  EXECUTING  ⚡\n"
	./ftest.exe graphs/${graph} $(src) $(dst) outfile
	@echo "\n   🥁  RESULT (content of outfile)  🥁\n"
	@echo "   😉  See logs directory  😉  \n"

clean:
	find -L . -name "*~" -delete
	rm -f *.exe
	rm -f *.dot
	dune clean
