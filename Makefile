SHELL := /bin/bash

# Disable built-in rules and variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

NETWORK := local

###########################################################################
# OS we're running on
ifeq ($(OS),Windows_NT)
	detected_OS := Windows
else
	detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

ifeq ($(detected_OS),Darwin)	  # Mac OS X  (Intel)
	OS += macos
	DIDC += didc-macos
endif
ifeq ($(detected_OS),Linux)		  # Ubuntu
	OS += linux
	DIDC += didc-linux64 
endif

ifeq ($(detected_OS),Windows_NT)  # Windows (icpp supports it but you cannot run this Makefile)
	OS += windows_cannot_run_make
endif
ifeq ($(detected_OS),Unknown)     # Unknown
	OS += unknown
endif

###########################################################################
# latest release of didc
VERSION_DIDC := $(shell curl --silent "https://api.github.com/repos/dfinity/candid/releases/latest" | grep -e '"tag_name"' | cut -c 16-25)
# version to install for clang
VERSION_CLANG := $(shell cat version_clang.txt)

###########################################################################
# Use some clang tools that come with wasi-sdk
WASI_SDK_COMPILER_ROOT := $(HOME)/.icpp/wasi-sdk/wasi-sdk-25.0
CLANG_FORMAT = $(WASI_SDK_COMPILER_ROOT)/bin/clang-format
CLANG_TIDY = $(WASI_SDK_COMPILER_ROOT)/bin/clang-tidy

.PHONY: summary
summary:
	@echo "-------------------------------------------------------------"
	@echo OS=$(OS)
	@echo VERSION_DIDC=$(VERSION_DIDC)
	@echo VERSION_CLANG=$(VERSION_CLANG)
	@echo WASI_SDK_COMPILER_VERSION=$(WASI_SDK_COMPILER_VERSION)
	@echo WASI_SDK_COMPILER_ROOT=$(WASI_SDK_COMPILER_ROOT)
	@echo CLANG_FORMAT=$(CLANG_FORMAT)
	@echo CLANG_TIDY=$(CLANG_TIDY)
	@echo "-------------------------------------------------------------"

###########################################################################
# CI/CD - Phony Makefile targets
#
.PHONY: all-tests
all-tests: all-static all-native deploy-local-pytest

.PHONY: deploy-local-pytest
deploy-local-pytest:
	dfx identity use icpp-qa
	dfx stop
	dfx start --clean --background
	@echo "Waiting for dfx to start..."
	sleep 5
	@echo "Build & Deploy"
	icpp build-wasm
	dfx deploy
	@echo "Running pytest"
	pytest -vv
	@echo "Stopping dfx"
	dfx stop


.PHONY: all-native
all-native:
	@echo "Build native"
	icpp build-native
	@echo "Run mockic.exe"
	./build-native/mockic.exe

.PHONY: all-static
all-static: \
	cpp-format cpp-lint \
	python-format python-lint python-type
	
CPP_AND_H_FILES = $(shell ls \
src/*.cpp src/*.h \
native/*.cpp native/*.h)

.PHONY: cpp-format
cpp-format:
	@echo "---"
	@echo "cpp-format"
	$(CLANG_FORMAT) --style=file --verbose -i $(CPP_AND_H_FILES)

.PHONY: cpp-lint
cpp-lint:
	@echo "---"
	@echo "cpp-lint"
	@echo "TO IMPLEMENT with clang-tidy"

.PHONY: clean-dfx
clean-dfx:
	rm -rf $(shell find . -name '.dfx' -type d)

.PHONY: clean-build
clean-build:
	rm -rf build build-native build-native-unit
	rm -rf $(shell find ./src -name 'build' -type d)
	rm -rf $(shell find ./tests -name 'build' -type d)
	
.PHONY: python-clean
python-clean:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f  {} +

PYTHON_DIRS ?= test

.PHONY: python-format
python-format:
	@echo "---"
	@echo "python-format"
	python -m black $(PYTHON_DIRS)

.PHONY: python-lint
python-lint:
	@echo "---"
	@echo "python-lint"
	python -m pylint --jobs=0 --rcfile=.pylintrc $(PYTHON_DIRS)

.PHONY: python-type
python-type:
	@echo "---"
	@echo "python-type"
	python -m mypy --config-file .mypy.ini --show-column-numbers --strict --explicit-package-bases $(PYTHON_DIRS)

###########################################################################
# Toolchain installation for .github/workflows

.PHONY: install-clang-ubuntu
install-clang-ubuntu:
	@echo "Installing clang-$(VERSION_CLANG) compiler"
	# sudo apt-get remove python3-lldb-14
	wget https://apt.llvm.org/llvm.sh
	chmod +x llvm.sh
	echo | sudo ./llvm.sh $(VERSION_CLANG)
	rm llvm.sh

	@echo "Creating soft links for compiler executables"
	sudo ln --force -s /usr/bin/clang-$(VERSION_CLANG) /usr/bin/clang
	sudo ln --force -s /usr/bin/clang++-$(VERSION_CLANG) /usr/bin/clang++

# This installs ~/bin/dfx
# Make sure to source ~/.profile afterwards -> it adds ~/bin to the path if it exists
.PHONY: install-dfx
install-dfx:
	DFXVM_INIT_YES=true sh -ci "$$(curl -fsSL https://sdk.dfinity.org/install.sh)"

.PHONY: install-didc
install-didc:
	@echo "Installing didc $(VERSION_DIDC) ..."
	sudo rm -rf /usr/local/bin/didc
	wget https://github.com/dfinity/candid/releases/download/${VERSION_DIDC}/$(DIDC)
	sudo mv $(DIDC) /usr/local/bin/didc
	chmod +x /usr/local/bin/didc
	@echo " "
	@echo "Installed successfully in:"
	@echo /usr/local/bin/didc

.PHONY: install-jp-ubuntu
install-jp-ubuntu:
	sudo apt-get update && sudo apt-get install jp

.PHONY: install-jp-mac
install-jp-mac:
	brew install jp

.PHONY: install-homebrew-mac
install-homebrew-mac:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

.PHONY: install-python
install-python:
	pip install --upgrade pip
	pip install -r requirements.txt