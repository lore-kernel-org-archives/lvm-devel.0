From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 15:27:55 +0000 (UTC)
Subject: master - tests: update thin test
Message-ID: <20150817152755.AB01D6035D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77357081c8143d13d02aa0b7d5eb044a29aa65c3
Commit:        77357081c8143d13d02aa0b7d5eb044a29aa65c3
Parent:        4b28383b1c5f84d5f4190dd19586082c23d6c904
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 17 17:07:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 17:07:09 2015 +0200

tests: update thin test

Since we now let pass activation of thin-pool 'off-by-one' for
plain 'vgchange -ay' update the test to use higher TID.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index d7f5ccc..4e80f75 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -63,8 +63,9 @@ vgcreate -s 1M $vg $(cat DEVICES)
 # Testing dmeventd autoresize
 lvcreate -L200M -V500M -n thin -T $vg/pool 2>&1 | tee out
 not grep "WARNING: Sum" out
+lvcreate -V2M -n thin2 $vg/pool
 lvcreate -L2M -n $lv1 $vg
-lvchange -an $vg/thin $vg/pool
+lvchange -an $vg/thin $vg/thin2 $vg/pool
 
 # Prepare some fake metadata with unmatching id
 # Transaction_id is lower by 1 and there are no message -> ERROR
@@ -77,7 +78,7 @@ grep expected out
 check inactive $vg pool_tmeta
 
 # Transaction_id is higher by 1
-fake_metadata_ 10 2 >data
+fake_metadata_ 10 3 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
@@ -86,7 +87,7 @@ grep expected out
 check inactive $vg pool_tmeta
 
 # Prepare some fake metadata prefilled to ~81% (>70%)
-fake_metadata_ 400 1 >data
+fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata


