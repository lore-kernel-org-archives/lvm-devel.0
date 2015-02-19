From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Feb 2015 15:19:23 +0000 (UTC)
Subject: master - configure: typo in configure --with-default-raid10-segtype causing it to be unrecognized
Message-ID: <20150219151923.E9D18610C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f80e7bb61bb794bfbedcca95a5dea8b1aac560b2
Commit:        f80e7bb61bb794bfbedcca95a5dea8b1aac560b2
Parent:        af395e61d52af330f5927f5dbf528c995574ee45
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 19 16:17:19 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 19 16:19:15 2015 +0100

configure: typo in configure --with-default-raid10-segtype causing it to be unrecognized

AC_ARG_WITH(default-raid10r-segtype --> AC_ARG_WITH(default-raid10-segtype

(...raid10r... --> ...raid10... - extra "r")
---
 WHATS_NEW    |    1 +
 aclocal.m4   |    2 +-
 configure    |    8 ++++----
 configure.in |    2 +-
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b956a80..7bf4dfb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Fix configure to properly recognize --with-default-raid10-segtype option.
   Do not refresh filters/rescan if no signature is wiped during pvcreate.
   Enforce none external dev info for wiping during pvcreate to avoid races.
   Add support for VG system_id to control host access to VGs.
diff --git a/aclocal.m4 b/aclocal.m4
index 6f752f2..2325191 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -1,4 +1,4 @@
-# generated automatically by aclocal 1.13.4 -*- Autoconf -*-
+# generated automatically by aclocal 1.14.1 -*- Autoconf -*-
 
 # Copyright (C) 1996-2013 Free Software Foundation, Inc.
 
diff --git a/configure b/configure
index ef0ae96..935702a 100755
--- a/configure
+++ b/configure
@@ -880,7 +880,7 @@ with_snapshots
 with_mirrors
 with_raid
 with_default_mirror_segtype
-with_default_raid10r_segtype
+with_default_raid10_segtype
 with_replicators
 with_default_sparse_segtype
 with_thin
@@ -7572,9 +7572,9 @@ else
 fi
 
 
-# Check whether --with-default-raid10r-segtype was given.
-if test "${with_default_raid10r_segtype+set}" = set; then :
-  withval=$with_default_raid10r_segtype; DEFAULT_RAID10_SEGTYPE=$withval
+# Check whether --with-default-raid10-segtype was given.
+if test "${with_default_raid10_segtype+set}" = set; then :
+  withval=$with_default_raid10_segtype; DEFAULT_RAID10_SEGTYPE=$withval
 else
   DEFAULT_RAID10_SEGTYPE="raid10"
 fi
diff --git a/configure.in b/configure.in
index 73ca4cd..7c855bf 100644
--- a/configure.in
+++ b/configure.in
@@ -354,7 +354,7 @@ AC_ARG_WITH(default-mirror-segtype,
 	    AC_HELP_STRING([--with-default-mirror-segtype=TYPE],
 			   [default mirror segtype: raid1/mirror [raid1]]),
 			   DEFAULT_MIRROR_SEGTYPE=$withval, DEFAULT_MIRROR_SEGTYPE="raid1")
-AC_ARG_WITH(default-raid10r-segtype,
+AC_ARG_WITH(default-raid10-segtype,
 	    AC_HELP_STRING([--with-default-raid10-segtype=TYPE],
 			   [default mirror segtype: raid10/mirror [raid10]]),
 			   DEFAULT_RAID10_SEGTYPE=$withval, DEFAULT_RAID10_SEGTYPE="raid10")


