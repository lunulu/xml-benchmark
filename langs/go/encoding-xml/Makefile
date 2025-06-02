BIN = main

build:
	go build -o $(BIN) main.go
	@echo "✅ Go encoding/xml: file is compiled"

run:
	./$(BIN) "$(INPUT)"

clean:
	@rm -f $(BIN)
	@echo "🧹 Go encoding/xml: temporary files are deleted"
