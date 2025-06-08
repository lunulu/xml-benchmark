MAKEFLAGS += --no-print-directory

LANG_DIR := langs
LANGS := ruby python go js
VARIANTS_ruby := ox ox-sax nokogiri
VARIANTS_python := lxml lxml-iterparse elementtree
VARIANTS_go := encoding-xml xml-stream-parser mxj
VARIANTS_js := fast-xml-parser sax

DATA := $(abspath data/input.xml)

.PHONY: install full generate clean build run bench $(LANGS:%=build-%) $(LANGS:%=run-%) $(LANGS:%=bench-%)

install:
	@command -v mise >/dev/null 2>&1 || { \
    		echo "❌ 'mise' is not installed. Please install it from: https://github.com/jdx/mise" >&2; \
    		echo "🔁 After installing, re-run: make install" >&2; \
    		exit 1; \
    }
	@echo "📦 Installing languages and dependencies with mise"
	@mise install ruby
	@mise install python
	@mise install go
	@mise install node
	@echo "✅ All environments installed"

full: generate build bench

generate:
	@gem list ox -i > /dev/null || gem install ox
	@mkdir -p data
	@rm -f $(DATA)
	@ruby tools/generate_xml.rb $(DATA) $(MB)


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
	@echo "🔧 Building $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$${variant} build || echo "❌ $(LANG_DIR)/$(1)/$$$${variant}: build failed"; \
	done

run-$(1):
	@echo "🚀 Running $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$${variant} run INPUT=$(DATA) || echo "❌ $(LANG_DIR)/$(1)/$$$${variant}: run failed"; \
	done

bench-$(1):
	@for variant in $$(VARIANTS_$(1)); do \
		echo ""; \
		echo "📶 Benchmarking $(1)/$$$$variant"; \
		/usr/bin/time -f "real: %e sec\nuser: %U sec\nsys:  %S sec\nmem:  %M KB" \
			$(MAKE) -s -C $(LANG_DIR)/$(1)/$$$$variant run INPUT=$(DATA) 2>&1; \
	done

endef

$(foreach lang,$(LANGS),$(eval $(call build_rules,$(lang))))