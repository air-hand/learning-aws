# just pass to src/Makefile
%:
	@$(MAKE) -C ./src --no-print-directory $@
