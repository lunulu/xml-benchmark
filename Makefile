MAKEFLAGS += --no-print-directory

# Пути к папкам
DIRS := python go ruby
DATA := data/input.xml

.PHONY: all build clean run generate bench

all: generate build bench

# Генерация большого XML-файла
generate:
	@mkdir -p data
	@rm -f data/input.xml
	@ruby tools/generate_xml.rb data/input.xml $(MB)


# Сборка всех, у кого есть build-цель
build: $(DIRS:%=build-%)

# Запуск всех, у кого есть run-цель
run: $(DIRS:%=run-%)

# Очистка
clean:
	@for dir in $(DIRS); do \
		$(MAKE) -C $$dir clean || true; \
	done

# Шаблоны для build/run целей
build-%:
	@echo "🔧 Building $*"
	@$(MAKE) -C $* build || echo "❌ $*: build not defined"

run-%:
	@echo "🚀 Running $*"
	@$(MAKE) -C $* run INPUT=../$(DATA) || echo "❌ $*: run not defined"

bench: $(DIRS:%=bench-%)

bench-%:
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📊 Benchmarking $*"
	@/usr/bin/time -f "$*: %e sec" $(MAKE) -s -C $* run INPUT=../$(DATA) 2>&1 | tee -a benchmark.log
