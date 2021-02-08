From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:05 +0000 (GMT)
Subject: main - tests: support for resized cached LVs
Message-ID: <20210208224505.0C8C03800C1A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b86eb913c18ca67415521b8003c04adf41a5496c
Commit:        b86eb913c18ca67415521b8003c04adf41a5496c
Parent:        5ec24dfb0bb0c9e48d59d6fbb83262a7087964e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 18:45:43 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

tests: support for resized cached LVs

Support for cached LVs is now enabled.
---
 test/shell/lvextend-thin-cache.sh | 19 +++++++++++++------
 test/shell/lvextend-thin.sh       | 18 +++++++++++++++++-
 2 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvextend-thin-cache.sh b/test/shell/lvextend-thin-cache.sh
index f7bbfd992..40c213b21 100644
--- a/test/shell/lvextend-thin-cache.sh
+++ b/test/shell/lvextend-thin-cache.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2017-2020 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -22,15 +22,22 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 0 0 || skip
 aux have_cache 1 3 0 || skip
 
-aux prepare_vg 2
+aux prepare_vg 2 20000
 
-lvcreate -l2 -T $vg/pool
+lvcreate -l1 -T $vg/pool
 # Caching of thin-pool's dataLV
 lvcreate -H -L10 $vg/pool
 
-# Resize is unsupported
-not lvextend -l+2 $vg/pool 2>&1 | tee out
+lvextend -l+2 $vg/pool
 
-grep "Unable to resize" out
+check lv_first_seg_field $vg/pool seg_size_pe "3"
+
+lvextend -L10G $vg/pool
+
+# Check data are resized and its metadata are matching data size
+check lv_field $vg/pool size		 "10.00g"
+check lv_field $vg/pool_tdata size	 "10.00g"
+check lv_field $vg/pool_tdata_corig size "10.00g"
+check lv_field $vg/pool_tmeta size "10.00m"
 
 vgremove -ff $vg
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 3e39ea3eb..d1efd4798 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -22,6 +22,22 @@ aux have_thin 1 0 0 || skip
 aux prepare_vg 3
 lvcreate -i2 -l2 -T $vg/pool2
 lvextend -l+2 $vg/pool2 "$dev2" "$dev3"
-should lvextend -l+100%FREE $vg/pool2
+lvextend -l+100%FREE $vg/pool2
+
+lvremove -f $vg
+
+lvcreate -L1 -n pool $vg
+# Does work only with thin-pools
+not lvextend --poolmetadatasize +1 $vg/pool
+lvconvert -y --thinpool $vg/pool --poolmetadatasize 2
+
+# _tdata cannot be used with --poolmetadata
+not lvextend --poolmetadatasize +1 $vg/pool_tdata
+lvextend --poolmetadatasize +1 $vg/pool_tmeta
+lvextend --poolmetadatasize +1 --size +1 $vg/pool
+check lv_field $vg/pool_tmeta size "4.00m"
+check lv_field $vg/lvol0_pmspare size "4.00m"
+
+not lvresize --poolmetadatasize -1 $vg/pool
 
 vgremove -ff $vg


