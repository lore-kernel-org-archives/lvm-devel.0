From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:14 -0400
Subject: master - lvmcache: simplify metadata cache
Message-ID: <201804231349.w3NDnEwb031607@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9a77e8bb4d25af33625d3cdddf5288207101d5b
Commit:        d9a77e8bb4d25af33625d3cdddf5288207101d5b
Parent:        79c4971210a6337563ffa2fca08fb636423d93d4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 1 09:35:40 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:45 2018 -0500

lvmcache: simplify metadata cache

The copy of VG metadata stored in lvmcache was not being used
in general.  It pretended to be a generic VG metadata cache,
but was not being used except for clvmd activation.  There
it was used to avoid reading from disk while devices were
suspended, i.e. in resume.

This removes the code that attempted to make this look
like a generic metadata cache, and replaces with with
something narrowly targetted to what it's actually used for.

This is a way of passing the VG from suspend to resume in
clvmd.  Since in the case of clvmd one caller can't simply
pass the same VG to both suspend and resume, suspend needs
to stash the VG somewhere that resume can grab it from.
(resume doesn't want to read it from disk since devices
are suspended.)  The lvmcache vginfo struct is used as a
convenient place to stash the VG to pass it from suspend
to resume, even though it isn't related to the lvmcache
or vginfo.  These suspended_vg* vginfo fields should
not be used or touched anywhere else, they are only to
be used for passing the VG data from suspend to resume
in clvmd.  The VG data being passed between suspend and
resume is never modified, and will only exist in the
brief period between suspend and resume in clvmd.

suspend has both old (current) and new (precommitted)
copies of the VG metadata.  It stashes both of these in
the vginfo prior to suspending devices.  When vg_commit
is successful, it sets a flag in vginfo as before,
signaling the transition from old to new metadata.

resume grabs the VG stashed by suspend.  If the vg_commit
happened, it grabs the new VG, and if the vg_commit didn't
happen it grabs the old VG.  The VG is then used to resume
LVs.

This isolates clvmd-specific code and usage from the
normal lvm vg_read code, making the code simpler and
the behavior easier to verify.

Sequence of operations:

- lv_suspend() has both vg_old and vg_new
  and stashes a copy of each onto the vginfo:
  lvmcache_save_suspended_vg(vg_old);
  lvmcache_save_suspended_vg(vg_new);

- vg_commit() happens, which causes all clvmd
  instances to call lvmcache_commit_metadata(vg).
  A flag is set in the vginfo indicating the
  transition from the old to new VG:
  vginfo->suspended_vg_committed = 1;

- lv_resume() needs either vg_old or vg_new
  to use in resuming LVs.  It doesn't want to
  read the VG from disk since devices are
  suspended, so it gets the VG stashed by
  lv_suspend:
  vg = lvmcache_get_suspended_vg(vgid);

If the vg_commit did not happen, suspended_vg_committed
will not be set, and in this case, lvmcache_get_suspended_vg()
will return the old VG instead of the new VG, and it will
resume LVs based on the old metadata.
---
 lib/activate/activate.c      |   82 ++++++++-
 lib/cache/lvmcache.c         |  405 +++++++++++++++++-------------------------
 lib/cache/lvmcache.h         |    7 +-
 lib/commands/toolcontext.c   |    4 -
 lib/config/config_settings.h |    7 +-
 lib/config/defaults.h        |    1 -
 lib/metadata/metadata.c      |   71 ++------
 lib/metadata/vg.c            |    5 -
 lib/misc/lvm-globals.c       |   12 --
 lib/misc/lvm-globals.h       |    2 -
 tools/commands.h             |    8 +-
 tools/lvmcmdline.c           |    1 -
 tools/tools.h                |    1 -
 13 files changed, 264 insertions(+), 342 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6611e99..565e643 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -28,6 +28,7 @@
 #include "config.h"
 #include "segtype.h"
 #include "sharedlib.h"
+#include "lvmcache.h"
 
 #include <limits.h>
 #include <fcntl.h>
@@ -2172,6 +2173,17 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
+	/*
+	 * Save old and new (current and precommitted) versions of the
+	 * VG metadata for lv_resume() to use, since lv_resume can't
+	 * read metadata given that devices are suspended.  lv_resume()
+	 * will resume LVs using the old/current metadata if the vg_commit
+	 * did happen (or failed), and it will resume LVs using the
+	 * new/precommitted metadata if the vg_commit succeeded.
+	 */
+	lvmcache_save_suspended_vg(lv->vg, 0);
+	lvmcache_save_suspended_vg(lv_pre->vg, 1);
+
 	if (!info.exists || info.suspended) {
 		if (!error_if_not_suspended) {
 			r = 1;
@@ -2378,16 +2390,55 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		      struct lv_activate_opts *laopts, int error_if_not_active,
 	              const struct logical_volume *lv)
 {
-	const struct logical_volume *lv_to_free = NULL;
 	struct dm_list *snh;
+	struct volume_group *vg = NULL;
+	struct logical_volume *lv_found = NULL;
+	const union lvid *lvid;
+	const char *vgid;
 	struct lvinfo info;
 	int r = 0;
 
 	if (!activation())
 		return 1;
 
-	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
-		goto_out;
+	/*
+	 * When called in clvmd, lvid_s is set and lv is not.  We need to
+	 * get the VG metadata without reading disks because devs are
+	 * suspended.  lv_suspend() saved old and new VG metadata for us
+	 * to use here.  If vg_commit() happened, lvmcache_get_suspended_vg
+	 * will return the new metadata for us to use in resuming LVs.
+	 * If vg_commit() did not happen, lvmcache_get_suspended_vg
+	 * returns the old metadata which we use to resume LVs.
+	 */
+	if (!lv && lvid_s) {
+		lvid = (const union lvid *) lvid_s;
+		vgid = (const char *)lvid->id[0].uuid;
+
+		if ((vg = lvmcache_get_suspended_vg(vgid))) {
+			log_debug_activation("Resuming LVID %s found saved vg seqno %d %s", lvid_s, vg->seqno, vg->name);
+			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
+				log_debug_activation("Resuming LVID %s found saved LV %s", lvid_s, display_lvname(lv_found));
+				lv = lv_found;
+			} else
+				log_debug_activation("Resuming LVID %s did not find saved LV", lvid_s);
+		} else
+			log_debug_activation("Resuming LVID %s did not find saved VG", lvid_s);
+
+		/*
+		 * resume must have been called without a preceding suspend,
+		 * so we need to read the vg.
+		 */
+
+		if (!lv) {
+			log_debug_activation("Resuming LVID %s reading VG", lvid_s);
+			if (!(lv_found = lv_from_lvid(cmd, lvid_s, 0))) {
+				log_debug_activation("Resuming LVID %s failed to read VG", lvid_s);
+				goto out;
+			}
+
+			lv = lv_found;
+		}
+	}
 
 	if (!lv_is_origin(lv) && !lv_is_thin_volume(lv) && !lv_is_thin_pool(lv))
 		laopts->origin_only = 0;
@@ -2448,9 +2499,6 @@ needs_resume:
 
 	r = 1;
 out:
-	if (lv_to_free)
-		release_vg(lv_to_free->vg);
-
 	return r;
 }
 
@@ -2587,6 +2635,10 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv, const struct logical_volume *lv)
 {
 	const struct logical_volume *lv_to_free = NULL;
+	struct volume_group *vg = NULL;
+	struct logical_volume *lv_found = NULL;
+	const union lvid *lvid;
+	const char *vgid;
 	int r = 0;
 
 	if (!activation()) {
@@ -2594,6 +2646,24 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 		return 1;
 	}
 
+	/*
+	 * This function is called while devices are suspended,
+	 * so try to use the copy of the vg that was saved in
+	 * lv_suspend.
+	 */
+	if (!lv && lvid_s) {
+		lvid = (const union lvid *) lvid_s;
+		vgid = (const char *)lvid->id[0].uuid;
+
+		if ((vg = lvmcache_get_suspended_vg(vgid))) {
+			log_debug_activation("activation_filter for %s found saved VG seqno %d %s", lvid_s, vg->seqno, vg->name);
+			if ((lv_found = find_lv_in_vg_by_lvid(vg, lvid))) {
+				log_debug_activation("activation_filter for %s found saved LV %s", lvid_s, display_lvname(lv_found));
+				lv = lv_found;
+			}
+		}
+	}
+
 	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8e119b5..28e46bb 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -63,16 +63,42 @@ struct lvmcache_vginfo {
 	char *lock_type;
 	uint32_t mda_checksum;
 	size_t mda_size;
-	size_t vgmetadata_size;
-	char *vgmetadata;	/* Copy of VG metadata as format_text string */
-	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
-				    /* Lifetime is directly tied to vgmetadata */
-	struct volume_group *cached_vg;
-	unsigned holders;
-	unsigned vg_use_count;	/* Counter of vg reusage */
-	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
-	unsigned cached_vg_invalidated;	/* Signal to regenerate cached_vg */
 	int independent_metadata_location; /* metadata read from independent areas */
+
+	/*
+	 * The following are not related to lvmcache or vginfo,
+	 * but are borrowing the vginfo to store the data.
+	 *
+	 * suspended_vg_* are used only by clvmd suspend/resume.
+	 * In suspend, both old (current) and new (precommitted)
+	 * metadata is saved.  (Each in three forms: buffer, cft,
+	 * and vg).  In resume, if the vg was committed
+	 * (suspended_vg_committed is set), then LVs are resumed
+	 * using the new metadata, but if the vg wasn't committed,
+	 * then LVs are resumed using the old metadata.
+	 *
+	 * suspended_vg_committed is set to 1 when clvmd gets
+	 * LCK_VG_COMMIT from vg_commit().
+	 *
+	 * These fields are only used between suspend and resume
+	 * in clvmd, and should never be used in any other way.
+	 * The contents of this data are never changed.  This
+	 * data does not really belong in lvmcache, it's unrelated
+	 * to lvmcache or vginfo, but it's just a convenient place
+	 * for clvmd to stash the VG between suspend and resume
+	 * (since the same caller isn't present to pass the VG to
+	 * both suspend and resume in the case of clvmd.)
+	 *
+	 * This data is not really a "cache" of the VG, it is just
+	 * a location to pass the VG between suspend and resume.
+	 */
+	int suspended_vg_committed;
+	char *suspended_vg_old_buf;
+	struct dm_config_tree *suspended_vg_old_cft;
+	struct volume_group *suspended_vg_old;
+	char *suspended_vg_new_buf;
+	struct dm_config_tree *suspended_vg_new_cft;
+	struct volume_group *suspended_vg_new;
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -139,73 +165,7 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 	_has_scanned = 1;
 }
 
-/* Volume Group metadata cache functions */
-static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
-{
-	if (!vginfo || !vginfo->vgmetadata)
-		return;
-
-	dm_free(vginfo->vgmetadata);
-
-	vginfo->vgmetadata = NULL;
-
-	/* Release also cached config tree */
-	if (vginfo->cft) {
-		dm_config_destroy(vginfo->cft);
-		vginfo->cft = NULL;
-	}
-
-	log_debug_cache("lvmcache: VG %s wiped.", vginfo->vgname);
-
-	release_vg(vginfo->cached_vg);
-}
-
-/*
- * Cache VG metadata against the vginfo with matching vgid.
- */
-static void _store_metadata(struct volume_group *vg, unsigned precommitted)
-{
-	char uuid[64] __attribute__((aligned(8)));
-	struct lvmcache_vginfo *vginfo;
-	char *data;
-	size_t size;
-
-	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id))) {
-		stack;
-		return;
-	}
-
-	if (!(size = export_vg_to_buffer(vg, &data))) {
-		stack;
-		_free_cached_vgmetadata(vginfo);
-		return;
-	}
-
-	/* Avoid reparsing of the same data string */
-	if (vginfo->vgmetadata && vginfo->vgmetadata_size == size &&
-	    strcmp(vginfo->vgmetadata, data) == 0)
-		dm_free(data);
-	else {
-		_free_cached_vgmetadata(vginfo);
-		vginfo->vgmetadata_size = size;
-		vginfo->vgmetadata = data;
-	}
-
-	vginfo->precommitted = precommitted;
-
-	if (!id_write_format((const struct id *)vginfo->vgid, uuid, sizeof(uuid))) {
-		stack;
-		return;
-	}
-
-	log_debug_cache("lvmcache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
-			vginfo->vgname, uuid, size,
-			precommitted ? ", precommitted" : "");
-}
-
-static void _update_cache_info_lock_state(struct lvmcache_info *info,
-					  int locked,
-					  int *cached_vgmetadata_valid)
+static void _update_cache_info_lock_state(struct lvmcache_info *info, int locked)
 {
 	int was_locked = (info->status & CACHE_LOCKED) ? 1 : 0;
 
@@ -213,10 +173,8 @@ static void _update_cache_info_lock_state(struct lvmcache_info *info,
 	 * Cache becomes invalid whenever lock state changes unless
 	 * exclusive VG_GLOBAL is held (i.e. while scanning).
 	 */
-	if (!lvmcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
+	if (!lvmcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked))
 		info->status |= CACHE_INVALID;
-		*cached_vgmetadata_valid = 0;
-	}
 
 	if (locked)
 		info->status |= CACHE_LOCKED;
@@ -228,14 +186,9 @@ static void _update_cache_vginfo_lock_state(struct lvmcache_vginfo *vginfo,
 					    int locked)
 {
 	struct lvmcache_info *info;
-	int cached_vgmetadata_valid = 1;
 
 	dm_list_iterate_items(info, &vginfo->infos)
-		_update_cache_info_lock_state(info, locked,
-					      &cached_vgmetadata_valid);
-
-	if (!cached_vgmetadata_valid)
-		_free_cached_vgmetadata(vginfo);
+		_update_cache_info_lock_state(info, locked);
 }
 
 static void _update_cache_lock_state(const char *vgname, int locked)
@@ -248,6 +201,35 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
+static void _suspended_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int free_new)
+{
+	if (free_old) {
+		if (vginfo->suspended_vg_old_buf)
+			dm_free(vginfo->suspended_vg_old_buf);
+		if (vginfo->suspended_vg_old_cft)
+			dm_config_destroy(vginfo->suspended_vg_old_cft);
+		if (vginfo->suspended_vg_old)
+			release_vg(vginfo->suspended_vg_old);
+
+		vginfo->suspended_vg_old_buf = NULL;
+		vginfo->suspended_vg_old_cft = NULL;
+		vginfo->suspended_vg_old = NULL;
+	}
+
+	if (free_new) {
+		if (vginfo->suspended_vg_new_buf)
+			dm_free(vginfo->suspended_vg_new_buf);
+		if (vginfo->suspended_vg_new_cft)
+			dm_config_destroy(vginfo->suspended_vg_new_cft);
+		if (vginfo->suspended_vg_new)
+			release_vg(vginfo->suspended_vg_new);
+
+		vginfo->suspended_vg_new_buf = NULL;
+		vginfo->suspended_vg_new_cft = NULL;
+		vginfo->suspended_vg_new = NULL;
+	}
+}
+
 static void _drop_metadata(const char *vgname, int drop_precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
@@ -256,25 +238,98 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
-	/*
-	 * Invalidate cached PV labels.
-	 * If cached precommitted metadata exists that means we
-	 * already invalidated the PV labels (before caching it)
-	 * and we must not do it again.
-	 */
-	if (!drop_precommitted && vginfo->precommitted && !vginfo->vgmetadata)
-		log_error(INTERNAL_ERROR "metadata commit (or revert) missing before "
-			  "dropping metadata from cache.");
-
-	if (drop_precommitted || !vginfo->precommitted)
+	if (drop_precommitted)
 		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
-	_free_cached_vgmetadata(vginfo);
-
-	/* VG revert */
 	if (drop_precommitted)
-		vginfo->precommitted = 0;
+		_suspended_vg_free(vginfo, 0, 1);
+	else
+		_suspended_vg_free(vginfo, 1, 1);
+}
+
+void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct format_instance *fid;
+	struct format_instance_ctx fic;
+	struct volume_group *susp_vg = NULL;
+	struct dm_config_tree *susp_cft = NULL;
+	char *susp_buf = NULL;
+	size_t size;
+	int new = precommitted;
+	int old = !precommitted;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id)))
+		goto_bad;
+
+	/* already saved */
+	if (old && vginfo->suspended_vg_old &&
+	    (vginfo->suspended_vg_old->seqno == vg->seqno))
+		return;
+
+	/* already saved */
+	if (new && vginfo->suspended_vg_new &&
+	    (vginfo->suspended_vg_new->seqno == vg->seqno))
+		return;
+
+	_suspended_vg_free(vginfo, old, new);
+
+	if (!(size = export_vg_to_buffer(vg, &susp_buf)))
+		goto_bad;
+
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vginfo->vgname;
+	fic.context.vg_ref.vg_id = vginfo->vgid;
+	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
+		goto_bad;
+
+	if (!(susp_cft = config_tree_from_string_without_dup_node_check(susp_buf)))
+		goto_bad;
+
+	if (!(susp_vg = import_vg_from_config_tree(susp_cft, fid)))
+		goto_bad;
+
+	if (old) {
+		vginfo->suspended_vg_old_buf = susp_buf;
+		vginfo->suspended_vg_old_cft = susp_cft;
+		vginfo->suspended_vg_old = susp_vg;
+		log_debug_cache("lvmcache saved suspended vg old seqno %d %s", vg->seqno, vg->name);
+	} else {
+		vginfo->suspended_vg_new_buf = susp_buf;
+		vginfo->suspended_vg_new_cft = susp_cft;
+		vginfo->suspended_vg_new = susp_vg;
+		log_debug_cache("lvmcache saved suspended vg new seqno %d %s", vg->seqno, vg->name);
+	}
+	return;
+
+bad:
+	_suspended_vg_free(vginfo, old, new);
+	log_debug_cache("lvmcache failed to save suspended pre %d vg %s", precommitted, vg->name);
+}
+
+struct volume_group *lvmcache_get_suspended_vg(const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
+		return_NULL;
+
+
+	if (vginfo->suspended_vg_committed)
+		return vginfo->suspended_vg_new;
+	else
+		return vginfo->suspended_vg_old;
+}
+
+void lvmcache_drop_suspended_vg(struct volume_group *vg)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id)))
+		return;
+
+	_suspended_vg_free(vginfo, 1, 1);
 }
 
 /*
@@ -289,11 +344,7 @@ void lvmcache_commit_metadata(const char *vgname)
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
-	if (vginfo->precommitted) {
-		log_debug_cache("lvmcache: Upgraded pre-committed VG %s metadata to committed.",
-				vginfo->vgname);
-		vginfo->precommitted = 0;
-	}
+	vginfo->suspended_vg_committed = 1;
 }
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
@@ -674,18 +725,6 @@ static int _info_is_valid(struct lvmcache_info *info)
 	return 1;
 }
 
-static int _vginfo_is_valid(struct lvmcache_vginfo *vginfo)
-{
-	struct lvmcache_info *info;
-
-	/* Invalid if any info is invalid */
-	dm_list_iterate_items(info, &vginfo->infos)
-		if (!_info_is_valid(info))
-			return 0;
-
-	return 1;
-}
-
 /* vginfo is invalid if it does not contain at least one valid info */
 static int _vginfo_is_invalid(struct lvmcache_vginfo *vginfo)
 {
@@ -1315,121 +1354,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	return r;
 }
 
-struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname,
-				     const char *vgid, unsigned precommitted)
-{
-	struct lvmcache_vginfo *vginfo;
-	struct volume_group *vg = NULL;
-	struct format_instance *fid;
-	struct format_instance_ctx fic;
-
-	/*
-	 * We currently do not store precommitted metadata in lvmetad at
-	 * all. This means that any request for precommitted metadata is served
-	 * using the classic scanning mechanics, and read from disk or from
-	 * lvmcache.
-	 */
-	if (lvmetad_used() && !precommitted) {
-		/* Still serve the locally cached VG if available */
-		if (vgid && (vginfo = lvmcache_vginfo_from_vgid(vgid)) &&
-		    vginfo->vgmetadata && (vg = vginfo->cached_vg))
-			goto out;
-		return lvmetad_vg_lookup(cmd, vgname, vgid);
-	}
-
-	if (!vgid || !(vginfo = lvmcache_vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
-		return NULL;
-
-	if (!_vginfo_is_valid(vginfo))
-		return NULL;
-
-	/*
-	 * Don't return cached data if either:
-	 * (i)  precommitted metadata is requested but we don't have it cached
-	 *      - caller should read it off disk;
-	 * (ii) live metadata is requested but we have precommitted metadata cached
-	 *      and no devices are suspended so caller may read it off disk.
-	 *
-	 * If live metadata is requested but we have precommitted metadata cached
-	 * and devices are suspended, we assume this precommitted metadata has
-	 * already been preloaded and committed so it's OK to return it as live.
-	 * Note that we do not clear the PRECOMMITTED flag.
-	 */
-	if ((precommitted && !vginfo->precommitted) ||
-	    (!precommitted && vginfo->precommitted && !critical_section()))
-		return NULL;
-
-	/* Use already-cached VG struct when available */
-	if ((vg = vginfo->cached_vg) && !vginfo->cached_vg_invalidated)
-		goto out;
-
-	release_vg(vginfo->cached_vg);
-
-	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = vginfo->vgname;
-	fic.context.vg_ref.vg_id = vgid;
-	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
-		return_NULL;
-
-	/* Build config tree from vgmetadata, if not yet cached */
-	if (!vginfo->cft &&
-	    !(vginfo->cft =
-	      config_tree_from_string_without_dup_node_check(vginfo->vgmetadata)))
-		goto_bad;
-
-	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
-		goto_bad;
-
-	/* Cache VG struct for reuse */
-	vginfo->cached_vg = vg;
-	vginfo->holders = 1;
-	vginfo->vg_use_count = 0;
-	vginfo->cached_vg_invalidated = 0;
-	vg->vginfo = vginfo;
-
-	if (!dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
-		goto_bad;
-
-out:
-	vginfo->holders++;
-	vginfo->vg_use_count++;
-	log_debug_cache("Using cached %smetadata for VG %s with %u holder(s).",
-			vginfo->precommitted ? "pre-committed " : "",
-			vginfo->vgname, vginfo->holders);
-
-	return vg;
-
-bad:
-	_free_cached_vgmetadata(vginfo);
-	return NULL;
-}
-
-// #if 0
-int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
-{
-	log_debug_cache("VG %s decrementing %d holder(s) at %p.",
-			vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
-
-	if (--vginfo->holders)
-		return 0;
-
-	if (vginfo->vg_use_count > 1)
-		log_debug_cache("VG %s reused %d times.",
-				vginfo->cached_vg->name, vginfo->vg_use_count);
-
-	/* Debug perform crc check only when it's been used more then once */
-	if (!dm_pool_unlock(vginfo->cached_vg->vgmem,
-			    detect_internal_vg_cache_corruption() &&
-			    (vginfo->vg_use_count > 1)))
-		stack;
-
-	vginfo->cached_vg->vginfo = NULL;
-	vginfo->cached_vg = NULL;
-
-	return 1;
-}
-// #endif
-
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 			   struct dm_list *vgnameids)
 {
@@ -1615,8 +1539,6 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
 	int r = 1;
 
-	_free_cached_vgmetadata(vginfo);
-
 	vginfo2 = primary_vginfo = lvmcache_vginfo_from_vgname(vginfo->vgname, NULL);
 
 	if (vginfo == primary_vginfo) {
@@ -1639,6 +1561,7 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 	dm_free(vginfo->system_id);
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
+	_suspended_vg_free(vginfo, 1, 1);
 
 	if (*vginfo->vgid && _vgid_hash &&
 	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
@@ -2076,12 +1999,6 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
-	/* If making a PV into an orphan, any cached VG metadata may become
-	 * invalid, incorrectly still referencing device structs.
-	 * (Example: pvcreate -ff) */
-	if (is_orphan_vg(vgname) && info->vginfo && !is_orphan_vg(info->vginfo->vgname))
-		info->vginfo->cached_vg_invalidated = 1;
-
 	/* If moving PV from orphan to real VG, always mark it valid */
 	if (!is_orphan_vg(vgname))
 		info->status &= ~CACHE_INVALID;
@@ -2117,10 +2034,6 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 			return_0;
 	}
 
-	/* store text representation of vg to cache */
-	if (vg->cmd->current_settings.cache_vgmetadata)
-		_store_metadata(vg, precommitted);
-
 	return 1;
 }
 
@@ -2657,6 +2570,10 @@ struct label *lvmcache_get_label(struct lvmcache_info *info) {
 	return info->label;
 }
 
+/*
+ * After label_scan reads pv_header, mda_header and mda locations
+ * from a PV, it clears the INVALID flag.
+ */
 void lvmcache_make_valid(struct lvmcache_info *info) {
 	info->status &= ~CACHE_INVALID;
 }
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 1b5379c..1856344 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -133,9 +133,6 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
 
-/* Returns cached volume group metadata. */
-struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname,
-				     const char *vgid, unsigned precommitted);
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
@@ -219,4 +216,8 @@ int lvmcache_get_vg_devs(struct cmd_context *cmd,
 			 struct dm_list *devs);
 void lvmcache_set_independent_location(const char *vgname);
 
+void lvmcache_save_suspended_vg(struct volume_group *vg, int precommitted);
+struct volume_group *lvmcache_get_suspended_vg(const char *vgid);
+void lvmcache_drop_suspended_vg(struct volume_group *vg);
+
 #endif
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index fe6b8a3..3dc3e2d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -688,9 +688,6 @@ static int _process_config(struct cmd_context *cmd)
 	if (find_config_tree_bool(cmd, report_two_word_unknown_device_CFG, NULL))
 		init_unknown_device_name("unknown device");
 
-	init_detect_internal_vg_cache_corruption
-		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
-
 	if (!_init_system_id(cmd))
 		return_0;
 
@@ -2010,7 +2007,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (set_filters && !init_filters(cmd, 1))
 		goto_out;
 
-	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
 	cmd->initialized.config = 1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 077fb15..b778f4c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -868,11 +868,8 @@ cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_
 	"Treat any internal errors as fatal errors, aborting the process that\n"
 	"encountered the internal error. Please only enable for debugging.\n")
 
-cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION, vsn(2, 2, 96), NULL, 0, NULL,
-	"Internal verification of VG structures.\n"
-	"Check if CRC matches when a parsed VG is used multiple times. This\n"
-	"is useful to catch unexpected changes to cached VG structures.\n"
-	"Please only enable for debugging.\n")
+cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 96), NULL, vsn(2, 2, 174), NULL,
+	"No longer used.\n")
 
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
 	"No operations that change on-disk metadata are permitted.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d9e19d9..7cebd84 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -179,7 +179,6 @@
 #define DEFAULT_LOGLEVEL 0
 #define DEFAULT_INDENT 1
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
-#define DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION 0
 #define DEFAULT_UNITS "r"
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 570cbe6..5d3f835 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3767,7 +3767,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
 
-	unsigned seqno = 0;
 	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
@@ -3788,7 +3787,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	if (lvmetad_used() && !use_precommitted) {
-		if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted))) {
+		if ((correct_vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
 			dm_list_iterate_items(pvl, &correct_vg->pvs)
 				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
 			if (reappeared && *consistent)
@@ -3819,23 +3818,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/*
-	 * If cached metadata was inconsistent and *consistent is set
-	 * then repair it now.  Otherwise just return it.
-	 * Also return if use_precommitted is set due to the FIXME in
-	 * the missing PV logic below.
-	 */
-	if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted)) &&
-	    (use_precommitted || !*consistent)) {
-		*consistent = 1;
-		return correct_vg;
-	} else {
-		if (correct_vg && correct_vg->seqno > seqno)
-			seqno = correct_vg->seqno;
-		release_vg(correct_vg);
-		correct_vg = NULL;
-	}
-
-	/*
 	 * Rescan the devices that are associated with this vg in lvmcache.
 	 * This repeats what was done by the command's initial label scan,
 	 * but only the devices associated with this VG.
@@ -4521,21 +4503,10 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    unsigned precommitted)
 {
 	const char *vgname;
-	struct dm_list *vgnames;
 	struct volume_group *vg;
-	struct dm_str_list *strl;
 	uint32_t warn_flags = WARN_PV_READ | WARN_INCONSISTENT;
 	int consistent = 0;
 
-	/* Is corresponding vgname already cached? */
-	if (lvmcache_vgid_is_cached(vgid)) {
-		if ((vg = _vg_read(cmd, NULL, vgid, warn_flags, &consistent, precommitted)) &&
-		    id_equal(&vg->id, (const struct id *)vgid)) {
-			return vg;
-		}
-		release_vg(vg);
-	}
-
 	/*
 	 * When using lvmlockd we should never reach this point.
 	 * The VG is locked, then vg_read() is done, which gets
@@ -4548,36 +4519,28 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
 	if (critical_section())
-		return_NULL;
+		log_debug_metadata("Reading VG by vgid in critical section pre %d vgid %.8s", precommitted, vgid);
 
-	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
-	/* FIXME Disabled vgrenames while active for now because we aren't
-	 *       allowed to do a full scan here any more. */
+	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+		log_debug_metadata("Reading VG by vgid %.8s no VG name found, retrying.", vgid);
+		lvmcache_destroy(cmd, 0, 0);
+		lvmcache_force_next_label_scan();
+		lvmcache_label_scan(cmd);
+	}
 
-	// The slow way - full scan required to cope with vgrename
-	lvmcache_force_next_label_scan();
-	lvmcache_label_scan(cmd);
-	if (!(vgnames = get_vgnames(cmd, 0))) {
-		log_error("vg_read_by_vgid: get_vgnames failed");
+	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
+		log_debug_metadata("Reading VG by vgid %.8s no VG name found.", vgid);
 		return NULL;
 	}
 
-	dm_list_iterate_items(strl, vgnames) {
-		vgname = strl->str;
-		if (!vgname)
-			continue;	// FIXME Unnecessary?
-		consistent = 0;
-		if ((vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted)) &&
-		    id_equal(&vg->id, (const struct id *)vgid)) {
-			if (!consistent) {
-				release_vg(vg);
-				return NULL;
-			}
-			return vg;
-		}
-		release_vg(vg);
+	consistent = 0;
+
+	if ((vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted))) {
+		/* Does it matter if consistent is 0 or 1? */
+		return vg;
 	}
 
+	log_debug_metadata("Reading VG by vgid %.8s not found.", vgid);
 	return NULL;
 }
 
@@ -4593,7 +4556,7 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 
 	log_very_verbose("Finding %svolume group for uuid %s", precommitted ? "precommitted " : "", lvid_s);
 	if (!(vg = _vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
-		log_error("Volume group for uuid not found: %s", lvid_s);
+		log_error("Reading VG not found for LVID %s", lvid_s);
 		return NULL;
 	}
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 4c808da..0b69e42 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -97,11 +97,6 @@ void release_vg(struct volume_group *vg)
 	if (!vg || (vg->fid && vg == vg->fid->fmt->orphan_vg))
 		return;
 
-	/* Check if there are any vginfo holders */
-	if (vg->vginfo &&
-	    !lvmcache_vginfo_holders_dec_and_test_for_zero(vg->vginfo))
-		return;
-
 	release_vg(vg->vg_committed);
 	release_vg(vg->vg_precommitted);
 	_free_vg(vg);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 0575d21..0f384bb 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -53,8 +53,6 @@ static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
-static int _detect_internal_vg_cache_corruption =
-	DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION;
 static const char *_unknown_device_name = DEFAULT_UNKNOWN_DEVICE_NAME;
 
 void init_verbose(int level)
@@ -197,11 +195,6 @@ void init_pv_min_size(uint64_t sectors)
 	_pv_min_size = sectors;
 }
 
-void init_detect_internal_vg_cache_corruption(int detect)
-{
-	_detect_internal_vg_cache_corruption = detect;
-}
-
 void set_cmd_name(const char *cmd)
 {
 	(void) dm_strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -384,11 +377,6 @@ uint64_t pv_min_size(void)
 	return _pv_min_size;
 }
 
-int detect_internal_vg_cache_corruption(void)
-{
-	return _detect_internal_vg_cache_corruption;
-}
-
 const char *unknown_device_name(void)
 {
 	return _unknown_device_name;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 14a7d43..e23d598 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -51,7 +51,6 @@ void init_udev_checking(int checking);
 void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
-void init_detect_internal_vg_cache_corruption(int detect);
 void init_retry_deactivation(int retry);
 void init_unknown_device_name(const char *name);
 
@@ -85,7 +84,6 @@ int udev_checking(void);
 const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
-int detect_internal_vg_cache_corruption(void);
 int retry_deactivation(void);
 const char *unknown_device_name(void);
 
diff --git a/tools/commands.h b/tools/commands.h
index d65330a..cbd527b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -43,7 +43,7 @@ xx(lastlog,
 
 xx(lvchange,
    "Change the attributes of logical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY)
+   PERMITTED_READ_ONLY)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -127,7 +127,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -145,7 +145,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
 
 xx(pvscan,
    "List all physical volumes",
@@ -173,7 +173,7 @@ xx(vgcfgrestore,
 
 xx(vgchange,
    "Change volume group attributes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 26510bc..fc96b8d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2281,7 +2281,6 @@ static int _get_current_settings(struct cmd_context *cmd)
 
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
-	cmd->current_settings.cache_vgmetadata = cmd->cname->flags & CACHE_VGMETADATA ? 1 : 0;
 
 	if (arg_is_set(cmd, readonly_ARG)) {
 		cmd->current_settings.activation = 0;
diff --git a/tools/tools.h b/tools/tools.h
index 33cbf10..0886551 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -113,7 +113,6 @@ struct arg_value_group_list {
 	uint32_t prio;
 };
 
-#define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
 /* Process all VGs if none specified on the command line. */
 #define ALL_VGS_IS_DEFAULT	0x00000004


