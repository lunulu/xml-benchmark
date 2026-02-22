MAKEFLAGS += --no-print-directory

LANG_DIR := langs
LANGS := ruby python go js dotnet java php c cpp
VARIANTS_ruby := ox ox-sax nokogiri
VARIANTS_python := lxml lxml-iterparse elementtree
VARIANTS_go := encoding-xml xml-stream-parser mxj
VARIANTS_js := fast-xml-parser sax
VARIANTS_dotnet := xmldocument xdocument xmlreader
VARIANTS_java := dom sax stax # jaxb vtd-xml
VARIANTS_php := domdocument xmlreader
VARIANTS_c := libxml2 expat
VARIANTS_cpp := pugixml expat

DATA := $(abspath data/input.xml)

.PHONY: install full generate clean build run bench visualize $(LANGS:%=build-%) $(LANGS:%=run-%) $(LANGS:%=bench-%)

install:
	@command -v mise >/dev/null 2>&1 || { \
    		echo "'mise' is not installed. Please install it from: https://github.com/jdx/mise" >&2; \
    		echo "After installing, re-run: make install" >&2; \
    		exit 1; \
    }
	@echo "📦 Installing languages and dependencies with mise"
	@sudo apt update
	@sudo apt install -y autoconf bison re2c libxml2-dev libsqlite3-dev \
  		libcurl4-openssl-dev libjpeg-dev libpng-dev libonig-dev libssl-dev \
  		libreadline-dev libzip-dev libtidy-dev libxslt-dev pkg-config \
  		build-essential locate libgd-dev libglib2.0-dev uthash-dev
	@mise install
	@echo "All environments installed"

full: generate build bench visualize

generate:
	@gem list ox -i > /dev/null || gem install ox
	@mkdir -p data
	@rm -f $(DATA)
	@ruby tools/generate_xml.rb $(DATA) $(MB)

visualize:
	@gem list colorize -i > /dev/null || gem install colorize
	@gem list tty-table -i > /dev/null || gem install tty-table
	@ruby tools/visualize_bench.rb

visualize-md:
	@gem list colorize -i > /dev/null || gem install colorize
	@gem list tty-table -i > /dev/null || gem install tty-table
	@ruby tools/visualize_bench.rb -u

build: $(LANGS:%=build-%)
run:   $(LANGS:%=run-%)
bench: $(LANGS:%=bench-%)

define CLEAN_VARIANTS
clean-$(1):
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -C $(LANG_DIR)/$(1)/$$$$variant clean || true; \
	done
endef

$(foreach lang,$(LANGS),$(eval $(call CLEAN_VARIANTS,$(lang))))

clean: $(foreach lang,$(LANGS),clean-$(lang))

define build_rules

build-$(1):
	@echo "Building $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$${variant} build || echo "$(LANG_DIR)/$(1)/$$$${variant}: build failed"; \
	done

run-$(1):
	@echo "Running $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$${variant} run INPUT=$(DATA) || echo "$(LANG_DIR)/$(1)/$$$${variant}: run failed"; \
	done

bench-$(1):
	@mkdir -p data/benchmark_results/$(1)
	@for variant in $$(VARIANTS_$(1)); do \
		echo ""; \
		echo "Benchmarking $(1)/$$$$variant"; \
		/usr/bin/time -f "real: %e sec\nuser: %U sec\nsys:  %S sec\nmem:  %M KB" \
			$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$$variant run INPUT=$(DATA) 2>&1 \
			| tee data/benchmark_results/$(1)/$$$$variant.log; \
	done


endef

$(foreach lang,$(LANGS),$(eval $(call build_rules,$(lang))))
