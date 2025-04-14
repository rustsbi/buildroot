################################################################################
#
# rustup-bin
#
################################################################################

RUSTUP_BIN_VERSION = latest
RUSTUP_BIN_SITE = https://static.rust-lang.org/rustup/dist/$(RUSTC_HOST_NAME)
RUSTUP_BIN_LICENSE = Apache-2.0 or MIT
RUSTUP_BIN_LICENSE_FILES = LICENSE-APACHE LICENSE-MIT

HOST_RUSTUP_BIN_PROVIDES = host-rustc

HOST_RUSTUP_BIN_SOURCE = rustup-init

define HOST_RUSTUP_BIN_EXTRACT_CMDS 
	mkdir -p $(@D);
	cd $(HOST_RUSTUP_BIN_DL_DIR) && cp rustup-init $(@D)/;
	(cd $(@D); chmod +x ./rustup-init)
endef

HOST_RUSTUP_BIN_ENV_RUSTUP_HOME=$(HOST_DIR)/rustup
# Use CARGO_HOME set in package/pkg-cargo.mk
HOST_RUSTUP_BIN_ENV_CARGO_HOME=$(DL_DIR)/br-cargo-home

define HOST_RUSTUP_BIN_PRE
	source $(HOST_RUSTUP_BIN_ENV_CARGO_HOME)/env
endef

define HOST_RUSTUP_BIN_ENV
	RUSTUP_HOME=$(HOST_RUSTUP_BIN_ENV_RUSTUP_HOME) CARGO_HOME=$(HOST_RUSTUP_BIN_ENV_CARGO_HOME)
endef

ifeq ($(BR2_PACKAGE_HOST_RUSTC_TARGET_ARCH_SUPPORTS),y)
define HOST_RUSTUP_INSTALL_TARGET
	($(call HOST_RUSTUP_BIN_PRE) && $(HOST_RUSTUP_BIN_ENV) rustup target add $(RUSTC_TARGET_NAME))
endef
else
define HOST_RUSTUP_INSTALL_TARGET
	echo "Target is not support by rust"
endef
endif

define HOST_RUSTUP_BIN_INSTALL_CMDS
	(cd $(@D); $(HOST_RUSTUP_BIN_ENV) ./rustup-init -y --no-modify-path)
	($(call HOST_RUSTUP_INSTALL_TARGET))
	($(call HOST_RUSTUP_BIN_PRE) && $(HOST_RUSTUP_BIN_ENV) rustup default stable)
endef

HOST_RUSTUP_BIN_POST_INSTALL_HOOKS += HOST_RUSTUP_INSTALL_CARGO_CONFIG

$(eval $(host-generic-package))
