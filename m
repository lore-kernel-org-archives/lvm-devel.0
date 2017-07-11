From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:46 -0400
Subject: master - tests: improve logic for a race to catch abortion
Message-ID: <201707111522.v6BFMkUh015665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b97f75b1331b112412073ffd54812375867d9de7
Commit:        b97f75b1331b112412073ffd54812375867d9de7
Parent:        a87860965e99ae2d11f2c2496adb33fff050f4d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 17:20:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 17:21:25 2017 +0200

tests: improve logic for a race to catch abortion

---
 test/shell/lvconvert-cache-abort.sh |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 9cf9410..468f8aa 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -44,13 +44,21 @@ lvdisplay --maps $vg
 sync
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=4k count=100 conv=fdatasync
 
-LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >log 2>&1 &
+LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -v --splitcache $vg/$lv1 >logconvert 2>&1 &
 PID_CONVERT=$!
-sleep 0.2
+while ! (dmsetup table $vg-$lv1 | grep cleaner) ; do
+	echo "Waiting for cleaner policy on $vg/$lv1"
+	sleep .05
+done
 kill -INT $PID_CONVERT
 aux enable_dev "$dev1"
 wait
-grep -E "Flushing.*aborted" log
+
+grep -E "Flushing.*aborted" logconvert || {
+	cat logconvert || true
+	die "Flushing of $vg/$lv1 not aborted ?"
+}
+
 # check the table got restored
 check grep_dmsetup table $vg-$lv1 "writeback"
 


