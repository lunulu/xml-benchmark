BIN = Main
CLASS = $(BIN).class
INPUT = input.xml

JFLAGS = \
  -XX:+UseSerialGC \
  -XX:-TieredCompilation \
  -XX:CICompilerCount=1 \
  -XX:+DisableExplicitGC \
  -XX:-UsePerfData \
  -XX:+AlwaysPreTouch

build:
	javac $(BIN).java
	@echo "✅ Java DOM: file is compiled"

run:
	java $(JFLAGS) $(BIN) "$(INPUT)"

clean:
	@rm -f *.class
	@echo "🧹 Java DOM: temporary files are deleted"
