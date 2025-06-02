MAKEFLAGS += --no-print-directory

LANGS := python ruby go
VARIANTS_python := dom
VARIANTS_ruby := ox rexml nokogiri
VARIANTS_go := dom

DATA := $(abspath data/input.xml)

.PHONY: full generate clean build run bench \
        $(LANGS:%=build-%) $(LANGS:%=run-%) $(LANGS:%=bench-%)

full: generate build bench

# Генерация XML-файла
generate:
	@gem list ox -i > /dev/null || gem install ox
	@mkdir -p data
	@rm -f $(DATA)
	@ruby tools/generate_xml.rb $(DATA) $(MB)


# Сборка
build: $(LANGS:%=build-%)
run:   $(LANGS:%=run-%)
bench: $(LANGS:%=bench-%)

# Очистка
clean:
	@for lang in $(LANGS); do \
		for variant in $$(VARIANTS_$$lang); do \
			$(MAKE) -C $$lang/$$variant clean || true; \
		done \
	done

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
		/usr/bin/time -f "real: %e sec\nuser: %U sec\nsys:  %S sec" \
			$(MAKE) -s -C $(1)/$$$$variant run INPUT=$(DATA) 2>&1; \
	done

endef

$(foreach lang,$(LANGS),$(eval $(call build_rules,$(lang))))