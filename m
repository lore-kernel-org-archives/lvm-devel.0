From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 19:59:47 -0000
Subject: LVM2 lib/metadata/metadata.c test/t-lvresize-u ...
Message-ID: <20080410195947.1963.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 19:59:43

Modified files:
	lib/metadata   : metadata.c 
	test           : t-lvresize-usage.sh t-vgmerge-operation.sh 
	                 t-vgsplit-usage.sh 
	tools          : lvresize.c toollib.c vgsplit.c 

Log message:
	more pre-release cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/metadata/metadata.c	2008/04/10 19:14:26	1.169
+++ LVM2/lib/metadata/metadata.c	2008/04/10 19:59:42	1.170
@@ -885,6 +885,7 @@
 	list_iterate_items(pvl, pl)
 		if (pvl->pv == pv)
 			return pvl;
+
 	return NULL;
 }
 
@@ -957,6 +958,7 @@
 	list_iterate_items(lvl, ll)
 		if (lvl->lv == lv)
 			return lvl;
+
 	return NULL;
 }
 
--- LVM2/test/t-lvresize-usage.sh	2008/04/02 12:17:30	1.1
+++ LVM2/test/t-lvresize-usage.sh	2008/04/10 19:59:43	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/test/t-vgmerge-operation.sh	2008/03/26 18:03:35	1.1
+++ LVM2/test/t-vgmerge-operation.sh	2008/04/10 19:59:43	1.2
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/test/t-vgsplit-usage.sh	2008/04/10 01:06:48	1.4
+++ LVM2/test/t-vgsplit-usage.sh	2008/04/10 19:59:43	1.5
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/tools/lvresize.c	2008/04/02 12:17:30	1.95
+++ LVM2/tools/lvresize.c	2008/04/10 19:59:43	1.96
@@ -229,8 +229,8 @@
 	argv++;
 	argc--;
 
-	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, &dev_dir_found))
-	    || (!(lp->vg_name = extract_vgname(cmd, lp->lv_name)))) {
+	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, &dev_dir_found)) ||
+	    !(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
 		log_error("Please provide a volume group name");
 		return 0;
 	}
@@ -269,6 +269,7 @@
 	uint32_t sz, str;
 	struct list *pvh = NULL;
 	char size_buf[SIZE_BUF];
+	char lv_path[PATH_MAX];
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
@@ -623,8 +624,6 @@
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND)) {
-		char lv_path[PATH_MAX];
-
 		if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
 				lp->vg_name, lp->lv_name) < 0) {
 			log_error("Couldn't create LV path for %s",
--- LVM2/tools/toollib.c	2008/03/25 15:24:59	1.132
+++ LVM2/tools/toollib.c	2008/04/10 19:59:43	1.133
@@ -1245,8 +1245,6 @@
 	return rc;
 }
 
-
-
 /*
  * Set members of struct vgcreate_params from cmdline.
  * Do preliminary validation with arg_*() interface.
--- LVM2/tools/vgsplit.c	2008/04/10 19:14:27	1.62
+++ LVM2/tools/vgsplit.c	2008/04/10 19:59:43	1.63
@@ -93,13 +93,12 @@
 	return 0;
 }
 
-static int _move_one_lv(struct volume_group *vg_from,
-			struct volume_group *vg_to,
-			struct list *lvh)
+static void _move_one_lv(struct volume_group *vg_from,
+			 struct volume_group *vg_to,
+			 struct list *lvh)
 {
-	struct logical_volume *lv;
+	struct logical_volume *lv = list_item(lvh, struct lv_list)->lv;
 
-	lv = list_item(lvh, struct lv_list)->lv;
 	list_move(&vg_to->lvs, lvh);
 	
 	if (lv->status & SNAPSHOT) {
@@ -109,7 +108,6 @@
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}
-	return 1;
 }	
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
@@ -170,8 +168,7 @@
 			continue;
 
 		/* Move this LV */
-		if (!_move_one_lv(vg_from, vg_to, lvh))
-			return 0;
+		_move_one_lv(vg_from, vg_to, lvh);
 	}
 
 	/* FIXME Ensure no LVs contain segs pointing at LVs in the other VG */
@@ -215,10 +212,8 @@
 			 * in vg_to.
 			 */
 			if (_lv_is_in_vg(vg_to, seg->cow) &&
-			    _lv_is_in_vg(vg_to, seg->origin)) {
-				if (!_move_one_lv(vg_from, vg_to, lvh))
-					return 0;
-			}
+			    _lv_is_in_vg(vg_to, seg->origin))
+				_move_one_lv(vg_from, vg_to, lvh);
 		}
 
 	}
@@ -344,10 +339,10 @@
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
-			goto bad;
+			goto_bad;
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
-			goto bad;
+			goto_bad;
 	} else {
 		existing_vg = 0;
 
@@ -377,7 +372,7 @@
 		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
 					vp_new.max_pv, vp_new.max_lv,
 					vp_new.alloc, 0, NULL)))
-			goto bad;
+			goto_bad;
 
 		if (vg_is_clustered(vg_from))
 			vg_to->status |= CLUSTERED;
@@ -385,41 +380,39 @@
 
 	/* Archive vg_from before changing it */
 	if (!archive(vg_from))
-		goto bad;
+		goto_bad;
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
 		if (!_move_pv(vg_from, vg_to, argv[opt]))
-			goto bad;
+			goto_bad;
 	}
 
 	/* If an LV given on the cmdline, move used_by PVs */
-	if (lv_name) {
-		if (!_move_pvs_used_by_lv(vg_from, vg_to, lv_name))
-			goto bad;
-	}
+	if (lv_name && !_move_pvs_used_by_lv(vg_from, vg_to, lv_name))
+		goto_bad;
 
 	/* Move required LVs across, checking consistency */
 	if (!(_move_lvs(vg_from, vg_to)))
-		goto bad;
+		goto_bad;
 
 	/* Move required snapshots across */
 	if (!(_move_snapshots(vg_from, vg_to)))
-		goto bad;
+		goto_bad;
 
 	/* Move required mirrors across */
 	if (!(_move_mirrors(vg_from, vg_to)))
-		goto bad;
+		goto_bad;
 
 	/* Split metadata areas and check if both vgs have@least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
-		goto bad;
+		goto_bad;
 	}
 
 	/* Set proper name for all PVs in new VG */
 	if (!vg_rename(cmd, vg_to, vg_name_to))
-		goto bad;
+		goto_bad;
 
 	/* store it on disks */
 	log_verbose("Writing out updated volume groups");
@@ -434,21 +427,21 @@
 	vg_to->status |= EXPORTED_VG;
 
 	if (!archive(vg_to))
-		goto bad;
+		goto_bad;
 
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
-		goto bad;
+		goto_bad;
 
 	backup(vg_to);
 
 	/*
 	 * Next, write out the updated old VG.  If we crash after this point,
 	 * recovery is a vgimport on the new VG.
-	 * FIXME: recover automatically or instruct the user the user?
+	 * FIXME: recover automatically or instruct the user?
 	 */
 	if (vg_from->pv_count) {
 		if (!vg_write(vg_from) || !vg_commit(vg_from))
-			goto bad;
+			goto_bad;
 
 		backup(vg_from);
 	}
@@ -458,17 +451,17 @@
 	 */
 	consistent = 1;
 	if (!test_mode() &&
-	    (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))
-	     || !consistent)) {
+	    (!(vg_to = vg_read(cmd, vg_name_to, NULL, &consistent)) ||
+	     !consistent)) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);
-		goto bad;
+		goto_bad;
 	}
 
 	vg_to->status &= ~EXPORTED_VG;
 
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
-		goto bad;
+		goto_bad;
 
 	backup(vg_to);
 


