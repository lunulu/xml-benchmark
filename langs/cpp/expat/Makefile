CXX = g++
CXXFLAGS = -Wall -O2
LDFLAGS = -lexpat
TARGET = expat_parser
SRC = main.cpp

build:
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	@echo "✅ C++ expat: file is compiled"

run:
	@./$(TARGET) "$(INPUT)"

clean:
	@rm -f $(TARGET)
	@echo "🧹 C++ expat: temporary files are deleted"
