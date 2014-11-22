From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 17:52:09 +0000 (UTC)
Subject: master - tests: reduce thin test
Message-ID: <20141122175209.104CD60A4D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=078230971358c38b124fabb59b0dd3d92521b6f6
Commit:        078230971358c38b124fabb59b0dd3d92521b6f6
Parent:        4607cbcb0d785a8b112c32ee2487c5f9ee59cdc4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 18:15:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 18:51:02 2014 +0100

tests: reduce thin test

---
 test/shell/lvconvert-repair-thin.sh |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 8e35ad1..0e9534b 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -36,16 +36,14 @@ lvcreate -L2 -n fixed $vg
 lvs -a -o+seg_pe_ranges $vg
 #aux error_dev "$dev2" 2050:1
 
-vgchange -an $vg
-
-lvconvert --repair $vg/pool
-
-lvs -a $vg
+lvchange -an $vg/$lv2 $vg/$lv1 $vg/pool $vg/repair
 
 # Manual repair steps:
 # Test swapping - swap out thin-pool's metadata with our repair volume
 lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
+lvchange -ay $vg/repair
+
 #
 # To continue this test - we need real tools available
 # When they are not present mark test as skipped, but still
@@ -55,8 +53,6 @@ aux have_tool_at_least "$LVM_TEST_THIN_CHECK_CMD" 0 3 1 || skip
 aux have_tool_at_least "$LVM_TEST_THIN_DUMP_CMD" 0 3 1 || skip
 aux have_tool_at_least "$LVM_TEST_THIN_REPAIR_CMD" 0 3 1 || skip
 
-lvchange -aey $vg/repair $vg/fixed
-
 # Make some 'repairable' damage??
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/repair" bs=1 seek=40960 count=1
 
@@ -89,10 +85,10 @@ lvconvert -v --repair $vg/pool
 # Check repaired pool could be activated
 lvchange -ay $vg/pool
 
-lvchange -an $vg
+vgchange -an $vg
 
 # Restore damaged metadata
-lvconvert -y -f --poolmetadata $vg/pool_meta1 --thinpool $vg/pool
+lvconvert -y -f --poolmetadata $vg/pool_meta0 --thinpool $vg/pool
 
 # Check lvremove -ff works even with damaged pool
 lvremove -ff $vg


