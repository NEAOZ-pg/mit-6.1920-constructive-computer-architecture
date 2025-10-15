BUILD_DIR=build
BINARY_NAME=TbMM
BSC_FLAGS=--aggressive-conditions --show-schedule -vdir $(BUILD_DIR) -bdir $(BUILD_DIR) -simdir $(BUILD_DIR) -o 
TOP_MODULE=mkTb
BSV_FILES_TRACKED=TbMM.bsv

.PHONY: clean all submit

all: $(BINARY_NAME)
	./$(BINARY_NAME) 2>&1 | tee output.log

$(BINARY_NAME): FoldedMM.bsv TbMM.bsv
	mkdir -p $(BUILD_DIR)
	bsc $(BSC_FLAGS) $@ -sim -g $(TOP_MODULE) -u $@.bsv
	bsc $(BSC_FLAGS) $@ -sim -e $(TOP_MODULE)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)
	rm -f *.so
	rm -f *.sched

submit: all
	git add -A
	git commit -am "Save Changes & Submit"
	git push