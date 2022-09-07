From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:57 +0000 (GMT)
Subject: main - tests: make damage optional
Message-ID: <20220907130457.610133858005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80b782f86ffea19a9881b026df3dc133eebffbe5
Commit:        80b782f86ffea19a9881b026df3dc133eebffbe5
Parent:        e1e05cf2b526fbd8689dca8b0b232f0b1ce8ed7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 14:07:46 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: make damage optional

Investigate how to damage thin-pool across different versions/platforms.
Until them - use  'should' for test result.
---
 test/shell/lvconvert-repair-thin.sh | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 9b94cbfd2..0fb0d76ff 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -61,9 +61,10 @@ aux have_tool_at_least "$LVM_TEST_THIN_REPAIR_CMD" 0 3 1 || skip
 # Make some 'repairable' damage??
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/repair" bs=1 seek=40960 count=1
 
-not "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/repair"
+# Investige how to make such damage across different versions of thin-pool target.
+should not "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/repair"
 
-not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
+should not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 
 "$LVM_TEST_THIN_REPAIR_CMD" -i "$DM_DEV_DIR/$vg/repair" -o "$DM_DEV_DIR/$vg/fixed"
 

