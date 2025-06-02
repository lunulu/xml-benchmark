BIN = main

build:
	@test -f go.mod || go mod init mxj
	go get github.com/clbanning/mxj/v2
	go build -o $(BIN) main.go
	@echo "✅ Go mxj: file is compiled and dependencies installed"

run:
	./$(BIN) "$(INPUT)"

clean:
	@rm -f $(BIN)
	@rm -f go.mod go.sum
	@echo "🧹 Go mxj: temporary files are deleted"
