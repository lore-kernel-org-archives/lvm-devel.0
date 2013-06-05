From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:24 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Remove VG metadata caches (text, cfg, volume_group) for now.
Message-ID: <20130605120624.7AECC60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c9eddbab5ceeee00a4ae393ac33099dd2a31b6b
Commit:        0c9eddbab5ceeee00a4ae393ac33099dd2a31b6b
Parent:        a2d9a818cfc469f928239cef7498c87b4afc43ae
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 4 20:06:41 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:37 2013 +0200

lvmcache: Remove VG metadata caches (text, cfg, volume_group) for now.

---
 lib/cache/lvmcache.c |  156 +-------------------------------------------------
 1 files changed, 1 insertions(+), 155 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8d50919..f8c8a9e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -55,12 +55,7 @@ struct lvmcache_vginfo {
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
 	size_t vgmetadata_size;
-	char *vgmetadata;	/* Copy of VG metadata as format_text string */
-	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
-				    /* Lifetime is directly tied to vgmetadata */
-	struct volume_group *cached_vg;
 	unsigned holders;
-	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -111,27 +106,6 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
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
-	log_debug_cache("Metadata cache: VG %s wiped.", vginfo->vgname);
-
-	release_vg(vginfo->cached_vg);
-}
-
 /*
  * Cache VG metadata against the vginfo with matching vgid.
  */
@@ -139,40 +113,18 @@ static void _store_metadata(struct volume_group *vg, unsigned precommitted)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
-	char *data;
-	size_t size;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id))) {
 		stack;
 		return;
 	}
 
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
 	vginfo->precommitted = precommitted;
 
 	if (!id_write_format((const struct id *)vginfo->vgid, uuid, sizeof(uuid))) {
 		stack;
 		return;
 	}
-
-	log_debug_cache("Metadata cache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
-			vginfo->vgname, uuid, size,
-			precommitted ? ", precommitted" : "");
 }
 
 static void _update_cache_info_lock_state(struct lvmcache_info *info,
@@ -205,9 +157,6 @@ static void _update_cache_vginfo_lock_state(struct lvmcache_vginfo *vginfo,
 	dm_list_iterate_items(info, &vginfo->infos)
 		_update_cache_info_lock_state(info, locked,
 					      &cached_vgmetadata_valid);
-
-	if (!cached_vgmetadata_valid)
-		_free_cached_vgmetadata(vginfo);
 }
 
 void lvmcache_update_lock_state(const char *vgname, int locked)
@@ -234,16 +183,11 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 	 * already invalidated the PV labels (before caching it)
 	 * and we must not do it again.
 	 */
-	if (!drop_precommitted && vginfo->precommitted && !vginfo->vgmetadata)
-		log_error(INTERNAL_ERROR "metadata commit (or revert) missing before "
-			  "dropping metadata from cache.");
 
 	if (drop_precommitted || !vginfo->precommitted)
 		dm_list_iterate_items(info, &vginfo->infos)
 			info->status |= CACHE_INVALID;
 
-	_free_cached_vgmetadata(vginfo);
-
 	/* VG revert */
 	if (drop_precommitted)
 		vginfo->precommitted = 0;
@@ -603,114 +547,18 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname,
 				     const char *vgid, unsigned precommitted)
 {
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
-	if (lvmetad_active() && !precommitted) {
-		/* Still serve the locally cached VG if available */
-		if (vgid && (vginfo = lvmcache_vginfo_from_vgid(vgid)) &&
-		    vginfo->vgmetadata && (vg = vginfo->cached_vg))
-			goto out;
+	if (lvmetad_active() && !precommitted)
 		return lvmetad_vg_lookup(cmd, vgname, vgid);
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
-	if ((vg = vginfo->cached_vg))
-		goto out;
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
-	      dm_config_from_string(vginfo->vgmetadata)))
-		goto_bad;
-
-	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
-		goto_bad;
-
-	/* Cache VG struct for reuse */
-	vginfo->cached_vg = vg;
-	vginfo->holders = 1;
-	vginfo->vg_use_count = 0;
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
 	return NULL;
 }
 
-// #if 0
 int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
 {
-	log_debug_cache("VG %s decrementing %d holder(s) at %p.",
-			vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
-
 	if (--vginfo->holders)
 		return 0;
 
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
 	return 1;
 }
-// #endif
 
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
@@ -873,8 +721,6 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
 	int r = 1;
 
-	_free_cached_vgmetadata(vginfo);
-
 	vginfo2 = primary_vginfo = lvmcache_vginfo_from_vgname(vginfo->vgname, NULL);
 
 	if (vginfo == primary_vginfo) {


