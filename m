From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Apr 2009 16:56:24 -0000
Subject: LVM2 ./WHATS_NEW tools/args.h tools/commands.h ...
Message-ID: <20090423165624.19655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-04-23 16:56:23

Modified files:
	.              : WHATS_NEW 
	tools          : args.h commands.h lvconvert.c 
	man            : lvconvert.8.in 
Added files:
	test           : t-lvconvert-repair.sh 

Log message:
	Implement, test and document (first iteration of) lvconvert --repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1094&r2=1.1095
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/test/t-lvconvert-repair.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair.sh
+++ -	2009-04-23 16:56:23.365324000 +0000
@@ -0,0 +1,46 @@
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
+vgreduce $vg $dev4
+lvcreate -m 1 -L 1 -n mirror $vg
+
+lvchange -a n $vg/mirror
+vgextend $vg $dev4
+disable_dev $dev1
+lvchange --partial -a y $vg/mirror
+
+not vgreduce -v --removemissing $vg
+lvconvert -i 1 --repair $vg/mirror
+vgreduce --removemissing $vg
+
+enable_dev $dev1
+vgextend $vg $dev1
+disable_dev $dev2
+lvconvert -i 1 --repair $vg/mirror
+vgreduce --removemissing $vg
+
+enable_dev $dev2
+vgextend $vg $dev2
+disable_dev $dev3
+lvconvert -i 1 --repair $vg/mirror
+vgreduce --removemissing $vg
+
+enable_dev $dev3
+vgextend $vg $dev3
+lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
+vgchange -a n $vg
+pvremove -ff -y $dev4
+echo 'y' | not lvconvert -i 1 --repair $vg/mirror2
+vgs
--- LVM2/WHATS_NEW	2009/04/22 17:00:28	1.1094
+++ LVM2/WHATS_NEW	2009/04/23 16:56:22	1.1095
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Implement lvconvert --repair, for repairing partially failed mirrors.
   Fix vgreduce --removemissing failure exit code.
   Fix remote metadata backup for clvmd.
   Alloc PV internal structure from VG mempool if possible.
--- LVM2/tools/args.h	2009/02/22 19:00:28	1.61
+++ LVM2/tools/args.h	2009/04/23 16:56:22	1.62
@@ -49,6 +49,7 @@
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
 arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(repair_ARG, '\0', "repair", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
--- LVM2/tools/commands.h	2009/04/08 12:53:20	1.123
+++ LVM2/tools/commands.h	2009/04/23 16:56:22	1.124
@@ -94,6 +94,7 @@
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[--repair]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -115,7 +116,8 @@
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
+   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, snapshot_ARG,
+   test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
--- LVM2/tools/lvconvert.c	2009/04/21 14:31:58	1.70
+++ LVM2/tools/lvconvert.c	2009/04/23 16:56:22	1.71
@@ -366,6 +366,60 @@
 	return 1;
 }
 
+static int _area_missing(struct lv_segment *lvseg, int s)
+{
+	if (seg_type(lvseg, s) == AREA_LV) {
+		if (seg_lv(lvseg, s)->status & PARTIAL_LV)
+			return 1;
+	} else if (seg_type(lvseg, s) == AREA_PV) {
+		if (seg_pv(lvseg, s)->status & MISSING_PV)
+			return 1;
+	}
+	return 0;
+}
+
+/* FIXME we want to handle mirror stacks here... */
+static int _count_failed_mirrors(struct logical_volume *lv)
+{
+	struct lv_segment *lvseg;
+	int ret = 0;
+	int s;
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		if (!seg_is_mirrored(lvseg))
+			return -1;
+		for(s = 0; s < lvseg->area_count; ++s) {
+			if (_area_missing(lvseg, s))
+				++ ret;
+		}
+	}
+	return ret;
+}
+
+static struct dm_list *_failed_pv_list(struct volume_group *vg)
+{
+	struct dm_list *r;
+	struct pv_list *pvl, *new_pvl;
+
+	if (!(r = dm_pool_alloc(vg->vgmem, sizeof(*r)))) {
+		log_error("Allocation of list failed");
+		return_0;
+	}
+
+	dm_list_init(r);
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!(pvl->pv->status & MISSING_PV))
+			continue;
+
+		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
+			log_error("Unable to allocate physical volume list.");
+			return_0;
+		}
+		new_pvl->pv = pvl->pv;
+		dm_list_add(r, &new_pvl->list);
+	}
+	return r;
+}
+
 /* walk down the stacked mirror LV to the original mirror LV */
 static struct logical_volume *_original_lv(struct logical_volume *lv)
 {
@@ -386,17 +440,26 @@
 	unsigned corelog = 0;
 	struct logical_volume *original_lv;
 	int r = 0;
+	struct logical_volume *log_lv;
+	int failed_mirrors = 0, failed_log = 0;
+	struct dm_list *old_pvh, *remove_pvs = NULL;
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
 
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
-	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG)) {
+	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
+	    !arg_count(cmd, repair_ARG)) {
 		lp->need_polling = 1;
 		return 1;
 	}
 
+	if (arg_count(cmd, mirrors_ARG) && arg_count(cmd, repair_ARG)) {
+		log_error("You can only use one of -m, --repair.");
+		return 0;
+	}
+
 	/*
 	 * Adjust required number of mirrors
 	 *
@@ -414,38 +477,59 @@
 	else
 		lp->mirrors += 1;
 
-	/*
-	 * Did the user try to subtract more legs than available?
-	 */
-	if (lp->mirrors < 1) {
-		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
-			  lv->name, existing_mirrors);
-		return 0;
-	}
-
-	/*
-	 * Adjust log type
-	 */
-	if (arg_count(cmd, corelog_ARG))
-		corelog = 1;
-
-	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-				  corelog ? "core" : DEFAULT_MIRRORLOG);
-	if (!strcmp("disk", mirrorlog)) {
-		if (corelog) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
+	if (arg_count(cmd,repair_ARG)) {
+		cmd->handles_missing_pvs = 1;
+		cmd->partial_activation = 1;
+		lp->need_polling = 0;
+		if (!(lv->status & PARTIAL_LV)) {
+			log_error("The mirror is consistent, nothing to repair.");
+			return 0;
+		}
+		if ((failed_mirrors = _count_failed_mirrors(lv)) < 0)
+			return_0;
+		lp->mirrors -= failed_mirrors;
+		log_error("Mirror status: %d/%d legs failed.",
+			  failed_mirrors, existing_mirrors);
+		old_pvh = lp->pvh;
+		if (!(lp->pvh = _failed_pv_list(lv->vg)))
+			return_0;
+		log_lv=first_seg(lv)->log_lv;
+		if (!log_lv || log_lv->status & PARTIAL_LV)
+			failed_log = corelog = 1;
+	} else {
+		/*
+		 * Did the user try to subtract more legs than available?
+		 */
+		if (lp->mirrors < 1) {
+			log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+				  lv->name, existing_mirrors);
+			return 0;
+		}
+		
+		/*
+		 * Adjust log type
+		 */
+		if (arg_count(cmd, corelog_ARG))
+			corelog = 1;
+		
+		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+					  corelog ? "core" : DEFAULT_MIRRORLOG);
+		if (!strcmp("disk", mirrorlog)) {
+			if (corelog) {
+				log_error("--mirrorlog disk and --corelog "
+					  "are incompatible");
+				return 0;
+			}
+			corelog = 0;
+		} else if (!strcmp("core", mirrorlog))
+			corelog = 1;
+		else {
+			log_error("Unknown mirrorlog type: %s", mirrorlog);
 			return 0;
 		}
-		corelog = 0;
-	} else if (!strcmp("core", mirrorlog))
-		corelog = 1;
-	else {
-		log_error("Unknown mirrorlog type: %s", mirrorlog);
-		return 0;
-	}
 
-	log_verbose("Setting logging type to %s", mirrorlog);
+		log_verbose("Setting logging type to %s", mirrorlog);
+	}
 
 	/*
 	 * Region size must not change on existing mirrors
@@ -458,6 +542,18 @@
 	}
 
 	/*
+	 * FIXME This check used to precede mirror->mirror conversion
+	 * but didn't affect mirror->linear or linear->mirror. I do
+	 * not understand what is its intention, in fact.
+	 */
+	if (dm_list_size(&lv->segments) != 1) {
+		log_error("Logical volume %s has multiple "
+			  "mirror segments.", lv->name);
+		return 0;
+	}
+	
+ restart:
+	/*
 	 * Converting from mirror to linear
 	 */
 	if ((lp->mirrors == 1)) {
@@ -466,17 +562,24 @@
 				  lv->name);
 			return 1;
 		}
-
-		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - 1, 1,
-				       lp->pv_count ? lp->pvh : NULL, 0))
-			return_0;
-		goto commit_changes;
 	}
 
 	/*
-	 * Converting from linear to mirror
+	 * Downconversion.
 	 */
-	if (!(lv->status & MIRRORED)) {
+	if (lp->mirrors < existing_mirrors) {
+		/* Reduce number of mirrors */
+		if (arg_count(cmd, repair_ARG) || lp->pv_count)
+			remove_pvs = lp->pvh;
+		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
+				       (corelog || lp->mirrors == 1) ? 1U : 0U,
+				       remove_pvs, 0))
+			return_0;
+	} else if (!(lv->status & MIRRORED)) {
+		/*
+		 * Converting from linear to mirror
+		 */
+	
 		/* FIXME Share code with lvcreate */
 
 		/* FIXME Why is this restriction here?  Fix it! */
@@ -487,6 +590,11 @@
 			}
 		}
 
+		/*
+		 * FIXME should we give not only lp->pvh, but also all PVs
+		 * currently taken by the mirror? Would make more sense from
+		 * user perspective.
+		 */
 		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, 1,
 				    adjusted_mirror_region_size(
 						lv->vg->extent_size,
@@ -497,46 +605,7 @@
 			return_0;
 		if (lp->wait_completion)
 			lp->need_polling = 1;
-		goto commit_changes;
-	}
-
-	/*
-	 * Converting from mirror to mirror with different leg count,
-	 * or different log type.
-	 */
-	if (dm_list_size(&lv->segments) != 1) {
-		log_error("Logical volume %s has multiple "
-			  "mirror segments.", lv->name);
-		return 0;
-	}
-
-	if (lp->mirrors == existing_mirrors) {
-		/*
-		 * Convert Mirror log type
-		 */
-		original_lv = _original_lv(lv);
-		if (!first_seg(original_lv)->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, original_lv, 1,
-					    adjusted_mirror_region_size(
-							lv->vg->extent_size,
-							lv->le_count,
-							lp->region_size),
-					    lp->pvh, lp->alloc))
-				return_0;
-		} else if (first_seg(original_lv)->log_lv && corelog) {
-			if (!remove_mirror_log(cmd, original_lv,
-					       lp->pv_count ? lp->pvh : NULL))
-				return_0;
-		} else {
-			/* No change */
-			log_error("Logical volume %s already has %"
-				  PRIu32 " mirror(s).", lv->name,
-				  lp->mirrors - 1);
-			if (lv->status & CONVERTING)
-				lp->need_polling = 1;
-			return 1;
-		}
-	} else if (lp->mirrors > existing_mirrors) {
+	} else if (lp->mirrors > existing_mirrors || failed_mirrors) {
 		if (lv->status & MIRROR_NOTSYNCED) {
 			log_error("Not adding mirror to mirrored LV "
 				  "without initial resync");
@@ -578,15 +647,36 @@
 			return_0;
 		lv->status |= CONVERTING;
 		lp->need_polling = 1;
-	} else {
-		/* Reduce number of mirrors */
-		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-				       corelog ? 1U : 0U,
-				       lp->pv_count ? lp->pvh : NULL, 0))
-			return_0;
 	}
 
-commit_changes:
+	if (lp->mirrors == existing_mirrors) {
+		/*
+		 * Convert Mirror log type
+		 */
+		original_lv = _original_lv(lv);
+		if (!first_seg(original_lv)->log_lv && !corelog) {
+			if (!add_mirror_log(cmd, original_lv, 1,
+					    adjusted_mirror_region_size(
+							lv->vg->extent_size,
+							lv->le_count,
+							lp->region_size),
+					    lp->pvh, lp->alloc))
+				return_0;
+		} else if (first_seg(original_lv)->log_lv && corelog) {
+			if (!remove_mirror_log(cmd, original_lv,
+					       lp->pv_count ? lp->pvh : NULL))
+				return_0;
+		} else {
+			/* No change */
+			log_error("Logical volume %s already has %"
+				  PRIu32 " mirror(s).", lv->name,
+				  lp->mirrors - 1);
+			if (lv->status & CONVERTING)
+				lp->need_polling = 1;
+			return 1;
+		}
+	}
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
 	if (!vg_write(lv->vg))
@@ -610,6 +700,17 @@
 		goto out;
 	}
 
+	if (failed_log || failed_mirrors) {
+		lp->pvh = old_pvh;
+		if (failed_log)
+			failed_log = corelog = 0;
+		lp->mirrors += failed_mirrors;
+		failed_mirrors = 0;
+		existing_mirrors = lv_mirror_count(lv);
+		/* Now replace missing devices. */
+		goto restart;
+	}
+
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
--- LVM2/man/lvconvert.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvconvert.8.in	2009/04/23 16:56:22	1.3
@@ -29,7 +29,7 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
-Exactly one of \-\-mirrors or \-\-snapshot arguments required.
+Exactly one of \-\-mirrors, \-\-repair or \-\-snapshot arguments required.
 .br
 .TP
 .I \-m, \-\-mirrors Mirrors
@@ -61,6 +61,12 @@
 Report progress as a percentage at regular intervals.
 .br
 .TP
+.I \-\-repair
+Repair a mirror that has suffered a disk failure. The mirror will be brought
+back into a consistent state, and if possible, the original number of
+mirrors will be restored.
+.br
+.TP
 .I \-s, \-\-snapshot
 Create a snapshot from existing logical volume using another
 existing logical volume as its origin.


