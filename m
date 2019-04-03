From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 3 Apr 2019 07:30:02 -0400
Subject: master - tests: check auto-growth of thin-pool meta
Message-ID: <201904031130.x33BU2uK027584@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d6fe796bd03a49b44e387dc8026996292505f27
Commit:        5d6fe796bd03a49b44e387dc8026996292505f27
Parent:        fcec6691f074f1123b9c04c3130f84e35d195b01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:25:54 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 3 13:28:56 2019 +0200

tests: check auto-growth of thin-pool meta

---
 test/shell/lvextend-thin-full.sh |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-full.sh b/test/shell/lvextend-thin-full.sh
index e23eca8..263ab2f 100644
--- a/test/shell/lvextend-thin-full.sh
+++ b/test/shell/lvextend-thin-full.sh
@@ -28,7 +28,7 @@ test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_r
 
 aux have_thin 1 10 0 || skip
 
-aux prepare_vg 3 256
+aux prepare_vg 3 4096
 
 aux lvmconf 'activation/thin_pool_autoextend_percent = 30' \
 	    'activation/thin_pool_autoextend_threshold = 70'
@@ -58,6 +58,12 @@ not lvcreate -V10 $vg/pool
 lvextend --use-policies $vg/pool "$dev2" "$dev3"
 #should lvextend -l+100%FREE $vg/pool2
 
+check lv_field $vg/pool_tmeta size "3.00m"
+
+lvextend -L+3G $vg/pool
+
+check lv_field $vg/pool_tmeta size "3.50m"
+
 lvs -a $vg
 
 vgremove -ff $vg


