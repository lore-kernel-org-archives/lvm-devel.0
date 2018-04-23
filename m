From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:51 -0400
Subject: master - lvmcache: simplify
Message-ID: <201804231352.w3NDqpiw000982@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b6a62f9445b104f8b4f14b1ebe8258b360950e4
Commit:        9b6a62f9445b104f8b4f14b1ebe8258b360950e4
Parent:        c0973e70a58e7e14e9cca29a0f8ad12719ea554f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 9 13:40:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

lvmcache: simplify

Recent changes allow some major simplification of the way
lvmcache works and is used.  lvmcache_label_scan is now
called in a controlled fashion at the start of commands,
and not via various unpredictable side effects.  Remove
various calls to it from other places.  lvmcache_label_scan
should not be called from anywhere during a command, because
it produces an incorrect representation of PVs with no MDAs,
and misclassifies them as orphans.  This has been a long
standing problem.  The invalid flag and rescanning based on
that is no longer used and removed.  The 'force' variation is
no longer needed and removed.
---
 daemons/clvmd/lvm-functions.c  |    1 -
 lib/cache/lvmcache.c           |  259 ++++++----------------------------------
 lib/cache/lvmcache.h           |    8 --
 lib/format1/disk-rep.c         |    1 -
 lib/format1/lvm1-label.c       |    1 -
 lib/format_pool/disk_rep.c     |    3 -
 lib/format_text/text_label.c   |    1 -
 lib/metadata/metadata-liblvm.c |    1 -
 lib/metadata/metadata.c        |   10 +--
 libdm/libdm-config.c           |   10 +-
 liblvm/lvm_vg.c                |    1 -
 tools/toollib.c                |    6 +
 tools/vgcreate.c               |    1 -
 tools/vgmerge.c                |    3 +
 tools/vgsplit.c                |    3 +
 15 files changed, 54 insertions(+), 255 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c278692..6254122 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -662,7 +662,6 @@ int do_refresh_cache(void)
 	}
 
 	init_ignore_suspended_devices(1);
-	lvmcache_force_next_label_scan();
 	lvmcache_label_scan(cmd);
 	label_scan_destroy(cmd); /* destroys bcache (to close devs), keeps lvmcache */
 	dm_pool_empty(cmd->mem);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ef180b9..c8046f7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -29,7 +29,6 @@
 #include "lvmetad.h"
 #include "lvmetad-client.h"
 
-#define CACHE_INVALID	0x00000001
 #define CACHE_LOCKED	0x00000002
 
 /* One per device */
@@ -169,15 +168,6 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 
 static void _update_cache_info_lock_state(struct lvmcache_info *info, int locked)
 {
-	int was_locked = (info->status & CACHE_LOCKED) ? 1 : 0;
-
-	/*
-	 * Cache becomes invalid whenever lock state changes unless
-	 * exclusive VG_GLOBAL is held (i.e. while scanning).
-	 */
-	if (!lvmcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked))
-		info->status |= CACHE_INVALID;
-
 	if (locked)
 		info->status |= CACHE_LOCKED;
 	else
@@ -235,16 +225,11 @@ static void _suspended_vg_free(struct lvmcache_vginfo *vginfo, int free_old, int
 static void _drop_metadata(const char *vgname, int drop_precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
 	if (drop_precommitted)
-		dm_list_iterate_items(info, &vginfo->infos)
-			info->status |= CACHE_INVALID;
-
-	if (drop_precommitted)
 		_suspended_vg_free(vginfo, 0, 1);
 	else
 		_suspended_vg_free(vginfo, 1, 1);
@@ -703,39 +688,6 @@ const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgnam
 	return NULL;
 }
 
-static int _info_is_valid(struct lvmcache_info *info)
-{
-	if (info->status & CACHE_INVALID)
-		return 0;
-
-	/*
-	 * The caller must hold the VG lock to manipulate metadata.
-	 * In a cluster, remote nodes sometimes read metadata in the
-	 * knowledge that the controlling node is holding the lock.
-	 * So if the VG appears to be unlocked here, it should be safe
-	 * to use the cached value.
-	 */
-	if (info->vginfo && !lvmcache_vgname_is_locked(info->vginfo->vgname))
-		return 1;
-
-	if (!(info->status & CACHE_LOCKED))
-		return 0;
-
-	return 1;
-}
-
-/* vginfo is invalid if it does not contain at least one valid info */
-static int _vginfo_is_invalid(struct lvmcache_vginfo *vginfo)
-{
-	struct lvmcache_info *info;
-
-	dm_list_iterate_items(info, &vginfo->infos)
-		if (_info_is_valid(info))
-			return 0;
-
-	return 1;
-}
-
 /*
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
@@ -765,9 +717,6 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *d
 		return NULL;
 	}
 
-	if (valid_only && !_info_is_valid(info))
-		return NULL;
-
 	return info;
 }
 
@@ -805,64 +754,6 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 }
 
 /*
- * FIXME: get rid of the CACHE_INVALID state and rescanning
- * infos with that flag.  The code should just know which devices
- * need scanning and when.
- */
-static int _label_scan_invalid(struct cmd_context *cmd)
-{
-	struct dm_list devs;
-	struct dm_hash_node *n;
-	struct device_list *devl;
-	struct lvmcache_info *info;
-	int dev_count = 0;
-	int ret;
-
-	dm_list_init(&devs);
-
-	dm_hash_iterate(n, _pvid_hash) {
-		if (!(info = dm_hash_get_data(_pvid_hash, n)))
-			continue;
-
-		if (!(info->status & CACHE_INVALID))
-			continue;
-
-		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-			return_0;
-
-		devl->dev = info->dev;
-		dm_list_add(&devs, &devl->list);
-		dev_count++;
-	}
-
-	if (dm_list_empty(&devs))
-		return 1;
-
-	log_debug_cache("Scanning %d devs with invalid info.", dev_count);
-
-	ret = label_scan_devs(cmd, &devs);
-
-	return ret;
-}
-
-/*
- * lvmcache_label_scan() remembers that it has already
- * been called, and will not scan labels if it's called
- * again.  (It will rescan "INVALID" devices if called again.)
- *
- * To force lvmcache_label_scan() to rescan labels on all devices,
- * call lvmcache_force_next_label_scan() before calling
- * lvmcache_label_scan().
- */
-
-static int _force_label_scan;
-
-void lvmcache_force_next_label_scan(void)
-{
-	_force_label_scan = 1;
-}
-
-/*
  * Check if any PVs in vg->pvs have the same PVID as any
  * entries in _unused_duplicate_devices.
  */
@@ -1233,6 +1124,30 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	return 1;
 }
 
+/*
+ * Uses label_scan to populate lvmcache with 'vginfo' struct for each VG
+ * and associated 'info' structs for those VGs.  Only VG summary information
+ * is used to assemble the vginfo/info during the scan, so the resulting
+ * representation of VG/PV state is incomplete and even incorrect.
+ * Specifically, PVs with no MDAs are considered orphans and placed in the
+ * orphan vginfo by lvmcache_label_scan.  This is corrected during the
+ * processing phase as each vg_read() uses VG metadata for each VG to correct
+ * the lvmcache state, i.e. it moves no-MDA PVs from the orphan vginfo onto
+ * the correct vginfo.  Once vg_read() is finished for all VGs, all of the
+ * incorrectly placed PVs should have been moved from the orphan vginfo
+ * onto their correct vginfo's, and the orphan vginfo should (in theory)
+ * represent only real orphan PVs.  (Note: if lvmcache_label_scan is run
+ * after vg_read udpates to lvmcache state, then the lvmcache will be
+ * incorrect again, so do not run lvmcache_label_scan during the
+ * processing phase.)
+ *
+ * TODO: in this label scan phase, don't stash no-MDA PVs into the
+ * orphan VG.  We know that's a fiction, and it can have harmful/damaging
+ * results.  Instead, put them into a temporary list where they can be
+ * pulled from later when vg_read uses metadata to resolve which VG
+ * they actually belong to.
+ */
+
 int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
@@ -1264,20 +1179,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		goto out;
 	}
 
-	/*
-	 * Scan devices whose info struct has the INVALID flag set.
-	 * When scanning has read the pv_header, mda_header and
-	 * mda locations, it will clear the INVALID flag (via
-	 * lvmcache_make_valid).
-	 */
-	if (_has_scanned && !_force_label_scan) {
-		r = _label_scan_invalid(cmd);
-		goto out;
-	}
-
-	if (_force_label_scan && (cmd->full_filter && !cmd->full_filter->use_count) && !refresh_filters(cmd))
-		goto_out;
-
 	if (!cmd->full_filter) {
 		log_error("label scan is missing full filter");
 		goto out;
@@ -1339,28 +1240,16 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
 	}
 
-	_has_scanned = 1;
-
 	/* Perform any format-specific scanning e.g. text files */
 	if (cmd->independent_metadata_areas)
 		dm_list_iterate_items(fmt, &cmd->formats)
 			if (fmt->ops->scan && !fmt->ops->scan(fmt, NULL))
 				goto out;
 
-	/*
-	 * If we are a long-lived process, write out the updated persistent
-	 * device cache for the benefit of short-lived processes.
-	 */
-	if (_force_label_scan && cmd->is_long_lived &&
-	    cmd->dump_filter && cmd->full_filter && cmd->full_filter->dump &&
-	    !cmd->full_filter->dump(cmd->full_filter, 0))
-		stack;
-
 	r = 1;
 
       out:
 	_scanning_in_progress = 0;
-	_force_label_scan = 0;
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (is_orphan_vg(vginfo->vgname))
@@ -1768,10 +1657,8 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 				   uint32_t vgstatus, const char *creation_host,
 				   const struct format_type *fmt)
 {
-	struct lvmcache_vginfo *vginfo, *primary_vginfo, *orphan_vginfo;
-	struct lvmcache_info *info2, *info3;
+	struct lvmcache_vginfo *vginfo, *primary_vginfo;
 	char mdabuf[32];
-	// struct lvmcache_vginfo  *old_vginfo, *next;
 
 	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
 		return 1;
@@ -1780,44 +1667,12 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 	if (info)
 		_drop_vginfo(info, info->vginfo);
 
-	/* Get existing vginfo or create new one */
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
-/*** FIXME - vginfo ends up duplicated instead of renamed.
-		// Renaming?  This lookup fails.
-		if ((vginfo = vginfo_from_vgid(vgid))) {
-			next = vginfo->next;
-			old_vginfo = vginfo_from_vgname(vginfo->vgname, NULL);
-			if (old_vginfo == vginfo) {
-				dm_hash_remove(_vgname_hash, old_vginfo->vgname);
-				if (old_vginfo->next) {
-					if (!dm_hash_insert(_vgname_hash, old_vginfo->vgname, old_vginfo->next)) {
-						log_error("vg hash re-insertion failed: %s",
-							  old_vginfo->vgname);
-						return 0;
-					}
-				}
-			} else do {
-				if (old_vginfo->next == vginfo) {
-					old_vginfo->next = vginfo->next;
-					break;
-				}
-			} while ((old_vginfo = old_vginfo->next));
-			vginfo->next = NULL;
-
-			dm_free(vginfo->vgname);
-			if (!(vginfo->vgname = dm_strdup(vgname))) {
-				log_error("cache vgname alloc failed for %s", vgname);
-				return 0;
-			}
+		/*
+	 	 * Create a vginfo struct for this VG and put the vginfo
+	 	 * into the hash table.
+	 	 */
 
-			// Rename so can assume new name does not already exist
-			if (!dm_hash_insert(_vgname_hash, vginfo->vgname, vginfo->next)) {
-				log_error("vg hash re-insertion failed: %s",
-					  vginfo->vgname);
-		      		return 0;
-			}
-		} else {
-***/
 		if (!(vginfo = dm_zalloc(sizeof(*vginfo)))) {
 			log_error("lvmcache_update_vgname: list alloc failed");
 			return 0;
@@ -1830,52 +1685,24 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		dm_list_init(&vginfo->infos);
 
 		/*
-		 * If we're scanning and there's an invalidated entry, remove it.
-		 * Otherwise we risk bogus warnings of duplicate VGs.
+		 * A different VG (different uuid) can exist with the same name.
+		 * In this case, the two VGs will have separate vginfo structs,
+		 * but the second will be linked onto the existing vginfo->next,
+		 * not in the hash.
 		 */
-		while ((primary_vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)) &&
-		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo)) {
-			orphan_vginfo = lvmcache_vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
-			if (!orphan_vginfo) {
-				log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
-					  primary_vginfo->fmt->orphan_vg_name);
-				dm_free(vginfo->vgname);
-				dm_free(vginfo);
-				return 0;
-			}
-			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
-				_vginfo_detach_info(info2);
-				_vginfo_attach_info(orphan_vginfo, info2);
-				if (info2->mdas.n)
-					sprintf(mdabuf, " with %u mdas",
-						dm_list_size(&info2->mdas));
-				else
-					mdabuf[0] = '\0';
-				log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
-						dev_name(info2->dev),
-						vgname, orphan_vginfo->vgid[0] ? " (" : "",
-						orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
-						orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
-			}
-
-			if (!_drop_vginfo(NULL, primary_vginfo))
-				return_0;
-		}
+		primary_vginfo = lvmcache_vginfo_from_vgname(vgname, NULL);
 
-		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host,
-				    primary_vginfo)) {
+		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host, primary_vginfo)) {
 			dm_free(vginfo->vgname);
 			dm_free(vginfo);
 			return 0;
 		}
+
 		/* Ensure orphans appear last on list_iterate */
 		if (is_orphan_vg(vgname))
 			dm_list_add(&_vginfos, &vginfo->list);
 		else
 			dm_list_add_h(&_vginfos, &vginfo->list);
-/***
-		}
-***/
 	}
 
 	if (info)
@@ -2026,10 +1853,6 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vg
 	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
-	/* If moving PV from orphan to real VG, always mark it valid */
-	if (!is_orphan_vg(vgname))
-		info->status &= ~CACHE_INVALID;
-
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus,
 				     vgsummary->creation_host, info->fmt) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
@@ -2230,8 +2053,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 		}
 	}
 
-	info->status |= CACHE_INVALID;
-
 	/*
 	 * Add or update the _pvid_hash mapping, pvid to info.
 	 */
@@ -2617,14 +2438,6 @@ struct label *lvmcache_get_label(struct lvmcache_info *info) {
 	return info->label;
 }
 
-/*
- * After label_scan reads pv_header, mda_header and mda locations
- * from a PV, it clears the INVALID flag.
- */
-void lvmcache_make_valid(struct lvmcache_info *info) {
-	info->status &= ~CACHE_INVALID;
-}
-
 uint64_t lvmcache_device_size(struct lvmcache_info *info) {
 	return info->device_size;
 }
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4343060..107c993 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -67,13 +67,6 @@ void lvmcache_allow_reads_with_lvmetad(void);
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 
-/*
- * lvmcache_label_scan() will scan labels the first time it's
- * called, but not on subsequent calls, unless
- * lvmcache_force_next_label_scan() is called first
- * to force the next lvmcache_label_scan() to scan again.
- */
-void lvmcache_force_next_label_scan(void);
 int lvmcache_label_scan(struct cmd_context *cmd);
 int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
@@ -187,7 +180,6 @@ int lvmcache_foreach_pv(struct lvmcache_vginfo *vginfo,
 uint64_t lvmcache_device_size(struct lvmcache_info *info);
 void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size);
 struct device *lvmcache_device(struct lvmcache_info *info);
-void lvmcache_make_valid(struct lvmcache_info *info);
 int lvmcache_is_orphan(struct lvmcache_info *info);
 int lvmcache_uncertain_ownership(struct lvmcache_info *info);
 unsigned lvmcache_mda_count(struct lvmcache_info *info);
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 41955af..281adc1 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -337,7 +337,6 @@ static void __update_lvmcache(const struct format_type *fmt,
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(dl->pvd.pv_size)) << SECTOR_SHIFT);
 	lvmcache_del_mdas(info);
-	lvmcache_make_valid(info);
 }
 
 static struct disk_list *__read_disk(const struct format_type *fmt,
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 3b8a655..691a05a 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -84,7 +84,6 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
-	lvmcache_make_valid(info);
 
 	return 1;
 }
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 374ff44..fe9b03e 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -111,7 +111,6 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
-	lvmcache_make_valid(info);
 
 	pl->dev = dev;
 	pl->pv = NULL;
@@ -379,8 +378,6 @@ int read_pool_pds(const struct format_type *fmt, const char *vg_name,
 					   vg_name);
 			return 0;
 		}
-		if (full_scan > 0)
-			lvmcache_force_next_label_scan();
 		lvmcache_label_scan(fmt->cmd);
 
 	} while (1);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e65079e..c47a35a 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -443,7 +443,6 @@ out:
 		return 0;
 	}
 
-	lvmcache_make_valid(info);
 	return 1;
 }
 
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index d8b3b2a..b0b678a 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -273,7 +273,6 @@ out:
 		}
 
 	if (scan_needed) {
-		lvmcache_force_next_label_scan();
 		if (!lvmcache_label_scan(cmd)) {
 			stack;
 			r = 0;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8cb06be..8c8ce25 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3392,8 +3392,6 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct pv_list head;
 
 	dm_list_init(&head.list);
-	lvmcache_label_scan(cmd);
-	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
@@ -3839,11 +3837,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 */
 	log_debug_metadata("Reading VG rereading labels for %s", vgname);
 
-	if (!lvmcache_label_rescan_vg(cmd, vgname, vgid)) {
-		/* The VG wasn't found, so force a full label scan. */
-		lvmcache_force_next_label_scan();
-		lvmcache_label_scan(cmd);
-	}
+	lvmcache_label_rescan_vg(cmd, vgname, vgid);
 
 	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0))) {
 		log_debug_metadata("Cache did not find fmt for vgname %s", vgname);
@@ -4531,7 +4525,6 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
 		log_debug_metadata("Reading VG by vgid %.8s no VG name found, retrying.", vgid);
 		lvmcache_destroy(cmd, 0, 0);
-		lvmcache_force_next_label_scan();
 		lvmcache_label_scan(cmd);
 	}
 
@@ -5572,7 +5565,6 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 				unlock_vg(cmd, NULL, vgname);
 				return FAILED_LOCKING;
 			}
-			lvmcache_force_next_label_scan();
 			lvmcache_label_scan(cmd);
 			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0))
 				return SUCCESS; /* vgname not found after scanning */
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 746ef07..3f0d251 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -963,7 +963,7 @@ static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
 	if (n && n->v) {
 		if ((n->v->type == DM_CFG_STRING) &&
 		    (allow_empty || (*n->v->v.str))) {
-			log_very_verbose("Setting %s to %s", path, n->v->v.str);
+			/* log_very_verbose("Setting %s to %s", path, n->v->v.str); */
 			return n->v->v.str;
 		}
 		if ((n->v->type != DM_CFG_STRING) || (!allow_empty && fail))
@@ -994,7 +994,7 @@ static int64_t _find_config_int64(const void *start, node_lookup_fn find,
 	const struct dm_config_node *n = find(start, path);
 
 	if (n && n->v && n->v->type == DM_CFG_INT) {
-		log_very_verbose("Setting %s to %" PRId64, path, n->v->v.i);
+		/* log_very_verbose("Setting %s to %" PRId64, path, n->v->v.i); */
 		return n->v->v.i;
 	}
 
@@ -1009,7 +1009,7 @@ static float _find_config_float(const void *start, node_lookup_fn find,
 	const struct dm_config_node *n = find(start, path);
 
 	if (n && n->v && n->v->type == DM_CFG_FLOAT) {
-		log_very_verbose("Setting %s to %f", path, n->v->v.f);
+		/* log_very_verbose("Setting %s to %f", path, n->v->v.f); */
 		return n->v->v.f;
 	}
 
@@ -1058,12 +1058,12 @@ static int _find_config_bool(const void *start, node_lookup_fn find,
 		switch (v->type) {
 		case DM_CFG_INT:
 			b = v->v.i ? 1 : 0;
-			log_very_verbose("Setting %s to %d", path, b);
+			/* log_very_verbose("Setting %s to %d", path, b); */
 			return b;
 
 		case DM_CFG_STRING:
 			b = _str_to_bool(v->v.str, fail);
-			log_very_verbose("Setting %s to %d", path, b);
+			/* log_very_verbose("Setting %s to %d", path, b); */
 			return b;
 		default:
 			;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 5593579..0678bdc 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -512,7 +512,6 @@ int lvm_scan(lvm_t libh)
 	int rc = 0;
 	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	lvmcache_force_next_label_scan();
 	if (!lvmcache_label_scan((struct cmd_context *)libh))
 		rc = -1;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index fabf2dc..e887f65 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1485,6 +1485,12 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
+/*
+ * FIXME: replace process_each_label() with process_each_vg() which is
+ * based on performing vg_read(), which provides a correct representation
+ * of VGs/PVs, that is not provided by lvmcache_label_scan().
+ */
+
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		       struct processing_handle *handle,
 		       process_single_label_fn_t process_single_label)
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 87a296f..0c4c428 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -82,7 +82,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	lvmcache_force_next_label_scan();
 	lvmcache_label_scan(cmd);              /* Does nothing when using lvmetad. */
 	lvmcache_seed_infos_from_lvmetad(cmd); /* Does nothing unless using lvmetad. */
 
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 013bef4..67c3498 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -72,6 +72,9 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		return ECMD_FAILED;
 	}
 
+	lvmcache_label_scan(cmd);
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
 	if (strcmp(vg_name_to, vg_name_from) > 0)
 		lock_vg_from_first = 1;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 46c8911..2d39111 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -581,6 +581,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	lvmcache_label_scan(cmd);
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
 	if (strcmp(vg_name_to, vg_name_from) < 0)
 		lock_vg_from_first = 0;
 


