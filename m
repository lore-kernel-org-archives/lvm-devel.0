From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 09:25:16 +0000 (UTC)
Subject: master - tests: Revert update for new thin pool messaging
Message-ID: <20150817092516.5DEEB6104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a606966029d411a1336eb5bc2f99a4162e0d97d6
Commit:        a606966029d411a1336eb5bc2f99a4162e0d97d6
Parent:        79ea81b8a849677489c35717fb571d3d6e67a0a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 14 11:08:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 11:25:03 2015 +0200

tests: Revert update for new thin pool messaging

This reverts commit 3dbb9a57ca684271dbbc26300aa2e35da9608aa3.
Original code is back as the code restored previous TID handling.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    2 +-
 test/shell/thin-volume-list.sh                |    7 +++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 6897072..d7f5ccc 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -77,7 +77,7 @@ grep expected out
 check inactive $vg pool_tmeta
 
 # Transaction_id is higher by 1
-fake_metadata_ 10 3 >data
+fake_metadata_ 10 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index 88cae35..c3dab25 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -29,8 +29,11 @@ lvcreate -T -L8M $vg/pool -V10M -n $lv1
 # skip $vg from activation
 aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
 
-# We cannot pass - pool volume cannot be manipulated
-not lvcreate -V10 -n $lv2 -T $vg/pool
+# We still could pass - since pool is still active
+lvcreate -V10 -n $lv2 -T $vg/pool
+
+# but $lv2 is not active
+check inactive $vg $lv2
 
 vgchange -an $vg
 


