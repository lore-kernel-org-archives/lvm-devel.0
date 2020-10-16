From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:37 +0000 (GMT)
Subject: stable-2.02 - tests: switch for checking version of installed tools
Message-ID: <20201016191137.3751E396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b490cddfbcd6f4add64303fcd81751f98f086d4c
Commit:        b490cddfbcd6f4add64303fcd81751f98f086d4c
Parent:        844037ecdf64be306310ba48f4ae593cc8fde970
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 13:35:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: switch for checking version of installed tools

It looks like older tools were compacting metadata more.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 2f16d48b5..5f6db994a 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2020 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -19,6 +19,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
+
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
 }
@@ -59,6 +60,12 @@ test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_r
 "$LVM_TEST_THIN_RESTORE_CMD" -V || skip
 aux have_thin 1 10 0 || skip
 
+BIG_DATA=""
+case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
+	# With older version of thin-tool we got slightly more compact metadata
+	0.[0-6]*|0.7.0*) BIG_DATA="generate_more_metadata" ;;
+esac
+
 aux prepare_dmeventd
 
 aux prepare_pvs 3 256
@@ -91,7 +98,7 @@ lvchange -an $vg/pool
 # Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
 # (Test for less than 4MiB free space in metadata, which is less than 25%)
 DATA=7200  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 20 0 || DATA=7400
+test -z "$BIG_DATA" || DATA=7400
 fake_metadata_ "$DATA" 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
@@ -177,7 +184,7 @@ lvchange -an $vg
 
 #
 DATA=300  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 20 0 || DATA=350
+test -z "$BIG_DATA" || DATA=350
 fake_metadata_ $DATA 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"


