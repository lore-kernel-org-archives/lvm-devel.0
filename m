From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:18:03 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./make.tmpl.in ...
Message-ID: <20100329141803.21178.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:18:01

Modified files:
	.              : Makefile.in WHATS_NEW make.tmpl.in 
	daemons/clvmd  : Makefile.in 
	daemons/dmeventd: Makefile.in 
	lib            : Makefile.in 
	libdm          : Makefile.in 
	man            : Makefile.in 
	test           : Makefile.in 
	tools          : Makefile.in 

Log message:
	Fixing another set of distclean problems where we left some generated files
	in clvmd, dmevend, man, tests.
	
	Don't include dependency files for clow and cscope.out targets
	
	Improve dependency tracking for dmeventd and liblvm2cmd sources.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1485&r2=1.1486
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/Makefile.in	2010/03/29 14:11:17	1.46
+++ LVM2/Makefile.in	2010/03/29 14:17:59	1.47
@@ -34,12 +34,9 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS += liblvm \
-	     udev \
-	     test/api \
-	     test \
-	     po
-  DISTCLEAN_TARGETS += lib/misc/configure.h lib/misc/lvm-version.h
+  SUBDIRS = doc include man scripts \
+    lib tools daemons libdm \
+    udev po liblvm test/api test
   DISTCLEAN_DIRS += lcov_reports*
 endif
 
--- LVM2/WHATS_NEW	2010/03/26 22:15:43	1.1485
+++ LVM2/WHATS_NEW	2010/03/29 14:17:59	1.1486
@@ -1,5 +1,7 @@
 Version 2.02.63 -  
 ================================
+  Improved dependency tracking for dmeventd and liblvm2cmd sources.
+  Improved Makefile rules for distclean and cflow targets.
   Add ability to create mirrored logs for mirror LVs.
   Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
   Fix clvmd cluster propagation of dmeventd monitoring mode.
--- LVM2/make.tmpl.in	2010/03/29 14:11:17	1.85
+++ LVM2/make.tmpl.in	2010/03/29 14:18:00	1.86
@@ -301,12 +301,12 @@
 	$(MSGFMT) -o $@ $<
 
 clean: $(SUBDIRS.clean)
-	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
-	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
-	      $(SOURCES:%.c=%.gcda) $(LDDEPS) $(CLEAN_CFLOW)
+	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
+	$(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
+	$(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda)
 
 distclean: clean $(SUBDIRS.distclean)
-	$(RM) -rf $(DISTCLEAN_DIRS)
+	$(RM) -r $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS)  \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
@@ -317,15 +317,11 @@
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
-ifneq ($(MAKECMDGOALS),cflow)
-ifneq ($(MAKECMDGOALS),clean)
-  ifneq ($(MAKECMDGOALS),distclean)
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean))
     ifdef SOURCES
        -include $(SOURCES:.c=.d)
     endif
     ifdef SOURCES2
        -include $(SOURCES2:.c=.d)
     endif
-  endif
-endif
 endif
--- LVM2/daemons/clvmd/Makefile.in	2010/03/18 09:19:31	1.37
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/29 14:18:00	1.38
@@ -76,6 +76,14 @@
 	DEFS += -DUSE_SINGLENODE
 endif
 
+ifeq ($(MAKECMDGOALS),distclean)
+	SOURCES += clvmd-gulm.c tcp-comms.c
+	SOURCES += clvmd-cman.c
+	SOURCES += clvmd-openais.c
+	SOURCES += clvmd-corosync.c
+	SOURCES += clvmd-singlenode.c
+endif
+
 TARGETS = \
 	clvmd
 
@@ -109,4 +117,3 @@
 install: $(INSTALL_TARGETS)
 
 install_cluster: $(INSTALL_TARGETS)
-
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:11:17	1.38
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:18:00	1.39
@@ -17,6 +17,8 @@
 VPATH = @srcdir@
 
 SOURCES = libdevmapper-event.c
+SOURCES2 = dmeventd.c
+
 TARGETS = dmeventd
 
 .PHONY: install_lib_dynamic install_lib_static install_include \
@@ -118,10 +120,9 @@
 
 install_device-mapper: install_include install_lib install_dmeventd
 
-.PHONY: distclean_lib distclean
+.PHONY: distclean_lib
 
 distclean_lib: 
 	$(RM) libdevmapper-event.pc
 
 distclean: distclean_lib
-
--- LVM2/lib/Makefile.in	2010/03/29 14:11:18	1.99
+++ LVM2/lib/Makefile.in	2010/03/29 14:18:00	1.100
@@ -165,3 +165,5 @@
 include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
+
+DISTCLEAN_TARGETS += misc/configure.h misc/lvm-version.h
--- LVM2/libdm/Makefile.in	2010/03/29 14:11:18	1.51
+++ LVM2/libdm/Makefile.in	2010/03/29 14:18:01	1.52
@@ -106,9 +106,9 @@
 	rm -f libdevmapper.$(LIB_SUFFIX)
 	$(LN_S) $< libdevmapper.$(LIB_SUFFIX)
 
-CLEAN_TARGETS += libdevmapper.$(LIB_SUFFIX)
+CLEAN_TARGETS += libdevmapper.$(LIB_SUFFIX) ioctl/libdevmapper.a
 
-.PHONY: distclean_lib distclean
+.PHONY: distclean_lib
 
 distclean_lib:
 	$(RM) libdevmapper.pc
--- LVM2/man/Makefile.in	2010/03/04 09:56:01	1.32
+++ LVM2/man/Makefile.in	2010/03/29 14:18:01	1.33
@@ -47,6 +47,7 @@
 MAN8DIR=$(mandir)/man8
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
+DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8
 
 include $(top_builddir)/make.tmpl
 
--- LVM2/test/Makefile.in	2010/03/18 09:28:42	1.28
+++ LVM2/test/Makefile.in	2010/03/29 14:18:01	1.29
@@ -28,14 +28,16 @@
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
-T = $(wildcard $(srcdir)/t-*.sh)
+SCRIPTS := $(wildcard $(srcdir)/t-*.sh) \
+ $(srcdir)/test-utils.sh \
+ $(srcdir)/test-lib.sh
 
 ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1
 endif
 
 ifeq ("@APPLIB@", "yes")
-T += $(srcdir)/lvm2app.sh
+SCRIPTS += $(srcdir)/lvm2app.sh
 all: api/vgtest
 api/vgtest:
 	$(MAKE) -C api vgtest
@@ -66,9 +68,7 @@
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \
-	                                    $(srcdir)/test-lib.sh \
-	                                    $(T) .; fi
+	test "$(srcdir)" != . && cp $(SCRIPTS) .
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
@@ -95,9 +95,9 @@
 
 clean:
 	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
+	test "$(srcdir)" != . && rm -f $(subst $(srcdir)/, ,$(SCRIPTS)) lvm2app.sh
 
 distclean: clean
 	rm -f Makefile
 
-.PHONY: clean distclean
 .NOTPARALLEL:
--- LVM2/tools/Makefile.in	2010/03/29 14:11:18	1.112
+++ LVM2/tools/Makefile.in	2010/03/29 14:18:01	1.113
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -64,10 +64,15 @@
 	vgsplit.c
 
 SOURCES2 =\
-	dmsetup.c
+	dmsetup.c \
+	lvm.c \
+	lvm2cmd-static.c \
+	lvm2cmd.c \
+	lvmcmdlib.c
 
 TARGETS =\
 	.commands \
+	liblvm2cmd.a \
 	lvm
 
 TARGETS_DM = dmsetup
@@ -87,9 +92,8 @@
 LVMLIBS = $(LVMINTERNAL_LIBS)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
-		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
-		lvmcmdlib.o lvm-static.o dmsetup.o $(TARGETS_DM)
+CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
+	liblvm2cmd-static.a dmsetup.static lvm.static
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
@@ -146,15 +150,16 @@
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
 
-.PHONY: install_cmdlib_dynamic install_cmdlib_static \
-	install_tools_dynamic install_tools_static
-
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 -include $(top_builddir)/libdm/libdevmapper.cflow
 -include $(top_builddir)/lib/liblvm-internal.cflow
 endif
 
+.PHONY: install_cmdlib_dynamic install_cmdlib_static \
+	install_tools_dynamic install_tools_static \
+	install_dmsetup_dynamic install_dmsetup_static
+
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)


