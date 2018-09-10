From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Sep 2018 15:27:35 -0400
Subject: master - tests: remove lvmetad variation
Message-ID: <201809101927.w8AJRZBB007633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07d2794a1640f05a451657a2176ccea5308d3298
Commit:        07d2794a1640f05a451657a2176ccea5308d3298
Parent:        b070c14a8b70dd8b8f4f3393e22ea9f1c584de76
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 10 14:26:57 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 10 14:26:57 2018 -0500

tests: remove lvmetad variation

---
 test/shell/inconsistent-metadata.sh |   55 +++++++++++++++-------------------
 1 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index f5ccd13..b42715d 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -31,43 +31,36 @@ init() {
 	aux restore_dev "$dev1"
 }
 
-# vgscan fixes up metadata (needs --cache option for direct scan if lvmetad is used)
-cache=""
-test -e LOCAL_LVMETAD && cache="--cache"
 init
-vgscan $cache 2>&1 | tee cmd.out
+vgscan 2>&1 | tee cmd.out
 grep "Inconsistent metadata found for VG $vg" cmd.out
-test -e LOCAL_LVMETAD && vgrename $vg foo && vgrename foo $vg # trigger a write
-vgscan $cache 2>&1 | tee cmd.out
+vgscan 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check lv_field $vg/resized lv_size "8.00m"
 
-# only vgscan would have noticed metadata inconsistencies when lvmetad is active
-if test ! -e LOCAL_LVMETAD; then
-	# vgdisplay fixes
-	init
-	vgdisplay $vg 2>&1 | tee cmd.out
-	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgdisplay $vg 2>&1 | tee cmd.out
-	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check lv_field $vg/resized lv_size "8.00m"
+# vgdisplay fixes
+init
+vgdisplay $vg 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgdisplay $vg 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check lv_field $vg/resized lv_size "8.00m"
 
-	# lvs fixes up
-	init
-	lvs $vg 2>&1 | tee cmd.out
-	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgdisplay $vg 2>&1 | tee cmd.out
-	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check lv_field $vg/resized lv_size "8.00m"
+# lvs fixes up
+init
+lvs $vg 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgdisplay $vg 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check lv_field $vg/resized lv_size "8.00m"
 
-	# vgs fixes up as well
-	init
-	vgs $vg 2>&1 | tee cmd.out
-	grep "Inconsistent metadata found for VG $vg" cmd.out
-	vgs $vg 2>&1 | tee cmd.out
-	not grep "Inconsistent metadata found for VG $vg" cmd.out
-	check lv_field $vg/resized lv_size "8.00m"
-fi
+# vgs fixes up as well
+init
+vgs $vg 2>&1 | tee cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgs $vg 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check lv_field $vg/resized lv_size "8.00m"
 
 echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
 vgremove -f $vg
@@ -77,7 +70,7 @@ aux backup_dev "$dev2"
 vgcreate $SHARED $vg "$dev1"
 vgextend $vg "$dev2"
 aux restore_dev "$dev2"
-vgscan $cache
+vgscan
 should check compare_fields vgs $vg vg_mda_count pvs "$dev2" vg_mda_count
 
 vgremove -ff $vg


