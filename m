From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2011 23:10:15 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20110705231015.7033.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-05 23:10:15

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Abort operation if dm_tree_node_add_target_area fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2035&r2=1.2036
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225

--- LVM2/WHATS_NEW	2011/07/01 14:09:19	1.2035
+++ LVM2/WHATS_NEW	2011/07/05 23:10:14	1.2036
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Abort operation if dm_tree_node_add_target_area fails.
   Add activation/checks to lvm.conf to perform additional ioctl validation.
   When suspending, automatically preload newly-visible existing LVs.
   Report internal error when parameters are missing on table load.
--- LVM2/lib/activate/dev_manager.c	2011/07/05 01:01:19	1.224
+++ LVM2/lib/activate/dev_manager.c	2011/07/05 23:10:15	1.225
@@ -1178,12 +1178,11 @@
 		dlid = _add_error_device(dm, *tree, seg, s);
 		if (!dlid)
 			return_0;
-		dm_tree_node_add_target_area(node, NULL, dlid,
-					     extent_size * seg_le(seg, s));
+		if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
+			return_0;
 	} else
-		dm_tree_node_add_target_area(node,
-					     dm->cmd->stripe_filler,
-					     NULL, UINT64_C(0));
+		if (!dm_tree_node_add_target_area(node, dm->cmd->stripe_filler, NULL, UINT64_C(0)))
+			return_0;
 
 	return 1;
 }
@@ -1204,19 +1203,15 @@
 		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
 			if (!_add_error_area(dm, node, seg, s))
 				return_0;
-		} else if (seg_type(seg, s) == AREA_PV)
-			dm_tree_node_add_target_area(node,
-							dev_name(seg_dev(seg, s)),
-							NULL,
-							(seg_pv(seg, s)->pe_start +
-							 (extent_size * seg_pe(seg, s))));
-		else if (seg_type(seg, s) == AREA_LV) {
-			if (!(dlid = build_dm_uuid(dm->mem,
-						   seg_lv(seg, s)->lvid.s,
-						   NULL)))
+		} else if (seg_type(seg, s) == AREA_PV) {
+			if (!dm_tree_node_add_target_area(node, dev_name(seg_dev(seg, s)), NULL,
+				    (seg_pv(seg, s)->pe_start + (extent_size * seg_pe(seg, s)))))
+				return_0;
+		} else if (seg_type(seg, s) == AREA_LV) {
+			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
+				return_0;
+			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
 				return_0;
-			dm_tree_node_add_target_area(node, NULL, dlid,
-							extent_size * seg_le(seg, s));
 		} else {
 			log_error(INTERNAL_ERROR "Unassigned area found in LV %s.",
 				  seg->lv->name);


