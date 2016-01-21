From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Jan 2016 09:01:44 +0000 (UTC)
Subject: master - configure: fix configure to set proper use_blkid_wiping if autodetected as disabled
Message-ID: <20160121090144.AC679606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43b436398ec81c8d0a2dbd2062ce864997d22f26
Commit:        43b436398ec81c8d0a2dbd2062ce864997d22f26
Parent:        21028a7903a8ef78e3dbda6afbd245c1cae1aae8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 21 09:56:07 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jan 21 10:01:34 2016 +0100

configure: fix configure to set proper use_blkid_wiping if autodetected as disabled

If not using explicit --enable-blkid-wiping/--disable-blkid-wiping
configure option, the configure script tries to enable/disable blkid
wiping feature automatically based on blkid library version found.

The script incorrectly set default value for lvm.conf's
allocation/use_blkid_wiping" setting to "1" (enabled) if proper
blkid library version was not found or the version found was less
than the minimum required. It should be set to "0" in this case.
---
 WHATS_NEW    |    1 +
 aclocal.m4   |    2 +-
 configure    |    2 +-
 configure.in |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f909ab..20f86d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Fix configure to set proper use_blkid_wiping if autodetected as disabled.
   Initialise udev in clvmd for use in device scanning. (2.02.116)
   Add seg_le_ranges report field for common format when displaying seg devices.
   Honour report/list_item_separator for seg_metadata_le_ranges report field.
diff --git a/aclocal.m4 b/aclocal.m4
index 67b2d59..05e0ad5 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -15,7 +15,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
-# Copyright (c) 2004 Scott James Remnant <scott@netsplit.com>.
+# Copyright ?? 2004 Scott James Remnant <scott@netsplit.com>.
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
diff --git a/configure b/configure
index 8a9482d..f22a11e 100755
--- a/configure
+++ b/configure
@@ -11791,7 +11791,7 @@ fi
 $as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
 	else
-		DEFAULT_USE_BLKID_WIPING=1
+		DEFAULT_USE_BLKID_WIPING=0
 	fi
 else
 	DEFAULT_USE_BLKID_WIPING=0
diff --git a/configure.in b/configure.in
index 8e04782..2cad902 100644
--- a/configure.in
+++ b/configure.in
@@ -1291,7 +1291,7 @@ if test "$BLKID_WIPING" != no; then
 		DEFAULT_USE_BLKID_WIPING=1
 		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
 	else
-		DEFAULT_USE_BLKID_WIPING=1
+		DEFAULT_USE_BLKID_WIPING=0
 	fi
 else
 	DEFAULT_USE_BLKID_WIPING=0


