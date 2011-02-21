From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:29:22 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20110221122922.5003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:29:21

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgconvert.c 

Log message:
	Fix vgconvert code to work with changes in metadata area handling and changes
	in format_instance. Add new 'vg_convert' function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.432&r2=1.433
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:27:26	1.181
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:29:21	1.182
@@ -442,6 +442,9 @@
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
+int vg_convert(struct cmd_context *cmd, struct volume_group *vg,
+	       const struct format_type *target_fmt, int64_t label_sector,
+	       int pvmetadatacopies, uint64_t pvmetadatasize);
 int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
 int vg_reduce(struct volume_group *vg, const char *pv_name);
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:26:27	1.432
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:29:21	1.433
@@ -496,6 +496,109 @@
 	return 1;
 }
 
+int vg_convert(struct cmd_context *cmd, struct volume_group *vg,
+	       const struct format_type *target_fmt, int64_t label_sector,
+	       int pvmetadatacopies, uint64_t pvmetadatasize)
+{
+	struct physical_volume *pv, *existing_pv;
+	struct format_instance_ctx fic;
+	uint64_t pe_start = 0;
+	struct pv_list *pvl;
+	int change_made = 0;
+	const char *vg_name = vg->name;
+
+	/* Replace an old format instance with a new empty one. */
+	vg->fid->fmt->ops->destroy_instance(vg->fid);
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vg_name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(vg->fid = target_fmt->ops->create_instance(target_fmt, &fic))) {
+		log_error("Couldn't create target format instance "
+			  "for VG %s.", vg_name);
+		return 0;
+	}
+
+	/*
+	 * Create new PVs in target format taking original PVs as coimage.
+	 * Write the new PVs out and replace the old PVs in VG structure
+	 * with the new PVs.
+	 */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		existing_pv = pvl->pv;
+		pe_start = pv_pe_start(existing_pv);
+
+		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
+				     &existing_pv->id,
+				     0, 0, 0, pe_start,
+				     pv_pe_count(existing_pv),
+				     pv_pe_size(existing_pv),
+				     label_sector, pvmetadatacopies,
+				     pvmetadatasize, 0))) {
+			log_error("Failed to setup physical volume \"%s\"",
+				  pv_dev_name(existing_pv));
+			if (change_made)
+				goto revert;
+			return 0;
+		}
+
+		/* Need to revert manually if it fails after this point */
+		change_made = 1;
+
+		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+			    " available sectors", pv_dev_name(pv), pv_size(pv));
+
+		/* Wipe existing label first */
+		if (!label_remove(pv_dev(pv))) {
+			log_error("Failed to wipe existing label on %s",
+				  pv_dev_name(pv));
+		}
+
+		log_very_verbose("Writing physical volume data to disk \"%s\"",
+				 pv_dev_name(pv));
+		/* FIXME: This pv_write will change the VG assignment for the
+		 *	  PV info in the cache to orphan VG! We should just change
+		 *	  the existing VG format information in the cache or throw
+		 *	  the cache away after this pv_write. */
+		if (!(pv_write(cmd, pv))) {
+			log_error("Failed to write physical volume \"%s\"",
+				  pv_dev_name(pv));
+			goto revert;
+		}
+		log_verbose("Physical volume \"%s\" successfully created",
+			    pv_dev_name(pv));
+
+		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pv, vg)) {
+			log_error("Failed to setup PV %s in new format for VG %s.",
+				  pv_dev_name(pv), vg_name);
+			goto revert;
+		}
+
+		/* FIXME: Free the mem used by the old PV structure? */
+
+		/* Copy relevant fields from old PV and further initialise new PV. */
+		pv->vg = vg;
+		if (!(pv->vg_name = dm_pool_strdup(vg->vgmem, vg_name))) {
+			log_error("vg->name allocation failed for %s",pv_dev_name(pv));
+			goto revert;
+		}
+		memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
+		if (!alloc_pv_segment_whole_pv(vg->vgmem, pv)) {
+			log_error("pv->segments allocation failed for %s", pv_dev_name(pv));
+			goto revert;
+		}
+
+		pvl->pv = pv;
+	}
+
+
+	return 1;
+
+revert:
+	log_error("Use pvcreate and vgcfgrestore to repair "
+		  "from archived metadata.");
+	return 0;
+}
+
 int remove_lvs_in_vg(struct cmd_context *cmd,
 		     struct volume_group *vg,
 		     force_t force)
--- LVM2/tools/vgconvert.c	2011/02/21 12:26:28	1.47
+++ LVM2/tools/vgconvert.c	2011/02/21 12:29:21	1.48
@@ -19,16 +19,11 @@
 			    struct volume_group *vg,
 			    void *handle __attribute__((unused)))
 {
-	struct physical_volume *pv, *existing_pv;
+	const struct format_type *target_fmt = cmd->fmt;
 	struct logical_volume *lv;
 	struct lv_list *lvl;
-	uint64_t size = 0;
-	struct dm_list mdas;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
-	uint64_t pe_start = 0;
-	struct pv_list *pvl;
-	int change_made = 0;
 	struct lvinfo info;
 	int active = 0;
 
@@ -37,13 +32,13 @@
 		return ECMD_FAILED;
 	}
 
-	if (vg->fid->fmt == cmd->fmt) {
+	if (vg->fid->fmt == target_fmt) {
 		log_error("Volume group \"%s\" already uses format %s",
 			  vg_name, cmd->fmt->name);
 		return ECMD_FAILED;
 	}
 
-	if (cmd->fmt->features & FMT_MDAS) {
+	if (target_fmt->features & FMT_MDAS) {
 		if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
 			log_error("Metadata size may not be negative");
 			return EINVALID_CMD_LINE;
@@ -72,7 +67,7 @@
 
 	/* Set PV/LV limit if converting from unlimited metadata format */
 	if (vg->fid->fmt->features & FMT_UNLIMITED_VOLS &&
-	    !(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
+	    !(target_fmt->features & FMT_UNLIMITED_VOLS)) {
 		if (!vg->max_lv)
 			vg->max_lv = 255;
 		if (!vg->max_pv)
@@ -81,7 +76,7 @@
 
 	/* If converting to restricted lvid, check if lvid is compatible */
 	if (!(vg->fid->fmt->features & FMT_RESTRICTED_LVIDS) &&
-	    cmd->fmt->features & FMT_RESTRICTED_LVIDS)
+	    target_fmt->features & FMT_RESTRICTED_LVIDS)
 		dm_list_iterate_items(lvl, &vg->lvs)
 			if (!lvid_in_restricted_range(&lvl->lv->lvid)) {
 				log_error("Logical volume %s lvid format is"
@@ -91,7 +86,7 @@
 			}
 
 	/* Attempt to change any LVIDs that are too big */
-	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
+	if (target_fmt->features & FMT_RESTRICTED_LVIDS) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			lv = lvl->lv;
 			if (lv->status & SNAPSHOT)
@@ -115,66 +110,18 @@
 		return ECMD_FAILED;
 	}
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		existing_pv = pvl->pv;
-
-		pe_start = pv_pe_start(existing_pv);
-		/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1; */
-
-		dm_list_init(&mdas);
-		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size, 0, 0,
-				     pe_start, pv_pe_count(existing_pv),
-				     pv_pe_size(existing_pv),
-				     arg_int64_value(cmd, labelsector_ARG,
-						     DEFAULT_LABELSECTOR),
-				     pvmetadatacopies, pvmetadatasize, 0))) {
-			log_error("Failed to setup physical volume \"%s\"",
-				  pv_dev_name(existing_pv));
-			if (change_made)
-				log_error("Use pvcreate and vgcfgrestore to "
-					  "repair from archived metadata.");
-			return ECMD_FAILED;
-		}
-
-		/* Need to revert manually if it fails after this point */
-		change_made = 1;
-
-		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", pv_dev_name(pv), pv_size(pv));
-
-		/* Wipe existing label first */
-		if (!label_remove(pv_dev(pv))) {
-			log_error("Failed to wipe existing label on %s",
-				  pv_dev_name(pv));
-			log_error("Use pvcreate and vgcfgrestore to repair "
-				  "from archived metadata.");
-			return ECMD_FAILED;
-		}
-
-		log_very_verbose("Writing physical volume data to disk \"%s\"",
-				 pv_dev_name(pv));
-		if (!(pv_write(cmd, pv))) {
-			log_error("Failed to write physical volume \"%s\"",
-				  pv_dev_name(pv));
-			log_error("Use pvcreate and vgcfgrestore to repair "
-				  "from archived metadata.");
-			return ECMD_FAILED;
-		}
-		log_verbose("Physical volume \"%s\" successfully created",
-			    pv_dev_name(pv));
-
-	}
-
 	log_verbose("Deleting existing metadata for VG %s", vg_name);
 	if (!vg_remove_mdas(vg)) {
 		log_error("Removal of existing metadata for %s failed.",
 			  vg_name);
-		log_error("Use pvcreate and vgcfgrestore to repair "
-			  "from archived metadata.");
-		return ECMD_FAILED;
+		goto revert;
 	}
 
+	if (!vg_convert(cmd, vg, target_fmt, arg_int64_value(cmd,
+				labelsector_ARG, DEFAULT_LABELSECTOR),
+			pvmetadatacopies, pvmetadatasize))
+		goto revert;
+
 	/* FIXME Cache the label format change so we don't have to skip this */
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping metadata writing for VG %s in"
@@ -183,18 +130,21 @@
 	}
 
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
-		    cmd->fmt->name);
-	if (!backup_restore_vg(cmd, vg)) {
+		    target_fmt->name);
+	if (!vg_write(vg) || !vg_commit(vg)) {
 		log_error("Conversion failed for volume group %s.", vg_name);
-		log_error("Use pvcreate and vgcfgrestore to repair from "
-			  "archived metadata.");
-		return ECMD_FAILED;
+		goto revert;
 	}
 	log_print("Volume group %s successfully converted", vg_name);
 
 	backup(vg);
 
 	return ECMD_PROCESSED;
+
+revert:
+	log_error("Use pvcreate and vgcfgrestore to repair "
+		  "from archived metadata.");
+	return ECMD_FAILED;
 }
 
 int vgconvert(struct cmd_context *cmd, int argc, char **argv)


