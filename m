From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Jan 2014 11:03:24 +0000 (UTC)
Subject: master - tests: update testing for xfs
Message-ID: <20140120110324.14F0461159@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79768b2e9c01f6a56d6e2fef7d3bd82f9ce3c2c1
Commit:        79768b2e9c01f6a56d6e2fef7d3bd82f9ce3c2c1
Parent:        59336a2a0626eba91dc3bc76ff6297e0c70e7e9e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 12:02:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 20 12:02:33 2014 +0100

tests: update testing for xfs

---
 WHATS_NEW           |    1 +
 test/shell/fsadm.sh |   17 ++++++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 834cf0f..6f7abe6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Replace use of xfs_check with xfs_reparir in fsadm. 
   Mark lvm1 format metadata as FMT_OBSOLETE. Do not use it with lvmetad.
   Invalidate cached VG struct after a PV in it gets orphaned. (2.02.87)
   Mark pool format metadata as FMT_OBSOLETE.
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 4e624db..8d4b37d 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -24,7 +24,9 @@ check_reiserfs=
 which mkfs.ext3 || check_ext3=${check_ext3:-mkfs.ext3}
 which fsck.ext3 || check_ext3=${check_ext3:-fsck.ext3}
 which mkfs.xfs || check_xfs=${check_xfs:-mkfs.xfs}
-which xfs_check || check_xfs=${check_xfs:-xfs_check}
+which xfs_check || {
+	which xfs_repair || check_xfs=${check_xfs:-xfs_repair}
+}
 which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
 which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
 
@@ -54,7 +56,11 @@ fscheck_ext3()
 
 fscheck_xfs()
 {
-	xfs_check "$dev_vg_lv"
+	if which xfs_repair ; then
+		xfs_repair -n "$dev_vg_lv"
+	else
+		xfs_check "$dev_vg_lv"
+	fi
 }
 
 fscheck_reiserfs()
@@ -67,8 +73,9 @@ check_missing()
 	eval local t=$\check_$1
 	test -z "$t" && return 0
 	test "$t" = skip && return 1
-	# trick for warning test
-	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing"
+	# trick to get test listed with warning
+	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing."
+	should false;
 	return 1
 }
 


