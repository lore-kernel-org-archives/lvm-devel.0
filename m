From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:35:09 -0000
Subject: LVM2 ./Makefile.in ./configure ./make.tmpl.in ...
Message-ID: <20120228183509.24820.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:35:06

Modified files:
	.              : Makefile.in configure make.tmpl.in 
	tools          : Makefile.in 
	libdaemon/client: daemon-client.c daemon-client.h 
	                  daemon-shared.c daemon-shared.h 
	libdaemon/server: daemon-server.c daemon-server.h 
	lib            : Makefile.in 
	daemons        : Makefile.in 
	daemons/dmeventd/plugins/lvm2: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	daemons/lvmetad: Makefile.in lvmetad-client.h lvmetad-core.c 

Log message:
	Reflect new file locations, include file updates etc.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-shared.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-shared.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/server/daemon-server.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/Makefile.in	2012/02/22 17:55:10	1.69
+++ LVM2/Makefile.in	2012/02/28 18:35:04	1.70
@@ -32,10 +32,14 @@
   SUBDIRS += liblvm
 endif
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+  SUBDIRS += libdaemon
+endif
+
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man scripts \
-    lib tools daemons libdm \
+    libdaemon lib tools daemons libdm \
     udev po liblvm test \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
 endif
@@ -45,10 +49,10 @@
 include make.tmpl
 
 libdm: include
-lib: libdm
+lib: libdm libdaemon
 liblvm: lib
-daemons: lib tools
-tools: lib device-mapper
+daemons: lib libdaemon tools
+tools: lib libdaemon device-mapper
 po: tools daemons
 
 lib.device-mapper: include.device-mapper
--- LVM2/configure	2012/02/24 13:03:50	1.173
+++ LVM2/configure	2012/02/28 18:35:04	1.174
@@ -8739,6 +8739,12 @@
 
 BUILD_LVMETAD=$LVMETAD
 
+if test x$BUILD_LVMETAD = xyes; then
+
+$as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
+
+fi
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
 $as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
@@ -10426,7 +10432,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvm!
 etad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_!
 lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11120,7 +11126,6 @@
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
     "daemons/cmirrord/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/cmirrord/Makefile" ;;
-    "daemons/common/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/common/Makefile" ;;
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
@@ -11144,6 +11149,9 @@
     "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;
+    "libdaemon/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/Makefile" ;;
+    "libdaemon/client/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/client/Makefile" ;;
+    "libdaemon/server/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/server/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
--- LVM2/make.tmpl.in	2012/02/23 13:31:01	1.131
+++ LVM2/make.tmpl.in	2012/02/28 18:35:04	1.132
@@ -39,7 +39,7 @@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal -L$(top_builddir)/daemons/common -ldaemon $(UDEV_LIBS) $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS)
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
@@ -143,6 +143,12 @@
 LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+  DAEMON_LIBS = -ldaemonclient
+  LDFLAGS += -L$(top_builddir)/libdaemon/client
+  CLDFLAGS += -L$(top_builddir)/libdaemon/client
+endif
+
 ifeq ("@DMEVENTD@", "yes")
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
--- LVM2/tools/Makefile.in	2012/02/23 13:11:10	1.125
+++ LVM2/tools/Makefile.in	2012/02/28 18:35:04	1.126
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,8 +16,6 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/common -I$(top_srcdir)/daemons/lvmetad
-
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
--- LVM2/libdaemon/client/daemon-client.c	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/client/daemon-client.c	2012/02/28 18:35:05	1.2
@@ -1,5 +1,20 @@
-#include "daemon-client.h"
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include "daemon-shared.h"
+#include "daemon-client.h"
+
 #include <sys/un.h>
 #include <sys/socket.h>
 #include <string.h>
--- LVM2/libdaemon/client/daemon-client.h	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/client/daemon-client.h	2012/02/28 18:35:05	1.2
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -12,11 +12,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h" // for dm_list, needed by config.h
-
 #ifndef _LVM_DAEMON_COMMON_CLIENT_H
 #define _LVM_DAEMON_COMMON_CLIENT_H
 
+#include "libdevmapper.h"
+
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the daemon */
 	const char *protocol;
--- LVM2/libdaemon/client/daemon-shared.c	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/client/daemon-shared.c	2012/02/28 18:35:05	1.2
@@ -1,10 +1,26 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include <errno.h>
 #include <stdio.h>
 #include <malloc.h>
 #include <string.h>
 #include <unistd.h>
 #include <assert.h>
+
 #include "daemon-shared.h"
+#include "libdevmapper.h"
 
 /*
  * Read a single message from a (socket) filedescriptor. Messages are delimited
--- LVM2/libdaemon/client/daemon-shared.h	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/client/daemon-shared.h	2012/02/28 18:35:05	1.2
@@ -1,6 +1,30 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_SHARED_H
+#define _LVM_DAEMON_SHARED_H
+
+#include "configure.h"
+
+#define _REENTRANT
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
 #include <stdarg.h>
-#include <libdevmapper.h>
 
 int read_buffer(int fd, char **buffer);
 int write_buffer(int fd, const char *buffer, int length);
 char *format_buffer(const char *what, const char *id, va_list ap);
+
+#endif /* _LVM_DAEMON_SHARED_H */
--- LVM2/libdaemon/server/daemon-server.c	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/server/daemon-server.c	2012/02/28 18:35:05	1.2
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc.
  *
  * This copyrighted material is made available to anyone wishing to use,
  * modify, copy, or redistribute it subject to the terms and conditions
@@ -10,6 +10,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "daemon-shared.h"
+#include "daemon-server.h"
+
 #include <dlfcn.h>
 #include <errno.h>
 #include <pthread.h>
@@ -24,9 +27,6 @@
 #include <signal.h>
 
 #include <syslog.h>
-#include "daemon-server.h"
-#include "daemon-shared.h"
-#include "libdevmapper.h"
 
 #if 0
 /* Create a device monitoring thread. */
--- LVM2/libdaemon/server/daemon-server.h	2012/02/28 18:30:39	1.1
+++ LVM2/libdaemon/server/daemon-server.h	2012/02/28 18:35:05	1.2
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -12,11 +12,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "daemon-client.h"
-
 #ifndef _LVM_DAEMON_COMMON_SERVER_H
 #define _LVM_DAEMON_COMMON_SERVER_H
 
+#include "daemon-client.h"
+
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the client */
 	pthread_t thread_id;
--- LVM2/lib/Makefile.in	2012/02/23 13:11:08	1.115
+++ LVM2/lib/Makefile.in	2012/02/28 18:35:05	1.116
@@ -16,8 +16,6 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/daemons/common -I$(top_srcdir)/daemons/lvmetad
-
 ifeq ("@LVM1@", "shared")
   SUBDIRS = format1
 endif
@@ -48,7 +46,6 @@
 
 SOURCES =\
 	activate/activate.c \
-	cache/lvmetad.c \
 	cache/lvmcache.c \
 	commands/toolcontext.c \
 	config/config.c \
@@ -178,6 +175,11 @@
 	misc/sharedlib.c
 endif
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+  SOURCES +=\
+	cache/lvmetad.c
+endif
+
 ifeq ("@DMEVENTD@", "yes")
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
   LIBS += -ldevmapper-event
--- LVM2/daemons/Makefile.in	2012/02/23 13:58:56	1.24
+++ LVM2/daemons/Makefile.in	2012/02/28 18:35:05	1.25
@@ -15,13 +15,11 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += common
-
 ifeq ("@BUILD_LVMETAD@", "yes")
   SUBDIRS += lvmetad
 endif
 
-.PHONY: dmeventd clvmd common cmirrord lvmetad
+.PHONY: dmeventd clvmd cmirrord lvmetad
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS += clvmd
@@ -39,7 +37,7 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord common dmeventd lvmetad
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad
 endif
 
 include $(top_builddir)/make.tmpl
@@ -47,9 +45,3 @@
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
 endif
-
-ifeq ("@BUILD_LVMETAD@", "yes")
-lvmetad: common.device-mapper
-endif
-
-device-mapper: common.device-mapper
--- LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2012/02/23 13:11:07	1.8
+++ LVM2/daemons/dmeventd/plugins/lvm2/Makefile.in	2012/02/28 18:35:05	1.9
@@ -24,7 +24,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS) -L$(top_builddir)/daemons/common -ldaemon
+LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS) $(DAEMON_LIBS)
 
 install_lvm2: install_lib_shared
 
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2012/02/23 13:11:07	1.24
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2012/02/28 18:35:05	1.25
@@ -30,7 +30,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper -L$(top_builddir)/daemons/common -ldaemon
+LIBS += -ldevmapper-event-lvm2 -ldevmapper $(DAEMON_LIBS)
 
 install_lvm2: install_dm_plugin
 
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2012/02/23 13:11:08	1.19
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2012/02/28 18:35:05	1.20
@@ -26,7 +26,7 @@
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper -L$(top_builddir)/daemons/common -ldaemon
+LIBS += -ldevmapper-event-lvm2 -ldevmapper $(DAEMON_LIBS)
 
 install_lvm2: install_dm_plugin
 
--- LVM2/daemons/lvmetad/Makefile.in	2011/09/24 20:57:49	1.4
+++ LVM2/daemons/lvmetad/Makefile.in	2012/02/28 18:35:06	1.5
@@ -1,6 +1,7 @@
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the device-mapper userspace tools.
+# Copyright (C) 2011-2012 Red Hat, Inc.
+#
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -21,18 +22,23 @@
 
 .PHONY: install_lvmetad
 
-INCLUDES += -I$(top_srcdir)/daemons/common
-
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 CFLOW_TARGET = lvmetad
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper -ldaemon $(PTHREAD_LIBS)
+INCLUDES += -I$(top_srcdir)/libdaemon/server
+LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
+
+LIBS += $(PTHREAD_LIBS)
+
+LDFLAGS += -L$(top_builddir)/libdaemon/server
+CLDFLAGS += -L$(top_builddir)/libdaemon/server
 
-lvmetad: lvmetad-core.o
-	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/daemons/common -o $@ lvmetad-core.o \
+lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
+		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 # TODO: No idea. No idea how to test either.
--- LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 23:52:11	1.9
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/28 18:35:06	1.10
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -16,7 +16,8 @@
 #define _LVM_LVMETAD_CLIENT_H
 
 #include "daemon-client.h"
-#include "metadata-exported.h"
+
+struct volume_group;
 
 /* Different types of replies we may get from lvmetad. */
 
@@ -44,7 +45,7 @@
 daemon_reply lvmetad_remove_pv(daemon_handle h, const char *pv_uuid);
 
 /* Trigger a full disk scan, throwing away all caches. XXX do we eventually want
- * this? Probalby not yet, anyway.
+ * this? Probably not yet, anyway.
  *     daemon_reply lvmetad_rescan(daemon_handle h);
  */
 
@@ -57,7 +58,7 @@
  */
 daemon_reply lvmetad_supersede_vg(daemon_handle h, struct volume_group *vg);
 
-/* Implementation of inline functions */
+/* Wrappers to open/close connection */
 
 static inline daemon_handle lvmetad_open(const char *socket)
 {
--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/27 10:19:00	1.44
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/28 18:35:06	1.45
@@ -1,16 +1,29 @@
-#define _GNU_SOURCE
+/*
+ * Copyright (C) 2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #define _XOPEN_SOURCE 500  /* pthread */
 
+#include "configure.h"
+#include "daemon-shared.h"
+#include "daemon-server.h"
+
 #include <assert.h>
 #include <pthread.h>
 #include <malloc.h>
 #include <stdint.h>
 #include <unistd.h>
 
-#include "configure.h"
-#include "libdevmapper.h"
-#include "daemon-server.h"
-
 typedef struct {
 	struct dm_hash_table *pvid_to_pvmeta;
 	struct dm_hash_table *device_to_pvid; /* shares locks with above */
@@ -196,6 +209,7 @@
 	return cn;
 }
 
+#if 0
 static struct dm_config_node *make_int_node(struct dm_config_tree *cft,
 					    const char *key,
 					    int64_t value,
@@ -208,6 +222,7 @@
 	cn->v->v.i = value;
 	return cn;
 }
+#endif
 
 static void filter_metadata(struct dm_config_node *vg) {
 	struct dm_config_node *pv = pvs(vg);


