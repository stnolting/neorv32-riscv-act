# NEORV32 RISC-V ACT Makefile

.DEFAULT_GOAL := help

all: check mise tests elfs setup run

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
# [NOTE] sudo chown -R $USER:$USER /var/lib/gems/3.2.0/
mise:
	cd riscv-arch-test && \
	mise trust .mise.toml

# generate tests and coverpoints
tests:
	cd riscv-arch-test && \
	CONFIG_FILES=../config/test_config.yaml \
	make tests --jobs $(nproc)

# build target ELFs
elfs:
	cd riscv-arch-test && \
	EXCLUDE_EXTENSIONS= \
	CONFIG_FILES=../config/test_config.yaml \
	make elfs --jobs $(nproc)

# setup GHDL simulation
setup:
	ghdl -i --work=neorv32 --std=08 neorv32/rtl/core/*.vhd neorv32_act_tb.vhd && \
	ghdl -m --std=08 --work=neorv32 neorv32_act_tb

# run ELFs on NEORV32
run:
	cd riscv-arch-test && \
	./run_tests.py -v -d "./../config/run_cmd.sh __TRACEFILE__" work/neorv32/elfs/

# cleanup everything
clean:
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
	@echo "help  - show this text"
