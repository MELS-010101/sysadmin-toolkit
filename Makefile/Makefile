.PHONY: install lint test release clean

install:
	@echo "🔧 Installing SysAdmin-Toolkit to /usr/local/bin..."
	@cp -r bin/sat /usr/local/bin/
	@chmod +x /usr/local/bin/sat
	@echo "✅ Done. Run: sat --help"

lint:
	@echo "🔍 Running ShellCheck..."
	@shellcheck src/linux/*.sh src/macos/*.sh --severity=error
	@echo "🔍 Running PSScriptAnalyzer..."
	@pwsh -Command "Invoke-ScriptAnalyzer -Path src/windows -Recurse -Severity Error"

test:
	@echo "🧪 Running Bash tests (Bats)..."
	@bats tests/bash/
	@echo "🧪 Running PowerShell tests (Pester)..."
	@pwsh -Command "Invoke-Pester tests/powershell -PassThru"

release: lint test
	@echo "🚀 Tagging release..."
	@git tag -a "v$$(grep -m1 version packaging/npm/package.json | cut -d'"' -f4)" -m "Release v$$(grep -m1 version packaging/npm/package.json | cut -d'"' -f4)"
	@git push origin --tags
	@echo "📦 CI will publish to GitHub Packages automatically."

clean:
	@rm -rf dist/ coverage/ .pytest_cache/ node_modules/
	
test:
	@echo "🧪 Running Bash tests..."
	@bats tests/bash/test_system_health.bats tests/bash/test_log_cleanup.bats
	@echo "🧪 Running PowerShell tests..."
	@pwsh -Command "Invoke-Pester tests/powershell -PassThru"