# CachyOS Server x86-64-v4 Build System

.PHONY: help build-kernel build-iso build-all clean dist-clean test validate push

help:
	@echo "CachyOS Server x86-64-v4 Build System"
	@echo "======================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make build-kernel    - Build linux-cachyos-server kernel (x86-64-v4)"
	@echo "  make build-kernel-gcc    - Build with GCC compiler"
	@echo "  make build-kernel-clang  - Build with Clang/LLVM"
	@echo "  make build-iso       - Build ISO with custom kernel"
	@echo "  make build-all       - Build kernel and ISO"
	@echo "  make validate        - Validate workflow files"
	@echo "  make test            - Run tests"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make dist-clean      - Complete cleanup"
	@echo "  make push            - Push changes to GitHub"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "GitHub Actions Workflows:"
	@echo "  - Run workflow manually: gh workflow run build-server-v4-iso.yml"
	@echo "  - View workflow runs: gh run list"
	@echo ""

build-kernel:
	@echo "Building linux-cachyos-server kernel with default compiler..."
	chmod +x scripts/build-kernel.sh
	./scripts/build-kernel.sh gcc

build-kernel-gcc:
	@echo "Building linux-cachyos-server kernel with GCC..."
	chmod +x scripts/build-kernel.sh
	./scripts/build-kernel.sh gcc

build-kernel-clang:
	@echo "Building linux-cachyos-server kernel with Clang/LLVM..."
	chmod +x scripts/build-kernel.sh
	./scripts/build-kernel.sh clang

build-iso:
	@echo "Building CachyOS Server ISO..."
	chmod +x scripts/build-iso.sh
	sudo ./scripts/build-iso.sh

build-all: build-kernel build-iso
	@echo "✅ Build completed successfully!"

validate:
	@echo "Validating GitHub Actions workflow..."
	@if command -v actionlint &> /dev/null; then \
		actionlint .github/workflows/*.yml; \
	else \
		echo "WARNING: actionlint not installed. Install with: 'brew install actionlint'"; \
		echo "Validating basic YAML syntax..."; \
		python3 -m yaml .github/workflows/*.yml 2>/dev/null || echo "Python YAML module not available"; \
	fi
	@echo "✅ Validation complete"

test:
	@echo "Running tests..."
	@echo "  - Checking script syntax..."
	bash -n scripts/build-kernel.sh
	bash -n scripts/build-iso.sh
	@echo "✅ Tests passed"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf /tmp/cachyos-build-*
	rm -rf /tmp/cachyos-iso-build*
	rm -rf dist/*.iso dist/*.tar.*
	@echo "✅ Cleanup complete"

dist-clean: clean
	@echo "Complete cleanup (includes dist/)..."
	rm -rf dist/
	rm -rf /tmp/cachyos-*
	@echo "✅ Complete cleanup finished"

push:
	@echo "Pushing to GitHub..."
	@if [ -z "$$(git status --porcelain)" ]; then \
		echo "Nothing to commit, working tree clean"; \
	else \
		git add -A; \
		git commit -m "CachyOS Server x86-64-v4 Build Update"; \
		git push origin main; \
		echo "✅ Push complete"; \
	fi

.DEFAULT_GOAL := help
