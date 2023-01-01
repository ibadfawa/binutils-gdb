## See sim/Makefile.am.
##
## Copyright (C) 1997-2023 Free Software Foundation, Inc.
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Parts of the common/ sim code that have been unified.
## Most still lives in common/Make-common.in.

AM_CPPFLAGS += \
	-I$(srcdir)/%D% \
	-DSIM_COMMON_BUILD
AM_CPPFLAGS_FOR_BUILD += -I$(srcdir)/%D%

## This makes sure common parts are available before building the arch-subdirs
## which will refer to these.
SIM_ALL_RECURSIVE_DEPS += \
	%D%/libcommon.a

## NB: libcommon.a isn't used directly by ports.  We need a target for common
## objects to be a part of, and ports use the individual objects directly.
SIM_COMMON_LIB = %D%/libcommon.a
noinst_LIBRARIES += $(SIM_COMMON_LIB)
%C%_libcommon_a_SOURCES = \
	%D%/callback.c \
	%D%/portability.c \
	%D%/sim-load.c \
	%D%/syscall.c \
	%D%/target-newlib-errno.c \
	%D%/target-newlib-open.c \
	%D%/target-newlib-signal.c \
	%D%/target-newlib-syscall.c \
	%D%/version.c

%D%/version.c: %D%/version.c-stamp ; @true
%D%/version.c-stamp: $(srcroot)/gdb/version.in $(srcroot)/bfd/version.h $(srcdir)/%D%/create-version.sh
	$(AM_V_GEN)$(SHELL) $(srcdir)/%D%/create-version.sh $(srcroot)/gdb $@.tmp
	$(AM_V_at)$(SHELL) $(srcroot)/move-if-change $@.tmp $(@:-stamp=)
	$(AM_V_at)touch $@

CLEANFILES += \
	%D%/version.c %D%/version.c-stamp

##
## For subdirs.
##

SIM_COMMON_HW_OBJS = \
	hw-alloc.o \
	hw-base.o \
	hw-device.o \
	hw-events.o \
	hw-handles.o \
	hw-instances.o \
	hw-ports.o \
	hw-properties.o \
	hw-tree.o \
	sim-hw.o

SIM_NEW_COMMON_OBJS = \
	sim-arange.o \
	sim-bits.o \
	sim-close.o \
	sim-command.o \
	sim-config.o \
	sim-core.o \
	sim-cpu.o \
	sim-endian.o \
	sim-engine.o \
	sim-events.o \
	sim-fpu.o \
	sim-hload.o \
	sim-hrw.o \
	sim-io.o \
	sim-info.o \
	sim-memopt.o \
	sim-model.o \
	sim-module.o \
	sim-options.o \
	sim-profile.o \
	sim-reason.o \
	sim-reg.o \
	sim-signal.o \
	sim-stop.o \
	sim-syscall.o \
	sim-trace.o \
	sim-utils.o \
	sim-watch.o

AM_MAKEFLAGS += SIM_NEW_COMMON_OBJS_="$(SIM_NEW_COMMON_OBJS)"

SIM_HW_DEVICES = cfi core pal glue

if SIM_ENABLE_HW
SIM_NEW_COMMON_OBJS += \
	$(SIM_COMMON_HW_OBJS) \
	$(SIM_HW_SOCKSER)

AM_MAKEFLAGS += SIM_HW_DEVICES_="$(SIM_HW_DEVICES)"
endif

# FIXME This is one very simple-minded way of generating the file hw-config.h.
%/hw-config.h: %/stamp-hw ; @true
%/stamp-hw: Makefile
	$(AM_V_GEN)set -e; \
	( \
	sim_hw="$(SIM_HW_DEVICES) $($(@D)_SIM_EXTRA_HW_DEVICES)" ; \
	echo "/* generated by Makefile */" ; \
	printf "extern const struct hw_descriptor dv_%s_descriptor[];\n" $$sim_hw ; \
	echo "const struct hw_descriptor * const hw_descriptors[] = {" ; \
	printf "  dv_%s_descriptor,\n" $$sim_hw ; \
	echo "  NULL," ; \
	echo "};" \
	) > $@.tmp; \
	$(SHELL) $(srcroot)/move-if-change $@.tmp $(@D)/hw-config.h; \
	touch $@
.PRECIOUS: %/stamp-hw

%C%_HW_CONFIG_H_TARGETS = $(patsubst %,%/hw-config.h,$(SIM_ENABLED_ARCHES))
MOSTLYCLEANFILES += $(%C%_HW_CONFIG_H_TARGETS) $(patsubst %,%/stamp-hw,$(SIM_ENABLED_ARCHES))
SIM_ALL_RECURSIVE_DEPS += $(%C%_HW_CONFIG_H_TARGETS)

LIBIBERTY_LIB = ../libiberty/libiberty.a
BFD_LIB = ../bfd/libbfd.la
OPCODES_LIB = ../opcodes/libopcodes.la

SIM_COMMON_LIBS = \
	$(SIM_COMMON_LIB) \
	$(BFD_LIB) \
	$(OPCODES_LIB) \
	$(LIBIBERTY_LIB) \
	$(LIBGNU) \
	$(LIBGNU_EXTRA_LIBS)
