build:
	@dotnet build -nologo > /dev/null
	@echo "✅ C# XmlDocument: file is compiled"

run:
	@dotnet run --project . -- "$(INPUT)"

clean:
	@dotnet clean -nologo > /dev/null
	@rm -rf bin obj
	@echo "🧹 C# XmlDocument: temporary files are deleted"
