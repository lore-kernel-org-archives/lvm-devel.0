From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 05:16:09 -0400
Subject: master - build: remove --with-{snapshots, mirrors, raid, thin, cache} options from ./configure
Message-ID: <201804300916.w3U9G9qZ021329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bc896f2a3a0023a4f45f10da3d0a22295a633ee
Commit:        2bc896f2a3a0023a4f45f10da3d0a22295a633ee
Parent:        545ca594689575fdd58877ad6f66abe1fdab815d
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 10:11:23 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 10:11:23 2018 +0100

build: remove --with-{snapshots,mirrors,raid,thin,cache} options from ./configure

It now behaves as if the were all set as 'internal'
---
 WHATS_NEW                            |    5 +++
 daemons/dmeventd/plugins/Makefile.in |   18 +-----------
 lib/Makefile.in                      |   50 +++------------------------------
 lib/cache_segtype/Makefile.in        |   24 ----------------
 lib/mirror/Makefile.in               |   26 -----------------
 lib/raid/Makefile.in                 |   26 -----------------
 lib/snapshot/Makefile.in             |   26 -----------------
 lib/thin/Makefile.in                 |   25 -----------------
 man/Makefile.in                      |   14 +---------
 test/Makefile.in                     |    3 --
 10 files changed, 12 insertions(+), 205 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2d085a1..205a963 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.178 - 
 =====================================
+  --with-snapshots switch for ./configure has been removed.
+  --with-mirrors switch for ./configure has been removed.
+  --with-raid switch for ./configure has been removed.
+  --with-thin switch for ./configure has been removed.
+  --with-cache switch for ./configure has been removed.
   Extend validation of region_size for mirror segment.
   Reload whole device stack when reinitilizing mirror log.
   Mirrors without monitoring are WARNING and not blocking on error.
diff --git a/daemons/dmeventd/plugins/Makefile.in b/daemons/dmeventd/plugins/Makefile.in
index b164153..aea44cd 100644
--- a/daemons/dmeventd/plugins/Makefile.in
+++ b/daemons/dmeventd/plugins/Makefile.in
@@ -16,23 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += lvm2
-
-ifneq ("@MIRRORS@", "none")
-  SUBDIRS += mirror
-endif
-
-ifneq ("@SNAPSHOTS@", "none")
-  SUBDIRS += snapshot
-endif
-
-ifneq ("@RAID@", "none")
-  SUBDIRS += raid
-endif
-
-ifneq ("@THIN@", "none")
-  SUBDIRS += thin
-endif
+SUBDIRS += lvm2 snapshot raid thin mirrors
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = lvm2 mirror snapshot raid thin
diff --git a/lib/Makefile.in b/lib/Makefile.in
index bd68edc..e532626 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -24,26 +24,6 @@ ifeq ("@POOL@", "shared")
   SUBDIRS += format_pool
 endif
 
-ifeq ("@SNAPSHOTS@", "shared")
-  SUBDIRS += snapshot
-endif
-
-ifeq ("@MIRRORS@", "shared")
-  SUBDIRS += mirror
-endif
-
-ifeq ("@RAID@", "shared")
-  SUBDIRS += raid
-endif
-
-ifeq ("@THIN@", "shared")
-  SUBDIRS += thin
-endif
-
-ifeq ("@CACHE@", "shared")
-  SUBDIRS += cache_segtype
-endif
-
 ifeq ("@CLUSTER@", "shared")
   SUBDIRS += locking
 endif
@@ -51,6 +31,7 @@ endif
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
+	cache_segtype/cache.c \
 	commands/toolcontext.c \
 	config/config.c \
 	datastruct/btree.c \
@@ -108,6 +89,7 @@ SOURCES =\
 	metadata/snapshot_manip.c \
 	metadata/thin_manip.c \
 	metadata/vg.c \
+	mirror/mirrored.c \
 	misc/crc.c \
 	misc/lvm-exec.c \
 	misc/lvm-file.c \
@@ -121,9 +103,12 @@ SOURCES =\
 	mm/memlock.c \
 	notify/lvmnotify.c \
 	properties/prop_common.c \
+	raid/raid.c \
 	report/properties.c \
 	report/report.c \
+	snapshot/snapshot.c \
 	striped/striped.c \
+	thin/thin.c \
 	uuid/uuid.c \
 	zero/zero.c
 
@@ -150,26 +135,6 @@ ifeq ("@CLUSTER@", "internal")
   SOURCES += locking/cluster_locking.c
 endif
 
-ifeq ("@SNAPSHOTS@", "internal")
-  SOURCES += snapshot/snapshot.c
-endif
-
-ifeq ("@MIRRORS@", "internal")
-  SOURCES += mirror/mirrored.c
-endif
-
-ifeq ("@RAID@", "internal")
-  SOURCES += raid/raid.c
-endif
-
-ifeq ("@THIN@", "internal")
-  SOURCES += thin/thin.c
-endif
-
-ifeq ("@CACHE@", "internal")
-  SOURCES += cache_segtype/cache.c
-endif
-
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
@@ -204,12 +169,7 @@ ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS =\
 	format1 \
 	format_pool \
-	snapshot \
-	mirror \
 	notify \
-	raid \
-	thin \
-	cache_segtype \
 	locking
 endif
 
diff --git a/lib/cache_segtype/Makefile.in b/lib/cache_segtype/Makefile.in
deleted file mode 100644
index 5c4d415..0000000
--- a/lib/cache_segtype/Makefile.in
+++ /dev/null
@@ -1,24 +0,0 @@
-# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = cache.c
-
-LIB_SHARED = liblvm2cache.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
deleted file mode 100644
index 5c8db88..0000000
--- a/lib/mirror/Makefile.in
+++ /dev/null
@@ -1,26 +0,0 @@
-#
-# Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = mirrored.c
-
-LIB_SHARED = liblvm2mirror.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/raid/Makefile.in b/lib/raid/Makefile.in
deleted file mode 100644
index 7f5ea22..0000000
--- a/lib/raid/Makefile.in
+++ /dev/null
@@ -1,26 +0,0 @@
-#
-# Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = raid.c
-
-LIB_SHARED = liblvm2raid.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
deleted file mode 100644
index 40e44a2..0000000
--- a/lib/snapshot/Makefile.in
+++ /dev/null
@@ -1,26 +0,0 @@
-#
-# Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = snapshot.c
-
-LIB_SHARED = liblvm2snapshot.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/thin/Makefile.in b/lib/thin/Makefile.in
deleted file mode 100644
index 2fcf14b..0000000
--- a/lib/thin/Makefile.in
+++ /dev/null
@@ -1,25 +0,0 @@
-#
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = thin.c
-
-LIB_SHARED = liblvm2thin.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lib_shared_plugin
diff --git a/man/Makefile.in b/man/Makefile.in
index a40e168..844b0ca 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -64,7 +64,6 @@ ifeq ($(MAN_ALL),"yes")
   MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
-  MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMRAIDMAN)
 else
   ifeq ("@FSADM@", "yes")
     MAN8+=$(FSADMMAN)
@@ -105,20 +104,9 @@ else
   ifeq ("@BUILD_CMIRRORD@", "yes")
     MAN8CLUSTER+=$(CMIRRORDMAN)
   endif
-
-  ifneq ("@CACHE@", "none")
-    MAN7+=$(LVMCACHEMAN)
-  endif
-
-  ifneq ("@THIN@", "none")
-    MAN7+=$(LVMTHINMAN)
-  endif
-
-  ifneq ("@RAID@", "none")
-    MAN7+=$(LVMRAIDMAN)
-  endif
 endif
 
+MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMRAIDMAN)
 MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
diff --git a/test/Makefile.in b/test/Makefile.in
index 097b2fa..ccf1f31 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -275,9 +275,6 @@ lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
 
 lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
-	echo 'THIN=@THIN@' >> $@-t
-	echo 'RAID=@RAID@' >> $@-t
-	echo 'CACHE=@CACHE@' >> $@-t
 	echo 'LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
 	echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t


