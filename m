From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 17:03:21 +0000 (UTC)
Subject: master - tests: updates for new test
Message-ID: <20140306170321.5204360539@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef1d910dee1157d157402c28680dfe34e06194af
Commit:        ef1d910dee1157d157402c28680dfe34e06194af
Parent:        6b561a7a3b0a9dde9bba139154ebc881e89542e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 17:55:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 18:01:21 2014 +0100

tests: updates for new test

snaphost needs exclusive origin for cluster
older md5 needs 2 space char
---
 test/shell/snapshot-maxsize.sh    |    2 +-
 test/shell/snapshot-reactivate.sh |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 3d49a61..a20e306 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -18,7 +18,7 @@ aux prepare_pvs 1
 
 vgcreate -s 1K $vg $(cat DEVICES)
 
-lvcreate -L1 -n $lv1 $vg
+lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
 lvcreate -L2 -s $vg/$lv1 -n $lv2
 
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 289d81d..a4478b7 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -19,6 +19,7 @@
 
 # Snapshot should remain unmodified
 check_s_() {
+	rm -f debug.log
 	md5sum -c md5
 	#diff data "$DM_DEV_DIR/$vg/s"
 }
@@ -30,9 +31,9 @@ aux prepare_vg
 # 8M file with some random data
 dd if=/dev/urandom of=data bs=1M count=1
 dd if=data of=data bs=1M count=7 seek=1
-echo "$(md5sum data | cut -d' ' -f1) $DM_DEV_DIR/$vg/s" >md5
+echo "$(md5sum data | cut -d' ' -f1)  $DM_DEV_DIR/$vg/s" >md5
 
-lvcreate -L 8M -n o $vg
+lvcreate -aey -L 8M -n o $vg
 dd if=data of="$DM_DEV_DIR/$vg/o" bs=1M
 
 lvcreate -L 8M -s -n s $vg/o


