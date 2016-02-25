From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:31 +0000 (UTC)
Subject: master - vgconvert: refactor to avoid pvcreate code
Message-ID: <20160225151531.2B58761BB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff2267012aea37e08ed1fc2a511f8a0d3f0d145b
Commit:        ff2267012aea37e08ed1fc2a511f8a0d3f0d145b
Parent:        5dd615c41ee1c6c77a927b5f39bf1554caaa572f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 13:22:50 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

vgconvert: refactor to avoid pvcreate code

This uses the vg->pv_write_list in place of the
vg->pvs_to_write list, and eliminates the use of
pvcreate_params.  The label remove and zeroing
steps are shifted out of vg_write() to the higher
level like pvcreate will do.
---
 lib/format_text/archiver.c |   80 ++++++++++++++++++++++++++++++--------------
 lib/format_text/archiver.h |    9 ++++-
 tools/vgconvert.c          |   31 +++++++++--------
 3 files changed, 79 insertions(+), 41 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e52854f..07dece3 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -329,11 +329,11 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	return vg;
 }
 
-static int _restore_vg_should_write_pv(struct physical_volume *pv, struct pvcreate_params *pp)
+static int _restore_vg_should_write_pv(struct physical_volume *pv, int do_pvcreate)
 {
 	struct lvmcache_info *info;
 
-	if (pp)
+	if (do_pvcreate)
 		return 1;
 
 	if (!(pv->fmt->features & FMT_PV_FLAGS))
@@ -359,8 +359,15 @@ static int _restore_vg_should_write_pv(struct physical_volume *pv, struct pvcrea
 
 /* ORPHAN and VG locks held before calling this */
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
-		      struct pvcreate_params *pp, int drop_lvmetad)
+		      int drop_lvmetad,
+		      int do_pvcreate,
+		      uint64_t bootloaderareasize,
+		      int pvmetadatacopies,
+		      uint64_t pvmetadatasize,
+		      uint64_t label_sector)
+
 {
+	struct pvcreate_restorable_params rp = { 0 };
 	struct dm_list new_pvs;
 	struct pv_list *pvl, *new_pvl;
 	struct physical_volume *existing_pv, *pv;
@@ -368,7 +375,6 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 	int should_write_pv;
-	struct pv_to_write *pvw;
 	uint32_t tmp_extent_size;
 
 	/*
@@ -377,25 +383,26 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 */
 
 	/* Prepare new PVs if needed. */
-	if (pp) {
+	if (do_pvcreate) {
 		dm_list_init(&new_pvs);
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			existing_pv = pvl->pv;
 
-			pp->rp.id = existing_pv->id;
-			pp->rp.idp = &pp->rp.id;
-			pp->rp.pe_start = pv_pe_start(existing_pv);
-			pp->rp.extent_count = pv_pe_count(existing_pv);
-			pp->rp.extent_size = pv_pe_size(existing_pv);
+			rp.id = existing_pv->id;
+			rp.idp = &rp.id;
+			rp.pe_start = pv_pe_start(existing_pv);
+			rp.extent_count = pv_pe_count(existing_pv);
+			rp.extent_size = pv_pe_size(existing_pv);
+			rp.ba_size = bootloaderareasize;
 			/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1 */
 
 			if (!(pv = pv_create(cmd, pv_dev(existing_pv),
 					     0, 0, 0,
-					     pp->labelsector,
-					     pp->pvmetadatacopies,
-					     pp->pvmetadatasize,
-					     0, &pp->rp))) {
+					     label_sector,
+					     pvmetadatacopies,
+					     pvmetadatasize,
+					     0, &rp))) {
 				log_error("Failed to setup physical volume \"%s\".",
 					  pv_dev_name(existing_pv));
 				return 0;
@@ -408,6 +415,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 					  pv_dev_name(pvl->pv));
 				return 0;
 			}
+
 			new_pvl->pv = pv;
 			dm_list_add(&new_pvs, &new_pvl->list);
 
@@ -427,7 +435,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	if (pp) {
+	if (do_pvcreate) {
 		log_verbose("Deleting existing metadata for VG %s.", vg->name);
 		if (!vg_remove_mdas(vg)) {
 			cmd->fmt->ops->destroy_instance(fid);
@@ -449,23 +457,18 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, pvs) {
-		if ((should_write_pv = _restore_vg_should_write_pv(pvl->pv, pp)) < 0)
+		if ((should_write_pv = _restore_vg_should_write_pv(pvl->pv, do_pvcreate)) < 0)
 			return_0;
 
 		if (should_write_pv) {
-			if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+			if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
 				log_error("Failed to allocate structure for scheduled "
 					  "writing of PV '%s'.", pv_dev_name(pvl->pv));
 				return 0;
 			}
 
-			if (pp) {
-				pvw->new_pv = 1;
-				pvw->pp = pp;
-			}
-
-			pvw->pv = pvl->pv;
-			dm_list_add(&vg->pvs_to_write, &pvw->list);
+			new_pvl->pv = pvl->pv;
+			dm_list_add(&vg->pv_write_list, &new_pvl->list);
 		}
 
 		/* Add any metadata areas on the PV. */
@@ -480,6 +483,33 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 		vg->extent_size = tmp_extent_size;
 	}
 
+	if (do_pvcreate) {
+		dm_list_iterate_items(pvl, &vg->pv_write_list) {
+			struct device *dev = pv_dev(pvl->pv);
+			const char *pv_name = dev_name(dev);
+
+			if (!label_remove(dev)) {
+				log_error("Failed to wipe existing label on %s", pv_name);
+				return 0;
+			}
+
+			log_verbose("Zeroing start of device %s", pv_name);
+			if (!dev_open_quiet(dev)) {
+				log_error("%s not opened: device not zeroed", pv_name);
+				return 0;
+			}
+
+			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+				log_error("%s not wiped: aborting", pv_name);
+				if (!dev_close(dev))
+					stack;
+				return 0;
+			}
+			if (!dev_close(dev))
+				stack;
+		}
+	}
+
 	if (!vg_write(vg))
 		return_0;
 
@@ -531,7 +561,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
-		r = backup_restore_vg(cmd, vg, NULL, 1);
+		r = backup_restore_vg(cmd, vg, 1, 0, 0, 0, 0, 0);
 	else
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index f85e5af..b8e53e3 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -51,8 +51,15 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name);
 
 struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
+
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
-		      struct pvcreate_params *pp, int drop_lvmetad);
+                      int drop_lvmetad,
+                      int do_pvcreate,
+                      uint64_t bootloaderareasize,
+                      int pvmetadatacopies,
+                      uint64_t pvmetadatasize,
+                      uint64_t label_sector);
+
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file, int force);
 int backup_restore(struct cmd_context *cmd, const char *vg_name, int force);
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index de21a47..1462d77 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -19,11 +19,13 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
 			    struct processing_handle *handle __attribute__((unused)))
 {
-	struct pvcreate_params pp;
 	struct logical_volume *lv;
 	struct lv_list *lvl;
 	struct lvinfo info;
 	int active = 0;
+	int pvmetadatacopies = 0;
+	uint64_t pvmetadatasize = 0;
+	uint64_t bootloaderareasize = 0;
 
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return_ECMD_FAILED;
@@ -34,23 +36,19 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	pvcreate_params_set_defaults(&pp);
-
 	if (cmd->fmt->features & FMT_MDAS) {
 		if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Metadata size may not be negative");
 			return EINVALID_CMD_LINE;
 		}
 
-		pp.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-		if (!pp.pvmetadatasize)
-			pp.pvmetadatasize =
-			    find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
+		pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+		if (!pvmetadatasize)
+			pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
-		pp.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-		if (pp.pvmetadatacopies < 0)
-			pp.pvmetadatacopies =
-			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+		pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+		if (pvmetadatacopies < 0)
+			pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 	}
 
 	if (cmd->fmt->features & FMT_BAS) {
@@ -59,11 +57,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			return EINVALID_CMD_LINE;
 		}
 
-		pp.rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
+		bootloaderareasize = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
 	}
 
-	pp.labelsector = arg_int64_value(cmd, labelsector_ARG, DEFAULT_LABELSECTOR);
-
 	if (!vg_check_new_extent_size(cmd->fmt, vg->extent_size))
 		return_ECMD_FAILED;
 
@@ -131,7 +127,12 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 	log_verbose("Writing metadata for VG %s using format %s", vg_name,
 		    cmd->fmt->name);
-	if (!backup_restore_vg(cmd, vg, &pp, 0)) {
+
+	if (!backup_restore_vg(cmd, vg, 0, 1,
+			       bootloaderareasize,
+			       pvmetadatacopies,
+			       pvmetadatasize,
+			       arg_int64_value(cmd, labelsector_ARG, DEFAULT_LABELSECTOR))) {
 		log_error("Conversion failed for volume group %s.", vg_name);
 		log_error("Use pvcreate and vgcfgrestore to repair from "
 			  "archived metadata.");


