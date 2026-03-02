.PHONY: build test clean release lint help

# Default target
all: build

# Build the package in debug mode
build:
	swift build

# Build the package in release mode
release:
	swift build -c release

# Run tests
test:
	swift test

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build

# Resolve dependencies
resolve:
	swift package resolve

# Update dependencies
update:
	swift package update

# Generate Xcode project
xcode:
	swift package generate-xcodeproj

# Lint Swift code
lint:
	swiftlint

# Show help
help:
	@echo "Available targets:"
	@echo "  build   - Build the package in debug mode"
	@echo "  release - Build the package in release mode"
	@echo "  test    - Run tests"
	@echo "  clean   - Clean build artifacts"
	@echo "  resolve - Resolve dependencies"
	@echo "  update  - Update dependencies"
	@echo "  xcode   - Generate Xcode project"
	@echo "  lint    - Lint Swift code with SwiftLint"
	@echo "  help    - Show this help message"
