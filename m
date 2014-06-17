From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:46 +0000 (UTC)
Subject: master - tests: detect version of thin_restore command
Message-ID: <20140617132446.2342061207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8403bbd4adabb6718f45f67e5a4a98f6de26dbb6
Commit:        8403bbd4adabb6718f45f67e5a4a98f6de26dbb6
Parent:        6fb19f37fe6419fd2c22c04ffd71e0ac4a0bca36
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 17:46:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:43:05 2014 +0200

tests: detect version of thin_restore command

Skip test when missing.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 44144c6..d7be3a2 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -43,6 +43,7 @@ fake_metadata_() {
 }
 
 test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_restore) || skip
+"$LVM_TEST_THIN_RESTORE_CMD" -V || skip
 aux have_thin 1 10 0 || skip
 
 aux prepare_dmeventd
@@ -62,7 +63,7 @@ lvchange -an $vg/thin $vg/pool
 # Prepare some fake metadata with unmatching id
 # Transaction_id is lower by 1 and there are no message -> ERROR
 fake_metadata_ 10 0 >data
-$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
@@ -71,7 +72,7 @@ check inactive $vg pool_tmeta
 
 # Transaction_id is higher by 1
 fake_metadata_ 10 2 >data
-$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
 grep expected out
@@ -80,7 +81,7 @@ check inactive $vg pool_tmeta
 
 # Prepare some fake metadata prefilled to ~81% (>70%)
 fake_metadata_ 400 1 >data
-$LVM_TEST_THIN_RESTORE_CMD -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1


