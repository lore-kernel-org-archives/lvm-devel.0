From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Jun 2018 06:28:50 -0400
Subject: master - build: remove any leftover file
Message-ID: <201806041028.w54ASo0g032043@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eebf070d32b491fb08f7defccc08f9bcefb9aba2
Commit:        eebf070d32b491fb08f7defccc08f9bcefb9aba2
Parent:        21a5be2364574de43e2afe55a250ccced02df008
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 4 12:16:30 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 4 12:26:38 2018 +0200

build: remove any leftover file

In case repository is used after building older version of lvm2
(i.e. git bisect) make sure clean erases any possible old symlinks.
---
 include/.gitignore  |    3 --
 include/Makefile.in |   83 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 82 insertions(+), 4 deletions(-)

diff --git a/include/.gitignore b/include/.gitignore
index 4971e07..424c745 100644
--- a/include/.gitignore
+++ b/include/.gitignore
@@ -1,4 +1 @@
-.symlinks
-.symlinks_created
-
 *.h
diff --git a/include/Makefile.in b/include/Makefile.in
index cbbc003..efe263c 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,3 +19,84 @@ top_builddir = @top_builddir@
 include $(top_builddir)/make.tmpl
 
 DISTCLEAN_TARGETS += .configure.h lvm-version.h
+CLEAN_TARGETS += \
+ activate.h \
+ archiver.h \
+ bcache.h \
+ btree.h \
+ clvm.h \
+ config-util.h \
+ config.h \
+ config_settings.h \
+ crc.h \
+ daemon-client.h \
+ daemon-io.h \
+ defaults.h \
+ dev-cache.h \
+ dev-ext-udev-constants.h \
+ dev-type.h \
+ device-types.h \
+ device.h \
+ display.h \
+ dm-ioctl.h \
+ dm-log-userspace.h \
+ dm-logging.h \
+ dmlib.h \
+ filter.h \
+ format-text.h \
+ format1.h \
+ format_pool.h \
+ intl.h \
+ kdev_t.h \
+ label.h \
+ last-path-component.h \
+ lib.h \
+ libdevmapper-event.h \
+ libdevmapper.h \
+ locking.h \
+ log.h \
+ lv.h \
+ lvm-exec.h \
+ lvm-file.h \
+ lvm-flock.h \
+ lvm-globals.h \
+ lvm-logging.h \
+ lvm-maths.h \
+ lvm-percent.h \
+ lvm-signal.h \
+ lvm-string.h \
+ lvm-wrappers.h \
+ lvm2app.h \
+ lvm2cmd.h \
+ lvmcache.h \
+ lvmetad-client.h \
+ lvmetad.h \
+ lvmlockd-client.h \
+ lvmlockd.h \
+ lvmnotify.h \
+ lvmpolld-client.h \
+ lvmpolld-protocol.h \
+ lv_alloc.h \
+ memlock.h \
+ metadata-exported.h \
+ metadata.h \
+ pogen.h \
+ polldaemon.h \
+ polling_ops.h \
+ properties.h \
+ prop_common.h \
+ pv.h \
+ pv_alloc.h \
+ report.h \
+ segtype.h \
+ sharedlib.h \
+ str_list.h \
+ targets.h \
+ text_export.h \
+ text_import.h \
+ tool.h \
+ toolcontext.h \
+ util.h \
+ uuid.h \
+ vg.h \
+ xlate.h


