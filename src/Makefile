#
# CORSIS PortFusion -S[nowfall
# Copyright © 2013  Cetin Sert
#

#
# PortFusion/C Makefile
#

#############################################

# Source and Binary Files

SRC     = pf.c
BINDEF  = pf

ifeq (,$(BIN))
  BIN   = $(BINDEF)
endif


#############################################

# Default Compiler Flags

STRIP = True

ifneq (,$(findstring debug, $(f)))
  CFLAGS  += -g
  STRIP    =
else
  CFLAGS  += -O3
endif

CFLAGS += -Wall -Wextra


#############################################

# CORSIS Build Name Components

ifndef OS
  OS     := $(shell uname -s)
endif
ifndef ARCH
  ARCH   := $(shell uname -m)
endif

CFLAGS += -D__OS__="\"$(OS)\""
CFLAGS += -D__ARCH__="\"$(ARCH)\""
DIST    = $(BIN)-$(OS)-$(ARCH)$(SUFFIX)


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

ifeq  (,$(findstring scan, $(f)))
ifneq (,$(findstring llvm, $(f)))
  CC       = clang
else
  CC       = gcc
endif
ifneq (,$(findstring gcc, $(f)))
  CC       = gcc
endif
endif

ifeq (,$(findstring portable-threads, $(f)))
  CFLAGS  += -DUSE_POSIX_THREADS
  LDFLAGS += -pthread
endif
ifeq (,$(findstring portable-loops, $(f)))
  CFLAGS  += -DUSE_LINUX_SPLICE
endif
ifneq (,$(findstring linux-epoll, $(f)))
  CFLAGS  += -DUSE_LINUX_EPOLL
endif

ifneq (,$(findstring with-server, $(f)))
  CFLAGS  += -DBUILD_SERVER
endif


#############################################

# Static Recommendations

ifdef CHUNK
  CFLAGS += -DCHUNK=$(CHUNK)
endif


#############################################

# Targets

$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	-ls -l $@
ifdef STRIP
	-strip $@
	-ls -l $@
endif

$(DIST): $(BIN)
	cp $< $@

.PHONY: clean dist clean-dist
dist: $(DIST)
clean:
	-rm $(BIN)

clean-dist:
	-rm $(BIN) $(DIST)*
