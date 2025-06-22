CXX = g++
CXXFLAGS = -Wall -O2
TARGET = main
SRC = main.cpp pugixml.cpp

build:
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)
	@echo "✅ C++ pugixml: file is compiled"

run:
	@./$(TARGET) "$(INPUT)"

clean:
	@rm -f $(TARGET)
	@echo "🧹 C++ pugixml: temporary files are deleted"
