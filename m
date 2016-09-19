From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:41 +0000 (UTC)
Subject: master - tests: check for metadata test working properly
Message-ID: <20160919120141.010746053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a30adc062b30ef434857eb6d8345d8b66af120a
Commit:        1a30adc062b30ef434857eb6d8345d8b66af120a
Parent:        561f773bb47f11d495701e15d234c85cf746e285
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 21:55:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

tests: check for metadata test working properly

Add more tests to check they guard minimum free space in metadata
for new thin volume creation.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |   68 +++++++++++++++++++++++--
 1 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index a892bd4..6d27600 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -60,13 +60,73 @@ aux have_thin 1 10 0 || skip
 
 aux prepare_dmeventd
 
-aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
-	    "activation/thin_pool_autoextend_threshold = 70"
-
 aux prepare_pvs 3 256
 
 vgcreate -s 1M $vg $(cat DEVICES)
 
+# Testing dmeventd does NOT autoresize when default threshold 100% is left
+lvcreate -L200M -V50M -n thin -T $vg/pool
+lvcreate -V2M -n thin2 $vg/pool
+lvcreate -L2M -n $lv1 $vg
+lvcreate -L32M -n $lv2 $vg
+lvcreate -L32M -n $lv3 $vg
+lvchange -an $vg/thin $vg/thin2 $vg/pool
+
+# Filling 2M metadata volume
+# (Test for less then 25% free space in metadata)
+fake_metadata_ 400 2 >data
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+
+# Swap volume with restored fake metadata
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv1
+
+# Not alllowed when thin-pool metadata free space is <75% for 2M meta
+fail lvcreate -V20 $vg/pool
+
+
+lvchange -an $vg/pool
+
+# Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
+# (Test for less then 4MiB free space in metadata, which is less then 25%)
+fake_metadata_ 7400 2 >data
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
+# Swap volume with restored fake metadata
+lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv2
+lvchange -ay $vg/pool
+# Check generated metadata consume more then 88%
+test "$(meta_percent_)" -gt "88"
+lvchange -an $vg/pool
+
+# Creation of thin LV is prohibited when metadata are above this value
+fail lvcreate -V20 $vg/pool 2>&1 | tee out
+grep "free space" out
+lvs -a $vg
+
+
+# Check that even with 99% threshold policy - metadata will go below 88%
+lvextend --use-policies --config "\
+activation/thin_pool_autoextend_percent=1 \
+activation/thin_pool_autoextend_threshold=99" $vg/pool
+test "$(meta_percent_)" -lt "88"
+
+# After such operatoin creation of thin LV has to pass
+lvcreate -V20 $vg/pool
+
+# Let's revalidate pool metadata (thin_check upon deactivation/activation)
+lvchange -an $vg
+lvchange -ay $vg/pool
+
+lvremove -f $vg
+
+
+
+#########################################################
+# Test automatic resize with help of dmeventd DOES work #
+#########################################################
+
+aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
+	    "activation/thin_pool_autoextend_threshold = 70"
+
 # Testing dmeventd autoresize
 lvcreate -L200M -V500M -n thin -T $vg/pool 2>&1 | tee out
 not grep "WARNING: Sum" out


