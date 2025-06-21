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
	@echo "✅ Java STaX: file is compiled"

run:
	java $(JFLAGS) $(BIN) "$(INPUT)"

clean:
	@rm -f *.class
	@echo "🧹 Java STaX: temporary files are deleted"
