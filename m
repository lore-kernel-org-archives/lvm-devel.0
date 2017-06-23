From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 17:33:47 -0400
Subject: master - tests: add transient failure test
Message-ID: <201706232133.v5NLXlbT022660@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1598bf154e80f43a7b215a69dc44bd9a87b166df
Commit:        1598bf154e80f43a7b215a69dc44bd9a87b166df
Parent:        f48d1bf1474f4485d42a180c542618a416f00006
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 23:20:01 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 23:32:44 2017 +0200

tests: add transient failure test

Check raid  repairs still 'present', but failed device.

TODO: tests needs more checking about repair actually doing its work.
---
 test/shell/lvconvert-repair-raid.sh |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index b25d861..86ac261 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2013-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -18,7 +18,8 @@ aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
 
 aux lvmconf 'allocation/maximise_cling = 0' \
-	    'allocation/mirror_logs_require_separate_pvs = 1'
+	    'allocation/mirror_logs_require_separate_pvs = 1' \
+	    'activation/raid_fault_policy = "allocate"'
 
 aux prepare_vg 8 80
 
@@ -37,6 +38,23 @@ RAID_SIZE=32
 # Fast sync and repair afterwards
 delay 0
 
+# RAID1 transient failure check
+lvcreate --type raid1 -m 1 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2"
+aux wait_for_sync $vg $lv1
+# enforce replacing live rimage leg with error target
+dmsetup remove -f $vg-${lv1}_rimage_1 || true
+# let it notice there is problem
+echo a > "$DM_DEV_DIR/$vg/$lv1"
+check grep_dmsetup status $vg-$lv1 AD
+lvconvert -y --repair $vg/$lv1 "$dev3"
+lvs -a -o+devices $vg
+aux wait_for_sync $vg $lv1
+# Raid should have fixed device
+check grep_dmsetup status $vg-$lv1 AA
+check lv_on $vg ${lv1}_rimage_1 "$dev3"
+lvremove -ff $vg/$lv1
+
+
 # RAID1 dual-leg single replace after initial sync
 lvcreate --type raid1 -m 1 -L $RAID_SIZE -n $lv1 $vg "$dev1" "$dev2"
 aux wait_for_sync $vg $lv1


