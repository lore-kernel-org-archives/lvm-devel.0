From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 11:40:02 -0400
Subject: master - vgsplit: simplify vg creation
Message-ID: <201906101540.x5AFe2W6019903@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=550536474f2b2ad3ac58f1f91aa2325022df53b9
Commit:        550536474f2b2ad3ac58f1f91aa2325022df53b9
Parent:        5036244ce87f3854c7d6b14ab754f43eceaf24eb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 7 14:30:03 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 10:38:32 2019 -0500

vgsplit: simplify vg creation

The way that this command now uses the global lock
followed by a label scan, it can simply check if the
new VG name exists, and if not lock it and create it.
---
 lib/metadata/metadata.c |   62 +---------------------
 tools/vgsplit.c         |  133 ++++++++++-------------------------------------
 2 files changed, 29 insertions(+), 166 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e0a5114..aceac5a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -985,29 +985,6 @@ int vg_has_unknown_segments(const struct volume_group *vg)
 	return 0;
 }
 
-struct volume_group *vg_lock_and_create(struct cmd_context *cmd, const char *vg_name, int *exists)
-{
-	uint32_t rc;
-	struct volume_group *vg;
-
-	if (!validate_name(vg_name)) {
-		log_error("Invalid vg name %s", vg_name);
-		return NULL;
-	}
-
-	rc = vg_lock_newname(cmd, vg_name);
-	if (rc == FAILED_EXIST)
-		*exists = 1;
-	if (rc != SUCCESS)
-		return NULL;
-
-	vg = vg_create(cmd, vg_name);
-	if (!vg)
-		unlock_vg(cmd, NULL, vg_name);
-
-	return vg;
-}
-
 /*
  * Create a VG with default parameters.
  */
@@ -3265,7 +3242,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 /* Make orphan PVs look like a VG. */
 struct volume_group *vg_read_orphans(struct cmd_context *cmd, const char *orphan_vgname)
 {
-	const struct format_type *fmt;
+	const struct format_type *fmt = cmd->fmt;
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
 	struct _vg_read_orphan_baton baton;
@@ -3277,9 +3254,6 @@ struct volume_group *vg_read_orphans(struct cmd_context *cmd, const char *orphan
 	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
-	if (!(fmt = lvmcache_fmt_from_vgname(cmd, orphan_vgname, NULL, 0)))
-		return_NULL;
-
 	vg = fmt->orphan_vg;
 
 	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs)
@@ -3973,40 +3947,6 @@ uint32_t vg_read_error(struct volume_group *vg_handle)
 	return SUCCESS;
 }
 
-/*
- * Lock a vgname and/or check for existence.
- * Takes a WRITE lock on the vgname before scanning.
- * If scanning fails or vgname found, release the lock.
- * NOTE: If you find the return codes confusing, you might think of this
- * function as similar to an open() call with O_CREAT and O_EXCL flags
- * (open returns fail with -EEXIST if file already exists).
- *
- * Returns:
- * FAILED_LOCKING - Cannot lock name
- * FAILED_EXIST - VG name already exists - cannot reserve
- * SUCCESS - VG name does not exist in system and WRITE lock held
- */
-uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
-{
-	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL))
-		return FAILED_LOCKING;
-
-	/* Find the vgname in the cache */
-	/* If it's not there we must do full scan to be completely sure */
-	if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
-		lvmcache_label_scan(cmd);
-		if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
-			lvmcache_label_scan(cmd);
-			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0))
-				return SUCCESS; /* vgname not found after scanning */
-		}
-	}
-
-	/* Found vgname so cannot reserve. */
-	unlock_vg(cmd, NULL, vgname);
-	return FAILED_EXIST;
-}
-
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic)
 {
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index abf7013..61cb13b 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -446,80 +446,6 @@ static int _move_cache(struct volume_group *vg_from,
 }
 
 /*
- * Create or open the destination of the vgsplit operation.
- * Returns
- * - non-NULL: VG handle w/VG lock held
- * - NULL: no VG lock held
- */
-static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
-					const char *vg_name_to,
-					int *existing_vg)
-{
-	struct volume_group *vg_to = NULL;
-	int exists = 0;
-
-	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	/*
-	 * First try to create a new VG.  If we cannot create it,
-	 * and we get FAILED_EXIST (we will not be holding a lock),
-	 * a VG must already exist with this name.  We then try to
-	 * read the existing VG - the vgsplit will be into an existing VG.
-	 *
-	 * Otherwise, if the lock was successful, it must be the case that
-	 * we obtained a WRITE lock and could not find the vgname in the
-	 * system.  Thus, the split will be into a new VG.
-	 */
-	vg_to = vg_lock_and_create(cmd, vg_name_to, &exists);
-	if (!vg_to && !exists) {
-		log_error("Can't get lock for %s", vg_name_to);
-		release_vg(vg_to);
-		return NULL;
-	}
-	if (!vg_to && exists) {
-		*existing_vg = 1;
-		release_vg(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);
-
-		if (vg_read_error(vg_to)) {
-			release_vg(vg_to);
-			return_NULL;
-		}
-
-	} else if (vg_read_error(vg_to) == SUCCESS) {
-		*existing_vg = 0;
-	}
-	return vg_to;
-}
-
-/*
- * Open the source of the vgsplit operation.
- * Returns
- * - non-NULL: VG handle w/VG lock held
- * - NULL: no VG lock held
- */
-static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
-					  const char *vg_name_from)
-{
-	struct volume_group *vg_from;
-
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0, 0);
-	if (vg_read_error(vg_from)) {
-		release_vg(vg_from);
-		return NULL;
-	}
-
-	if (vg_is_shared(vg_from)) {
-		log_error("vgsplit not allowed for lock_type %s", vg_from->lock_type);
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
-		return NULL;
-	}
-
-	return vg_from;
-}
-
-/*
  * Has the user given an option related to a new vg as the split destination?
  */
 static int _new_vg_option_specified(struct cmd_context *cmd)
@@ -537,11 +463,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	struct vgcreate_params vp_def;
 	const char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
+	struct lvmcache_vginfo *vginfo_to;
 	int opt;
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
-	int lock_vg_from_first = 1;
 
 	if ((arg_is_set(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -577,47 +503,44 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	lvmcache_label_scan(cmd);
 
-	if (strcmp(vg_name_to, vg_name_from) < 0)
-		lock_vg_from_first = 0;
-
-	if (lock_vg_from_first) {
-		if (!(vg_from = _vgsplit_from(cmd, vg_name_from)))
-			return_ECMD_FAILED;
-		/*
-		 * Set metadata format of original VG.
-		 * NOTE: We must set the format before calling vg_lock_and_create()
-		 * since vg_lock_and_create() calls the per-format constructor.
-		 */
-		cmd->fmt = vg_from->fid->fmt;
-
-		if (!(vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg))) {
-			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-			return_ECMD_FAILED;
+	if (!(vginfo_to = lvmcache_vginfo_from_vgname(vg_name_to, NULL))) {
+		if (!validate_name(vg_name_to)) {
+			log_error("Invalid vg name %s.", vg_name_to);
+			return ECMD_FAILED;
 		}
-	} else {
-		if (!(vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg)))
-			return_ECMD_FAILED;
 
-		if (!(vg_from = _vgsplit_from(cmd, vg_name_from))) {
-			unlock_and_release_vg(cmd, vg_to, vg_name_to);
-			return_ECMD_FAILED;
+		if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE, NULL)) {
+			log_error("Failed to lock new VG name %s.", vg_name_to);
+			return ECMD_FAILED;
 		}
 
-		if (cmd->fmt != vg_from->fid->fmt) {
-			/* In this case we don't know the vg_from->fid->fmt */
-			log_error("Unable to set new VG metadata type based on "
-				  "source VG format - use -M option.");
-			goto bad;
+		if (!(vg_to = vg_create(cmd, vg_name_to))) {
+			log_error("Failed to create new VG %s.", vg_name_to);
+			unlock_vg(cmd, NULL, vg_name_to);
+			return ECMD_FAILED;
+		}
+	} else {
+		if (!(vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0))) {
+			log_error("Failed to read VG %s.", vg_name_to);
+			return ECMD_FAILED;
 		}
+		existing_vg = 1;
 	}
 
+	if (!(vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0, 0))) {
+		log_error("Failed to read VG %s.", vg_name_to);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		return ECMD_FAILED;
+	}
+
+	cmd->fmt = vg_from->fid->fmt;
+
 	if (existing_vg) {
 		if (_new_vg_option_specified(cmd)) {
-			log_error("Volume group \"%s\" exists, but new VG "
-				    "option specified", vg_name_to);
+			log_error("Volume group \"%s\" exists, but new VG option specified", vg_name_to);
 			goto bad;
 		}
-		if (!vgs_are_compatible(cmd, vg_from,vg_to))
+		if (!vgs_are_compatible(cmd, vg_from, vg_to))
 			goto_bad;
 	} else {
 		if (!vgcreate_params_set_defaults(cmd, &vp_def, vg_from)) {


