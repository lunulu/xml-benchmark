CXX = g++
CXXFLAGS = -Wall -O2
TARGET = main
SRC = main.cpp pugixml.cpp
PUGI_URL = https://raw.githubusercontent.com/zeux/pugixml/master/src

build:
	@curl -sSfL $(PUGI_URL)/pugixml.cpp -o pugixml.cpp
	@curl -sSfL $(PUGI_URL)/pugixml.hpp -o pugixml.hpp
	@curl -sSfL $(PUGI_URL)/pugiconfig.hpp -o pugiconfig.hpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)
	@echo "✅ C++ pugixml: file is compiled"

run:
	@./$(TARGET) "$(INPUT)"

clean:
	@rm -f $(TARGET)
	@rm -rf pugixml.cpp pugixml.hpp pugiconfig.hpp
	@echo "🧹 C++ pugixml: temporary files are deleted"
