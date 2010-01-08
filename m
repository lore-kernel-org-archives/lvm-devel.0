From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 8 Jan 2010 13:04:12 -0000
Subject: LVM2 tools/lvconvert.c test/t-lvconvert-repair ...
Message-ID: <20100108130412.25848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-01-08 13:04:10

Modified files:
	tools          : lvconvert.c 
Added files:
	test           : t-lvconvert-repair-policy.sh 

Log message:
	In lvconvert --repair --use-policies, for the allocate policies, return success
	even if allocation fails, as long as the downconversion or corelog conversion
	succeeded.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/tools/lvconvert.c	2010/01/07 20:42:55	1.102
+++ LVM2/tools/lvconvert.c	2010/01/08 13:04:10	1.103
@@ -40,6 +40,7 @@
 	int pv_count;
 	char **pvs;
 	struct dm_list *pvh;
+	struct dm_list *failed_pvs;
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -229,6 +230,7 @@
 
 	lp->pv_count = argc;
 	lp->pvs = argv;
+	lp->failed_pvs = NULL;
 
 	return 1;
 }
@@ -587,6 +589,7 @@
 
 	int repair = arg_count(cmd, repair_ARG);
 	int replace_log = 1, replace_mirrors = 1;
+	int failure_code = 0;
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
@@ -644,8 +647,8 @@
 		cmd->partial_activation = 1;
 		lp->need_polling = 0;
 		if (!(lv->status & PARTIAL_LV)) {
-			log_error("The mirror is consistent, nothing to repair.");
-			return 0;
+			log_error("The mirror is consistent. Nothing to repair.");
+			return 1;
 		}
 		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
 			return_0;
@@ -653,9 +656,9 @@
 		log_error("Mirror status: %d of %d images failed.",
 			  failed_mirrors, existing_mirrors);
 		old_pvh = lp->pvh;
-		if (!(lp->pvh = _failed_pv_list(lv->vg)))
+		if (!(failed_pvs = _failed_pv_list(lv->vg)))
 			return_0;
-		failed_pvs = lp->pvh;
+		lp->pvh = lp->failed_pvs = failed_pvs;
 		log_lv=first_seg(lv)->log_lv;
 		if (!log_lv || log_lv->status & PARTIAL_LV)
 			failed_log = corelog = 1;
@@ -770,8 +773,10 @@
 						lv->le_count,
 						lp->region_size),
 				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV))
-			return_0;
+				    MIRROR_BY_LV)) {
+			stack;
+			return failure_code;
+		}
 		if (lp->wait_completion)
 			lp->need_polling = 1;
 	} else if (lp->mirrors > existing_mirrors || failed_mirrors) {
@@ -791,7 +796,7 @@
 		if (lv_is_origin(lv)) {
 			log_error("Can't add additional mirror images to "
 				  "mirrors that are under snapshots");
-			return 0;
+			return failure_code;
 		}
 
 		/*
@@ -799,8 +804,10 @@
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		if (!_lv_update_log_type(cmd, lp, lv, corelog))
-			return_0;
+		if (!_lv_update_log_type(cmd, lp, lv, corelog)) {
+			stack;
+			return failure_code;
+		}
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
@@ -827,7 +834,8 @@
 					  "and dmsetup may be required.");
 				return 0;
 			}
-			return_0;
+			stack;
+			return failure_code;
 		}
 		lv->status |= CONVERTING;
 		lp->need_polling = 1;
@@ -835,8 +843,10 @@
 
 	if (lp->mirrors == existing_mirrors) {
 		if (_using_corelog(lv) != corelog) {
-			if (!_lv_update_log_type(cmd, lp, lv, corelog))
-				return_0;
+			if (!_lv_update_log_type(cmd, lp, lv, corelog)) {
+				stack;
+				return failure_code;
+			}
 		} else {
 			log_error("Logical volume %s already has %"
 				  PRIu32 " mirror(s).", lv->name,
@@ -879,15 +889,18 @@
 			lp->mirrors += failed_mirrors;
 		failed_mirrors = 0;
 		existing_mirrors = lv_mirror_count(lv);
+		/*
+		 * Ignore failure in upconversion if this is a policy-driven
+		 * action. If we got this far, only unexpected failures are
+		 * reported.
+		 */
+		if (arg_count(cmd, use_policies_ARG))
+			failure_code = 1;
 		/* Now replace missing devices. */
 		if (replace_log || replace_mirrors)
 			goto restart;
 	}
 
-	/* If repairing and using policies, remove missing PVs from VG */
-	if (repair && arg_count(cmd, use_policies_ARG))
-		_remove_missing_empty_pv(lv->vg, failed_pvs);
-
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
@@ -1015,6 +1028,10 @@
 			stack;
 			return ECMD_FAILED;
 		}
+
+		/* If repairing and using policies, remove missing PVs from VG */
+		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
+			_remove_missing_empty_pv(lv->vg, lp->failed_pvs);
 	}
 
 	return ECMD_PROCESSED;
/cvs/lvm2/LVM2/test/t-lvconvert-repair-policy.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-policy.sh
+++ -	2010-01-08 13:04:12.076104000 +0000
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
+prepare_vg 4
+
+cleanup() {
+	vgreduce --removemissing $vg
+	for d in "$@"; do enable_dev $d; done
+	for d in "$@"; do vgextend $vg $d; done
+	lvremove -ff $vg/mirror
+	lvcreate -m 1 -L 1 -n mirror $vg
+}
+
+repair() {
+	lvconvert -i 1 --repair --use-policies --config "$1" $vg/mirror
+}
+
+lvcreate -m 1 -L 1 -n mirror $vg
+lvchange -a n $vg/mirror
+
+disable_dev $dev1
+lvchange --partial -a y $vg/mirror
+repair 'activation { mirror_image_fault_policy = "remove" }'
+lvs | grep -- -wi-a- # non-mirror
+cleanup $dev1
+
+disable_dev $dev1
+repair 'activation { mirror_image_fault_policy = "replace" }'
+lvs | grep -- mwi-a- # mirror
+lvs | grep mirror_mlog
+cleanup $dev1
+
+disable_dev $dev1
+repair 'activation { mirror_device_fault_policy = "replace" }'
+lvs | grep -- mwi-a- # mirror
+lvs | grep mirror_mlog
+cleanup $dev1
+
+disable_dev $dev2 $dev4
+# no room for repair, downconversion should happen
+repair 'activation { mirror_image_fault_policy = "replace" }'
+lvs | grep -- -wi-a-
+cleanup $dev2 $dev4
+
+disable_dev $dev2 $dev4
+# no room for new log, corelog conversion should happen
+repair 'activation { mirror_image_fault_policy = "replace" }'
+lvs
+lvs | grep -- mwi-a-
+lvs | not grep mirror_mlog
+cleanup $dev2 $dev4


