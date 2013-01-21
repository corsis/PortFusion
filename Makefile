#
# CORSIS PortFusion -S[nowfall
# Copyright © 2013  Cetin Sert
#

#
# OpenWrt Package Makefile
#

include $(TOPDIR)/rules.mk

PKG_NAME:=PortFusion
PKG_RELEASE:=2013-01-21
PKG_LICENSE:=GPLv3.0
PKG_MAINTAINER:=Cetin Sert <fusion@corsis.eu>, Corsis Research

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/pfl
  SECTION:=corsis
  CATEGORY:=Corsis Research
  TITLE:=Corsis PortFusion Embedded
  DEPENDS=+libpthread
endef

define Package/pfl/description
  Corsis PortFusion for OpenWrt, developed for ke2therm.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/pfl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pfl $(1)/usr/bin/
endef

$(eval $(call BuildPackage,pfl))
