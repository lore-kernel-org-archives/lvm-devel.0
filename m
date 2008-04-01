From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2008 22:40:14 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20080401224014.23642.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-01 22:40:13

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format_text: export.c import.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Cache VG metadata internally while VG lock is held.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.814&r2=1.815
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/WHATS_NEW	2008/04/01 22:15:16	1.814
+++ LVM2/WHATS_NEW	2008/04/01 22:40:12	1.815
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Cache VG metadata internally while VG lock is held.
   Fix redundant lvresize message if vg doesn't exist.
   Fix another allocation bug with clvmd and large node IDs.
   Add find_lv_in_lv_list() and find_pv_in_pv_list().
--- LVM2/lib/cache/lvmcache.c	2008/03/17 16:51:31	1.39
+++ LVM2/lib/cache/lvmcache.c	2008/04/01 22:40:12	1.40
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -49,15 +49,53 @@
 	return 1;
 }
 
-static void _update_cache_info_lock_state(struct lvmcache_info *info, int locked)
+/* Volume Group metadata cache functions */
+static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
+{
+	if (!vginfo || !vginfo->vgmetadata)
+		return;
+
+	dm_free(vginfo->vgmetadata);
+
+	vginfo->vgmetadata = NULL;
+	vginfo->fid = NULL;
+
+	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
+}
+
+static void _store_metadata(struct lvmcache_vginfo *vginfo,
+			    struct volume_group *vg, unsigned precommitted)
+{
+	int size;
+
+	if (vginfo->vgmetadata)
+		_free_cached_vgmetadata(vginfo);
+
+	if (!(size = export_vg_to_buffer(vg, &vginfo->vgmetadata))) {
+		stack;
+		return;
+	}
+
+	vginfo->fid = vg->fid;
+	vginfo->precommitted = precommitted;
+
+	log_debug("Metadata cache: VG %s stored (%d bytes%s).", vginfo->vgname,
+		  size, precommitted ? ", precommitted" : "");
+}
+
+static void _update_cache_info_lock_state(struct lvmcache_info *info,
+					  int locked,
+					  int *cached_vgmetadata_valid)
 {
 	int was_locked = (info->status & CACHE_LOCKED) ? 1 : 0;
 
 	/*
 	 * Cache becomes invalid whenever lock state changes
 	 */
-	if (was_locked != locked)
+	if (was_locked != locked) {
 		info->status |= CACHE_INVALID;
+		*cached_vgmetadata_valid = 0;
+	}
 
 	if (locked)
 		info->status |= CACHE_LOCKED;
@@ -69,9 +107,14 @@
 					    int locked)
 {
 	struct lvmcache_info *info;
+	int cached_vgmetadata_valid = 1;
 
 	list_iterate_items(info, &vginfo->infos)
-		_update_cache_info_lock_state(info, locked);
+		_update_cache_info_lock_state(info, locked,
+					      &cached_vgmetadata_valid);
+
+	if (!cached_vgmetadata_valid)
+		_free_cached_vgmetadata(vginfo);
 }
 
 static void _update_cache_lock_state(const char *vgname, int locked)
@@ -238,6 +281,17 @@
 	return 1;
 }
 
+static int _vginfo_is_valid(struct lvmcache_vginfo *vginfo)
+{
+	struct lvmcache_info *info;
+
+	list_iterate_items(info, &vginfo->infos)
+		if (!_info_is_valid(info))
+			return 0;
+
+	return 1;
+}
+
 /*
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
@@ -329,6 +383,32 @@
 	return r;
 }
 
+struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct volume_group *vg;
+
+	if (!vgid || !(vginfo = vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
+		return NULL;
+
+	if (!_vginfo_is_valid(vginfo))
+		return NULL;
+
+	if ((precommitted && !vginfo->precommitted) ||
+	    (!precommitted && vginfo->precommitted))
+		return NULL;
+
+	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, vginfo->fid)) ||
+	    !vg_validate(vg)) {
+		_free_cached_vgmetadata(vginfo);
+		return_NULL;
+	}
+
+	log_debug("Using cached metadata for VG %s.", vginfo->vgname);
+
+	return vg;
+}
+
 struct list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
 {
 	struct list *vgids;
@@ -490,20 +570,6 @@
 	return;
 } */
 
-int lvmcache_store_vg(struct lvmcache_vginfo *vginfo, struct volume_group *vg,
-		      unsigned precommitted)
-{
-	return 1;
-}
-
-void lvmcache_drop_vg(const char *vgname)
-{
-	struct lvmcache_vginfo *vginfo;
-
-	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
-		return;
-}
-
 static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
 	if (!strcmp(info->dev->pvid, pvid))
@@ -803,7 +869,7 @@
 
 	/* store text representation of vg to cache */
 	if ((vginfo = vginfo_from_vgname(vg->name, NULL)))
-		lvmcache_store_vg(vginfo, vg, precommitted);
+		_store_metadata(vginfo, vg, precommitted);
 
 	return 1;
 }
@@ -935,6 +1001,7 @@
 			dm_free(vginfo->vgname);
 		if (vginfo->creation_host)
 			dm_free(vginfo->creation_host);
+		_free_cached_vgmetadata(vginfo);
 		dm_free(vginfo);
 	} while ((vginfo = next));
 }
--- LVM2/lib/cache/lvmcache.h	2008/03/17 16:51:31	1.18
+++ LVM2/lib/cache/lvmcache.h	2008/04/01 22:40:12	1.19
@@ -109,4 +109,7 @@
 struct list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
 
+/* Returns cached volume group metadata. */
+struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+
 #endif
--- LVM2/lib/format_text/export.c	2008/03/12 16:03:22	1.62
+++ LVM2/lib/format_text/export.c	2008/04/01 22:40:12	1.63
@@ -742,5 +742,10 @@
 	return r;
 }
 
+int export_vg_to_buffer(struct volume_group *vg, char **buf)
+{
+	return text_vg_export_raw(vg, "", buf);
+}
+
 #undef outf
 #undef outnl
--- LVM2/lib/format_text/import.c	2008/03/13 12:33:22	1.46
+++ LVM2/lib/format_text/import.c	2008/04/01 22:40:12	1.47
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -130,3 +130,27 @@
 	return text_vg_import_fd(fid, file, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
 				 when, desc);
 }
+
+struct volume_group *import_vg_from_buffer(char *buf,
+                                           struct format_instance *fid)
+{
+	struct volume_group *vg = NULL;
+	struct config_tree *cft;
+	struct text_vg_version_ops **vsn;
+
+	_init_text_import();
+
+	if (!(cft = create_config_tree_from_string(fid->fmt->cmd, buf)))
+		return_NULL;
+
+	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
+		if (!(*vsn)->check_version(cft))
+			continue;
+		if (!(vg = (*vsn)->read_vg(fid, cft)))
+			stack;
+		break;
+	}
+
+	destroy_config_tree(cft);
+	return vg;
+}
--- LVM2/lib/metadata/metadata.c	2008/03/28 19:08:23	1.163
+++ LVM2/lib/metadata/metadata.c	2008/04/01 22:40:12	1.164
@@ -1316,9 +1316,6 @@
 	int cache_updated = 0;
 	int failed = 0;
 
-	/* Forget all cached instances of vg and force reread */
-	lvmcache_drop_vg(vg->name);             
-
 	/* Commit to each copy of the metadata area */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		failed = 0;
@@ -1455,6 +1452,11 @@
 		return _vg_read_orphans(cmd, vgname);
 	}
 
+	if ((correct_vg = lvmcache_get_vg(vgid, precommitted))) {
+		*consistent = 1;
+		return correct_vg;
+	}
+
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
 	if (!(fmt = fmt_from_vgname(vgname, vgid))) {
--- LVM2/lib/metadata/metadata.h	2008/03/28 19:08:23	1.179
+++ LVM2/lib/metadata/metadata.h	2008/04/01 22:40:13	1.180
@@ -313,6 +313,13 @@
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
 /*
+ * For internal metadata caching.
+ */
+int export_vg_to_buffer(struct volume_group *vg, char **buf);
+struct volume_group *import_vg_from_buffer(char *buf,
+					   struct format_instance *fid);
+
+/*
  * Mirroring functions
  */
 


