From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:51:45 -0000
Subject: LVM2 ./WHATS_NEW daemons/Makefile.in daemons/c ...
Message-ID: <20100304095145.22519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:51:42

Modified files:
	.              : WHATS_NEW 
	daemons        : Makefile.in 
	daemons/clvmd  : Makefile.in 
	daemons/cmirrord: Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins: Makefile.in 
	doc            : Makefile.in 
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
	tools          : Makefile.in 
	udev           : Makefile.in 

Log message:
	Use $(top_builddir) for inclusion of make.tmpl in Makefiles.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1444&r2=1.1445
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/device/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/filters/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/mm/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/03/04 09:48:19	1.1444
+++ LVM2/WHATS_NEW	2010/03/04 09:51:37	1.1445
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
   Fix autoconf warning about ignored datarootdir.
   Increase AC_PREREQ version to 2.61 (for AC_PROC_SED, AC_PROG_MKDIR_P).
   Handle a misaligned device that reports a -1 alignment_offset.
--- LVM2/daemons/Makefile.in	2009/10/02 19:10:32	1.12
+++ LVM2/daemons/Makefile.in	2010/03/04 09:51:37	1.13
@@ -30,7 +30,7 @@
   SUBDIRS += dmeventd
 endif
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
--- LVM2/daemons/clvmd/Makefile.in	2009/10/05 13:46:00	1.32
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/04 09:51:37	1.33
@@ -86,7 +86,7 @@
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 INSTALL_TARGETS = \
 	install_clvmd
--- LVM2/daemons/cmirrord/Makefile.in	2010/01/15 19:49:36	1.6
+++ LVM2/daemons/cmirrord/Makefile.in	2010/03/04 09:51:38	1.7
@@ -25,7 +25,7 @@
 
 TARGETS = cmirrord
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
--- LVM2/daemons/dmeventd/Makefile.in	2010/01/19 01:10:47	1.31
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/04 09:51:38	1.32
@@ -48,7 +48,7 @@
   SUBDIRS+=plugins
 endif
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 all: device-mapper
 device-mapper: $(TARGETS)
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2010/02/02 14:03:51	1.6
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2010/03/04 09:51:38	1.7
@@ -19,7 +19,7 @@
 
 SUBDIRS += lvm2 mirror snapshot
 
-include ../../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 mirror: lvm2
 snapshot: lvm2
--- LVM2/doc/Makefile.in	2009/10/02 19:10:33	1.6
+++ LVM2/doc/Makefile.in	2010/03/04 09:51:38	1.7
@@ -19,7 +19,7 @@
 CONFSRC=example.conf
 CONFDEST=lvm.conf
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
--- LVM2/lib/Makefile.in	2009/10/16 17:41:50	1.96
+++ LVM2/lib/Makefile.in	2010/03/04 09:51:39	1.97
@@ -143,7 +143,7 @@
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-  CLDFLAGS += -L../daemons/dmeventd
+  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
   LIBS += -ldevmapper-event
 endif
 
@@ -152,7 +152,7 @@
 
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
 
--- LVM2/lib/format1/Makefile.in	2009/10/02 19:10:34	1.11
+++ LVM2/lib/format1/Makefile.in	2010/03/04 09:51:39	1.12
@@ -29,7 +29,7 @@
 LIB_SHARED = liblvm2format1.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2format1.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/format_pool/Makefile.in	2009/10/02 19:10:35	1.7
+++ LVM2/lib/format_pool/Makefile.in	2010/03/04 09:51:39	1.8
@@ -26,7 +26,7 @@
 LIB_SHARED = liblvm2formatpool.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2formatpool.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/locking/Makefile.in	2009/10/02 19:10:35	1.5
+++ LVM2/lib/locking/Makefile.in	2010/03/04 09:51:39	1.6
@@ -22,7 +22,7 @@
 LIB_SHARED = liblvm2clusterlock.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install install_cluster: liblvm2clusterlock.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/mirror/Makefile.in	2009/10/02 19:10:35	1.6
+++ LVM2/lib/mirror/Makefile.in	2010/03/04 09:51:39	1.7
@@ -22,7 +22,7 @@
 LIB_SHARED = liblvm2mirror.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2mirror.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/lib/snapshot/Makefile.in	2009/10/02 19:10:35	1.6
+++ LVM2/lib/snapshot/Makefile.in	2010/03/04 09:51:40	1.7
@@ -22,7 +22,7 @@
 LIB_SHARED = liblvm2snapshot.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2snapshot.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
--- LVM2/libdm/Makefile.in	2009/10/02 19:10:36	1.46
+++ LVM2/libdm/Makefile.in	2010/03/04 09:51:40	1.47
@@ -50,7 +50,7 @@
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 device-mapper: all
 
--- LVM2/liblvm/Makefile.in	2010/02/24 18:16:10	1.18
+++ LVM2/liblvm/Makefile.in	2010/03/04 09:51:40	1.19
@@ -40,7 +40,7 @@
 
 CLEAN_TARGETS += liblvm.cflow
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper -llvm-internal
 
--- LVM2/man/Makefile.in	2010/01/19 02:04:34	1.30
+++ LVM2/man/Makefile.in	2010/03/04 09:51:40	1.31
@@ -48,7 +48,7 @@
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 ifneq ("@CLVMD@", "none")
   install: install_cluster
--- LVM2/old-tests/device/Makefile.in	2009/10/02 19:10:36	1.5
+++ LVM2/old-tests/device/Makefile.in	2010/03/04 09:51:40	1.6
@@ -22,8 +22,8 @@
 
 TARGETS=dev_cache_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 dev_cache_t: dev_cache_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o dev_cache_t dev_cache_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o dev_cache_t dev_cache_t.o -L$(top_builddir)/lib -llvm
 
--- LVM2/old-tests/filters/Makefile.in	2009/10/02 19:10:36	1.6
+++ LVM2/old-tests/filters/Makefile.in	2010/03/04 09:51:41	1.7
@@ -25,11 +25,11 @@
 	rfilter_t \
 	pfilter_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 rfilter_t: rfilter_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o rfilter_t rfilter_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o rfilter_t rfilter_t.o -L$(top_builddir)/lib -llvm
 
 pfilter_t: pfilter_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o pfilter_t pfilter_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o pfilter_t pfilter_t.o -L$(top_builddir)/lib -llvm
 
--- LVM2/old-tests/format1/Makefile.in	2009/10/02 19:10:37	1.10
+++ LVM2/old-tests/format1/Makefile.in	2010/03/04 09:51:41	1.11
@@ -32,21 +32,21 @@
 	read_pv_t \
 	get_vgs_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
-read_vg_t: read_vg_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o read_vg_t read_vg_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+read_vg_t: read_vg_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o read_vg_t read_vg_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-write_vg_t: write_vg_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
+write_vg_t: write_vg_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
 	$(CC) -o write_vg_t write_vg_t.o pretty_print.o \
-	-L$(top_srcdir)/lib -llvm
+	-L$(top_builddir)/lib -llvm
 
-get_pvs_t: get_pvs_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o get_pvs_t get_pvs_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+get_pvs_t: get_pvs_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o get_pvs_t get_pvs_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-read_pv_t: read_pv_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o read_pv_t read_pv_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+read_pv_t: read_pv_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o read_pv_t read_pv_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-get_vgs_t: get_vgs_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o get_vgs_t get_vgs_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+get_vgs_t: get_vgs_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o get_vgs_t get_vgs_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
--- LVM2/old-tests/mm/Makefile.in	2009/10/02 19:10:37	1.7
+++ LVM2/old-tests/mm/Makefile.in	2010/03/04 09:51:41	1.8
@@ -22,12 +22,12 @@
 
 TARGETS=dbg_malloc_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 dbg_malloc_t: dbg_malloc_t.o
 	$(CC) $(CFLAGS) -o dbg_malloc_t dbg_malloc_t.o \
-		-L$(top_srcdir)/lib -llvm
+		-L$(top_builddir)/lib -llvm
 
 pool_t: pool_t.o
-	$(CC) $(CFLAGS) -o pool_t pool_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) $(CFLAGS) -o pool_t pool_t.o -L$(top_builddir)/lib -llvm
 
--- LVM2/old-tests/regex/Makefile.in	2009/10/02 19:10:37	1.5
+++ LVM2/old-tests/regex/Makefile.in	2010/03/04 09:51:41	1.6
@@ -25,11 +25,11 @@
 	parse_t \
 	matcher_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
-parse_t: parse_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o parse_t parse_t.o -L$(top_srcdir)/lib -llvm
+parse_t: parse_t.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o parse_t parse_t.o -L$(top_builddir)/lib -llvm
 
-matcher_t: matcher_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o matcher_t matcher_t.o -L$(top_srcdir)/lib -llvm
+matcher_t: matcher_t.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o matcher_t matcher_t.o -L$(top_builddir)/lib -llvm
 
--- LVM2/po/Makefile.in	2009/10/02 19:10:37	1.7
+++ LVM2/po/Makefile.in	2010/03/04 09:51:41	1.8
@@ -25,7 +25,7 @@
 
 LVM_POSOURCES = $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 lvm2.po: Makefile $(LVM_POSOURCES)
 	@echo Compiling string table
--- LVM2/scripts/Makefile.in	2010/01/19 02:04:35	1.12
+++ LVM2/scripts/Makefile.in	2010/03/04 09:51:41	1.13
@@ -16,7 +16,7 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
--- LVM2/tools/Makefile.in	2010/01/19 01:10:47	1.103
+++ LVM2/tools/Makefile.in	2010/03/04 09:51:42	1.104
@@ -107,7 +107,7 @@
 
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 device-mapper: $(TARGETS_DM)
 
--- LVM2/udev/Makefile.in	2009/10/26 14:29:34	1.4
+++ LVM2/udev/Makefile.in	2010/03/04 09:51:42	1.5
@@ -22,7 +22,7 @@
 
 CLEAN_TARGETS=10-dm.rules
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 %: %.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@


