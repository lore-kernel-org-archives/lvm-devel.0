From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Apr 2008 13:47:14 -0000
Subject: LVM2 ./WHATS_NEW tools/commands.h tools/vgsplit.c
Message-ID: <20080409134714.24497.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-09 13:47:13

Modified files:
	.              : WHATS_NEW 
	tools          : commands.h vgsplit.c 

Log message:
	Update vgsplit to take "-n LogicalVolumeName" on the commandline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.837&r2=1.838
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/04/09 12:56:34	1.837
+++ LVM2/WHATS_NEW	2008/04/09 13:47:13	1.838
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Update vgsplit to take "-n LogicalVolumeName" on the commandline.
   Use clustered mirror log with pvmove in clustered VGs, if available.
   Fix some pvmove error status codes.
   Fix vgsplit error paths to release vg_to lock.
--- LVM2/tools/commands.h	2008/04/02 21:23:39	1.109
+++ LVM2/tools/commands.h	2008/04/09 13:47:13	1.110
@@ -927,16 +927,17 @@
    "\t[-h|--help] " "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
    "\tSourceVolumeGroupName DestinationVolumeGroupName" "\n"
-   "\tPhysicalVolumePath [PhysicalVolumePath...]\n",
+   "\t[PhysicalVolumePath...]\n",
 
    alloc_ARG, autobackup_ARG, clustered_ARG,
    maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
-   metadatatype_ARG, test_ARG)
+   metadatatype_ARG, name_ARG, test_ARG)
 
 xx(version,
    "Display software and driver version information",
--- LVM2/tools/vgsplit.c	2008/04/08 21:47:54	1.56
+++ LVM2/tools/vgsplit.c	2008/04/09 13:47:13	1.57
@@ -15,10 +15,18 @@
 
 #include "tools.h"
 
-static void _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
-		     struct pv_list *pvl)
+static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+		    const char *pv_name)
 {
 	struct physical_volume *pv;
+	struct pv_list *pvl;
+
+	/* FIXME: handle tags */
+	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
+		log_error("Physical volume %s not in volume group %s",
+			  pv_name, vg_from->name);
+		return 0;
+	}
 
 	list_move(&pvl->list, &vg_to->pvs);
 
@@ -32,6 +40,45 @@
 
 	vg_from->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg_to->free_count += pv_pe_count(pv) - pv_pe_alloc_count(pv);
+
+	return 1;
+}
+
+static int _move_pvs_used_by_lv(struct volume_group *vg_from,
+				   struct volume_group *vg_to,
+				   const char *lv_name)
+{
+	struct lv_segment *lvseg;
+	unsigned s;
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+
+	/* FIXME: handle tags */
+	if (!(lvl = find_lv_in_vg(vg_from, lv_name))) {
+		log_error("Logical volume %s not in volume group %s",
+			  lv_name, vg_from->name);
+		return 0;
+	}
+
+	list_iterate_items(lvseg, &lvl->lv->segments) {
+		if (lvseg->log_lv)
+			if (!_move_pvs_used_by_lv(vg_from, vg_to,
+						     lvseg->log_lv->name))
+				return_0;
+		for (s = 0; s < lvseg->area_count; s++) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				if (!_move_pv(vg_from, vg_to,
+					      pv_dev_name(seg_pv(lvseg, s))))
+					return_0;
+			} else if (seg_type(lvseg, s) == AREA_LV) {
+				lv = seg_lv(lvseg, s);
+				if (!_move_pvs_used_by_lv(vg_from, vg_to,
+							     lv->name))
+				    return_0;
+			}
+		}
+	}
+	return 1;
 }
 
 /* FIXME Why not (lv->vg == vg) ? */
@@ -220,14 +267,26 @@
 	int opt;
 	int active;
 	int existing_vg;
-	struct pv_list *pvl;
 	int consistent;
+	const char *lv_name;
 
-	if (argc < 3) {
-		log_error("Existing VG, new VG and physical volumes required.");
+	if ((arg_count(cmd, name_ARG) + argc) < 3) {
+		log_error("Existing VG, new VG and either physical volumes "
+			  "or logical volume required.");
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, name_ARG) && (argc > 2)) {
+		log_error("A logical volume name cannot be given with "
+			  "physical volumes.");
+		return ECMD_FAILED;
+	}
+
+	if (arg_count(cmd, name_ARG))
+		lv_name = arg_value(cmd, name_ARG);
+	else
+		lv_name = NULL;
+
 	vg_name_from = skip_dev_dir(cmd, argv[0], NULL);
 	vg_name_to = skip_dev_dir(cmd, argv[1], NULL);
 	argc -= 2;
@@ -266,10 +325,10 @@
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
-			goto error;
+			goto bad;
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
-			goto error;
+			goto bad;
 	} else {
 		existing_vg = 0;
 
@@ -299,7 +358,7 @@
 		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
 					vp_new.max_pv, vp_new.max_lv,
 					vp_new.alloc, 0, NULL)))
-			goto error;
+			goto bad;
 
 		if (vg_from->status & CLUSTERED)
 			vg_to->status |= CLUSTERED;
@@ -307,40 +366,41 @@
 
 	/* Archive vg_from before changing it */
 	if (!archive(vg_from))
-		goto error;
+		goto bad;
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
-		if (!(pvl = find_pv_in_vg(vg_from, argv[opt]))) {
-			log_error("Physical volume %s not in volume group %s",
-				  argv[opt], vg_from->name);
-			goto error;
-		}
+		if (!_move_pv(vg_from, vg_to, argv[opt]))
+			goto bad;
+	}
 
-		_move_pv(vg_from, vg_to, pvl);
+	/* If an LV given on the cmdline, move used_by PVs */
+	if (lv_name) {
+		if (!_move_pvs_used_by_lv(vg_from, vg_to, lv_name))
+			goto bad;
 	}
 
 	/* Move required LVs across, checking consistency */
 	if (!(_move_lvs(vg_from, vg_to)))
-		goto error;
+		goto bad;
 
 	/* Move required snapshots across */
 	if (!(_move_snapshots(vg_from, vg_to)))
-		goto error;
+		goto bad;
 
 	/* Move required mirrors across */
 	if (!(_move_mirrors(vg_from, vg_to)))
-		goto error;
+		goto bad;
 
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
-		goto error;
+		goto bad;
 	}
 
 	/* Set proper name for all PVs in new VG */
 	if (!vg_rename(cmd, vg_to, vg_name_to))
-		goto error;
+		goto bad;
 
 	/* store it on disks */
 	log_verbose("Writing out updated volume groups");
@@ -355,10 +415,10 @@
 	vg_to->status |= EXPORTED_VG;
 
 	if (!archive(vg_to))
-		goto error;
+		goto bad;
 
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
-		goto error;
+		goto bad;
 
 	backup(vg_to);
 
@@ -369,7 +429,7 @@
 	 */
 	if (vg_from->pv_count) {
 		if (!vg_write(vg_from) || !vg_commit(vg_from))
-			goto error;
+			goto bad;
 
 		backup(vg_from);
 	}
@@ -383,13 +443,13 @@
 	     || !consistent)) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);
-		goto error;
+		goto bad;
 	}
 
 	vg_to->status &= ~EXPORTED_VG;
 
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
-		goto error;
+		goto bad;
 
 	backup(vg_to);
 
@@ -401,7 +461,7 @@
 		  vg_to->name, vg_from->name);
 	return ECMD_PROCESSED;
 
-      error:
+      bad:
 	unlock_vg(cmd, vg_name_from);
 	unlock_vg(cmd, vg_name_to);
 	return ECMD_FAILED;


