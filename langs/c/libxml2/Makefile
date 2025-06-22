CC = gcc
CFLAGS = -Wall -O2 `pkg-config --cflags libxml-2.0 glib-2.0`
LDFLAGS = `pkg-config --libs libxml-2.0 glib-2.0`
TARGET = main
SRC = main.c

build:
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	@echo "✅ C libxml2: file is compiled"

run:
	@./$(TARGET) "$(INPUT)"

clean:
	@rm -f $(TARGET)
	@echo "🧹 C libxml2: temporary files are deleted"
