#
# CORSIS PortFusion -S[nowfall
# Copyright © 2013  Cetin Sert
#

#
# OpenWrt Package Makefile
#

include $(TOPDIR)/rules.mk

ARCH=$(TARGET_ARCH)
PKG_NAME:=PortFusion
PKG_RELEASE:=2013-01-21
PKG_LICENSE:=GPLv3.0
PKG_MAINTAINER:=Cetin Sert <fusion@corsis.eu>, Corsis Research

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/pf
  SECTION:=corsis
  CATEGORY:=Corsis Research
  TITLE:=CORSIS PortFusion Embedded
  URL:=http://fusion.corsis.eu
  MAINTAINER:=Cetin Sert <fusion@corsis.eu>, Corsis Research
  DEPENDS:=+libpthread
endef

define Package/pf/description
  CORSIS PortFusion Embedded Packaged for OpenWrt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	OS=OpenWrt ARCH=$(LINUX_KARCH) $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/pf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pf $(1)/usr/bin/
endef

$(eval $(call BuildPackage,pf))
