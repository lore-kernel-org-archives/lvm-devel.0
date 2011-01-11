From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Jan 2011 17:05:12 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110111170512.2348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-11 17:05:10

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 
	test           : t-lvconvert-mirror-basic.sh 
	                 t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair-replace.sh 
	                 t-lvconvert-repair.sh t-lvconvert-twostep.sh 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Add disk to mirrored log type conversion.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1875&r2=1.1876
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228

--- LVM2/WHATS_NEW	2011/01/10 21:12:54	1.1875
+++ LVM2/WHATS_NEW	2011/01/11 17:05:08	1.1876
@@ -1,5 +1,6 @@
 Version 2.02.81 -
 ===================================
+  Add disk to mirrored log type conversion.
 
 Version 2.02.80 - 10th January 2011
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2011/01/10 14:02:31	1.242
+++ LVM2/lib/metadata/lv_manip.c	2011/01/11 17:05:09	1.243
@@ -1557,8 +1557,7 @@
 			       parallel_areas)))
 		return_NULL;
 
-	if (!segtype_is_virtual(segtype) &&
-	    !_allocate(ah, vg, lv, 1, allocatable_pvs)) {
+	if (!_allocate(ah, vg, lv, 1, allocatable_pvs)) {
 		alloc_destroy(ah);
 		return_NULL;
 	}
--- LVM2/lib/metadata/mirror.c	2010/11/30 11:53:32	1.138
+++ LVM2/lib/metadata/mirror.c	2011/01/11 17:05:09	1.139
@@ -1295,7 +1295,7 @@
 			      struct logical_volume **img_lvs,
 			      int log)
 {
-	uint32_t m;
+	uint32_t m, first_area;
 	char *img_name;
 	size_t len;
 	
@@ -1322,10 +1322,13 @@
 		}
 
 		if (log) {
-			if (!lv_add_log_segment(ah, m * stripes + 1, img_lvs[m], 0)) {
-				log_error("Aborting. Failed to add mirror image segment "
-					  "to %s. Remove new LV and retry.",
-					  img_lvs[m]->name);
+			first_area = m * stripes + (log - 1);
+
+			if (!lv_add_log_segment(ah, first_area, img_lvs[m], 0)) {
+				/* error msg already from lv_add_log_segment */
+				log_verbose("Failed to add mirror image segment"
+					    " to %s. Remove new LV and retry.",
+					    img_lvs[m]->name);
 				return 0;
 			}
 		} else {
@@ -1760,7 +1763,7 @@
 	}
 
 	if ((log_count > 1) &&
-	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 1)) {
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 2)) {
 		log_error("Failed to form mirrored log.");
 		return NULL;
 	}
@@ -1792,6 +1795,7 @@
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
+	int old_log_count;
 	int r = 0;
 
 	if (dm_list_size(&lv->segments) != 1) {
@@ -1811,6 +1815,15 @@
 		return 0;
 	}
 
+	log_lv = first_seg(lv)->log_lv;
+	old_log_count = (log_lv) ? lv_mirror_count(log_lv) : 0;
+	if (old_log_count == log_count) {
+		log_verbose("Mirror already has a %s log",
+			    !log_count ? "core" :
+			    (log_count == 1) ? "disk" : "mirrored");
+		return 1;
+	}
+
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
 		return_0;
 
@@ -1826,13 +1839,24 @@
 
 	/* allocate destination extents */
 	ah = allocate_extents(lv->vg, NULL, segtype,
-			      0, 0, log_count, region_size, 0,
+			      0, 0, log_count - old_log_count, region_size, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;
 	}
 
+	if (old_log_count) {
+		/* Converting from disk to mirrored log */
+		if (!_form_mirror(cmd, ah, log_lv, log_count - 1, 1, 0,
+				  region_size, 1)) {
+			log_error("Failed to convert mirror log");
+			return 0;
+		}
+		r = 1;
+		goto out;
+	}
+
 	/* check sync status */
 	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
 	    (sync_percent == PERCENT_100))
--- LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/05 00:16:20	1.5
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/11 17:05:09	1.6
@@ -54,12 +54,6 @@
 	local active=true
 	local i
 
-	if [ "$start_log_type" = "disk" ] &&
-		[ "$finish_log_type" = "mirrored" ]; then
-		echo "FIXME:  disk -> mirrored log conversion not yet supported by LVM"
-		return 0
-	fi
-
 	test "$5" = "active" && active=false
 	#test $finish_count -gt $start_count && up=true
 
--- LVM2/test/t-lvconvert-repair-policy.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-lvconvert-repair-policy.sh	2011/01/11 17:05:09	1.7
@@ -55,7 +55,8 @@
 cleanup $dev1
 
 # Fail a leg of a mirror w/ no available spare
-# Expected result: 2-way with corelog
+# Expected result: linear
+#                  (or 2-way with leg/log overlap if alloc anywhere)
 aux disable_dev $dev2 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
--- LVM2/test/t-lvconvert-repair-replace.sh	2011/01/05 00:16:20	1.2
+++ LVM2/test/t-lvconvert-repair-replace.sh	2011/01/11 17:05:09	1.3
@@ -13,6 +13,7 @@
 
 aux prepare_vg 6
 
+# 3-way, disk log
 # multiple failures, full replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
 aux disable_dev $dev1 $dev2
@@ -23,8 +24,37 @@
 check mirror $vg 3way
 aux enable_dev $dev1 $dev2
 
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 2-way, mirrored log
+# Double log failure, full replace
+lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+    $dev1 $dev2 $dev3:0 $dev4:0
+aux disable_dev $dev3 $dev4
+echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 2way.out
+vgreduce --removemissing $vg
+check mirror $vg 2way
+aux enable_dev $dev3 $dev4
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5 $dev6
+
+# 3-way, mirrored log
+# Single log failure, replace
+lvcreate --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev $dev4
+
 vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
 
+# 3-way, disk log
 # multiple failures, partial replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
 aux disable_dev $dev1 $dev2
--- LVM2/test/t-lvconvert-repair.sh	2011/01/05 00:16:20	1.9
+++ LVM2/test/t-lvconvert-repair.sh	2011/01/11 17:05:09	1.10
@@ -14,6 +14,7 @@
 
 # fail multiple devices
 
+# 4-way, disk log => 2-way, disk log
 aux prepare_vg 5
 lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
 aux disable_dev $dev2 $dev4
@@ -23,6 +24,7 @@
 aux enable_dev $dev2 $dev4
 check mirror $vg 4way $dev5
 
+# 3-way, disk log => linear
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg
 aux disable_dev $dev1 $dev2
@@ -37,6 +39,7 @@
 
 # fail just log and get it removed
 
+# 3-way, disk log => 3-way, core log
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
 aux disable_dev $dev4
@@ -48,6 +51,20 @@
 vgreduce --removemissing $vg
 aux enable_dev $dev4
 
+# 3-way, mirrored log => 3-way, core log
+aux prepare_vg 5
+lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
+    $dev1 $dev2 $dev3 $dev4:0 $dev5:0
+aux disable_dev $dev4 $dev5
+echo n | lvconvert --repair $vg/3way
+check mirror $vg 3way core
+lvs -a -o +devices | not grep unknown
+lvs -a -o +devices | not grep mlog
+dmsetup ls | grep $PREFIX | not grep mlog
+vgreduce --removemissing $vg
+aux enable_dev $dev4 $dev5
+
+# 2-way, disk log => 2-way, core log
 aux prepare_vg 5
 lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
 aux disable_dev $dev3
--- LVM2/test/t-lvconvert-twostep.sh	2011/01/05 00:16:20	1.2
+++ LVM2/test/t-lvconvert-twostep.sh	2011/01/11 17:05:09	1.3
@@ -12,10 +12,15 @@
 . lib/test
 
 aux prepare_vg 4
+
 lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
 not lvconvert -m 2 --mirrorlog core $vg/mirror $dev3 2>&1 | tee errs
 grep "two steps" errs
+
 lvconvert -m 2 $vg/mirror $dev3
 lvconvert --mirrorlog core $vg/mirror
 not lvconvert -m 1 --mirrorlog disk $vg/mirror $dev3 2>&1 | tee errs
 grep "two steps" errs
+
+not lvconvert -m 1 --mirrorlog mirrored $vg/mirror $dev3 $dev4 2>&1 | tee errs
+grep "two steps" errs
--- LVM2/tools/lvconvert.c	2011/01/05 23:18:47	1.154
+++ LVM2/tools/lvconvert.c	2011/01/11 17:05:10	1.155
@@ -718,6 +718,7 @@
 				    operable_pvs, 0U);
 }
 
+static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv);
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
@@ -738,14 +739,6 @@
 						  lv->le_count,
 						  lp->region_size);
 
-	/* Add a log where there is none */
-	if (!old_log_count) {
-		if (!add_mirror_log(cmd, original_lv, log_count,
-				    region_size, operable_pvs, lp->alloc))
-			return_0;
-		return 1;
-	}
-
 	/* Remove an existing log completely */
 	if (!log_count) {
 		if (!remove_mirror_log(cmd, original_lv, operable_pvs,
@@ -759,9 +752,17 @@
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
-		log_error("Adding log redundancy not supported yet.");
-		log_error("Try converting the log to 'core' first.");
-		return_0;
+		if (!add_mirror_log(cmd, original_lv, log_count,
+				    region_size, operable_pvs, lp->alloc))
+			return_0;
+		/*
+		 * FIXME: This simple approach won't work in cluster mirrors,
+		 *        but it doesn't matter because we don't support
+		 *        mirrored logs in cluster mirrors.
+		 */
+		if (old_log_count)
+			return _reload_lv(cmd, log_lv);
+		return 1;
 	}
 
 	/* Reducing redundancy of the log */
@@ -1109,7 +1110,8 @@
 
 		/* FIXME: can't have multiple mlogs. force corelog. */
 		if (!lv_add_mirrors(cmd, lv,
-				    new_mimage_count - old_mimage_count, lp->stripes, lp->stripe_size,
+				    new_mimage_count - old_mimage_count,
+				    lp->stripes, lp->stripe_size,
 				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
--- LVM2/tools/lvcreate.c	2010/12/08 20:50:51	1.227
+++ LVM2/tools/lvcreate.c	2011/01/11 17:05:10	1.228
@@ -538,8 +538,6 @@
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
 
-	memset(&lp, 0, sizeof(lp));
-
 	if (!_lvcreate_params(&lp, &lcp, cmd, argc, argv))
 		return EINVALID_CMD_LINE;
 


