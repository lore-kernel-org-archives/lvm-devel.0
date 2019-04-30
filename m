From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:30:46 -0400
Subject: stable-2.02 - tests: check auto-growth of thin-pool meta
Message-ID: <201904301130.x3UBUk4a020452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1370277ea7be06a945803a018ad9f38d681c6d67
Commit:        1370277ea7be06a945803a018ad9f38d681c6d67
Parent:        f38cfd09c4a2b2ea76662264f3f99abff24b3ca0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:25:54 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:06:08 2019 +0200

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


