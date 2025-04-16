################################################################################
#
# rustsbi
#
################################################################################

RUSTSBI_VERSION = 051ee5fd75d65785a318e4c7a0cc9589c2c1c716
RUSTSBI_SITE = $(call github,rustsbi,rustsbi,$(RUSTSBI_VERSION))
RUSTSBI_LICENSE = MIT or MulanSPL-2.0
RUSTUP_BIN_LICENSE_FILES = LICENSE-MIT LICENSE-MULAN
 
# Build xtask
define RUSTSBI_BUILD_CMDS
	$(call HOST_RUSTUP_BIN_PRE) && \
	cd $(RUSTSBI_BUILDDIR) && \
	$(HOST_RUSTUP_BIN_ENV) cargo clean && \
	$(HOST_RUSTUP_BIN_ENV) cargo install cargo-binutils && \
	$(HOST_RUSTUP_BIN_ENV) cargo build --package xtask --release 
endef

ifeq ($(BR2_TARGET_RUSTSBI_USE_FDT),y)
# Get FDT PATH 
RUSTSBI_FDT_PATH = $(BR2_TARGET_RUSTSBI_FDT_PATH)
RUSTSBI_CARGO_OPT += --fdt $(RUSTSBI_FDT_PATH)
endif

# RUSTSBI_CONFIG_NAME = $(BR2_TARGET_RUSTSBI_CONFIG_NAME)
# RUSTSBI_CARGO_OPT += -c $(RUSTSBI_CONFIG_NAME).toml

RUSTSBI_INSTALL_TARGET  = NO
RUSTSBI_INSTALL_STAGING = NO
RUSTSBI_INSTALL_IMAGES  = YES

ifeq ($(BR2_TARGET_RUSTSBI_INSTALL_DYNAMIC_IMG),y)
RUSTSBI_FW_IMAGES      += dynamic
RUSTSBI_FW_DYNAMIC_OPT  = 
endif

ifeq ($(BR2_TARGET_RUSTSBI_INSTALL_JUMP_IMG),y)
RUSTSBI_FW_IMAGES   += jump
RUSTSBI_FW_JUMP_OPT  = --jump
endif

ifeq ($(BR2_TARGET_RUSTSBI_INSTALL_PAYLOAD_IMG),y)
RUSTSBI_DEPENDENCIES   += linux
RUSTSBI_FW_IMAGES      += payload
RUSTSBI_FW_PAYLOAD_OPT  = --payload $(BINARIES_DIR)/Image
endif

# Build and install image.
#
# It will override file that opensbi generated, for compatibility.
define RUSTSBI_INSTALL_IMAGES_CMDS
	$(foreach f,$(RUSTSBI_FW_IMAGES),\
		cd $(@D) && \
		$(call HOST_RUSTUP_BIN_PRE) && \
		$(HOST_RUSTUP_BIN_ENV) \
			cargo run --package xtask --release -- \
			prototyper \
			$(RUSTSBI_FW_$(call UPPERCASE, $(f))_OPT) \
			$(RUSTSBI_CARGO_OPT)
		$(INSTALL) -m 0644 -D $(@D)/target/riscv64imac-unknown-none-elf/release/rustsbi-prototyper-$(f).bin \
			$(BINARIES_DIR)/rustsbi-prototyper-$(f).bin
		$(INSTALL) -m 0644 -D $(@D)/target/riscv64imac-unknown-none-elf/release/rustsbi-prototyper-$(f).elf \
			$(BINARIES_DIR)/rustsbi-prototyper-$(f).elf
		$(INSTALL) -m 0644 -D $(@D)/target/riscv64imac-unknown-none-elf/release/rustsbi-prototyper-$(f).bin \
			$(BINARIES_DIR)/fw_$(f).bin
	)
endef

# `cargo-package` will try to update Cargo.toml and it will make target to TARGET_NAME,
# but we want to compile xtask to HOST_NAME.
$(eval $(generic-package))
