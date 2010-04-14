From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Apr 2010 13:51:59 -0000
Subject: LVM2 test/t-lvconvert-repair-policy.sh test/t- ...
Message-ID: <20100414135159.26967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-14 13:51:59

Modified files:
	test           : t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair.sh 
	tools          : lvconvert.c 
Added files:
	test           : t-lvconvert-repair-replace.sh 

Log message:
	Allow incomplete mirror restore in lvconvert --repair upon insufficient space.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

/cvs/lvm2/LVM2/test/t-lvconvert-repair-replace.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-replace.sh
+++ -	2010-04-14 13:51:59.339011000 +0000
@@ -0,0 +1,61 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+prepare_vg 6
+
+# multiple failures, full replace
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
+disable_dev $dev1 $dev2
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+enable_dev $dev1 $dev2
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
+
+# multiple failures, partial replace
+lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
+disable_dev $dev1 $dev2
+echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+grep "WARNING: Failed" 3way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 3way
+enable_dev $dev1 $dev2
+lvchange -a n $vg/3way
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3
+
+lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3
+disable_dev $dev1
+echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+grep "WARNING: Failed" 2way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+check mirror $vg 2way
+enable_dev $dev1 $dev2
+lvchange -a n $vg/2way
+
+vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
+
+# Test repair of inactive mirror with log failure
+#  Replacement should fail, but covert should succeed (switch to corelog)
+lvcreate -m 2 --ig -l 2 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4:0
+vgchange -a n $vg
+pvremove -ff -y $dev4
+echo 'y' | lvconvert -y --repair $vg/mirror2
+check mirror $vg mirror2
+vgs
+
--- LVM2/test/t-lvconvert-repair-policy.sh	2010/03/31 02:36:03	1.3
+++ LVM2/test/t-lvconvert-repair-policy.sh	2010/04/14 13:51:58	1.4
@@ -25,25 +25,24 @@
 }
 
 repair() {
-	lvconvert -i 1 --repair --use-policies --config "$1" $vg/mirror
+	lvconvert --repair --use-policies --config "$1" $vg/mirror
 }
 
 lvcreate -m 1 -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.
-# Expected result: linear
 disable_dev $dev1
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
-lvs | grep -- -wi-a- # non-mirror
+check linear $vg mirror
 cleanup $dev1
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
-lvs | grep -- mwi-a- # mirror
+check mirror $vg mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
@@ -51,22 +50,22 @@
 # Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_device_fault_policy = "replace" }'
-lvs | grep -- mwi-a- # mirror
+check mirror $vg mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
 # Fail a leg of a mirror w/ no available spare
-# Expected result: linear
+# Expected result: 2-way with corelog
 disable_dev $dev2 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
-lvs | grep -- -wi-a-
+check mirror $vg mirror
+lvs | not grep mirror_mlog
 cleanup $dev2 $dev4
 
 # Fail the log device of a mirror w/ no available spare
 # Expected result: mirror w/ corelog
 disable_dev $dev3 $dev4
-repair 'activation { mirror_image_fault_policy = "replace" }'
-lvs
-lvs | grep -- mwi-a-
+lvconvert --repair --use-policies --config 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
+check mirror $vg mirror
 lvs | not grep mirror_mlog
 cleanup $dev3 $dev4
--- LVM2/test/t-lvconvert-repair.sh	2010/03/31 02:36:03	1.6
+++ LVM2/test/t-lvconvert-repair.sh	2010/04/14 13:51:58	1.7
@@ -15,26 +15,26 @@
 
 # fail multiple devices
 
-lvcreate -m 3 --ig -L 1 -n 3way $vg
+lvcreate -m 3 --ig -L 1 -n 4way $vg
 disable_dev $dev2 $dev4
-echo n | lvconvert -i 1 --repair $vg/3way
-lvs -a -o +devices > lvlist
-not grep unknown lvlist
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 enable_dev $dev2 $dev4
-lvchange -a n $vg/3way
+check mirror $vg 4way
+lvchange -a n $vg/4way
 
 vgremove -ff $vg
 vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
 
-lvcreate -m 2 --ig -L 1 -n 4way $vg
+lvcreate -m 2 --ig -L 1 -n 3way $vg
 disable_dev $dev1 $dev2
-echo n | lvconvert -i 1 --repair $vg/4way
-lvs -a -o +devices > lvlist
-not grep unknown lvlist
+echo n | lvconvert --repair $vg/3way
+lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 enable_dev $dev1 $dev2
-lvchange -a n $vg/4way
+check linear $vg 3way
+lvchange -a n $vg/3way
 
 # fail single devices
 
@@ -49,29 +49,20 @@
 lvchange --partial -a y $vg/mirror
 
 not vgreduce -v --removemissing $vg
-lvconvert -y -i 1 --repair $vg/mirror
+lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
 enable_dev $dev1
 vgextend $vg $dev1
 disable_dev $dev2
-lvconvert -y -i 1 --repair $vg/mirror
+lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
 enable_dev $dev2
 vgextend $vg $dev2
 disable_dev $dev3
-lvconvert -y -i 1 --repair $vg/mirror
+lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 enable_dev $dev3
 vgextend $vg $dev3
 lvremove -ff $vg
-
-# Test repair of inactive mirror with log failure
-#  Replacement should fail, but covert should succeed (switch to corelog)
-lvcreate -m 2 --ig -l 2 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4:0
-vgchange -a n $vg
-pvremove -ff -y $dev4
-echo 'y' | lvconvert -y -i 1 --repair $vg/mirror2
-# FIXME: check that mirror ok and log is now 'core'
-vgs
--- LVM2/tools/lvconvert.c	2010/04/13 17:26:03	1.127
+++ LVM2/tools/lvconvert.c	2010/04/14 13:51:58	1.128
@@ -919,24 +919,19 @@
  * Add/remove mirror images and adjust log type.  'operable_pvs'
  * are the set of PVs open to removal or allocation - depending
  * on the operation being performed.
- *
- * If 'allocation_failures_ok' is set, and there is a failure to
- * convert due to space, success will be returned.
  */
 static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				  struct logical_volume *lv,
 				  struct lvconvert_params *lp,
 				  struct dm_list *operable_pvs,
 				  uint32_t new_mimage_count,
-				  uint32_t new_log_count,
-				  int allocation_failures_ok)
+				  uint32_t new_log_count)
 {
 	uint32_t region_size;
 	struct lv_segment *seg;
 	struct logical_volume *layer_lv;
 	uint32_t old_mimage_count = lv_mirror_count(lv);
 	uint32_t old_log_count = _get_log_count(lv);
-	int failure_code = (allocation_failures_ok) ? 1 : 0;
 
 	if ((lp->mirrors == 1) && !(lv->status & MIRRORED)) {
 		log_error("Logical volume %s is already not mirrored.",
@@ -968,7 +963,7 @@
 				    lp->stripe_size, region_size, new_log_count, operable_pvs,
 				    lp->alloc, MIRROR_BY_LV)) {
 			stack;
-			return failure_code;
+			return 0;
 		}
 		if (lp->wait_completion)
 			lp->need_polling = 1;
@@ -996,7 +991,7 @@
 		if (lv_is_origin(lv)) {
 			log_error("Can't add additional mirror images to "
 				  "mirrors that are under snapshots");
-			return failure_code;
+			return 0;
 		}
 
 		/*
@@ -1007,7 +1002,7 @@
 		if (!_lv_update_log_type(cmd, lp, lv,
 					 operable_pvs, new_log_count)) {
 			stack;
-			return failure_code;
+			return 0;
 		}
 
 		/* Insert a temporary layer for syncing,
@@ -1035,7 +1030,7 @@
 				return 0;
 			}
 			stack;
-			return failure_code;
+			return 0;
 		}
 		if (seg->log_lv)
 			lv->status |= CONVERTING;
@@ -1073,7 +1068,7 @@
 		if (!_lv_update_log_type(cmd, lp, lv,
 					 operable_pvs, new_log_count)) {
 			stack;
-			return failure_code;
+			return 0;
 		}
 	}
 
@@ -1126,7 +1121,7 @@
 	int failed_mirrors = 0;
 	int replace_log = 0;
 	int replace_mirrors = 0;
-	uint32_t new_log_count;
+	uint32_t new_log_count, log_count;
 	struct dm_list *failed_pvs = NULL;
 	struct logical_volume *log_lv;
 
@@ -1191,38 +1186,44 @@
 		return 0;
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
-				    lp->mirrors, new_log_count, 0))
+				    lp->mirrors, new_log_count))
 		return 0;
 
 	/*
 	 * Second phase - replace faulty devices
-	 *
-	 * FIXME: It would be nice to do this all in one step, but
-	 *        for simplicity, we replace mimages first and then
-	 *        work on the log.
 	 */
-	if (replace_mirrors && (old_mimage_count != lp->mirrors)) {
+
+	if (replace_mirrors)
 		lp->mirrors = old_mimage_count;
-		if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
-					    old_mimage_count, new_log_count, 1))
-			return 0;
-	}
 
-	log_lv = first_seg(lv)->log_lv;
-	if (replace_log && (old_log_count != new_log_count)) {
-		/*
-		 * If we are up-converting the log from linear to
-		 * mirrored, then we must use '_lvconvert_mirrors_aux'
-		 */
-		if ((new_log_count == 1) && (old_log_count > 1)) {
-			if (!_lvconvert_mirrors_aux(cmd, log_lv, lp, NULL,
-						    old_log_count, 0, 1))
-				return 0;
-		} else if (!_lv_update_log_type(cmd, lp, lv,
-						lp->pvh, new_log_count))
-			return 0;
+	log_count = replace_log ? old_log_count : new_log_count;
+
+	while (replace_mirrors || replace_log) {
+		log_warn("Trying to up-convert to %d images, %d logs.", lp->mirrors, log_count);
+		if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+					   lp->mirrors, log_count))
+			break;
+		else {
+			if (lp->mirrors > 2)
+				-- lp->mirrors;
+			else if (log_count > 0)
+				-- log_count;
+			else
+				break; /* nowhere to go, anymore... */
+		}
 	}
 
+	if (lp->mirrors != old_mimage_count)
+		log_warn("WARNING: Failed to replace %d of %d images in volume %s",
+			 old_mimage_count - lp->mirrors, old_mimage_count, lv->name);
+	if (log_count != old_log_count)
+		log_warn("WARNING: Failed to replace %d of %d logs in volume %s",
+			 old_log_count - log_count, old_log_count, lv->name);
+
+	/* if (!arg_count(cmd, use_policies_ARG) && (lp->mirrors != old_mimage_count
+						  || log_count != old_log_count))
+						  return 0; */
+
 	return 1;
 }
 
@@ -1259,7 +1260,7 @@
 						 old_log_count);
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
-				    new_mimage_count, new_log_count, 0))
+				    new_mimage_count, new_log_count))
 		return 0;
 
 	if (!lp->need_polling)


