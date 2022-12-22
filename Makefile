# Build2 variables
BUILD2_INSTALLER=https://download.build2.org/0.15.0/build2-install-0.15.0.sh
BUILD2_TMP=$(PWD)/.tmp
BUILD2_DIR=$(PWD)/.build2
BUILD2_B=$(BUILD2_DIR)/bin/b
BUILD2_BDEP=$(BUILD2_DIR)/bin/bdep
BUILD2_CONFIG_GCC=.config-gcc

# Variable to iterate over the days directories, used
# together with a wildcard, e.g. 'Day*'
DAY_DIRS=libDay


# Default build target:
# Setup everything, test, and build it
all: cleanup install_build2 config_build2 test build


# Cleanup the project, delete the local installation of the build system,
# all intermediate build results, and all binaries
.PHONY: cleanup
cleanup:
	rm -rf \
		$(BUILD2_TMP) \
		$(BUILD2_DIR) \
		$(BUILD2_CONFIG_GCC)


# Build2 does not provide a package for Ubuntu, has to be compiled
# directly on the machine.
# To avoid requesting admin rights, installation is done locally
# in BUILD2_DIR
.PHONY: install_build2
install_build2:
	@curl \
		--output-dir $(BUILD2_TMP) \
		--create-dirs \
		-sSfO $(BUILD2_INSTALLER)
	@(cd $(BUILD2_TMP) \
		&& sh $(notdir $(BUILD2_INSTALLER)) \
			--local \
			--cxx g++ \
			--yes \
			--no-check \
			$(BUILD2_DIR) \
	)
	@rm -rf \
		$(BUILD2_TMP)


# Configure all build targets in Build2
.PHONY: config_build2
config_build2:
	@rm -rf \
		$(BUILD2_CONFIG_GCC)
	@$(BUILD2_B) create: $(BUILD2_CONFIG_GCC)/,cxx \
			config.cxx=g++
#@$(foreach dir, $(wildcard $(DAY_DIRS)*), cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) configure: ../$(dir)/@$(BUILD2_CONFIG_GCC)/$(dir)/libDay01/;)
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) configure: ../libDay01/libDay01/@libDay01/
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) configure: ../libDay01/libDay01-tests/@libDay01-tests/
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) configure: ../App/@App/


# Delete intermediate build results, but preseve local build2 installation
# and any downloaded dependencies
.PHONY: clean
clean:
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) clean


# Build the project, in this case the App binary.
# Builds all dependencies as well.
build:
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) App/


# Build unit tests and run them
test:
	@cd $(BUILD2_CONFIG_GCC) && $(BUILD2_B) test


# Add a new day via the build2 bdep tool
.PHONY: add_day
add_day:
	./scripts/add_day.sh	\
		$(BUILD2_BDEP)