From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Apr 2010 13:55:09 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c test/t- ...
Message-ID: <20100421135509.15735.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-21 13:55:08

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	test           : t-lvconvert-mirror.sh t-mirror-lvconvert.sh 

Log message:
	Disallow the primary mirror image from being removed when the
	mirror is not in-sync.  This restriction is not extended to
	repair operations (i.e. it will not limit what 'lvconvert --repair'
	can do).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1532&r2=1.1533
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2010/04/20 18:17:56	1.1532
+++ LVM2/WHATS_NEW	2010/04/21 13:55:08	1.1533
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Disallow primary mirror image removal when mirror is not in-sync.
   Remove obsolete --name parameter from vgcfgrestore.
   Add -S command to clvmd to restart the daemon preserving exclusive locks.
   Increment lvm2app version from 1 to 2.
--- LVM2/lib/metadata/mirror.c	2010/04/20 12:14:28	1.113
+++ LVM2/lib/metadata/mirror.c	2010/04/21 13:55:08	1.114
@@ -751,7 +751,7 @@
 				 uint32_t *removed)
 {
 	uint32_t m;
-	uint32_t s;
+	int32_t s;
 	int removable_pvs_specified;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
@@ -781,15 +781,25 @@
 
 	/* Move removable_pvs to end of array */
 	if (removable_pvs_specified) {
-		for (s = 0; s < mirrored_seg->area_count &&
-			    old_area_count - new_area_count < num_removed; s++) {
+		for (s = mirrored_seg->area_count - 1;
+		     s >= 0 && old_area_count - new_area_count < num_removed;
+		     s--) {
 			sub_lv = seg_lv(mirrored_seg, s);
 
 			if (!is_temporary_mirror_layer(sub_lv) &&
 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
+				/*
+				 * Check if the user is trying to pull the
+				 * primary mirror image when the mirror is
+				 * not in-sync.
+				 */
+				if ((s == 0) && !_mirrored_lv_in_sync(lv) &&
+				    !(lv->status & PARTIAL_LV)) {
+					log_error("Unable to remove primary mirror image while mirror is not in-sync");
+					return_0;
+				}
 				if (!shift_mirror_images(mirrored_seg, s))
 					return_0;
-				s--; /* adjust counter after shifting */
 				new_area_count--;
 			}
 		}
--- LVM2/test/t-lvconvert-mirror.sh	2010/04/12 19:32:58	1.2
+++ LVM2/test/t-lvconvert-mirror.sh	2010/04/21 13:55:08	1.3
@@ -61,10 +61,20 @@
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
 lvremove -ff $vg
 
-lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+# Start w/ 3-way mirror
+# Test pulling primary image before mirror in-sync (should fail)
+# Test pulling primary image after mirror in-sync (should work)
+# Test that the correct devices remain in the mirror
+lvcreate -l8 -m2 -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
+# FIXME:
+#  This is somewhat timing dependent - sync /could/ finish before
+#  we get a chance to have this command fail
+not lvconvert -m-1 $vg/$lv1 $dev1
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do
+	sleep 1
+done
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2
 check linear $vg $lv1
 check lv_on $vg/$lv1 $dev4
-
--- LVM2/test/t-mirror-lvconvert.sh	2010/04/07 16:00:19	1.23
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/21 13:55:08	1.24
@@ -98,6 +98,12 @@
   while (lvs --noheadings -oattr "$lv" | grep -q '^ *c'); do sleep 1; done
 }
 
+wait_sync_()
+{
+  local lv=$1
+  while [ `lvs --noheadings -o copy_percent $lv` != "100.00" ]; do sleep 1; done
+}
+
 check_no_tmplvs_()
 {
   local lv=$1
@@ -404,6 +410,7 @@
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
+wait_sync_ $vg/$lv1 # cannot pull primary unless mirror in-sync
 lvconvert -m0 $vg/$lv1 $dev1 
 lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 


