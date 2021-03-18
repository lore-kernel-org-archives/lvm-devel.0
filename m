From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:10 +0000 (GMT)
Subject: main - tests: add check for lvconvert without zeroing
Message-ID: <20210318181510.A2F5638438A3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=accf324ccba681ad06cd8bcb27ead17ec191a471
Commit:        accf324ccba681ad06cd8bcb27ead17ec191a471
Parent:        c06325263f6e8bbba3b240295ba766a7769735a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 18:19:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:57:45 2021 +0100

tests: add check for lvconvert without zeroing

Check lvconvert -Zn does not zero thin-pool metadata.
Also check --type zero is usable for thin-pool data.
---
 test/shell/thin-foreign-repair.sh | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
index 55e9f62c6..7cfa865f0 100644
--- a/test/shell/thin-foreign-repair.sh
+++ b/test/shell/thin-foreign-repair.sh
@@ -77,4 +77,22 @@ dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 fsck -n "$DM_DEV_DIR/mapper/$THIN"
 
+clean_thin_
+
+lvchange -an $vg
+
+# Take a copy of metadata
+lvchange -y -ay $vg/pool_tmeta
+
+lvcreate -L2 -n $lv1 $vg
+dd if="$DM_DEV_DIR/$vg/pool_tmeta" of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=1
+
+# Use zero backend for data device
+lvcreate --type zero -L2 -n $lv2 $vg
+
+lvconvert --thinpool $vg/$lv2 --poolmetadata $vg/$lv1 -Zn -y
+
+# Metadata should NOT be zeroed and device should be available
+dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/$vg/$lv2 0"
+
 # exit calls cleanup_mounted_and_teardown


