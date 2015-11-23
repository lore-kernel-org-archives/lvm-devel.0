From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Nov 2015 03:44:11 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20151123034411.3FDAC60BD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=369bc264b0db8be18243a6f95e1f6c14fdd0db99
Commit:        369bc264b0db8be18243a6f95e1f6c14fdd0db99
Parent:        da50f8bee654b029e2fc818b66765fa79a70b251
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 23 03:33:43 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 23 03:37:54 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    7 +++++--
 WHATS_NEW_DM |    5 +++--
 aclocal.m4   |    2 +-
 5 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 81a0997..eda7bf3 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.135(2)-git (2015-11-09)
+2.02.135(2)-git (2015-11-23)
diff --git a/VERSION_DM b/VERSION_DM
index 934b030..7439aaa 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.111-git (2015-11-09)
+1.02.111-git (2015-11-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index b0e79c8..1bbb0de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,12 @@
-Version 2.02.135 - 
-====================================
+Version 2.02.135 - 23rd November 2015
+=====================================
+  Add a model file for Coverity.
   Show correct error message for unsupported yet cache pool repair.
   Allow lvconvert cache pools' data and metadata LV to raid.
   Fix reading of old metadata with missing cache policy or mode settings.
   Issue error if external_device_info_source=udev and udev db record incomplete.
+  Update lvmetad duplicate VG name handling to use hash function extensions.
+  Detect invalid vgrenames by vgid where the name is unchanged.
   Fix passing of 32bit values through daemons (mostly lvmlockd).
   Use local memory pool for whole alloc_handle manipulation.
   Add missing pointer validation after dm_get_next_target().
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5e9228a..d4bc242 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.111 - 
-====================================
+Version 1.02.111 - 23rd November 2015
+=====================================
+  Extend dm_hash to support multiple values with the same key.
   Add missing check for allocation inside dm_split_lvm_name().
   Test dm_task_get_message_response for !NULL in dm_stats_print_region().
   Add checks for failing dm_stats_create() in dmsetup.
diff --git a/aclocal.m4 b/aclocal.m4
index 05e0ad5..67b2d59 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -15,7 +15,7 @@ m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun
 # pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
 # serial 1 (pkg-config-0.24)
 # 
-# Copyright ?? 2004 Scott James Remnant <scott@netsplit.com>.
+# Copyright (c) 2004 Scott James Remnant <scott@netsplit.com>.
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by


