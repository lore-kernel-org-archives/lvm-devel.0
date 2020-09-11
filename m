From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:52 +0000 (GMT)
Subject: master - tests: lower at_least to version 1.19
Message-ID: <20200911195352.05DEF386F024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9b40083fc34b5e2a1bfc7b251b38c0b8737483f
Commit:        c9b40083fc34b5e2a1bfc7b251b38c0b8737483f
Parent:        f233d9a909a233c5147065bb5b17a2693622b281
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 13:35:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:55 2020 +0200

tests: lower at_least to version 1.19

With this version already can be seen different metadata usage on
kernel side, so lower the target version.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 2f16d48b5..38a405668 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2020 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -91,7 +91,7 @@ lvchange -an $vg/pool
 # Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
 # (Test for less than 4MiB free space in metadata, which is less than 25%)
 DATA=7200  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 20 0 || DATA=7400
+aux target_at_least dm-thin-pool 1 19 0 || DATA=7400
 fake_metadata_ "$DATA" 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
@@ -177,7 +177,7 @@ lvchange -an $vg
 
 #
 DATA=300  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 20 0 || DATA=350
+aux target_at_least dm-thin-pool 1 19 0 || DATA=350
 fake_metadata_ $DATA 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"


