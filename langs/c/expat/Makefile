CC = gcc
CFLAGS = -Wall -O2
LDFLAGS = -lexpat
TARGET = main
SRC = main.c

build:
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	@echo "✅ C Expat: file is compiled"

run:
	@./$(TARGET) "$(INPUT)"

clean:
	@rm -f $(TARGET)
	@echo "🧹 C Expat: temporary files are deleted"
