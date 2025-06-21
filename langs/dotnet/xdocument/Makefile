build:
	@dotnet build -nologo > /dev/null
	@echo "✅ C# XDocument: file is compiled"

run:
	@dotnet run --project . -- "$(INPUT)"

clean:
	@dotnet clean -nologo > /dev/null
	@rm -rf bin obj
	@echo "🧹 C# XDocument: temporary files are deleted"
