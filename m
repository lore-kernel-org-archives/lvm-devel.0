From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Jan 2014 13:59:52 +0000 (UTC)
Subject: master - tests: validate acceptable external origin size
Message-ID: <20140129135952.2505160E35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42fa0e6dd14a105d17ca329f73e27f1daa64e9f3
Commit:        42fa0e6dd14a105d17ca329f73e27f1daa64e9f3
Parent:        155405b0e1d310fbc44f263c5e3a5c5d23043207
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 14:23:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 29 14:59:09 2014 +0100

tests: validate acceptable external origin size

---
 test/shell/lvconvert-thin-external.sh |    8 ++++++--
 test/shell/lvcreate-thin-external.sh  |   10 ++++++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 53758fc..dbe5972 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -49,9 +49,13 @@ fi
 
 lvcreate -l10 -T $vg/pool
 # Can't convert pool to external origin
-lvcreate -l10 -T $vg/pool1
+lvcreate -l10 -T $vg/pool1 -c 192k
 not lvconvert -T --thinpool $vg/pool1 $vg/pool --originname origin
-lvremove -f $vg/pool1
+# Create pool1 chunk_size unaligned LV and check failing conversion
+lvcreate -l2 -n $lv1 $vg
+not lvconvert -T --thinpool $vg/pool1 $vg/$lv1
+
+lvremove -f $vg/pool1 $vg/$lv1
 
 # create plain LV (will be used for external origin)
 lvcreate -L8M -n $lv1 $vg
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index c9aba6f..14c7f82 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -26,6 +26,16 @@ aux prepare_pvs 2 64
 
 vgcreate $vg -s 64K $(cat DEVICES)
 
+# Test validation for external origin being multiple of thin pool chunk size
+lvcreate -L10M -T $vg/pool192 -c 192k
+lvcreate -an -pr -Zn -l1 -n $lv1 $vg
+not lvcreate -s $vg/$lv1 --thinpool $vg/pool192
+
+lvcreate -an -pr -Zn -l5 -n $lv2 $vg
+not lvcreate -s $vg/$lv2 --thinpool $vg/pool192
+lvremove -f $vg
+
+# Prepare pool and external origin with filesystem
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
 


