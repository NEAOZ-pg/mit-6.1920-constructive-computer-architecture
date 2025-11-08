.DEFAULT_GOAL := all
BUILD_DIR=build
BINARY_NAME=CrossbarTestBench RouterTestBench
BSC_FLAGS=--aggressive-conditions --show-schedule -vdir $(BUILD_DIR) -bdir $(BUILD_DIR) -simdir $(BUILD_DIR) -o 

.PHONY: clean all $(BINARY_NAME)

CrossbarTestBench:
	mkdir -p $(BUILD_DIR)
	bsc $(BSC_FLAGS) $@ -sim -g mk$@ -u $@.bsv
	bsc $(BSC_FLAGS) $@ -sim -e mk$@

RouterTestBench:
	mkdir -p $(BUILD_DIR)
	bsc $(BSC_FLAGS) $@ -sim -g mk$@ -u $@.bsv
	bsc $(BSC_FLAGS) $@ -sim -e mk$@

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)
	rm -f RouterTestBench
	rm -f CrossbarTestBench
	rm -f *.so
	rm -f *.sched

all: clean $(BINARY_NAME)

submit:
	make all
	./CrossbarTestBench 2>&1 | tee output_submit1.txt 
	./RouterTestBench 2>&1 | tee output_submit2.txt 
	cat output_submit1.txt output_submit2.txt > output_submit.txt
	git add -A
	git commit -am "Save Changes & Submit"
	git push
