# This looks for riscv32-unknown-elf-gcc or riscv64-unknown-elf-gcc and sets
# RISCV_TARGET accordingly. The check_for_riscv_target variable is used to
# abort compilation if no RISC-V compiler was found.
#RVNE_EXISTS:=$(shell command -v riscv-none-embed-gcc 2> /dev/null)
#check_for_riscv_target=$(error No RISC-V compiler found. \
#		       Expecting riscv-none-embed-gcc. \
#		       Please ensure your Athena setup is correct.)


RISCV_TARGET=/usr/bin/riscv64-unknown-elf-

CFLAGS=-march=rv32i -mabi=ilp32 -static -nostdlib -nostartfiles -mcmodel=medany
LDFLAGS=-march=rv32i -nostdlib -nostartfiles -Wl,-Ttools/bare-link.ld
OBJDUMPFLAGS=-s -d -Mno-aliases -Mnumeric

MICROTESTS_VMH=$(patsubst microtests/%.S, build/microtests/%.vmh, $(wildcard microtests/*.S))
MICROTESTS_DUMP=$(patsubst microtests/%.S, build/microtests/%.dump, $(wildcard microtests/*.S))
FULLASMTESTS_VMH=$(patsubst fullasmtests/%.S, build/fullasmtests/%.vmh, $(wildcard fullasmtests/*.S))
FULLASMTESTS_DUMP=$(patsubst fullasmtests/%.S, build/fullasmtests/%.dump, $(wildcard fullasmtests/*.S))
QUICKSORT_VMH=build/quicksort/quicksort.vmh
QUICKSORT_DUMP=build/quicksort/quicksort.dump

all: microtests fullasmtests quicksort

microtests: $(MICROTESTS_VMH) $(MICROTESTS_DUMP)

fullasmtests: $(FULLASMTESTS_VMH) $(FULLASMTESTS_DUMP)

quicksort: $(QUICKSORT_VMH) $(QUICKSORT_DUMP)

# general targets

%.vmh : %.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K 4 $@

%.dump: %.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump $(OBJDUMPFLAGS) $^ > $@

# mircotests targets

build/microtests/%.riscv: microtests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/microtests
	$(RISCV_TARGET)gcc $(CFLAGS) $(LDFLAGS) $^ -o $@


# fullasmtests targets

build/fullasmtests/%.riscv: fullasmtests/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/fullasmtests
	$(RISCV_TARGET)gcc $(CFLAGS) -I fullasmtests $(LDFLAGS) $^ -o $@

# quicksort targets

# TODO(qmn): see if we can just use src/riscv-link.ld
QUICKSORT_LDFLAGS=-march=rv32i -nostdlib -nostartfiles -Wl,-Ttools/quicksort.ld
build/quicksort/%.riscv: build/quicksort/main.o build/quicksort/crt0.o build/quicksort/quicksort.o
	$(call check_for_riscv_target)
	@mkdir -p build/quicksort
	$(RISCV_TARGET)gcc $(CFLAGS) $(QUICKSORT_LDFLAGS) $^ -o $@

build/quicksort/%.o : quicksort/%.c
	$(call check_for_riscv_target)
	@mkdir -p build/quicksort
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

build/quicksort/%.o : quicksort/%.S
	$(call check_for_riscv_target)
	@mkdir -p build/quicksort
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

# Technically this should be a phony target, but we're assuming this tool
# will not change often.
tools/elf2hex/elf2hex:
	make -C tools/elf2hex

clean:
	rm -rf build __pycache__ tools/__pycache__
	rm -f *.dump *.vmh *.x86

.PHONY: all microtests fullasmtests quicksort clean
