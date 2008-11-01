From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2008 02:19:22 -0000
Subject: LVM2 ./Makefile.in ./configure.in ./make.tmpl. ...
Message-ID: <20081101021922.13806.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-01 02:19:19

Modified files:
	.              : Makefile.in configure.in make.tmpl.in 
	include        : Makefile.in 
	lib/misc       : configure.h.in lib.h 
	libdm          : Makefile.in libdm-common.c libdm-deptree.c 
	libdm/ioctl    : libdm-compat.h libdm-iface.c 
	man            : Makefile.in 
	po             : Makefile.in 
	scripts        : Makefile.in 
	tools          : Makefile.in 

Log message:
	further progress

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-compat.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/Makefile.in	2008/10/31 22:29:44	1.24
+++ LVM2/Makefile.in	2008/11/01 02:19:17	1.25
@@ -22,7 +22,7 @@
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons
+SUBDIRS += lib tools daemons libdm
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
@@ -40,11 +40,14 @@
 
 include make.tmpl
 
+libdm: include
+lib: libdm
 daemons: lib
-lib: include
 tools: lib
 po: tools daemons
 
+tools.device-mapper: libdm.device-mapper
+
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
 tools.pofile: lib.pofile
--- LVM2/configure.in	2008/11/01 01:43:31	1.85
+++ LVM2/configure.in	2008/11/01 02:19:17	1.86
@@ -160,6 +160,24 @@
 fi
 
 ################################################################################
+dnl -- Setup device node ownership
+AC_MSG_CHECKING(device node uid)
+
+AC_ARG_WITH(device-uid,
+  [  --with-device-uid=UID   Set the owner used for new device nodes [[UID=0]] ],
+  [ DM_DEVICE_UID="$withval" ], [ DM_DEVICE_UID="0" ] )
+AC_MSG_RESULT($DM_DEVICE_UID)
+
+################################################################################
+dnl -- Setup device group ownership
+AC_MSG_CHECKING(device node gid)
+
+AC_ARG_WITH(device-gid,
+  [  --with-device-gid=UID   Set the group used for new device nodes [[GID=0]] ],
+  [ DM_DEVICE_GID="$withval" ], [ DM_DEVICE_GID="0" ] )
+AC_MSG_RESULT($DM_DEVICE_GID)
+
+################################################################################
 dnl -- Setup device mode
 AC_MSG_CHECKING(device node mode)
 
--- LVM2/make.tmpl.in	2008/10/31 22:33:55	1.58
+++ LVM2/make.tmpl.in	2008/11/01 02:19:17	1.59
@@ -109,12 +109,15 @@
 OBJECTS = $(SOURCES:%.c=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
-.PHONY: all install install_cluster pofile distclean clean cflow
+.PHONY: all install install_cluster pofile distclean clean cflow device-mapper
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
+.PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
 
+SUBDIRS.device-mapper := $(SUBDIRS:=.device-mapper)
 SUBDIRS.install := $(SUBDIRS:=.install)
 SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
+SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
 SUBDIRS.pofile := $(SUBDIRS:=.pofile)
 SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
@@ -124,18 +127,27 @@
 
 all: $(SUBDIRS) $(TARGETS)
 
+device-mapper: $(SUBDIRS.device-mapper)
+
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
+install_device-mapper: $(SUBDIRS.install_device-mapper)
 
 $(SUBDIRS):
 	$(MAKE) -C $@
 
+$(SUBDIRS.device-mapper):
+	$(MAKE) -C $(@:.device-mapper=) device-mapper
+
 $(SUBDIRS.install): $(SUBDIRS)
 	$(MAKE) -C $(@:.install=) install
 
 $(SUBDIRS.install_cluster): $(SUBDIRS)
 	$(MAKE) -C $(@:.install_cluster=) install_cluster
 
+$(SUBDIRS.install_device-mapper): $(SUBDIRS)
+	$(MAKE) -C $(@:.install_device-mapper=) install_device-mapper
+
 $(SUBDIRS.clean):
 	-$(MAKE) -C $(@:.clean=) clean
 
--- LVM2/include/Makefile.in	2007/09/21 10:16:43	1.8
+++ LVM2/include/Makefile.in	2008/11/01 02:19:17	1.9
@@ -35,6 +35,8 @@
 
 pofile: all
 
+device-mapper: all
+
 clean:
 
 install:
--- LVM2/lib/misc/configure.h.in	2008/10/31 22:12:56	1.7
+++ LVM2/lib/misc/configure.h.in	2008/11/01 02:19:17	1.8
@@ -26,6 +26,9 @@
 /* Path to dmeventd pidfile. */
 #undef DMEVENTD_PIDFILE
 
+/* Library version */
+#undef DM_LIB_VERSION
+
 /* Define to 1 if you have `alloca', as a function or macro. */
 #undef HAVE_ALLOCA
 
--- LVM2/lib/misc/lib.h	2008/10/30 17:27:27	1.14
+++ LVM2/lib/misc/lib.h	2008/11/01 02:19:17	1.15
@@ -26,11 +26,17 @@
 #define _FILE_OFFSET_BITS 64
 
 #include "intl.h"
+#include "libdevmapper.h"
 #include "lvm-logging.h"
 #include "lvm-types.h"
 #include "lvm-wrappers.h"
 #include "util.h"
 
-#include <libdevmapper.h>
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/stat.h>
 
 #endif
--- LVM2/libdm/Makefile.in	2008/06/06 20:44:35	1.38
+++ LVM2/libdm/Makefile.in	2008/11/01 02:19:18	1.39
@@ -32,7 +32,7 @@
 	regex/ttree.c \
 	$(interface)/libdm-iface.c
 
-INCLUDES = -I$(interface)
+INCLUDES = -I$(interface) -I.
 
 LIB_STATIC = $(interface)/libdevmapper.a
 
@@ -48,6 +48,8 @@
 
 include ../make.tmpl
 
+device-mapper: all
+
 .PHONY: install_dynamic install_static install_include \
 	install_ioctl install_ioctl_static \
 	install_pkgconfig
--- LVM2/libdm/libdm-common.c	2008/06/06 20:44:35	1.59
+++ LVM2/libdm/libdm-common.c	2008/11/01 02:19:18	1.60
@@ -18,14 +18,13 @@
 #include "libdm-common.h"
 #include "list.h"
 #include "kdev_t.h"
+#include "dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
 #include <sys/ioctl.h>
 #include <fcntl.h>
 
-#include <linux/dm-ioctl.h>
-
 #ifdef linux
 #  include <linux/fs.h>
 #endif
--- LVM2/libdm/libdm-deptree.c	2008/09/18 22:55:33	1.43
+++ LVM2/libdm/libdm-deptree.c	2008/11/01 02:19:18	1.44
@@ -17,12 +17,11 @@
 #include "libdm-common.h"
 #include "list.h"
 #include "kdev_t.h"
+#include "dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
 
-#include <linux/dm-ioctl.h>
-
 #define MAX_TARGET_PARAMSIZE 500000
 
 /* FIXME Fix interface so this is used only by LVM */
--- LVM2/libdm/ioctl/libdm-compat.h	2007/08/21 16:26:07	1.10
+++ LVM2/libdm/ioctl/libdm-compat.h	2008/11/01 02:19:18	1.11
@@ -17,8 +17,8 @@
 #define _LINUX_LIBDM_COMPAT_H
 
 #include "kdev_t.h"
+#include "dm-ioctl.h"
 #include <inttypes.h>
-#include <linux/dm-ioctl.h>
 #include <sys/ioctl.h>
 
 struct dm_task;
--- LVM2/libdm/ioctl/libdm-iface.c	2008/09/18 18:34:53	1.52
+++ LVM2/libdm/ioctl/libdm-iface.c	2008/11/01 02:19:18	1.53
@@ -35,7 +35,7 @@
 #  define MKDEV(x,y) makedev((x),(y))
 #endif
 
-#include <linux/dm-ioctl.h>
+#include "dm-ioctl.h"
 
 /*
  * Ensure build compatibility.  
--- LVM2/man/Makefile.in	2008/10/08 12:50:13	1.23
+++ LVM2/man/Makefile.in	2008/11/01 02:19:18	1.24
@@ -35,7 +35,7 @@
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN)
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) dmsetup.8
 
 include $(top_srcdir)/make.tmpl
 
@@ -47,6 +47,8 @@
 
 .PHONY: man
 
+device-mapper: dmsetup.8
+
 man: $(MAN5) $(MAN8) $(MAN8CLUSTER)
 
 $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
--- LVM2/po/Makefile.in	2007/09/21 10:16:45	1.5
+++ LVM2/po/Makefile.in	2008/11/01 02:19:18	1.6
@@ -17,22 +17,16 @@
 
 LANGS=de
 
-TARGETS=$(LANGS:%=%.mo)
+TARGETS=$(LANGS:%=lvm2_%.mo) $(LANGS:%=dm_%.mo)
 
-include $(top_srcdir)/make.tmpl
+DM_POSOURCES = $(top_srcdir)/dmsetup/*.pot $(top_srcdir)/libdm/*.pot \
+	       $(top_srcdir)/libdm/*/*.pot
 
-install: $(TARGETS)
-	@echo Installing translation files in $(localedir)
-	@( \
-		for lang in $(LANGS); do \
-			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
-			    $(localedir)/$$lang/LC_MESSAGES/@INTL_PACKAGE at .mo;\
-	  done; \
-	)
+LVM_POSOURCES = $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
 
-pofile: lvm2.po
+include $(top_srcdir)/make.tmpl
 
-lvm2.po: Makefile $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
+lvm2.po: Makefile $(LVM_POSOURCES)
 	@echo Compiling string table
 	@xgettext -C -F --keyword=print_log --keyword=log_debug \
 		--keyword=log_info --keyword=_ --keyword=N_ \
@@ -40,6 +34,32 @@
 		--keyword=log_fatal --keyword=log_debug --keyword=log_error \
 		--keyword=log_print --keyword=log_verbose \
 		--keyword=log_very_verbose -d - \
-		$(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot \
-		> $@
+		$(LVM_POSOURCES) > $@
 
+device-mapper.po: Makefile $(DM_POSOURCES)
+	@echo Compiling string table
+	@xgettext -C -F --keyword=dm_log --keyword=log_debug \
+		--keyword=log_info --keyword=_ --keyword=N_ \
+		--keyword=log_notice --keyword=log_warn --keyword=log_err \
+		--keyword=log_fatal --keyword=log_debug --keyword=log_error \
+		--keyword=log_print --keyword=log_verbose \
+		--keyword=log_very_verbose -d - \
+		$(DM_POSOURCES) > $@
+
+pofile: lvm2.po device-mapper.po
+
+# FIXME
+install: $(TARGETS)
+	@echo Installing translation files in $(localedir)
+	@( \
+		for lang in $(LANGS); do \
+			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			    $(localedir)/$$lang/LC_MESSAGES/lvm2.mo;\
+	  done; \
+	)
+	@( \
+		for lang in $(LANGS); do \
+			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			    $(localedir)/$$lang/LC_MESSAGES/device-mapper.mo;\
+	  done; \
+	)
--- LVM2/scripts/Makefile.in	2007/12/17 12:23:24	1.3
+++ LVM2/scripts/Makefile.in	2008/11/01 02:19:18	1.4
@@ -20,6 +20,7 @@
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
 		$(sbindir)/lvmdump
+ifeq ("@FSADM@", "yes")
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm.sh \
 		$(sbindir)/fsadm
-
+endif
--- LVM2/tools/Makefile.in	2008/05/19 20:06:34	1.85
+++ LVM2/tools/Makefile.in	2008/11/01 02:19:19	1.86
@@ -97,6 +97,19 @@
 
 include $(top_srcdir)/make.tmpl
 
+device-mapper: dmsetup
+
+dmsetup: dmsetup.o $(interfacedir)/libdevmapper.$(LIB_SUFFIX)
+	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
+	      -L$(interfacedir) -L$(DESTDIR)/lib -ldevmapper $(LIBS)
+
+dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
+	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) -static \
+	      -L$(interfacedir) -L$(DESTDIR)/lib -ldevmapper $(LIBS) \
+	      $(LIB_PTHREAD)
+
+all: device-mapper
+
 lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
 		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic


