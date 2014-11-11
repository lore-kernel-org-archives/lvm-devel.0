From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 11 Nov 2014 14:18:42 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20141111141842.E7F3660DA5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a5910bdf9a8d79051181f110a43a7c1ef2288d6
Commit:        9a5910bdf9a8d79051181f110a43a7c1ef2288d6
Parent:        9704515c1e22ff0ebaec16572d1c51d954259da5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 11 14:13:00 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 11 14:13:00 2014 +0000

pre-release

---
 VERSION                     |    2 +-
 VERSION_DM                  |    2 +-
 WHATS_NEW                   |   21 +++++++++++++--------
 WHATS_NEW_DM                |    8 ++++----
 daemons/cmirrord/compat.c   |    1 -
 lib/cache_segtype/cache.c   |    2 +-
 lib/format_text/flags.c     |    2 +-
 lib/locking/locking_types.h |    4 ++--
 lib/metadata/cache_manip.c  |    2 +-
 lib/metadata/lv.c           |    2 +-
 lib/metadata/lv_manip.c     |   26 +++++++++++++-------------
 lib/metadata/metadata.c     |    4 ++--
 lib/metadata/vg.c           |    4 +---
 libdm/libdevmapper.h        |    4 ++--
 libdm/libdm-report.c        |    2 +-
 tools/lvcreate.c            |    8 ++++----
 16 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/VERSION b/VERSION
index 061e5da..a533a72 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.112(2)-git (2014-09-01)
+2.02.112(2)-git (2014-11-11)
diff --git a/VERSION_DM b/VERSION_DM
index d021c49..a5eac8b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.91-git (2014-09-01)
+1.02.91-git (2014-11-11)
diff --git a/WHATS_NEW b/WHATS_NEW
index a4f5c97..820106b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,9 @@
-Version 2.02.112 - 
+Version 2.02.112 - 11th November 2014
 =====================================
   Add cache_{read,write}_{hits,misses} reporting fields.
   Add cache_{total,used,dirty}_blocks reporting fields.
   Add _corig as reserved suffix.
-  Reduce vg write and vg commits when creating spare volumes.
+  Reduce number of VG writes and commits when creating spare volumes.
   When remove_layer_from_lv() removes layer, restore subLV names.
   Cache-pool in use becomes invisible LV.
   Don't prompt for removal of _pmspare in VG without pool metadata LV.
@@ -15,7 +15,8 @@ Version 2.02.112 -
   Report some basic percentage info for cache pools.
   Introduce size_mb_arg_with_percent() for advanced size arg reading.
   Add extra support for '.' as decimal point in size args.
-  Configurable support for creation of sparse volumes with thin-pools.
+  Add configure parameters for default segment type choices.
+  Add global/sparse_segtype_default setting to use thin for --type sparse.
   Update and correct lvcreate and lvcovert man pages.
   Mark pools and snapshots as unzeroable volumes.
   Check for zeroing of volume after segment type is fully detected.
@@ -28,13 +29,14 @@ Version 2.02.112 -
   Query lock holding LV when replacing and converting raid volumes.
   Add extra validate for locked lv within validate_lv_cache_create().
   Add internal lvseg_name() function.
-  Skip trying to file lock virtual internal vg name.
+  Skip use of lock files for virtual internal VG names.
   Fix selection on {vg,lv}_permissions fields to properly match selection criteria.
   Fix lv_permissions reporting to display read-only{-override} instead of blank.
   Fix liblvm2cmd and lvm shell to respect quotes around args in cmd line string.
   Permit extent sizes > 128KB that are not power of 2 with lvm2 format.
   Remove workaround for lvm2-monitor.service hang on stop if lvmetad stopped.
   Change vgremove to use process_each_lv_in_vg.
+  Allow lvconvert --repair and --splitmirrors on internal LVs.
   Introduce WARN_ flags to control some metadata warning messages.
   Use process_each_pv in vgreduce.
   Refactor process_each_pv in toollib.
@@ -47,11 +49,12 @@ Version 2.02.112 -
   Improve code for creation of cache and cache pool volumes.
   Check cluster-wide (not local) active status before removing LV.
   Properly check if activation of removed cached LV really activated.
-  Lvremoving cached LV removes cachepool (keep with lvconvert --splitcache).
+  lvremove cached LV removes cachepool (keep with lvconvert --splitcache).
   Always remove spare LV with last removed pool volume.
   Support lvconvert --splitcache and --uncache of cached LV.
   Option --cache has also shortcut -H (i.e. lvcreate -H).
   Refactor lvcreate code and better preserve --type argument.
+  Refactor filter processing around lvmetad.
   Refactor process_each_lv in toollib.
   Refactor process_each_vg in toollib.
   Pools cannot be used as external origin.
@@ -64,6 +67,7 @@ Version 2.02.112 -
   Unify handling of --persistent option for lvcreate and lvchange.
   Validate major and minor numbers stored in metadata.
   Use -fPIE when linking -pie executables.
+  Support DEBUG_MEMLOCK to trap unsupported mmap usage.
   Enable cache segment type by default.
   Ensure only supported volume types are used with cache segments.
   Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.
@@ -75,8 +79,6 @@ Version 2.02.112 -
   Fix cmirror endian conversions.
   Introduce lv_is_pvmove/locked/converting/merging macros.
   Avoid leaving linear logical volume when thin pool creation fails.
-  Demote an error to a warning when devices known to lvmetad are filtered out.
-  Re-order filter evaluation, making component filters global.
   Don't leak alloc_handle on raid target error path.
   Properly validate raid leg names.
   Archive metadata before starting their modification in raid target.
@@ -84,7 +86,10 @@ Version 2.02.112 -
   Add missing backup of lvm2 metadata after some raid modifications.
   Use vg memory pool for extent allocation.
   Add allocation/physical_extent_size config option for default PE size of VGs.
-  Introduce common code to modify metadate and reload updated LV.
+  Demote an error to a warning when devices known to lvmetad are filtered out.
+  Re-order filter evaluation, making component filters global.
+  Fix logic that checks for full scan before iterating through devices.
+  Introduce common code to modify metadata and reload updated LV.
   Fix rename of active snapshot volume in cluster.
   Make sure shared libraries are built with RELRO option.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f4148bc..97eb339 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,10 +1,10 @@
-Version 1.02.91 - 
+Version 1.02.91 - 11th November 2014
 ====================================
-  Update API for cache creation and dm_config_node to pass policy.
-  Allow activation of any thin-pool with passed transaction_id == 0.
+  Update cache creation and dm_config_node to pass policy.
+  Allow activation of any thin-pool if transaction_id supplied is 0.
   Don't print uninitialized stack bytes when non-root uses dm_check_version().
   Fix selection criteria to not match reserved values when using >, <, >=, <.
-  Add DM_LIST_HEAD_INIT macro to libdevmapper.h
+  Add DM_LIST_HEAD_INIT macro to libdevmapper.h.
   Fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
 
 Version 1.02.90 - 1st September 2014
diff --git a/daemons/cmirrord/compat.c b/daemons/cmirrord/compat.c
index 4955f50..a9696d7 100644
--- a/daemons/cmirrord/compat.c
+++ b/daemons/cmirrord/compat.c
@@ -183,7 +183,6 @@ int clog_request_from_network(void *data, size_t data_len)
 {
 	uint64_t *vp = data;
 	uint64_t version = xlate64(vp[0]);
-	uint64_t unconverted_version = vp[1];
 	struct clog_request *rq = data;
 
 	switch (version) {
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index b42a529..02ac198 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -78,7 +78,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
 	} else
 		/* Cannot use 'just' default, so pick one */
-		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* TODO: configurable default */
+		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* FIXME make configurable */
 
 	/*
 	 * Read in policy args:
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 21555d6..e3a00a6 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -88,7 +88,7 @@ static const struct flag _lv_flags[] = {
 	{CACHE_POOL, NULL, 0},
 	{CACHE_POOL_DATA, NULL, 0},
 	{CACHE_POOL_METADATA, NULL, 0},
-	{LV_PENDING_DELETE, NULL, 0}, /* TODO: print as COMPATIBLE_FLAG */
+	{LV_PENDING_DELETE, NULL, 0}, /* FIXME Display like COMPATIBLE_FLAG */
 	{0, NULL, 0}
 };
 
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 8280e4f..64d13db 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -23,8 +23,8 @@ typedef int (*query_resource_fn) (const char *resource, int *mode);
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
 
-#define LCK_PRE_MEMLOCK	0x00000001	/* Is memlock() needed before calls? */
-#define LCK_CLUSTERED	0x00000002
+#define LCK_PRE_MEMLOCK			0x00000001	/* Is memlock() needed before calls? */
+#define LCK_CLUSTERED			0x00000002
 #define LCK_SUPPORTS_REMOTE_QUERIES	0x00000004
 
 struct locking_type {
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 9c69970..d7813c3 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -27,7 +27,7 @@
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
 #define DM_BYTES_PER_BLOCK		16 /* bytes */
 #define DM_HINT_OVERHEAD_PER_BLOCK	8  /* bytes */
-#define DM_MAX_HINT_WIDTH		(4+16)  /* bytes,  TODO: configurable ?? */
+#define DM_MAX_HINT_WIDTH		(4+16)  /* bytes.  FIXME Configurable? */
 
 const char *get_cache_pool_cachemode_name(const struct lv_segment *seg)
 {
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 85076fa..bf2d04e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -863,7 +863,7 @@ static int _lv_is_exclusive(struct logical_volume *lv)
 	struct lv_segment *seg;
 
 	/* Some seg types require exclusive activation */
-	/* TODO: deep-scan of every segtype in use */
+	/* FIXME Scan recursively */
 	dm_list_iterate_items(seg, &lv->segments)
 		if (seg_only_exclusive(seg))
 			return 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a6ab3d3..543f070 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6768,11 +6768,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 		/* Create cache origin for cache pool */
-		/* TODO: eventually support raid/mirrors with -m */
+		/* FIXME Eventually support raid/mirrors with -m */
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
 	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
-		/* FIXME: this will not pass cluster lock! */
+		/* FIXME This will not pass cluster lock! */
 		init_mirror_in_sync(lp->nosync);
 
 		if (lp->nosync) {
@@ -6809,11 +6809,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					return_NULL;
 				if (origin_lv->status & LVM_WRITE) {
 					log_error("Cannot use writable LV as the external origin.");
-					return NULL; // TODO conversion for inactive
+					return NULL; /* FIXME conversion for inactive */
 				}
 				if (lv_is_active(origin_lv) && !lv_is_external_origin(origin_lv)) {
 					log_error("Cannot use active LV for the external origin.");
-					return NULL; // We can't be sure device is read-only
+					return NULL; /* We can't be sure device is read-only */
 				}
 			}
 		}
@@ -7029,7 +7029,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lv->status |= LV_TEMPORARY;
 
 	if (seg_is_cache(lp)) {
-		/* TODO: support remote exclusive activation? */
+		/* FIXME Support remote exclusive activation? */
 		/* Not yet 'cache' LV, it is stripe volume for wiping */
 		if (is_change_activating(lp->activate) &&
 		    !activate_lv_excl_local(cmd, lv)) {
@@ -7132,7 +7132,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (origin_lv) {
 			/* Convert origin to cached LV */
 			if (!(tmp_lv = lv_cache_create(lv, origin_lv))) {
-				/* TODO: do a better revert */
+				/* FIXME Do a better revert */
 				log_error("Aborting. Leaving cache pool %s and uncached origin volume %s.",
 					  display_lvname(lv), display_lvname(origin_lv));
 				return NULL;
@@ -7146,7 +7146,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		lv = tmp_lv;
 		if (!lv_update_and_reload(lv)) {
-			/* TODO: do a better revert */
+			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
 			return NULL; /* FIXME: revert */
 		}
@@ -7186,13 +7186,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 			backup(vg);
 			/*
-			 * TODO:
-			 *   We do not actually need snapshot-origin as an active device,
-			 *   as virtual origin is already 'hidden' private device without
-			 *   vg/lv links. As such it is not supposed to be used by any user.
-			 *   Also it would save one dm table entry, but it needs quite a few
-			 *   changes in the libdm/lvm2 code base to support it.
+			 * FIXME We do not actually need snapshot-origin as an active device,
+			 * as virtual origin is already 'hidden' private device without
+			 * vg/lv links. As such it is not supposed to be used by any user.
+			 * Also it would save one dm table entry, but it needs quite a few
+			 * changes in the libdm/lvm2 code base to support it.
 			 */
+
 			/* Activate spare snapshot once it is a complete LV */
 			if (!lv_active_change(cmd, origin_lv, lp->activate, 1)) {
 				log_error("Failed to activate sparce volume %s.",
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index df2d6a3..11dabcc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2547,12 +2547,12 @@ int vg_validate(struct volume_group *vg)
 
 		if (lv_is_pool_metadata_spare(lvl->lv)) {
 			if (++spare_count > 1) {
-				log_error(INTERNAL_ERROR "LV %s is %u. pool metadata spare (>1).",
+				log_error(INTERNAL_ERROR "LV %s is extra pool metadata spare volume. %u found but only 1 allowed.",
 					  lvl->lv->name, spare_count);
 				r = 0;
 			}
 			if (vg->pool_metadata_spare_lv != lvl->lv) {
-				log_error(INTERNAL_ERROR "LV %s is not vg pool metadata spare.",
+				log_error(INTERNAL_ERROR "LV %s is not the VG's pool metadata spare volume.",
 					  lvl->lv->name);
 				r = 0;
 			}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 71b894b..fee3767 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -552,9 +552,7 @@ int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc)
 }
 
 /*
- * Switching the cluster attribute make the active volume
- * exclusively activate
- * with any active logical volumes.
+ * Setting the cluster attribute marks active volumes exclusive.
  *
  * FIXME: resolve logic with reacquiring proper top-level LV locks
  *        and we likely can't giveup DLM locks for active LVs...
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 9ea7dbe..6e237c0 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -799,8 +799,8 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint32_t chunk_size);
 
 /*
- * TODO: Add individual cache policy pairs  <key> = value, like:
- *int dm_tree_node_add_cache_policy_arg(struct dm_tree_node *dnode,
+ * FIXME Add individual cache policy pairs  <key> = value, like:
+ * int dm_tree_node_add_cache_policy_arg(struct dm_tree_node *dnode,
  *				      const char *key, uint64_t value);
  */
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f68aa85..bf64cc3 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1265,7 +1265,7 @@ static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const v
 						return 1;
 					break;
 				case DM_REPORT_FIELD_TYPE_STRING_LIST:
-					// TODO: add comparison for string list
+					/* FIXME Add comparison for string list */
 					break;
 			}
 		}
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index af00fee..b0186d3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -675,7 +675,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 
 	/* Starts basic option validation for every segment type */
 
-	/* TODO: Use these ARGS macros also in commands.h ? */
+	/* FIXME Use these ARGS macros also in commands.h? */
 	/* ARGS are disjoint! sets of options */
 #define LVCREATE_ARGS \
 	activate_ARG,\
@@ -783,7 +783,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					    -1))
 			return_0;
 
-		/* TODO: resolve this ambiguous case with --pooldatasize  */
+		/* FIXME Resolve this ambiguous case with --pooldatasize  */
 		if (arg_is_set(cmd, thinpool_ARG)) {
 			if (lp->type) {
 				/* Unsupported with --type snapshot */
@@ -1071,12 +1071,12 @@ static int _determine_cache_argument(struct volume_group *vg,
 			log_error("Change of volume permission is unsupported with cache conversion, use lvchange.");
 			return 0;
 		}
-		/* FIXME: how to handle skip flag */
+		/* FIXME How to handle skip flag? */
 		if (arg_from_list_is_set(cmd, "is unsupported with cache conversion",
 					 setactivationskip_ARG,
 					 ignoreactivationskip_ARG,
 					 -1))
-			return_0; /* TODO FIX THIS */
+			return_0; /* FIXME */
 
 		/* Put origin into resulting activation state first */
 		if (is_change_activating(lp->activate)) {


