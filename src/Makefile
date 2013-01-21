#
# CORSIS PortFusion -S[nowfall
# Copyright © 2013  Cetin Sert
#

#
# PortFusion/C Makefile
#

#############################################

# Source and Binary File Names

SRC     = pf.c
BINDEF  = pfl

ifeq (,$(BIN))
  BIN   = $(BINDEF)
endif

CFLAGS += -Wall -Wextra


#############################################

# CORSIS Build Name Components

OS     := $(shell uname -s)
ARCH   := $(shell uname -m)
CFLAGS += -D__OS__="\"$(OS)\""
CFLAGS += -D__ARCH__="\"$(ARCH)\""
DIST    = $(BIN)-$(OS)-$(ARCH)$(SUFFIX)

ifeq (,$(findstring mips, $(ARCH)))
  f    += llvm
endif


#############################################

# CORSIS Compilation Flags

f += $(F)

ifeq (,$(findstring mips, $(ARCH)))
  f       += llvm
endif

ifneq (,$(findstring static, $(f)))
  LDFLAGS += -static
  SUFFIX  += -static
endif

ifneq (,$(findstring llvm, $(f)))
  CC       = clang
else
  CC       = gcc
endif
ifneq (,$(findstring gcc, $(f)))
  CC       = gcc
endif

ifneq (,$(findstring debug, $(f)))
  CFLAGS  += -g
else
  CFLAGS  += -O3
endif
ifeq (,$(findstring portable-loops, $(f)))
  CFLAGS  += -DUSE_LINUX_SPLICE
endif
ifeq (,$(findstring portable-threads, $(f)))
  CFLAGS  += -DUSE_POSIX_THREADS
  LDFLAGS += -pthread
endif


#############################################

# Targets

$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	-ls -l $@
	-strip $@
	-ls -l $@

$(DIST): $(BIN)
	cp $< $@

.PHONY: clean dist clean-dist
dist: $(DIST)
clean:
	-rm $(BIN)

clean-dist:
	-rm $(BIN) $(DIST)*
