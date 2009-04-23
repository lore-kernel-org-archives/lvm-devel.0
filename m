From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 23 Apr 2009 22:18:41 +0100
Subject: RFC: Command line support to create sparse devices
Message-ID: <20090423211840.GA7421@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here's a quick patch I've thrown together to make it easier to create sparse
devices.

Usage is exactly like creating a snapshot except instead of providing
an origin LV you give the size of the virtual origin you want to use
with --virtualoriginsize.  The name of the VG must still be provided
of course.

E.g.
  lvcreate -s vg1 -L 400M --virtualoriginsize 1T

Comments?

Alasdair


--- tools/args.h	23 Apr 2009 16:56:22 -0000	1.62
+++ tools/args.h	23 Apr 2009 21:13:13 -0000
@@ -58,6 +58,7 @@
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- tools/commands.h	23 Apr 2009 16:56:22 -0000	1.124
+++ tools/commands.h	23 Apr 2009 21:13:13 -0000
@@ -162,6 +162,7 @@
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
+   "\t[--virtualoriginsize VirtualOriginSize]\n"
    "\t[--version]\n"
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
@@ -169,7 +170,7 @@
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, zero_ARG)
+   test_ARG, type_ARG, virtualoriginsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- tools/lvcreate.c	21 Apr 2009 14:31:58 -0000	1.182
+++ tools/lvcreate.c	23 Apr 2009 21:13:13 -0000
@@ -43,6 +43,8 @@
 	/* size */
 	uint32_t extents;
 	uint64_t size;
+	uint32_t voriginextents;
+	uint64_t voriginsize;
 	percent_t percent;
 
 	uint32_t permission;
@@ -64,7 +66,7 @@
 	if (arg_count(cmd, name_ARG))
 		lp->lv_name = arg_value(cmd, name_ARG);
 
-	if (lp->snapshot) {
+	if (lp->snapshot && !arg_count(cmd, virtualoriginsize_ARG)) {
 		if (!argc) {
 			log_err("Please specify a logical volume to act as "
 				"the snapshot origin.");
@@ -175,6 +177,19 @@
 		lp->percent = PERCENT_NONE;
 	}
 
+	/* Size returned in kilobyte units; held in sectors */
+	if (arg_count(cmd, virtualoriginsize_ARG)) {
+		if (arg_sign_value(cmd, virtualoriginsize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative virtual origin size is invalid");
+			return 0;
+		}
+		lp->voriginsize = arg_uint64_value(cmd, size_ARG, UINT64_C(0));
+		if (!lp->voriginsize) {
+			log_error("Virtual origin size may not be zero");
+			return 0;
+		}
+	}
+
 	return 1;
 }
 
@@ -390,6 +405,10 @@
 			log_error("-c is only available with snapshots");
 			return 0;
 		}
+		if (arg_count(cmd, virtualoriginsize_ARG)) {
+			log_error("--virtualoriginsize is only available with snapshots");
+			return 0;
+		}
 	}
 
 	if (lp->mirrors > 1) {
@@ -511,12 +530,73 @@
 	return 1;
 }
 
+static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
+				   uint32_t extent_size)
+{
+	if (size % extent_size) {
+		size += extent_size - size % extent_size;
+		log_print("Rounding up size to full physical extent %s",
+			  display_size(cmd, size));
+	}
+
+	if (size > (uint64_t) UINT32_MAX * extent_size) {
+		log_error("Volume too large (%s) for extent size %s. "
+			  "Upper limit is %s.",
+			  display_size(cmd, size),
+			  display_size(cmd, (uint64_t) extent_size),
+			  display_size(cmd, (uint64_t) UINT32_MAX *
+				       extent_size));
+		return 0;
+	}
+
+	return (uint64_t) size / extent_size;
+}
+
+static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
+						     struct volume_group *vg,
+						     const char *lv_name,
+						     uint32_t permission,
+						     uint64_t voriginextents)
+{
+	const struct segment_type *segtype;
+	size_t len;
+	char *vorigin_name;
+	struct logical_volume *lv;
+	
+	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
+		log_error("Zero segment type for virtual origin not found");
+		return 0;
+	}
+
+	len = strlen(lv_name) + 32;
+	if (!(vorigin_name = alloca(len)) ||
+	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
+		log_error("Virtual origin name allocation failed.");
+		return 0;
+	}
+
+	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
+				   ALLOC_INHERIT, 0, vg)))
+		return_0;
+
+	if (!lv_extend(lv, segtype, 1, 0,
+		       1, voriginextents, NULL, 0u, 0u, NULL, ALLOC_INHERIT))
+		return_0;
+
+	/* store vg on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	backup(vg);
+
+	return lv;
+}
+
 static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
 	uint32_t size_rest;
 	uint32_t status = 0;
-	uint64_t tmp_size;
 	struct logical_volume *lv, *org = NULL;
 	struct dm_list *pvh;
 	const char *tag = NULL;
@@ -562,28 +642,14 @@
 		return 0;
 	}
 
-	if (lp->size) {
-		/* No of 512-byte sectors */
-		tmp_size = lp->size;
-
-		if (tmp_size % vg->extent_size) {
-			tmp_size += vg->extent_size - tmp_size %
-			    vg->extent_size;
-			log_print("Rounding up size to full physical extent %s",
-				  display_size(cmd, tmp_size));
-		}
-
-		if (tmp_size > (uint64_t) UINT32_MAX * vg->extent_size) {
-			log_error("Volume too large (%s) for extent size %s. "
-				  "Upper limit is %s.",
-				  display_size(cmd, tmp_size),
-				  display_size(cmd, (uint64_t) vg->extent_size),
-				  display_size(cmd, (uint64_t) UINT32_MAX *
-						   vg->extent_size));
-			return 0;
-		}
-		lp->extents = (uint64_t) tmp_size / vg->extent_size;
-	}
+	if (lp->size &&
+	    !(lp->extents = _extents_from_size(cmd, lp->size, vg->extent_size)))
+		return_0;
+
+	if (lp->voriginsize &&
+	    !(lp->voriginextents = _extents_from_size(cmd, lp->size,
+						      vg->extent_size)))
+		return_0;
 
 	/*
 	 * Create the pv list.
@@ -645,37 +711,44 @@
 			log_error("Clustered snapshots are not yet supported.");
 			return 0;
 		}
-		if (!(org = find_lv(vg, lp->origin))) {
-			log_err("Couldn't find origin volume '%s'.",
-				lp->origin);
-			return 0;
-		}
-		if (lv_is_cow(org)) {
-			log_error("Snapshots of snapshots are not supported "
-				  "yet.");
-			return 0;
-		}
-		if (org->status & LOCKED) {
-			log_error("Snapshots of locked devices are not "
-				  "supported yet");
-			return 0;
-		}
-		if (org->status & MIRROR_IMAGE ||
-		    org->status & MIRROR_LOG ||
-		    org->status & MIRRORED) {
-			log_error("Snapshots and mirrors may not yet be mixed.");
-			return 0;
-		}
 
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (!lv_info(cmd, org, &info, 0, 0)) {
-			log_error("Check for existence of snapshot origin "
-				  "'%s' failed.", org->name);
-			return 0;
+		if (arg_count(cmd, virtualoriginsize_ARG))
+			origin_active = 1;
+		else {
+
+			if (!(org = find_lv(vg, lp->origin))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin);
+				return 0;
+			}
+			if (lv_is_cow(org)) {
+				log_error("Snapshots of snapshots are not "
+					  "supported yet.");
+				return 0;
+			}
+			if (org->status & LOCKED) {
+				log_error("Snapshots of locked devices are not "
+					  "supported yet");
+				return 0;
+			}
+			if (org->status & MIRROR_IMAGE ||
+			    org->status & MIRROR_LOG ||
+			    org->status & MIRRORED) {
+				log_error("Snapshots and mirrors may not yet "
+					  "be mixed.");
+				return 0;
+			}
+	
+			if (!lv_info(cmd, org, &info, 0, 0)) {
+				log_error("Check for existence of snapshot "
+					  "origin '%s' failed.", org->name);
+				return 0;
+			}
+			origin_active = info.exists;
 		}
-		origin_active = info.exists;
 	}
 
 	if (!lp->extents) {
@@ -828,6 +901,15 @@
 			return 0;
 		}
 
+		if (lp->voriginsize &&
+		    !(org = _create_virtual_origin(cmd, vg, lv->name,
+						   lp->permission,
+						   lp->voriginextents))) {
+			log_error("Couldn't create virtual origin for LV %s",
+				  lv->name);
+			goto deactivate_and_revert_new_lv;
+		}
+
 		/* cow LV remains active and becomes snapshot LV */
 
 		if (!vg_add_snapshot(NULL, org, lv, NULL,
--- tools/toollib.c	23 Apr 2009 16:45:30 -0000	1.151
+++ tools/toollib.c	23 Apr 2009 21:13:13 -0000
@@ -1229,6 +1229,12 @@
 		return 0;
 	}
 
+	if (strstr(name, "_vorigin")) {
+		log_error("Names including \"_vorigin\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	return 1;
 }
 


