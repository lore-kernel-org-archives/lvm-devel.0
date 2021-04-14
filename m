From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 14 Apr 2021 09:07:36 +0000 (GMT)
Subject: main - Revert "tests: add check for lvconvert without zeroing"
Message-ID: <20210414090736.67D3C3987C24@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94c264b9754c92a6d48ca7911a9db246490e64b8
Commit:        94c264b9754c92a6d48ca7911a9db246490e64b8
Parent:        9a33388c1ac69cd23d28e3d53c59130726670c98
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 14 10:53:21 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 14 10:53:34 2021 +0200

Revert "tests: add check for lvconvert without zeroing"

This reverts commit accf324ccba681ad06cd8bcb27ead17ec191a471.
---
 test/shell/thin-foreign-repair.sh | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
index 7cfa865f0..55e9f62c6 100644
--- a/test/shell/thin-foreign-repair.sh
+++ b/test/shell/thin-foreign-repair.sh
@@ -77,22 +77,4 @@ dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 fsck -n "$DM_DEV_DIR/mapper/$THIN"
 
-clean_thin_
-
-lvchange -an $vg
-
-# Take a copy of metadata
-lvchange -y -ay $vg/pool_tmeta
-
-lvcreate -L2 -n $lv1 $vg
-dd if="$DM_DEV_DIR/$vg/pool_tmeta" of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=1
-
-# Use zero backend for data device
-lvcreate --type zero -L2 -n $lv2 $vg
-
-lvconvert --thinpool $vg/$lv2 --poolmetadata $vg/$lv1 -Zn -y
-
-# Metadata should NOT be zeroed and device should be available
-dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/$vg/$lv2 0"
-
 # exit calls cleanup_mounted_and_teardown


