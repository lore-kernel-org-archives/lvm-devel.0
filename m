From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:50 +0000 (GMT)
Subject: master - tests: check vdopool policy extension
Message-ID: <20200922214650.7833E39450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbed63eeb9d06958a42721dcd2093ff80582f47d
Commit:        cbed63eeb9d06958a42721dcd2093ff80582f47d
Parent:        3a3307c0d8029f545a31d305a23a0dec2ece65f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 15:44:31 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:28:43 2020 +0200

tests: check vdopool policy extension

Check pool will grow even with small policy amount.
---
 test/shell/lvextend-vdo.sh | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvextend-vdo.sh b/test/shell/lvextend-vdo.sh
index 5a68bb157..2e9cee4f5 100644
--- a/test/shell/lvextend-vdo.sh
+++ b/test/shell/lvextend-vdo.sh
@@ -17,7 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_vdo 6 2 0 || skip
 
-aux lvmconf 'allocation/vdo_slab_size_mb = 128'
+aux lvmconf "activation/vdo_pool_autoextend_percent = 1" \
+	    "activation/vdo_pool_autoextend_threshold = 70" \
+	    "allocation/vdo_slab_size_mb = 128"
 
 aux prepare_vg 1 7000
 lvcreate --vdo -V3G -L4G -n $lv1 $vg/$lv2
@@ -31,4 +33,22 @@ check lv_field $vg/${lv2}_vdata size "5.00g"
 lvextend -L+1G $vg/$lv1
 check lv_field $vg/$lv1 size "4.00g"
 
+lvremove -f $vg
+
+
+# Resize by policy
+lvcreate --vdo -V3G -L4G -n $lv1 $vg/$lv2
+
+# Fill VDO LV to match configured threshold >= 70%
+dd if=/dev/urandom of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=60 oflag=direct
+PERCENT=$(get lv_field $vg/$lv2 data_percent | cut -d. -f1)
+test "$PERCENT" -ge "70"
+
+lvextend --use-policies "$vg/$lv2"
+
+# although autoextend is only 1%, it needs to extend at least by slab_size
+# this is corner case where min growth requires 128M + 128k
+check lv_field $vg/$lv2 size "<4.13g"
+
+
 vgremove -ff $vg


