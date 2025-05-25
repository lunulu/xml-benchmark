BIN = main

build:
	go build -o $(BIN) main.go
	@echo "✅ Go: файл скомпилирован"

run:
	./$(BIN) "$(INPUT)"

clean:
	@rm -f $(BIN)
	@echo "🧹 Go: временные файлы удалены"
