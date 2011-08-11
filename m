From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Aug 2011 19:18:20 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20110811191820.23001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-11 19:18:19

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	                 make.tmpl.in 
	daemons/dmeventd/plugins: Makefile.in 
	tools          : dmsetup.c 
Added files:
	lib/raid       : .exported_symbols Makefile.in 

Log message:
	pre-release fixes incl make distclean and configure --with-raid=none/shared

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2069&r2=1.2070
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168

--- LVM2/Makefile.in	2011/07/28 12:57:26	1.64
+++ LVM2/Makefile.in	2011/08/11 19:18:17	1.65
@@ -32,10 +32,12 @@
   SUBDIRS += liblvm
 endif
 
+# FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man scripts \
     lib tools daemons libdm \
-    udev po liblvm test/api test
+    udev po liblvm test/api test \
+    unit-tests/datastruct unit-tests/mm unit-tests/regex
 endif
 DISTCLEAN_DIRS += lcov_reports*
 DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
@@ -141,6 +143,7 @@
 .PHONEY: unit-test ruby-test test-programs
 
 # FIXME: put dependencies on libdm and liblvm
+# FIXME: Should be handled by Makefiles in subdirs, not here at top level.
 test-programs:
 	cd unit-tests/regex && $(MAKE)
 	cd unit-tests/datastruct && $(MAKE)
--- LVM2/WHATS_NEW	2011/08/11 18:24:40	1.2069
+++ LVM2/WHATS_NEW	2011/08/11 19:18:18	1.2070
@@ -8,14 +8,14 @@
   Fix possible format instance memory leaks and premature releases in _vg_read.
   Suppress locking error messages in monitoring init scripts.
   If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
-  Add dmeventd monitoring shared library for RAID.
-  Add RAID metadata devices to considered devices in _add_lv_to_dtree.
+  Add dmeventd monitoring shared library for raid.
+  Add raid metadata devices to considered devices in _add_lv_to_dtree.
   Fix renaming of RAID logical volumes.
   Replace free_vg with release_vg and move it to vg.c.
   Remove INCONSISTENT_VG flag from the code.
   Remove lock from cache even if unlock fails.
   Initialise clvmd locks before lvm context to avoid open descriptor leaks.
-  Remove obsoleted GULM clvmd cluster locking support.
+  Remove obsolete gulm clvmd cluster locking support.
   Suppress low-level locking errors and warnings while using --sysinit.
   Remove unused inconsistent_seqno variable in _vg_read().
   Remove meaningless const type qualifiers on cast type.
@@ -23,7 +23,7 @@
   Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
   Add missing new line in lvrename help text.
-  Add basic support for RAID 1/4/5/6 (i.e. create, remove, display)
+  Add basic support for MD RAID 1/4/5/6 as new segment type called raid.
   Change DEFAULT_UDEV_SYNC to 1 so udev_sync is used even without any config.
   Add systemd unit file to provide lvm2 monitoring.
   Compare also file size to detect changed config file.
--- LVM2/configure	2011/08/11 05:00:20	1.153
+++ LVM2/configure	2011/08/11 19:18:18	1.154
@@ -10165,7 +10165,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/dat!
 astruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makef!
 ile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10877,6 +10877,7 @@
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
+    "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
--- LVM2/configure.in	2011/08/11 05:00:21	1.167
+++ LVM2/configure.in	2011/08/11 19:18:18	1.168
@@ -1396,6 +1396,7 @@
 lib/mirror/Makefile
 lib/replicator/Makefile
 lib/misc/lvm-version.h
+lib/raid/Makefile
 lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
--- LVM2/make.tmpl.in	2011/08/11 17:29:04	1.119
+++ LVM2/make.tmpl.in	2011/08/11 19:18:18	1.120
@@ -363,7 +363,8 @@
 cleandir:
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
 	  $(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
-	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda)
+	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda) \
+	  .exported_symbols_generated Makefile core
 
 clean: $(SUBDIRS.clean) cleandir
 
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2011/08/11 05:00:21	1.9
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2011/08/11 19:18:18	1.10
@@ -16,10 +16,26 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += lvm2 mirror snapshot raid
+SUBDIRS += lvm2
+
+ifneq ("@MIRRORS@", "none")
+  SUBDIRS += mirror
+endif
+
+ifneq ("@SNAPSHOTS@", "none")
+  SUBDIRS += snapshot
+endif
+
+ifneq ("@RAID@", "none")
+  SUBDIRS += raid
+endif
+
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS = lvm2 mirror snapshot raid
+endif
 
 include $(top_builddir)/make.tmpl
 
-mirror: lvm2
 snapshot: lvm2
-
+mirror: lvm2
+raid: lvm2
/cvs/lvm2/LVM2/lib/raid/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/lib/raid/.exported_symbols
+++ -	2011-08-11 19:18:19.949017000 +0000
@@ -0,0 +1 @@
+init_segtype
/cvs/lvm2/LVM2/lib/raid/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/lib/raid/Makefile.in
+++ -	2011-08-11 19:18:20.032169000 +0000
@@ -0,0 +1,26 @@
+#
+# Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = raid.c
+
+LIB_SHARED = liblvm2raid.$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+include $(top_builddir)/make.tmpl
+
+install: install_lvm2_plugin
--- LVM2/tools/dmsetup.c	2011/08/11 17:06:24	1.167
+++ LVM2/tools/dmsetup.c	2011/08/11 19:18:18	1.168
@@ -3479,7 +3479,7 @@
 
       doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
-			   (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
+			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
 	do {
 		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");


