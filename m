From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jul 2015 14:19:13 +0000 (UTC)
Subject: master - tests: update for new thin pool messaging
Message-ID: <20150703141913.6B86960FE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3dbb9a57ca684271dbbc26300aa2e35da9608aa3
Commit:        3dbb9a57ca684271dbbc26300aa2e35da9608aa3
Parent:        a900d150e4658a5d72c39acdd4fefd069b8f00b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 1 13:31:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 3 16:13:15 2015 +0200

tests: update for new thin pool messaging

---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    2 +-
 test/shell/thin-volume-list.sh                |    7 ++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 473f1ca..72cdb81 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -76,7 +76,7 @@ grep expected out
 check inactive $vg pool_tmeta
 
 # Transaction_id is higher by 1
-fake_metadata_ 10 2 >data
+fake_metadata_ 10 3 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
 not vgchange -ay $vg 2>&1 | tee out
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index c3dab25..88cae35 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -29,11 +29,8 @@ lvcreate -T -L8M $vg/pool -V10M -n $lv1
 # skip $vg from activation
 aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
 
-# We still could pass - since pool is still active
-lvcreate -V10 -n $lv2 -T $vg/pool
-
-# but $lv2 is not active
-check inactive $vg $lv2
+# We cannot pass - pool volume cannot be manipulated
+not lvcreate -V10 -n $lv2 -T $vg/pool
 
 vgchange -an $vg
 


