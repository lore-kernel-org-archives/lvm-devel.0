From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Oct 2009 19:10:43 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20091002191043.13860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-02 19:10:38

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	                 make.tmpl.in 
	daemons        : Makefile.in 
	daemons/clvmd  : Makefile.in 
	daemons/cmirrord: Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	doc            : Makefile.in 
	include        : Makefile.in 
	lib            : Makefile.in 
	lib/format1    : Makefile.in 
	lib/format_pool: Makefile.in 
	lib/locking    : Makefile.in 
	lib/mirror     : Makefile.in 
	lib/snapshot   : Makefile.in 
	libdm          : Makefile.in 
	liblvm         : Makefile.in 
	man            : Makefile.in 
	old-tests/device: Makefile.in 
	old-tests/filters: Makefile.in 
	old-tests/format1: Makefile.in 
	old-tests/mm   : Makefile.in 
	old-tests/regex: Makefile.in 
	po             : Makefile.in 
	scripts        : Makefile.in 
	test/api       : Makefile.in 
	tools          : Makefile.in 
	udev           : Makefile.in 
Added files:
	include        : .symlinks.in 
Removed files:
	include        : .symlinks 

Log message:
	Allow for a build directory separate from the source.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1287&r2=1.1288
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.60&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/device/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/filters/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/mm/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/Makefile.in	2009/10/02 11:35:25	1.41
+++ LVM2/Makefile.in	2009/10/02 19:10:31	1.42
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SUBDIRS = doc include man scripts
--- LVM2/WHATS_NEW	2009/10/02 11:41:54	1.1287
+++ LVM2/WHATS_NEW	2009/10/02 19:10:31	1.1288
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Allow for a build directory separate from the source.
   Update distclean target for rename clogd to cmirrord. (2.02.52)
   Only do lock conversions in clvmd if we are explicitly asked for one.
   Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
--- LVM2/configure	2009/09/28 21:23:02	1.108
+++ LVM2/configure	2009/10/02 19:10:31	1.109
@@ -15419,18 +15419,18 @@
 $as_echo "$interface" >&6; }
 
 ################################################################################
-DM_LIB_VERSION="\"`cat VERSION_DM 2>/dev/null || echo Unknown`\""
+DM_LIB_VERSION="\"`cat "$srcdir"/VERSION_DM 2>/dev/null || echo Unknown`\""
 
 cat >>confdefs.h <<_ACEOF
 #define DM_LIB_VERSION $DM_LIB_VERSION
 _ACEOF
 
 
-DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
-LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM_VERSION="\"`cat "$srcdir"/VERSION 2>/dev/null || echo Unknown`\""
 
-VER=`cat VERSION`
+VER=`cat "$srcdir"/VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
@@ -15525,7 +15525,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16135,6 +16135,7 @@
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
+    "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
--- LVM2/configure.in	2009/09/28 21:23:02	1.116
+++ LVM2/configure.in	2009/10/02 19:10:32	1.117
@@ -1040,14 +1040,14 @@
 AC_MSG_RESULT($interface)
 
 ################################################################################
-DM_LIB_VERSION="\"`cat VERSION_DM 2>/dev/null || echo Unknown`\""
+DM_LIB_VERSION="\"`cat "$srcdir"/VERSION_DM 2>/dev/null || echo Unknown`\""
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 
-DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
-LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
+LVM_VERSION="\"`cat "$srcdir"/VERSION 2>/dev/null || echo Unknown`\""
 
-VER=`cat VERSION`
+VER=`cat "$srcdir"/VERSION`
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
@@ -1156,6 +1156,7 @@
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 doc/Makefile
+include/.symlinks
 include/Makefile
 lib/Makefile
 lib/format1/Makefile
--- LVM2/make.tmpl.in	2009/09/11 15:52:22	1.71
+++ LVM2/make.tmpl.in	2009/10/02 19:10:32	1.72
@@ -85,12 +85,12 @@
   DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
 endif
 
-LDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
-CLDFLAGS += -L$(top_srcdir)/libdm -L$(top_srcdir)/lib
+LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
+CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 
 ifeq ("@DMEVENTD@", "yes")
-  LDFLAGS += -L$(top_srcdir)/daemons/dmeventd
-  CLDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+  LDFLAGS += -L$(top_builddir)/daemons/dmeventd
+  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
 
 ifeq ("@DM_COMPAT@", "yes")
@@ -121,11 +121,12 @@
 LIB_VERSION_APP := $(shell cat $(top_srcdir)/VERSION | \
 		     awk -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
 
-INCLUDES += -I. -I$(top_srcdir)/include
+INCLUDES += -I. -I$(top_builddir)/include
 
-INC_LNS = $(top_srcdir)/include/.symlinks_created
+INC_LNS = $(top_builddir)/include/.symlinks_created
 
-DEPS = $(top_srcdir)/make.tmpl $(top_srcdir)/VERSION Makefile $(INC_LNS)
+DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
+       $(top_builddir)/Makefile $(INC_LNS)
 
 OBJECTS = $(SOURCES:%.c=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -227,11 +228,12 @@
 	$(AR) rs $@ $(OBJECTS)
 
 %.d: %.c
+	$(MKDIR_P) $(dir $@); \
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(DEFS) $(CFLAGS) $< | \
-	sed "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" > $@; \
+	$(CC) -MM $(INCLUDES) $(DEFS) $(CFLAGS) -o $@ $<; \
+	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
 	[ -s $@ ] || $(RM) $@
 
 %.mo: %.po
--- LVM2/daemons/Makefile.in	2009/09/02 17:36:46	1.11
+++ LVM2/daemons/Makefile.in	2009/10/02 19:10:32	1.12
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 .PHONY: dmeventd clvmd cmirrord
@@ -29,7 +30,7 @@
   SUBDIRS += dmeventd
 endif
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
--- LVM2/daemons/clvmd/Makefile.in	2009/08/28 19:22:05	1.30
+++ LVM2/daemons/clvmd/Makefile.in	2009/10/02 19:10:32	1.31
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 CCS_LIBS = @CCS_LIBS@
@@ -85,12 +86,12 @@
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 INSTALL_TARGETS = \
 	install_clvmd
 
-clvmd: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
+clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) -o clvmd $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
--- LVM2/daemons/cmirrord/Makefile.in	2009/09/14 22:57:46	1.3
+++ LVM2/daemons/cmirrord/Makefile.in	2009/10/02 19:10:32	1.4
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 CPG_LIBS = @CPG_LIBS@
@@ -24,13 +25,13 @@
 
 TARGETS = cmirrord
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
-cmirrord: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
+cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 	$(CC) -o cmirrord $(OBJECTS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
--- LVM2/daemons/dmeventd/Makefile.in	2009/05/11 10:12:35	1.25
+++ LVM2/daemons/dmeventd/Makefile.in	2009/10/02 19:10:32	1.26
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES = libdevmapper-event.c
@@ -36,7 +37,7 @@
   SUBDIRS+=plugins
 endif
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 all: dmeventd
 device-mapper: dmeventd $(LIB_STATIC)
@@ -66,7 +67,7 @@
 install_device-mapper: $(INSTALL_TYPE) install_include install_dmeventd
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.h \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
 
 install_dynamic: libdevmapper-event.$(LIB_SUFFIX)
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2008/01/09 15:32:19	1.3
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2009/10/02 19:10:33	1.4
@@ -14,9 +14,10 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SUBDIRS += mirror snapshot
 
-include $(top_srcdir)/make.tmpl
+include ../../../make.tmpl
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/05/11 10:28:46	1.9
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/02 19:10:33	1.10
@@ -14,10 +14,11 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper @LVM2CMD_LIB@
+CLDFLAGS += -L${top_builddir}/tools -ldevmapper @LVM2CMD_LIB@
 
 SOURCES = dmeventd_mirror.c
 
@@ -29,7 +30,7 @@
 
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include $(top_builddir)/make.tmpl
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/05/11 10:28:46	1.5
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/02 19:10:33	1.6
@@ -14,10 +14,11 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper @LVM2CMD_LIB@
+CLDFLAGS += -L${top_builddir}/tools -ldevmapper @LVM2CMD_LIB@
 
 SOURCES = dmeventd_snapshot.c
 
@@ -29,7 +30,7 @@
 
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include $(top_builddir)/make.tmpl
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/doc/Makefile.in	2009/05/11 10:28:46	1.5
+++ LVM2/doc/Makefile.in	2009/10/02 19:10:33	1.6
@@ -13,17 +13,18 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 CONFSRC=example.conf
 CONFDEST=lvm.conf
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
-install_lvm2:
+install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
-		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $(CONFSRC) \
+		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $< \
 			$(confdir)/$(CONFDEST); \
 	fi
 
/cvs/lvm2/LVM2/include/.symlinks.in,v  -->  standard output
revision 1.1
--- LVM2/include/.symlinks.in
+++ -	2009-10-02 19:10:40.280856000 +0000
@@ -0,0 +1,61 @@
+ at top_srcdir@/daemons/clvmd/clvm.h
+ at top_srcdir@/daemons/dmeventd/libdevmapper-event.h
+ at top_srcdir@/liblvm/lvm2app.h
+ at top_srcdir@/lib/activate/activate.h
+ at top_srcdir@/lib/activate/targets.h
+ at top_srcdir@/lib/cache/lvmcache.h
+ at top_srcdir@/lib/commands/errors.h
+ at top_srcdir@/lib/commands/toolcontext.h
+ at top_srcdir@/lib/config/config.h
+ at top_srcdir@/lib/config/defaults.h
+ at top_srcdir@/lib/datastruct/btree.h
+ at top_srcdir@/lib/datastruct/lvm-types.h
+ at top_srcdir@/lib/datastruct/str_list.h
+ at top_srcdir@/lib/device/dev-cache.h
+ at top_srcdir@/lib/device/device.h
+ at top_srcdir@/lib/display/display.h
+ at top_srcdir@/lib/filters/filter-composite.h
+ at top_srcdir@/lib/filters/filter-md.h
+ at top_srcdir@/lib/filters/filter-persistent.h
+ at top_srcdir@/lib/filters/filter-regex.h
+ at top_srcdir@/lib/filters/filter-sysfs.h
+ at top_srcdir@/lib/filters/filter.h
+ at top_srcdir@/lib/format1/format1.h
+ at top_srcdir@/lib/format_pool/format_pool.h
+ at top_srcdir@/lib/format_text/archiver.h
+ at top_srcdir@/lib/format_text/format-text.h
+ at top_srcdir@/lib/format_text/text_export.h
+ at top_srcdir@/lib/format_text/text_import.h
+ at top_srcdir@/lib/label/label.h
+ at top_srcdir@/lib/locking/locking.h
+ at top_srcdir@/lib/log/log.h
+ at top_srcdir@/lib/log/lvm-logging.h
+ at top_srcdir@/lib/metadata/lv_alloc.h
+ at top_srcdir@/lib/metadata/metadata.h
+ at top_srcdir@/lib/metadata/metadata-exported.h
+ at top_srcdir@/lib/metadata/pv_alloc.h
+ at top_srcdir@/lib/metadata/segtype.h
+ at top_srcdir@/lib/mm/memlock.h
+ at top_srcdir@/lib/mm/xlate.h
+ at top_builddir@/lib/misc/configure.h
+ at top_srcdir@/lib/misc/crc.h
+ at top_srcdir@/lib/misc/intl.h
+ at top_srcdir@/lib/misc/util.h
+ at top_srcdir@/lib/misc/last-path-component.h
+ at top_srcdir@/lib/misc/lib.h
+ at top_srcdir@/lib/misc/lvm-exec.h
+ at top_srcdir@/lib/misc/lvm-file.h
+ at top_srcdir@/lib/misc/lvm-globals.h
+ at top_srcdir@/lib/misc/lvm-string.h
+ at top_builddir@/lib/misc/lvm-version.h
+ at top_srcdir@/lib/misc/lvm-wrappers.h
+ at top_srcdir@/lib/misc/sharedlib.h
+ at top_srcdir@/lib/report/report.h
+ at top_srcdir@/lib/uuid/uuid.h
+ at top_srcdir@/libdm/libdevmapper.h
+ at top_srcdir@/libdm/misc/dm-ioctl.h
+ at top_srcdir@/libdm/misc/dm-logging.h
+ at top_srcdir@/libdm/misc/dm-log-userspace.h
+ at top_srcdir@/libdm/misc/dmlib.h
+ at top_srcdir@/libdm/misc/kdev_t.h
+ at top_srcdir@/po/pogen.h
--- LVM2/include/Makefile.in	2009/05/11 10:28:46	1.11
+++ LVM2/include/Makefile.in	2009/10/02 19:10:34	1.12
@@ -16,6 +16,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 LN_S = @LN_S@
@@ -24,14 +25,14 @@
 
 all: .symlinks_created
 
-.symlinks_created: .symlinks
+.symlinks_created: .symlinks 
 	find . -maxdepth 1 -type l -exec $(RM) \{\} \;
-	for i in `cat .symlinks`; do $(LN_S) $$i ; done
+	for i in `cat $<`; do $(LN_S) $$i ; done
 	touch $@
 
 distclean:
 	find . -maxdepth 1 -type l -exec $(RM) \{\} \;
-	$(RM) Makefile .include_symlinks .symlinks_created
+	$(RM) Makefile .include_symlinks .symlinks_created .symlinks
 
 pofile: all
 
--- LVM2/lib/Makefile.in	2009/06/03 11:31:06	1.92
+++ LVM2/lib/Makefile.in	2009/10/02 19:10:34	1.93
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 ifeq ("@LVM1@", "shared")
@@ -145,7 +146,7 @@
 
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
 
--- LVM2/lib/format1/Makefile.in	2008/11/03 22:14:28	1.10
+++ LVM2/lib/format1/Makefile.in	2009/10/02 19:10:34	1.11
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
@@ -28,7 +29,7 @@
 LIB_SHARED = liblvm2format1.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 install: liblvm2format1.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/format_pool/Makefile.in	2008/11/03 22:14:28	1.6
+++ LVM2/lib/format_pool/Makefile.in	2009/10/02 19:10:35	1.7
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
@@ -25,7 +26,7 @@
 LIB_SHARED = liblvm2formatpool.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 install: liblvm2formatpool.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/locking/Makefile.in	2008/11/03 22:14:29	1.4
+++ LVM2/lib/locking/Makefile.in	2009/10/02 19:10:35	1.5
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES = cluster_locking.c
@@ -21,7 +22,7 @@
 LIB_SHARED = liblvm2clusterlock.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 install install_cluster: liblvm2clusterlock.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/mirror/Makefile.in	2008/11/03 22:14:29	1.5
+++ LVM2/lib/mirror/Makefile.in	2009/10/02 19:10:35	1.6
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES = mirrored.c
@@ -21,7 +22,7 @@
 LIB_SHARED = liblvm2mirror.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 install: liblvm2mirror.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/snapshot/Makefile.in	2008/11/03 22:14:29	1.5
+++ LVM2/lib/snapshot/Makefile.in	2009/10/02 19:10:35	1.6
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES = snapshot.c
@@ -21,7 +22,7 @@
 LIB_SHARED = liblvm2snapshot.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 install: liblvm2snapshot.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/libdm/Makefile.in	2009/04/08 14:04:35	1.45
+++ LVM2/libdm/Makefile.in	2009/10/02 19:10:36	1.46
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
@@ -32,7 +33,7 @@
 	regex/ttree.c \
 	$(interface)/libdm-iface.c
 
-INCLUDES = -I$(interface) -I.
+INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
@@ -72,7 +73,7 @@
 install_device-mapper: install
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.h \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper.h \
 		$(includedir)/libdevmapper.h
 
 install_dynamic: install_@interface@
--- LVM2/liblvm/Makefile.in	2009/09/14 22:56:27	1.16
+++ LVM2/liblvm/Makefile.in	2009/10/02 19:10:36	1.17
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
@@ -38,7 +39,7 @@
 
 CLEAN_TARGETS += liblvm.cflow
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 LIBS += -ldevmapper -llvm-internal
 
@@ -66,7 +67,7 @@
 install: $(INSTALL_TYPE) install_include
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2app.h $(includedir)/lvm2app.h
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
 
 install_dynamic: $(LIB_SHARED)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/man/Makefile.in	2009/05/14 16:46:13	1.27
+++ LVM2/man/Makefile.in	2009/10/02 19:10:36	1.28
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 ifeq ("@FSADM@", "yes")
@@ -38,7 +39,7 @@
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 ifneq ("@CLVMD@", "none")
   install: install_cluster
--- LVM2/old-tests/device/Makefile.in	2007/09/21 10:16:44	1.4
+++ LVM2/old-tests/device/Makefile.in	2009/10/02 19:10:36	1.5
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
@@ -21,7 +22,7 @@
 
 TARGETS=dev_cache_t
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 dev_cache_t: dev_cache_t.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o dev_cache_t dev_cache_t.o -L$(top_srcdir)/lib -llvm
--- LVM2/old-tests/filters/Makefile.in	2007/09/21 10:16:45	1.5
+++ LVM2/old-tests/filters/Makefile.in	2009/10/02 19:10:36	1.6
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
@@ -24,7 +25,7 @@
 	rfilter_t \
 	pfilter_t
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 rfilter_t: rfilter_t.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o rfilter_t rfilter_t.o -L$(top_srcdir)/lib -llvm
--- LVM2/old-tests/format1/Makefile.in	2007/09/21 10:16:45	1.9
+++ LVM2/old-tests/format1/Makefile.in	2009/10/02 19:10:37	1.10
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
@@ -31,7 +32,7 @@
 	read_pv_t \
 	get_vgs_t
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 read_vg_t: read_vg_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o read_vg_t read_vg_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
--- LVM2/old-tests/mm/Makefile.in	2007/09/21 10:16:45	1.6
+++ LVM2/old-tests/mm/Makefile.in	2009/10/02 19:10:37	1.7
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
@@ -21,7 +22,7 @@
 
 TARGETS=dbg_malloc_t
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 dbg_malloc_t: dbg_malloc_t.o
 	$(CC) $(CFLAGS) -o dbg_malloc_t dbg_malloc_t.o \
--- LVM2/old-tests/regex/Makefile.in	2007/09/21 10:16:45	1.4
+++ LVM2/old-tests/regex/Makefile.in	2009/10/02 19:10:37	1.5
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
@@ -24,7 +25,7 @@
 	parse_t \
 	matcher_t
 
-include $(top_srcdir)/make.tmpl
+include ../../make.tmpl
 
 parse_t: parse_t.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o parse_t parse_t.o -L$(top_srcdir)/lib -llvm
--- LVM2/po/Makefile.in	2008/11/01 02:19:18	1.6
+++ LVM2/po/Makefile.in	2009/10/02 19:10:37	1.7
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 LANGS=de
@@ -24,7 +25,7 @@
 
 LVM_POSOURCES = $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 lvm2.po: Makefile $(LVM_POSOURCES)
 	@echo Compiling string table
--- LVM2/scripts/Makefile.in	2009/09/16 23:22:40	1.10
+++ LVM2/scripts/Makefile.in	2009/10/02 19:10:37	1.11
@@ -13,17 +13,18 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 install:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
 		$(sbindir)/lvmdump
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) vgimportclone.sh \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/vgimportclone.sh \
 		$(sbindir)/vgimportclone
 ifeq ("@FSADM@", "yes")
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm.sh \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/fsadm.sh \
 		$(sbindir)/fsadm
 endif
 
--- LVM2/test/api/Makefile.in	2009/09/14 22:56:27	1.9
+++ LVM2/test/api/Makefile.in	2009/10/02 19:10:38	1.10
@@ -13,6 +13,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 ifeq ("@DEBUG@", "yes")
@@ -22,7 +23,7 @@
 TARGETS = vgtest
 test_SOURCES = test.c
 vgtest_SOURCES = vgtest.c
-INCLUDES += -I${top_srcdir}/include
+INCLUDES += -I../../include
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 DEPLIBS = $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
--- LVM2/tools/Makefile.in	2009/09/11 15:52:23	1.99
+++ LVM2/tools/Makefile.in	2009/10/02 19:10:38	1.100
@@ -14,6 +14,7 @@
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
@@ -104,13 +105,13 @@
 
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 device-mapper: $(TARGETS_DM)
 
-dmsetup: dmsetup.o $(top_srcdir)/libdm/libdevmapper.$(LIB_SUFFIX)
+dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
-	      -L$(top_srcdir)/libdm -ldevmapper $(LIBS)
+	      -L$(top_builddir)/libdm -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) -static \
@@ -119,27 +120,27 @@
 
 all: device-mapper
 
-lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm-internal.a
+lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
 		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 LIB_PTHREAD = @LIB_PTHREAD@
-lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
+lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
 		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
-liblvm2cmd.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
-	cat $(top_srcdir)/lib/liblvm-internal.a > $@
+liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
+	cat $(top_builddir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 
-liblvm2cmd-static.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
-	cat $(top_srcdir)/lib/liblvm-internal.a > $@
+liblvm2cmd-static.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
+	cat $(top_builddir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 
 .commands: commands.h cmdnames.h Makefile
-	$(CC) -E -P cmdnames.h 2> /dev/null | \
+	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
 
 .PHONY: install_cmdlib_dynamic install_cmdlib_static \
@@ -163,17 +164,17 @@
 endif
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd.$(LIB_SUFFIX) \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd-static.a \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_tools_dynamic: lvm .commands
@@ -181,14 +182,14 @@
 		$(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@( \
-		for v in `cat .commands`; do \
+		for v in `cat $(srcdir)/.commands`; do \
 			cd $(sbindir); \
 			$(LN_S) -f lvm $$v; \
 		done; \
 	)
 
 install_tools_static: lvm.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm.static \
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(staticdir)/lvm.static
 
 install_dmsetup_dynamic: dmsetup
--- LVM2/udev/Makefile.in	2009/08/03 18:44:54	1.2
+++ LVM2/udev/Makefile.in	2009/10/02 19:10:38	1.3
@@ -11,9 +11,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-srcdir = .
-top_srcdir = ..
-
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+VPATH = @srcdir@
 
 DM_RULES=10-dm.rules 12-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-lvm.rules
@@ -21,7 +22,7 @@
 
 CLEAN_TARGETS=10-dm.rules
 
-include $(top_srcdir)/make.tmpl
+include ../make.tmpl
 
 %: %.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
@@ -31,7 +32,7 @@
 	@for f in $(LVM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install_device-mapper: $(DM_RULES)
@@ -39,7 +40,7 @@
 	@for f in $(DM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$f $(udevdir)/$$f; \
+	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper


