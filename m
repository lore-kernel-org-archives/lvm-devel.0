From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:46 +0000 (UTC)
Subject: master - backup: backup_restore_vg: register PVs that need writing via vg->pvs_to_write list
Message-ID: <20160215120846.BC68460A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d84a80afb5e65420fdca3c283754a90e5b0bacaa
Commit:        d84a80afb5e65420fdca3c283754a90e5b0bacaa
Parent:        531ced90dcaa6d7b18189cb9169456b74c6a2d65
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 26 14:20:46 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

backup: backup_restore_vg: register PVs that need writing via vg->pvs_to_write list

The backup_restore_vg is used directly for restoring the VG from backup.
It's also used to do the VG conversions from one metadata format to
another which means vgconvert calls backup_restore_vg too.

When restoring VG from backup, we need to rewrite/write PV headers as
PVs may have been orphans before and now they're becoming part of some
VG - we need to write the PV_EXT_USED flag at least.

When using the backup_restore_vg for vgconvert, we need to write
completely new PV header in different format.

Avoid the special "pv_write" call and handling that was used before
this patch in vgconvert (vgconvert_single function to be more precise)
and reuse existing internal interface to register PV header for writing
(or rewriting) via vg->pvs_to_write list instead like we do it elsewhere
in the code.

This patch also resolves a problem in which PV headers with target
format were written in the vgconvert_single fn as orphans and VG
metadata were added later on - this was a tiny hack actually.
We can't do this now - we need to write the PV as belonging
to a VG because otherwise the PV_EXT_USED flag won't be written
properly (if the PV header is written as orphan, the PV_EXT_USED
is set to 0, of course, even though metadata are attached later).
So this patch removes this tiny inconsistency which was passing
just fine before because we didn't have any relation to the VG
in PV header before. Now we have the PV_EXT_USED flag which says
the "PV is used in some VG".
---
 lib/format_text/archiver.c |  120 +++++++++++++++++++++++++++++++++++++++----
 lib/format_text/archiver.h |    3 +-
 tools/vgconvert.c          |   89 +++++----------------------------
 3 files changed, 123 insertions(+), 89 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 56eb1ca..1bc9557 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -329,28 +329,113 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	return vg;
 }
 
+static int _restore_vg_should_write_pv(struct physical_volume *pv, struct pvcreate_params *pp)
+{
+	struct lvmcache_info *info;
+
+	if (pp)
+		return 1;
+
+	if (!(pv->fmt->features & FMT_PV_FLAGS))
+		return 0;
+
+	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
+		return -1;
+	}
+
+	/*
+	 * We're restoring a VG and if the PV_EXT_USED
+	 * flag is not set yet in PV, we need to set it now!
+	 * This may happen if we have plain PVs without a VG
+	 * and we're restoring former VG from backup on top
+	 * of these PVs.
+	 */
+	if (!(lvmcache_ext_flags(info) & PV_EXT_USED))
+		return 1;
+
+	return 0;
+}
+
 /* ORPHAN and VG locks held before calling this */
-int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop_lvmetad)
+int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
+		      struct pvcreate_params *pp, int drop_lvmetad)
 {
-	struct pv_list *pvl;
+	struct dm_list new_pvs;
+	struct pv_list *pvl, *new_pvl;
+	struct physical_volume *existing_pv, *pv;
+	struct dm_list *pvs = &vg->pvs;;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
+	int should_write_pv;
 	struct pv_to_write *pvw;
-	uint32_t tmp;
+	uint32_t tmp_extent_size;
 
 	/*
 	 * FIXME: Check that the PVs referenced in the backup are
 	 * not members of other existing VGs.
 	 */
 
+	/* Prepare new PVs if needed. */
+	if (pp) {
+		dm_list_init(&new_pvs);
+
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			existing_pv = pvl->pv;
+
+			pp->rp.id = existing_pv->id;
+			pp->rp.idp = &pp->rp.id;
+			pp->rp.pe_start = pv_pe_start(existing_pv);
+			pp->rp.extent_count = pv_pe_count(existing_pv);
+			pp->rp.extent_size = pv_pe_size(existing_pv);
+			/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1 */
+
+			if (!(pv = pv_create(cmd, pv_dev(existing_pv),
+					     0, 0, 0,
+					     pp->labelsector,
+					     pp->pvmetadatacopies,
+					     pp->pvmetadatasize,
+					     0, &pp->rp))) {
+				log_error("Failed to setup physical volume \"%s\".",
+					  pv_dev_name(existing_pv));
+				return 0;
+			}
+			pv->vg_name = vg->name;
+			pv->vgid = vg->id;
+
+			if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
+				log_error("Failed to allocate PV list item for \"%s\".",
+					  pv_dev_name(pvl->pv));
+				return 0;
+			}
+			new_pvl->pv = pv;
+			dm_list_add(&new_pvs, &new_pvl->list);
+
+			log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+				    " available sectors.", pv_dev_name(pv), pv_size(pv));
+		}
+
+		pvs = &new_pvs;
+	}
+
 	/* Attempt to write out using currently active format */
 	fic.type = FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg->name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
-		log_error("Failed to allocate format instance");
+		log_error("Failed to allocate format instance.");
 		return 0;
 	}
+
+	if (pp) {
+		log_verbose("Deleting existing metadata for VG %s.", vg->name);
+		if (!vg_remove_mdas(vg)) {
+			cmd->fmt->ops->destroy_instance(fid);
+			log_error("Removal of existing metadata for VG %s failed.", vg->name);
+			return 0;
+		}
+	}
+
 	vg_set_fid(vg, fid);
 
 	/*
@@ -363,25 +448,36 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop
 	}
 
 	/* Add any metadata areas on the PVs */
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (pvl->pv->fmt->features & FMT_PV_FLAGS) {
+	dm_list_iterate_items(pvl, pvs) {
+		if ((should_write_pv = _restore_vg_should_write_pv(pvl->pv, pp)) < 0)
+			return_0;
+
+		if (should_write_pv) {
 			if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
-				log_error("pv_to_write allocation for '%s' failed", pv_dev_name(pvl->pv));
+				log_error("Failed to allocate structure for scheduled "
+					  "writing of PV '%s'.", pv_dev_name(pvl->pv));
 				return 0;
 			}
+
+			if (pp) {
+				pvw->new_pv = 1;
+				pvw->pp = pp;
+			}
+
 			pvw->pv = pvl->pv;
 			dm_list_add(&vg->pvs_to_write, &pvw->list);
 		}
 
-		tmp = vg->extent_size;
+		/* Add any metadata areas on the PV. */
+		tmp_extent_size = vg->extent_size;
 		vg->extent_size = 0;
 		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pvl->pv, vg)) {
-			vg->extent_size = tmp;
-			log_error("Format-specific setup for %s failed",
+			vg->extent_size = tmp_extent_size;
+			log_error("Format-specific setup for %s failed.",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
-		vg->extent_size = tmp;
+		vg->extent_size = tmp_extent_size;
 	}
 
 	if (!vg_write(vg))
@@ -435,7 +531,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg, 1);
+		r = backup_restore_vg(cmd, vg, NULL, 1);
 	else
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index c283420..f85e5af 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -51,7 +51,8 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name);
 
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
-int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg, int drop_lvmetad);
+int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
+		      struct pvcreate_params *pp, int drop_lvmetad);
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file, int force);
 int backup_restore(struct cmd_context *cmd, const char *vg_name, int force);
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 0b680b9..de21a47 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -19,14 +19,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    struct processing_handle *handle __attribute__((unused)))
 {
-	struct physical_volume *pv, *existing_pv;
-	struct pvcreate_restorable_params rp;
+	struct pvcreate_params pp;
 	struct logical_volume *lv;
 	struct lv_list *lvl;
-	int pvmetadatacopies = 0;
-	uint64_t pvmetadatasize = 0;
-	struct pv_list *pvl;
-	int change_made = 0;
 	struct lvinfo info;
 	int active = 0;
 
@@ -39,21 +34,22 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
+	pvcreate_params_set_defaults(&pp);
+
 	if (cmd->fmt->features & FMT_MDAS) {
 		if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Metadata size may not be negative");
 			return EINVALID_CMD_LINE;
 		}
 
-		pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG,
-						  UINT64_C(0));
-		if (!pvmetadatasize)
-			pvmetadatasize =
+		pp.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+		if (!pp.pvmetadatasize)
+			pp.pvmetadatasize =
 			    find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
-		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-		if (pvmetadatacopies < 0)
-			pvmetadatacopies =
+		pp.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+		if (pp.pvmetadatacopies < 0)
+			pp.pvmetadatacopies =
 			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 	}
 
@@ -63,9 +59,11 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			return EINVALID_CMD_LINE;
 		}
 
-		rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
+		pp.rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
 	}
 
+	pp.labelsector = arg_int64_value(cmd, labelsector_ARG, DEFAULT_LABELSECTOR);
+
 	if (!vg_check_new_extent_size(cmd->fmt, vg->extent_size))
 		return_ECMD_FAILED;
 
@@ -124,67 +122,6 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	if (active)
 		return_ECMD_FAILED;
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		existing_pv = pvl->pv;
-
-		rp.id = existing_pv->id;
-		rp.idp = &rp.id;
-		rp.pe_start = pv_pe_start(existing_pv);
-		rp.extent_count = pv_pe_count(existing_pv);
-		rp.extent_size = pv_pe_size(existing_pv);
-
-		/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1; */
-
-		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     0, 0, 0,
-				     arg_int64_value(cmd, labelsector_ARG,
-						     DEFAULT_LABELSECTOR),
-				     pvmetadatacopies, pvmetadatasize, 0, &rp))) {
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
-		if (!(pv_write(cmd, pv, 0))) {
-			log_error("Failed to write physical volume \"%s\"",
-				  pv_dev_name(pv));
-			log_error("Use pvcreate and vgcfgrestore to repair "
-				  "from archived metadata.");
-			return ECMD_FAILED;
-		}
-		log_verbose("Physical volume \"%s\" successfully created",
-			    pv_dev_name(pv));
-	}
-
-	log_verbose("Deleting existing metadata for VG %s", vg_name);
-	if (!vg_remove_mdas(vg)) {
-		log_error("Removal of existing metadata for %s failed.",
-			  vg_name);
-		log_error("Use pvcreate and vgcfgrestore to repair "
-			  "from archived metadata.");
-		return ECMD_FAILED;
-	}
-
 	/* FIXME Cache the label format change so we don't have to skip this */
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping metadata writing for VG %s in"
@@ -194,7 +131,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
-	if (!backup_restore_vg(cmd, vg, 0)) {
+	if (!backup_restore_vg(cmd, vg, &pp, 0)) {
 		log_error("Conversion failed for volume group %s.", vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");


