.PHONY: test test-unit test-integration format lint clean install-dev-tools

# Development tools installation
install-dev-tools:
	@echo "Installing development tools..."
	@echo "Installing StyLua (requires Cargo)..."
	@if command -v cargo > /dev/null; then \
		cargo install stylua; \
	else \
		echo "Cargo not found. Install Rust from https://rustup.rs/"; \
	fi
	@echo "Installing Luacheck (requires Luarocks)..."
	@if command -v luarocks > /dev/null; then \
		luarocks install --local luacheck; \
	else \
		echo "Luarocks not found. Install with: brew install luarocks (macOS) or apt-get install luarocks (Linux)"; \
	fi
	@echo "Done! You may need to add ~/.luarocks/bin to your PATH"

# Test targets
test: test-unit test-integration

test-unit:
	@echo "Running unit tests..."
	nvim --headless --noplugin -u test/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('test/unit', { minimal_init = 'test/minimal_init.lua' })"

test-integration:
	@echo "Running integration tests..."
	nvim --headless --noplugin -u test/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('test/integration', { minimal_init = 'test/minimal_init.lua' })"

# Format code with StyLua
format:
	@echo "Formatting Lua code..."
	@if command -v stylua > /dev/null; then \
		stylua lua/ plugin/ ftdetect/ ftplugin/ test/; \
	else \
		echo "StyLua not found. Install with: cargo install stylua"; \
		exit 1; \
	fi

# Lint code
lint:
	@echo "Linting Lua code..."
	@if command -v luacheck > /dev/null; then \
		luacheck lua/ plugin/ ftdetect/ ftplugin/; \
	else \
		echo "Luacheck not found. Install with: luarocks install luacheck"; \
		exit 1; \
	fi

# Check formatting without modifying files
check-format:
	@echo "Checking code formatting..."
	@if command -v stylua > /dev/null; then \
		stylua --check lua/ plugin/ ftdetect/ ftplugin/ test/; \
	else \
		echo "StyLua not found. Install with: cargo install stylua"; \
		exit 1; \
	fi

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	rm -rf test/output/
	rm -rf test/tmp/
	find . -name "*.log" -delete

# Help
help:
	@echo "Available targets:"
	@echo "  make test              - Run all tests"
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make format            - Format code with StyLua"
	@echo "  make lint              - Lint code with Luacheck"
	@echo "  make check-format      - Check if code is formatted"
	@echo "  make clean             - Clean test artifacts"
	@echo "  make install-dev-tools - Install development tools (StyLua, Luacheck)"
	@echo "  make help              - Show this help message"
