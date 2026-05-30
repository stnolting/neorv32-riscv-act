# NEORV32 RISC-V ACT Makefile

.DEFAULT_GOAL := help

all: mise tests elfs setup run

# number of parallel jobs
JOBS ?= $(shell nproc)

# check tools
check:
	python3 -V
	@echo "------------------------------"
	riscv-none-elf-gcc -v
	@echo "------------------------------"
	riscv-none-elf-objcopy -V
	@echo "------------------------------"
	sail_riscv_sim --version
	@echo "------------------------------"
	ghdl -v
	@echo "------------------------------"
	mise --version
	@echo "------------------------------"
	@echo "NEORV32 hardware version"
	@grep "hw_version_c" neorv32/rtl/core/neorv32_package.vhd
	@echo "------------------------------"
	@echo "Tool checks OK"

# allow mise to install required tools
mise:
	cd riscv-arch-test && \
	mise trust .mise.toml

# generate tests and coverpoints
tests:
	@echo "Generating tests and coverpoints..."
	cd riscv-arch-test && \
	CONFIG_FILES=../config/test_config.yaml \
	make tests --jobs $(JOBS)

# build target ELFs
elfs:
	@echo "Building ELFs..."
	cd riscv-arch-test && \
	EXCLUDE_EXTENSIONS=ExceptionsZicboU,SsstrictSm,SsstrictU,InterruptsU \
	CONFIG_FILES=../config/test_config.yaml \
	EXTENSIONS= \
	DEBUG=False \
	make elfs --jobs $(JOBS)

# setup GHDL simulation
setup:
	@echo "Preparing GHDL simulation..."
	ghdl -i --work=neorv32 --std=08 neorv32/rtl/core/*.vhd neorv32_act_tb.vhd && \
	ghdl -m --std=08 --work=neorv32 neorv32_act_tb

# run ELFs on NEORV32
run:
	@echo "Running tests..."
	chmod +x ./config/run_cmd.sh
	cd riscv-arch-test && \
	./run_tests.py --timeout 2000 -j $(JOBS) "./../config/run_cmd.sh __TRACEFILE__" work/neorv32/elfs/

# cleanup everything
clean:
	@echo "Cleaning up..."
	cd riscv-arch-test && make clean
	rm -f *.cf

# help text
help:
	@echo "NEORV32 RISC-V ACT Makefile"
	@echo ""
	@echo "check - check required tools"
	@echo "mise  - allow mise to install required tools"
	@echo "tests - generate tests and coverpoints"
	@echo "elfs  - build target ELFs"
	@echo "setup - setup simulation"
	@echo "run   - run all tests on target"
	@echo "clean - remove all artifacts"
	@echo "all   - mise + tests + elfs + setup + run"
	@echo "help  - show this text"
