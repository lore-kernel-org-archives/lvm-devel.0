From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:07 +0000 (UTC)
Subject: dev-dct-process-latest - logging: use flags to enable warnings
Message-ID: <20140922154007.90D3A60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=437bcc5abe67c97da965403b699f2ed1a54af40a
Commit:        437bcc5abe67c97da965403b699f2ed1a54af40a
Parent:        6351dabe95a7c0f4837567953466c4910c858fa9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 23 13:44:54 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:24 2014 -0500

logging: use flags to enable warnings

The "warnings" arg was used to enable logging of warnings
when reading a pv.  This arg is turned into a set of flags
with the WARN_PV_READ flag matching the existing behavior.

A new flag WARN_INCONSISTENT is added that will cause
vg_read_internal() to log the "vg is not consistent"
warning, and the various callers do not need to log
this warning themselves.

A new vg_read flag READ_WARN_INCONSISTENT is used from
reporting to enable the WARN_INCONSISTENT flag in
vg_read_internal.
---
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/format_text/import.c         |    7 ++-
 lib/metadata/metadata-exported.h |    9 +++-
 lib/metadata/metadata.c          |   92 +++++++++++++++++++-------------------
 tools/toollib.c                  |    2 +-
 5 files changed, 59 insertions(+), 53 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f3a56ce..4ebd059 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -842,7 +842,7 @@ void lvm_do_backup(const char *vgname)
 
 	pthread_mutex_lock(&lvm_lock);
 
-	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, 1, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, WARN_PV_READ, &consistent);
 
 	if (vg && consistent)
 		check_current_backup(vg);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 1b1f332..41e41a6 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -51,8 +51,10 @@ const char *text_vgname_import(const struct format_type *fmt,
 
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum)))
-		goto_out;
+					 offset2, size2, checksum_fn, checksum))) {
+		log_error("Couldn't read volume group metadata.");
+		goto out;
+	}
 
 	/*
 	 * Find a set of version functions that can read this file
@@ -98,7 +100,6 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
 					 offset2, size2, checksum_fn, checksum))) {
-		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0fa6c97..a699799 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -144,6 +144,7 @@
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
 #define READ_WITHOUT_LOCK	0x00040000U
+#define READ_WARN_INCONSISTENT	0x00080000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE		0x00100000U
@@ -542,6 +543,10 @@ int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		    struct pvcreate_params *pp);
 void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 
+/* warn_flags */
+#define WARN_PV_READ      0x00000001
+#define WARN_INCONSISTENT 0x00000002
+
 /*
 * Utility functions
 */
@@ -549,7 +554,7 @@ int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 void vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-				      const char *vgid, int warnings, int *consistent);
+				      const char *vgid, uint32_t warn_flags, int *consistent);
 
 #define get_pvs( cmd ) get_pvs_internal((cmd), NULL, NULL)
 #define get_pvs_perserve_vg( cmd, pv_list, vg_list ) get_pvs_internal((cmd), (pv_list), (vg_list))
@@ -567,7 +572,7 @@ void lv_set_hidden(struct logical_volume *lv);
 
 struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
-int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings);
+int scan_vgs_for_pvs(struct cmd_context *cmd, uint32_t warn_flags);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv, int allow_non_orphan);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0842563..586876d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -39,7 +39,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					int warnings, int scan_label_only);
+					uint32_t warn_flags, int scan_label_only);
 
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
@@ -333,18 +333,15 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 {
 	struct volume_group *vg;
 	struct pv_list *pvl;
+	uint32_t warn_flags = WARN_PV_READ | WARN_INCONSISTENT;
 	int r = 0, consistent = 0;
 
-	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, 1, &consistent))) {
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, warn_flags, &consistent))) {
 		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
 
-	if (!consistent)
-		log_warn("WARNING: Volume group %s is not consistent",
-			 vg_name);
-
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
 			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
@@ -1045,7 +1042,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	/* FIXME: Is this vg_read_internal necessary? Move it inside
 	   vg_lock_newname? */
 	/* is this vg name already in use ? */
-	if ((vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, WARN_PV_READ, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
@@ -2909,7 +2906,7 @@ void vg_revert(struct volume_group *vg)
 
 struct _vg_read_orphan_baton {
 	struct volume_group *vg;
-	int warnings;
+	uint32_t warn_flags;
 };
 
 static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
@@ -2919,7 +2916,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	struct pv_list *pvl;
 
 	if (!(pv = _pv_read(b->vg->cmd, b->vg->vgmem, dev_name(lvmcache_device(info)),
-			    b->vg->fid, b->warnings, 0))) {
+			    b->vg->fid, b->warn_flags, 0))) {
 		stack;
 		return 1;
 	}
@@ -2936,7 +2933,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 
 /* Make orphan PVs look like a VG. */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
-					     int warnings,
+					     uint32_t warn_flags,
 					     const char *orphan_vgname)
 {
 	const struct format_type *fmt;
@@ -2969,7 +2966,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	vg->extent_count = 0;
 	vg->free_count = 0;
 
-	baton.warnings = warnings;
+	baton.warn_flags = warn_flags;
 	baton.vg = vg;
 
 	while ((pvl = (struct pv_list *) dm_list_first(&head.list))) {
@@ -3118,7 +3115,7 @@ static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
-				     int warnings, 
+				     uint32_t warn_flags, 
 				     int *consistent, unsigned precommitted)
 {
 	struct format_instance *fid = NULL;
@@ -3147,7 +3144,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return NULL;
 		}
 		*consistent = 1;
-		return _vg_read_orphans(cmd, warnings, vgname);
+		return _vg_read_orphans(cmd, warn_flags, vgname);
 	}
 
 	if (lvmetad_active() && !use_precommitted) {
@@ -3584,19 +3581,21 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 }
 
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
-			     const char *vgid, int warnings, int *consistent)
+			     const char *vgid, uint32_t warn_flags, int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, warnings, consistent, 0)))
-		return NULL;
+	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, consistent, 0))) {
+		goto_out;
+	}
 
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
 		release_vg(vg);
-		return NULL;
+		vg = NULL;
+		goto out;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -3604,7 +3603,8 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
 			release_vg(vg);
-			return NULL;
+			vg = NULL;
+			goto out;
 		}
 	}
 
@@ -3616,9 +3616,13 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
 			release_vg(vg);
-			return NULL;
+			vg = NULL;
+			goto out;
 		}
 	}
+out:
+	if (!*consistent && (warn_flags & WARN_INCONSISTENT))
+		log_warn("WARNING: Volume Group %s is not consistent", vgname);
 
 	return vg;
 }
@@ -3643,16 +3647,13 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	struct dm_list *vgnames;
 	struct volume_group *vg;
 	struct dm_str_list *strl;
+	uint32_t warn_flags = WARN_PV_READ | WARN_INCONSISTENT;
 	int consistent = 0;
 
 	/* Is corresponding vgname already cached? */
 	if (lvmcache_vgid_is_cached(vgid)) {
-		if ((vg = _vg_read(cmd, NULL, vgid, 1,
-				   &consistent, precommitted)) &&
+		if ((vg = _vg_read(cmd, NULL, vgid, warn_flags, &consistent, precommitted)) &&
 		    id_equal(&vg->id, (const struct id *)vgid)) {
-			if (!consistent)
-				log_error("Volume group %s metadata is "
-					  "inconsistent", vg->name);
 			return vg;
 		}
 		release_vg(vg);
@@ -3678,12 +3679,9 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		if (!vgname)
 			continue;	// FIXME Unnecessary?
 		consistent = 0;
-		if ((vg = _vg_read(cmd, vgname, vgid, 1, &consistent,
-				   precommitted)) &&
+		if ((vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted)) &&
 		    id_equal(&vg->id, (const struct id *)vgid)) {
 			if (!consistent) {
-				log_error("Volume group %s metadata is "
-					  "inconsistent", vgname);
 				release_vg(vg);
 				return NULL;
 			}
@@ -3747,7 +3745,7 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 		 * every PV on the system.
 		 */
 		if (lvmcache_uncertain_ownership(info)) {
-			if (!scan_vgs_for_pvs(cmd, 1)) {
+			if (!scan_vgs_for_pvs(cmd, WARN_PV_READ)) {
 				log_error("Rescan for PVs without "
 					  "metadata areas failed.");
 				return NULL;
@@ -3781,7 +3779,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					int warnings, int scan_label_only)
+					uint32_t warn_flags, int scan_label_only)
 {
 	struct physical_volume *pv;
 	struct label *label;
@@ -3799,13 +3797,13 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
 				return_NULL;
 			if (!found) {
-				if (warnings)
+				if (warn_flags & WARN_PV_READ)
 					log_error("No physical volume found in lvmetad cache for %s",
 						  pv_name);
 				return NULL;
 			}
 			if (!(info = lvmcache_info_from_pvid(dev->pvid, 0))) {
-				if (warnings)
+				if (warn_flags & WARN_PV_READ)
 					log_error("No cache info in lvmetad cache for %s.",
 						  pv_name);
 				return NULL;
@@ -3814,7 +3812,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 		label = lvmcache_get_label(info);
 	} else {
 		if (!(label_read(dev, &label, UINT64_C(0)))) {
-			if (warnings)
+			if (warn_flags & WARN_PV_READ)
 				log_error("No physical volume label read from %s",
 					  pv_name);
 			return NULL;
@@ -3870,7 +3868,7 @@ struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 	return lvmcache_get_vgids(cmd, include_internal);
 }
 
-static int _get_pvs(struct cmd_context *cmd, int warnings,
+static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 		struct dm_list *pvslist, struct dm_list *vgslist)
 {
 	struct dm_str_list *strl;
@@ -3913,13 +3911,13 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 		 * vgid will be NULL.
 		 * FIXME Remove this hack.
 		 */
-		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, warnings, &consistent))) {
+
+		warn_flags |= WARN_INCONSISTENT;
+
+		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, warn_flags, &consistent))) {
 			stack;
 			continue;
 		}
-		if (!consistent)
-			log_warn("WARNING: Volume Group %s is not consistent",
-				 vgname);
 
 		/* Move PVs onto results list */
 		if (pvslist)
@@ -4001,7 +3999,7 @@ struct dm_list *get_pvs_internal(struct cmd_context *cmd,
 		dm_list_init(results);
 	}
 
-	if (!_get_pvs(cmd, 1, results, vgslist)) {
+	if (!_get_pvs(cmd, WARN_PV_READ, results, vgslist)) {
 		if (!pvslist)
 			dm_pool_free(cmd->mem, results);
 		return NULL;
@@ -4009,9 +4007,9 @@ struct dm_list *get_pvs_internal(struct cmd_context *cmd,
 	return results;
 }
 
-int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings)
+int scan_vgs_for_pvs(struct cmd_context *cmd, uint32_t warn_flags)
 {
-	return _get_pvs(cmd, warnings, NULL, NULL);
+	return _get_pvs(cmd, warn_flags, NULL, NULL);
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
@@ -4217,7 +4215,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, WARN_PV_READ, &consistent))) {
 		unlock_vg(cmd, vg_name);
 		return_NULL;
 	}
@@ -4250,6 +4248,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	int consistent = 1;
 	int consistent_in;
 	uint32_t failure = 0;
+	uint32_t warn_flags = 0;
 	int already_locked;
 
 	if (misc_flags & READ_ALLOW_INCONSISTENT || lock_flags != LCK_VG_WRITE)
@@ -4274,16 +4273,17 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	consistent_in = consistent;
 
+	warn_flags = WARN_PV_READ;
+	if (consistent || (misc_flags & READ_WARN_INCONSISTENT))
+		warn_flags |= WARN_INCONSISTENT;
+
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, warn_flags, &consistent))) {
 		if (consistent_in && !consistent) {
-			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto bad;
 		}
-
 		log_error("Volume group \"%s\" not found", vg_name);
-
 		failure |= FAILED_NOTFOUND;
 		goto bad;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 0a0cb6f..bc5e5e1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2014,7 +2014,7 @@ static int process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		ret = 0;
 		skip = 0;
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags);
+		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
 		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &ret)) {
 			if (ret > ret_max)
 				ret_max = ret;


