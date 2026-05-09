# NEORV32 RISC-V Architectural Certification Tests

[![neorv32-riscv-act](https://img.shields.io/github/actions/workflow/status/stnolting/neorv32-riscv-act/riscv-act.yml?branch=main&longCache=true&style=flat-square&label=neorv32-riscv-act&logo=Github%20Actions&logoColor=fff)](https://github.com/stnolting/neorv32-riscv-act/actions/workflows/riscv-act.yml)
[![License](https://img.shields.io/github/license/stnolting/neorv32-riscv-act?longCache=true&style=flat-square&label=License)](https://github.com/stnolting/neorv32-riscv-act/blob/main/LICENSE)

[NEORV32](https://github.com/stnolting/neorv32) port of the
[RISC-V Architectural Certification Tests (ACTs)](https://github.com/riscv/riscv-arch-test)
to certify that the processor faithfully implements the RISC-V specification. This port was set up
based on the ACT [_Getting Started_](https://github.com/riscv/riscv-arch-test#getting-started) guide.
This port is still under development and will be expanded with additional ISA extensions in the future.


## Prerequisites

* [Python](https://www.python.org/) - main scripting language for the test framework
* [RISC-V GCC toolchain](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack) - for compiling native RISC-V code
* [Sail RISC-V](https://github.com/riscv/sail-riscv) - golden reference model
* [GHDL](https://github.com/ghdl/ghdl) - VHDL simulator for simulating the DUT
* [mise](https://mise.jdx.dev) - tool and environment management (handles tool installation)
* NEORV32 submodule - the device under test (DUT)
* [riscv-arch-test](https://github.com/riscv-non-isa/riscv-arch-test) submodule - test cases and framework

> [!NOTE]
> You may need to run `sudo chown -R $USER:$USER /var/lib/gems/3.2.0/` to adjust the ownership of the system-wide installation directory for Ruby gems.


## Port Details

All NEORV32-specific test framework configuration files are located in [`config`](config). These files are
passed to the test framework as out-of-tree configuration. See [`config/neorv32.yaml`](config/neorv32.yaml)
for a list of all currently supported/tested ISA extensions. The DUT testbench [`neorv32_act_tb.vhd`](neorv32_act_tb.vhd)
instantiates the DUT and also implements a memory subsystem attached to the core's external bus interface.
This subsystem provides main memory and environment control mechanisms:

| Address | Description |
|:--------|:------------|
| `0x80000000` ... `0x803FFFFF` | Main memory (RAM), max 4MB; pre-initialized with the application executable |
| `0xF0000000` | Write any value to terminate the simulation; writing `0x12345678` indicates a PASS; used by the `RVMODEL_HALT_PASS` and `RVMODEL_HALT_FAIL` macros |
| `0xF0000004` | Print character (lowest 8 bits) to the simulator console; used by the `RVMODEL_IO_WRITE_STR` macro for test status and logging |
| `0xF0000008` | Bit 0 controls the hart's external machine interrupt; used by `RVMODEL_SET_MEXT_INT` and `RVMODEL_CLR_MEXT_INT` macros |

> [!NOTE]
> For advanced profiling and debugging, execution trace data is logged to the test's `log` folders.


## Running ACT

Once all prerequisites have been installed the main Makefile is used to build and run the tests:

```bash
neorv32-riscv-act$ make help
NEORV32 RISC-V ACT Makefile

check - check required tools
mise  - allow mise to install required tools
tests - generate tests and coverpoints
elfs  - build target ELFs
setup - setup simulation
run   - run all tests on target
clean - remove all artifacts
all   - mise + tests + elfs + setup + run
help  - show this text
neorv32-riscv-act$ make all
...
```

The test are executed automatically as a [GitHub cction](https://github.com/stnolting/neorv32-riscv-act/actions/workflows/riscv-act.yml).
Dependabot updates the riscv-arch-test and NEORV32 submodules as soon as updates are available in the main branches.


## TODOs

* add support for all ISA extensions provided by NEORV32
* check the PMP grain configuration; currently, the granularity is set to 8 bytes, which means that no PMP-NA4 tests are executed
* T.B.A.
