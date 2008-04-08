From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2008 12:49:23 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20080408124923.25754.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-08 12:49:21

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/format_pool: format_pool.c format_pool.h 
	lib/metadata   : metadata.c 
	tools          : lvmcmdline.c pvcreate.c pvscan.c vgreduce.c 
	                 vgrename.c vgscan.c 

Log message:
	Fix vgreduce to use vg_split_mdas to check sufficient mdas remain.
	Add (empty) orphan VGs to lvmcache during initialisation.
	Fix orphan VG name used for format_pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.829&r2=1.830
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2008/04/07 22:12:35	1.829
+++ LVM2/WHATS_NEW	2008/04/08 12:49:20	1.830
@@ -1,5 +1,8 @@
 Version 2.02.34 -
 ===================================
+  Fix vgreduce to use vg_split_mdas to check sufficient mdas remain.
+  Add (empty) orphan VGs to lvmcache during initialisation.
+  Fix orphan VG name used for format_pool.
   Create a fid for internal orphan VGs.
   Update lvmcache VG lock state for all locking types now.
   Fix output if overriding command_names on cmdline.
--- LVM2/lib/cache/lvmcache.c	2008/04/03 18:56:40	1.42
+++ LVM2/lib/cache/lvmcache.c	2008/04/08 12:49:20	1.43
@@ -536,34 +536,38 @@
 	return NULL;
 }
 
-static int _drop_vginfo(struct lvmcache_info *info)
+/*
+ * vginfo must be info->vginfo unless info is NULL
+ */
+static int _drop_vginfo(struct lvmcache_info *info, struct lvmcache_vginfo *vginfo)
 {
-	if (!list_empty(&info->list)) {
+	if (info && !list_empty(&info->list)) {
 		list_del(&info->list);
 		list_init(&info->list);
 	}
 
-	if (info->vginfo && list_empty(&info->vginfo->infos)) {
-		dm_hash_remove(_vgname_hash, info->vginfo->vgname);
-		if (info->vginfo->next) {
-			if (!dm_hash_insert(_vgname_hash, info->vginfo->vgname, info->vginfo->next)) {
+	if (vginfo && !is_orphan_vg(vginfo->vgname) && list_empty(&vginfo->infos)) {
+		dm_hash_remove(_vgname_hash, vginfo->vgname);
+		if (vginfo->next) {
+			if (!dm_hash_insert(_vgname_hash, vginfo->vgname, vginfo->next)) {
 				log_error("vg hash re-insertion failed: %s",
-					  info->vginfo->vgname);
+					  vginfo->vgname);
 				return 0;
 			}
 		}
 
-		if (info->vginfo->vgname)
-			dm_free(info->vginfo->vgname);
-		if (info->vginfo->creation_host)
-			dm_free(info->vginfo->creation_host);
-		if (*info->vginfo->vgid)
-			dm_hash_remove(_vgid_hash, info->vginfo->vgid);
-		list_del(&info->vginfo->list);
+		if (vginfo->vgname)
+			dm_free(vginfo->vgname);
+		if (vginfo->creation_host)
+			dm_free(vginfo->creation_host);
+		if (*vginfo->vgid)
+			dm_hash_remove(_vgid_hash, vginfo->vgid);
+		list_del(&vginfo->list);
 		dm_free(info->vginfo);
 	}
 
-	info->vginfo = NULL;
+	if (info)
+		info->vginfo = NULL;
 
 	return 1;
 }
@@ -574,7 +578,7 @@
 	if (info->dev->pvid[0] && _pvid_hash)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
 
-	_drop_vginfo(info);
+	_drop_vginfo(info, info->vginfo);
 
 	info->label->labeller->ops->destroy_label(info->label->labeller,
 						info->label);
@@ -599,31 +603,36 @@
 	return 1;
 }
 
-static int _lvmcache_update_vgid(struct lvmcache_info *info, const char *vgid)
+/*
+ * vginfo must be info->vginfo unless info is NULL (orphans)
+ */
+static int _lvmcache_update_vgid(struct lvmcache_info *info,
+				 struct lvmcache_vginfo *vginfo,
+				 const char *vgid)
 {
-	if (!vgid || !info->vginfo ||
-	    !strncmp(info->vginfo->vgid, vgid, ID_LEN))
+	if (!vgid || !vginfo ||
+	    !strncmp(vginfo->vgid, vgid, ID_LEN))
 		return 1;
 
-	if (info->vginfo && *info->vginfo->vgid)
-		dm_hash_remove(_vgid_hash, info->vginfo->vgid);
+	if (vginfo && *vginfo->vgid)
+		dm_hash_remove(_vgid_hash, vginfo->vgid);
 	if (!vgid) {
-		log_debug("lvmcache: %s: clearing VGID", dev_name(info->dev));
+		log_debug("lvmcache: %s: clearing VGID", info ? dev_name(info->dev) : vginfo->vgname);
 		return 1;
 	}
 
-	strncpy(info->vginfo->vgid, vgid, ID_LEN);
-	info->vginfo->vgid[ID_LEN] = '\0';
-	if (!dm_hash_insert(_vgid_hash, info->vginfo->vgid, info->vginfo)) {
+	strncpy(vginfo->vgid, vgid, ID_LEN);
+	vginfo->vgid[ID_LEN] = '\0';
+	if (!dm_hash_insert(_vgid_hash, vginfo->vgid, vginfo)) {
 		log_error("_lvmcache_update: vgid hash insertion failed: %s",
-			  info->vginfo->vgid);
+			  vginfo->vgid);
 		return 0;
 	}
 
-	if (!is_orphan_vg(info->vginfo->vgname))
+	if (!is_orphan_vg(vginfo->vgname))
 		log_debug("lvmcache: %s: setting %s VGID to %s",
-			  dev_name(info->dev), info->vginfo->vgname,
-			  info->vginfo->vgid);
+			  dev_name(info->dev), vginfo->vgname,
+			  vginfo->vgid);
 
 	return 1;
 }
@@ -714,16 +723,18 @@
 
 static int _lvmcache_update_vgname(struct lvmcache_info *info,
 				   const char *vgname, const char *vgid,
-				   uint32_t vgstatus, const char *creation_host)
+				   uint32_t vgstatus, const char *creation_host,
+				   const struct format_type *fmt)
 {
 	struct lvmcache_vginfo *vginfo, *primary_vginfo;
 	// struct lvmcache_vginfo  *old_vginfo, *next;
 
-	if (!vgname || (info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
+	if (!vgname || (info && info->vginfo && !strcmp(info->vginfo->vgname, vgname)))
 		return 1;
 
 	/* Remove existing vginfo entry */
-	_drop_vginfo(info);
+	if (info)
+		_drop_vginfo(info, info->vginfo);
 
 	/* Get existing vginfo or create new one */
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid))) {
@@ -791,18 +802,25 @@
 ***/
 	}
 
-	info->vginfo = vginfo;
-	list_add(&vginfo->infos, &info->list);
+	if (info) {
+		info->vginfo = vginfo;
+		list_add(&vginfo->infos, &info->list);
+	} else if (!_lvmcache_update_vgid(info, vginfo, vgid)) /* Orphans */
+		return_0;
 
 	_update_cache_vginfo_lock_state(vginfo, vgname_is_locked(vgname));
 
 	/* FIXME Check consistency of list! */
-	vginfo->fmt = info->fmt;
+	vginfo->fmt = fmt;
 
-	log_debug("lvmcache: %s: now in VG %s%s%s%s", dev_name(info->dev),
-		  vgname, vginfo->vgid[0] ? " (" : "",
-		  vginfo->vgid[0] ? vginfo->vgid : "",
-		  vginfo->vgid[0] ? ")" : "");
+	if (info)
+		log_debug("lvmcache: %s: now in VG %s%s%s%s",
+			  dev_name(info->dev),
+			  vgname, vginfo->vgid[0] ? " (" : "",
+			  vginfo->vgid[0] ? vginfo->vgid : "",
+			  vginfo->vgid[0] ? ")" : "");
+	else
+		log_debug("lvmcache: initialised VG %s", vgname);
 
 	return 1;
 }
@@ -842,6 +860,16 @@
 	return 1;
 }
 
+int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
+{
+	if (!_lock_hash && !lvmcache_init()) {
+		log_error("Internal cache initialisation failed");
+		return 0;
+	}
+
+	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
+}
+
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *creation_host)
@@ -852,9 +880,10 @@
 		vgname = info->fmt->orphan_vg_name;
 		vgid = vgname;
 	}
+
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgstatus,
-				     creation_host) ||
-	    !_lvmcache_update_vgid(info, vgid) ||
+				     creation_host, info->fmt) ||
+	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
 	    !_lvmcache_update_vgstatus(info, vgstatus, creation_host))
 		return_0;
 
@@ -1036,7 +1065,7 @@
 			  dm_hash_get_key(_lock_hash, n));
 }
 
-void lvmcache_destroy(void)
+void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 {
 	struct dm_hash_node *n;
 	log_verbose("Wiping internal VG cache");
@@ -1069,4 +1098,7 @@
 	}
 
 	list_init(&_vginfos);
+
+	if (retain_orphans)
+		init_lvmcache_orphans(cmd);
 }
--- LVM2/lib/cache/lvmcache.h	2008/04/01 22:40:12	1.19
+++ LVM2/lib/cache/lvmcache.h	2008/04/08 12:49:20	1.20
@@ -63,7 +63,7 @@
 };
 
 int lvmcache_init(void);
-void lvmcache_destroy(void);
+void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
 
 /* Set full_scan to 1 to reread every filtered device label or
  * 2 to rescan /dev for new devices */
@@ -74,6 +74,7 @@
 				   struct device *dev,
 				   const char *vgname, const char *vgid,
 				   uint32_t vgstatus);
+int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
 void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
--- LVM2/lib/commands/toolcontext.c	2008/04/02 21:31:14	1.58
+++ LVM2/lib/commands/toolcontext.c	2008/04/08 12:49:20	1.59
@@ -721,6 +721,17 @@
 	return 0;
 }
 
+int init_lvmcache_orphans(struct cmd_context *cmd)
+{
+	struct format_type *fmt;
+
+	list_iterate_items(fmt, &cmd->formats)
+		if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
+			return_0;
+
+	return 1;
+}
+
 static int _init_segtypes(struct cmd_context *cmd)
 {
 	struct segment_type *segtype;
@@ -981,6 +992,9 @@
 	if (!_init_formats(cmd))
 		goto error;
 
+	if (!init_lvmcache_orphans(cmd))
+		goto error;
+
 	if (!_init_segtypes(cmd))
 		goto error;
 
@@ -1044,7 +1058,7 @@
 	 */
 
 	activation_release();
-	lvmcache_destroy();
+	lvmcache_destroy(cmd, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(&cmd->formats);
@@ -1086,6 +1100,9 @@
 	if (!_init_formats(cmd))
 		return 0;
 
+	if (!init_lvmcache_orphans(cmd))
+		return 0;
+
 	if (!_init_segtypes(cmd))
 		return 0;
 
@@ -1107,7 +1124,7 @@
 
 	archive_exit(cmd);
 	backup_exit(cmd);
-	lvmcache_destroy();
+	lvmcache_destroy(cmd, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(&cmd->formats);
--- LVM2/lib/commands/toolcontext.h	2008/04/02 21:23:39	1.22
+++ LVM2/lib/commands/toolcontext.h	2008/04/08 12:49:20	1.23
@@ -95,5 +95,6 @@
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
+int init_lvmcache_orphans(struct cmd_context *cmd);
 
 #endif
--- LVM2/lib/format_pool/format_pool.c	2008/02/06 15:47:27	1.14
+++ LVM2/lib/format_pool/format_pool.c	2008/04/08 12:49:20	1.15
@@ -24,8 +24,6 @@
 #include "format_pool.h"
 #include "pool_label.h"
 
-#define FMT_POOL_NAME "pool"
-
 /* Must be called after pvs are imported */
 static struct user_subpool *_build_usp(struct list *pls, struct dm_pool *mem,
 				       int *sps)
@@ -316,7 +314,7 @@
 	fmt->ops = &_format_pool_ops;
 	fmt->name = FMT_POOL_NAME;
 	fmt->alias = NULL;
-	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_POOL_NAME);
+	fmt->orphan_vg_name = FMT_POOL_ORPHAN_VG_NAME;
 	fmt->features = 0;
 	fmt->private = NULL;
 
--- LVM2/lib/format_pool/format_pool.h	2007/08/20 20:55:25	1.2
+++ LVM2/lib/format_pool/format_pool.h	2008/04/08 12:49:20	1.3
@@ -18,6 +18,9 @@
 
 #include "metadata.h"
 
+#define FMT_POOL_NAME "pool"
+#define FMT_POOL_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_POOL_NAME)
+
 #ifdef POOL_INTERNAL
 struct format_type *init_pool_format(struct cmd_context *cmd);
 #endif
--- LVM2/lib/metadata/metadata.c	2008/04/07 22:12:37	1.166
+++ LVM2/lib/metadata/metadata.c	2008/04/08 12:49:20	1.167
@@ -692,6 +692,10 @@
 	return 1;
 }
 
+/*
+ * Separate metadata areas after splitting a VG.
+ * Also accepts orphan VG as destination (for vgreduce).
+ */
 int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
 		  struct volume_group *vg_from, struct volume_group *vg_to)
 {
@@ -708,11 +712,16 @@
 			continue;
 		}
 
-		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda))
-			list_move(&mda->list, mdas_to);
+		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda)) {
+			if (is_orphan_vg(vg_to->name))
+				list_del(&mda->list);
+			else
+				list_move(&mda->list, mdas_to);
+		}
 	}
 
-	if (list_empty(mdas_from) || list_empty(mdas_to))
+	if (list_empty(mdas_from) ||
+	    (!is_orphan_vg(vg_to->name) && list_empty(mdas_to)))
 		return common_mda;
 
 	return 1;
@@ -1366,6 +1375,8 @@
 	struct volume_group *vg;
 	struct physical_volume *pv;
 
+	lvmcache_label_scan(cmd, 0);
+
 	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
--- LVM2/tools/lvmcmdline.c	2008/04/02 21:23:39	1.62
+++ LVM2/tools/lvmcmdline.c	2008/04/08 12:49:21	1.63
@@ -938,7 +938,7 @@
       out:
 	if (test_mode()) {
 		log_verbose("Test mode: Wiping internal cache");
-		lvmcache_destroy();
+		lvmcache_destroy(cmd, 1);
 	}
 
 	if (cmd->cft_override) {
--- LVM2/tools/pvcreate.c	2008/01/30 14:00:02	1.61
+++ LVM2/tools/pvcreate.c	2008/04/08 12:49:21	1.62
@@ -81,7 +81,7 @@
 		unlock_vg(cmd, VG_ORPHANS);
 
 		persistent_filter_wipe(cmd->filter);
-		lvmcache_destroy();
+		lvmcache_destroy(cmd, 1);
 
 		init_md_filtering(0);
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
--- LVM2/tools/pvscan.c	2008/01/30 14:00:02	1.45
+++ LVM2/tools/pvscan.c	2008/04/08 12:49:21	1.46
@@ -130,7 +130,7 @@
 	}
 
 	persistent_filter_wipe(cmd->filter);
-	lvmcache_destroy();
+	lvmcache_destroy(cmd, 1);
 
 	log_verbose("Walking through all physical volumes");
 	if (!(pvslist = get_pvs(cmd))) {
--- LVM2/tools/vgreduce.c	2008/02/06 15:47:28	1.79
+++ LVM2/tools/vgreduce.c	2008/04/08 12:49:21	1.80
@@ -353,6 +353,8 @@
 			    void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
+	struct volume_group *orphan_vg;
+	int consistent = 1;
 	const char *name = pv_dev_name(pv);
 
 	if (pv_pe_alloc_count(pv)) {
@@ -366,10 +368,17 @@
 		return ECMD_FAILED;
 	}
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE | LCK_NONBLOCK)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
 	pvl = find_pv_in_vg(vg, name);
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
+	}
 
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
@@ -381,6 +390,7 @@
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -388,9 +398,24 @@
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
+	if(!(orphan_vg = vg_read(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
+	   !consistent) {
+		log_error("Unable to read existing orphan PVs");
+		unlock_vg(cmd, VG_ORPHANS);
+		return ECMD_FAILED;
+	}
+
+	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
+		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
+			  name, vg->name);
+		unlock_vg(cmd, VG_ORPHANS);
+		return ECMD_FAILED;
+	}
+
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		log_error("Removal of physical volume \"%s\" from "
 			  "\"%s\" failed", name, vg->name);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -398,9 +423,11 @@
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
+	unlock_vg(cmd, VG_ORPHANS);
 	backup(vg);
 
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
--- LVM2/tools/vgrename.c	2008/01/30 14:00:02	1.50
+++ LVM2/tools/vgrename.c	2008/04/08 12:49:21	1.51
@@ -151,7 +151,7 @@
 
 	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
 	persistent_filter_wipe(cmd->filter);
-	lvmcache_destroy();
+	lvmcache_destroy(cmd, 1);
 
 	return 1;
 
--- LVM2/tools/vgscan.c	2008/01/30 14:00:02	1.29
+++ LVM2/tools/vgscan.c	2008/04/08 12:49:21	1.30
@@ -57,7 +57,7 @@
 	}
 
 	persistent_filter_wipe(cmd->filter);
-	lvmcache_destroy();
+	lvmcache_destroy(cmd, 1);
 
 	log_print("Reading all physical volumes.  This may take a while...");
 


