build:
	@dotnet build -nologo > /dev/null
	@echo "✅ C# XmlReader: file is compiled"

run:
	@dotnet run --project . -- "$(INPUT)"

clean:
	@dotnet clean -nologo > /dev/null
	@rm -rf bin obj
	@echo "🧹 C# XmlReader: temporary files are deleted"
