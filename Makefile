MAKEFLAGS += --no-print-directory

LANGS := ruby python go
VARIANTS_ruby := ox ox-sax nokogiri # rexml
VARIANTS_python := lxml lxml-iterparse elementtree # xmltodict
VARIANTS_go := encoding-xml xml-stream-parser mxj

DATA := $(abspath data/input.xml)

.PHONY: full generate clean build run bench $(LANGS:%=build-%) $(LANGS:%=run-%) $(LANGS:%=bench-%)

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
		$(MAKE) -C $(1)/$$$$variant clean || true; \
	done
endef

$(foreach lang,$(LANGS),$(eval $(call CLEAN_VARIANTS,$(lang))))

clean: $(foreach lang,$(LANGS),clean-$(lang))

define build_rules

build-$(1):
	@echo "🔧 Building $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(1)/$$$${variant} build || echo "❌ $(1)/$$$${variant}: build failed"; \
	done

run-$(1):
	@echo "🚀 Running $(1)"
	@for variant in $$(VARIANTS_$(1)); do \
		$(MAKE) -s -C $(1)/$$$${variant} run INPUT=$(DATA) || echo "❌ $(1)/$$$${variant}: run failed"; \
	done

bench-$(1):
	@for variant in $$(VARIANTS_$(1)); do \
		echo ""; \
		echo "📶 Benchmarking $(1)/$$$$variant"; \
		/usr/bin/time -f "real: %e sec\nuser: %U sec\nsys:  %S sec\nmem:  %M KB" \
			$(MAKE) -s -C $(1)/$$$$variant run INPUT=$(DATA) 2>&1; \
	done

endef

$(foreach lang,$(LANGS),$(eval $(call build_rules,$(lang))))