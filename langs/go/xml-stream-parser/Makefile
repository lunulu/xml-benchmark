BIN = main

build:
	@test -f go.mod || go mod init xmlparser-bench
	go get github.com/tamerh/xml-stream-parser
	go mod tidy
	go build -o $(BIN) main.go
	@echo "✅ Go xml-stream-parser: file is compiled and dependencies installed"

run:
	./$(BIN) "$(INPUT)"

clean:
	@rm -f $(BIN)
	@rm -f go.mod go.sum
	@echo "🧹 Go xml-stream-parser: temporary files are deleted"
