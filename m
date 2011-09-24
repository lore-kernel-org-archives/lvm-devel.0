From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 20:57:50 -0000
Subject: LVM2 ./configure ./configure.in daemons/Makefi ...
Message-ID: <20110924205750.32303.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 20:57:49

Modified files:
	.              : configure configure.in 
	daemons        : Makefile.in 
	daemons/lvmetad: Makefile.in 
Added files:
	daemons/common : Makefile.in 

Log message:
	Use Makefile for daemmons/common library.
	
	Next iteration for better fit of lvmetad compilation.
	
	Move build of libdaemon.a into common subdir Makefile.
	libdaemon.a is device-mapper target.
	
	Build and install lvmetad as lvm2 target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/configure	2011/09/24 20:50:35	1.158
+++ LVM2/configure	2011/09/24 20:57:49	1.159
@@ -10212,7 +10212,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile !
 test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10906,6 +10906,7 @@
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
     "daemons/cmirrord/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/cmirrord/Makefile" ;;
+    "daemons/common/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/common/Makefile" ;;
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
--- LVM2/configure.in	2011/09/24 20:50:36	1.172
+++ LVM2/configure.in	2011/09/24 20:57:49	1.173
@@ -1410,6 +1410,7 @@
 daemons/Makefile
 daemons/clvmd/Makefile
 daemons/cmirrord/Makefile
+daemons/common/Makefile
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile
--- LVM2/daemons/Makefile.in	2011/09/19 00:29:11	1.21
+++ LVM2/daemons/Makefile.in	2011/09/24 20:57:49	1.22
@@ -16,13 +16,10 @@
 top_builddir = @top_builddir@
 
 ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += lvmetad
-
-LIB_STATIC = libdaemon.a
-SOURCES = common/daemon-shared.c common/daemon-server.c common/daemon-client.c
+  SUBDIRS += common lvmetad
 endif
 
-.PHONY: dmeventd clvmd cmirrord lvmetad
+.PHONY: dmeventd clvmd common cmirrord lvmetad
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS += clvmd
@@ -40,7 +37,7 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad
+  SUBDIRS = clvmd cmirrord common dmeventd lvmetad
 endif
 
 include $(top_builddir)/make.tmpl
@@ -50,7 +47,6 @@
 endif
 
 ifeq ("@BUILD_LVMETAD@", "yes")
-device-mapper: lvmetad.device-mapper
-lvmetad.device-mapper: $(LIB_STATIC)
+lvmetad: common.device-mapper
 endif
 
/cvs/lvm2/LVM2/daemons/common/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/Makefile.in
+++ -	2011-09-24 20:57:50.640380000 +0000
@@ -0,0 +1,22 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the device-mapper userspace tools.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+LIB_STATIC = libdaemon.a
+SOURCES = daemon-shared.c daemon-server.c daemon-client.c
+
+include $(top_builddir)/make.tmpl
+
+device-mapper: $(LIB_STATIC)
--- LVM2/daemons/lvmetad/Makefile.in	2011/09/19 00:29:12	1.3
+++ LVM2/daemons/lvmetad/Makefile.in	2011/09/24 20:57:49	1.4
@@ -22,8 +22,6 @@
 .PHONY: install_lvmetad
 
 INCLUDES += -I$(top_srcdir)/daemons/common
-INSTALL_LVMETAD_TARGETS = install_lvmetad
-CLEAN_TARGETS = lvmetad lvmetad-testclient
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = $(LIB_NAME).cflow
@@ -31,12 +29,10 @@
 
 include $(top_builddir)/make.tmpl
 
-device-mapper: $(TARGETS)
-
 LIBS += -ldevmapper -ldaemon $(PTHREAD_LIBS)
 
 lvmetad: lvmetad-core.o
-	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/daemons -o $@ lvmetad-core.o \
+	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/daemons/common -o $@ lvmetad-core.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 # TODO: No idea. No idea how to test either.
@@ -52,6 +48,6 @@
 install_lvmetad: lvmetad
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
-install: install_lvmetad
+install_lvm2: install_lvmetad
 
-install_device-mapper: install_lvmetad
+install: install_lvm2


