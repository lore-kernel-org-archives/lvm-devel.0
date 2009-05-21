From: agk@sourceware.org <agk@sourceware.org>
Date: 21 May 2009 03:04:59 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20090521030459.20466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-21 03:04:54

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/activate   : activate.c 
	lib/locking    : .exported_symbols cluster_locking.c 
	                 external_locking.c locking.c locking.h 
	                 locking_types.h 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 mirror.c snapshot_manip.c 
	lib/report     : columns.h 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvmove.c toollib.c 
	                 vgchange.c vgconvert.c vgextend.c vgmerge.c 
	                 vgreduce.c vgrename.c vgscan.c vgsplit.c 

Log message:
	Pre-release cleanups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1120&r2=1.1121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.267&r2=1.268
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/.exported_symbols.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/VERSION	2009/03/03 18:25:05	1.193
+++ LVM2/VERSION	2009/05/21 03:04:52	1.194
@@ -1 +1 @@
-2.02.46-cvs (2009-03-03)
+2.02.46-cvs (2009-05-21)
--- LVM2/VERSION_DM	2009/03/03 18:25:05	1.7
+++ LVM2/VERSION_DM	2009/05/21 03:04:52	1.8
@@ -1 +1 @@
-1.02.32-cvs (2009-03-03)
+1.02.32-cvs (2009-05-21)
--- LVM2/WHATS_NEW	2009/05/20 22:24:48	1.1120
+++ LVM2/WHATS_NEW	2009/05/21 03:04:52	1.1121
@@ -1,9 +1,11 @@
-Version 2.02.46 - 
-================================
-  Inherit read ahead from underlying device.
-  Use lock query instead of activate_lv_excl.
+Version 2.02.46 - 21st May 2009
+===============================
+  Inherit readahead setting from underlying devices during activation.
+  Detect LVs active on remote nodes by querying locks if supported.
   Enable online resizing of mirrors.
   Use suspend with flush when device size was changed during table preload.
+  Implement query_resource_fn for cluster_locking.
+  Support query_resource_fn in locking modules.
   Introduce CLVMD_CMD_LOCK_QUERY command for clvmd.
   Fix pvmove to revert operation if temporary mirror creation fails.
   Fix metadata export for VG with missing PVs.
@@ -11,7 +13,7 @@
   Force max_lv restriction only for newly created LV.
   Remove unneeded import parameter from lv_create_empty.
   Merge lv_is_displayable and lv_is_visible functions.
-  Introduce lv_set_visible & lv_set_invisible functions.
+  Introduce lv_set_visible & lv_set_hidden functions.
   Fix lv_is_visible to handle virtual origin.
   Introduce link_lv_to_vg and unlink_lv_from_vg functions.
   Remove lv_count from VG and use counter function instead.
@@ -20,15 +22,18 @@
   Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
   Remove snapshot_count from VG and use function instead.
   Fix first_seg() call for empty segment list.
-  Add make install_lvm2 as complement to device-mapper install.
+  Add install_lvm2 makefile target to install only the LVM2 components.
   Reject missing PVs from allocation in toollib.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
+  Fix minimum width of devices column in reports.
   Add lvs origin_size field.
   Fix linux configure --enable-debug to exclude -O2.
-  Implement lvconvert --repair, for repairing partially failed mirrors.
+  Implement lvconvert --repair for repairing partially-failed mirrors.
   Fix vgreduce --removemissing failure exit code.
   Fix remote metadata backup for clvmd.
+  Introduce unlock_and_release_vg macro.
+  Introduce vg_release() to be called to free every struct volume_group.
   Alloc PV internal structure from VG mempool if possible.
   Fix metadata backup to run after vg_commit always.
   Tidy clvmd volume lock cache functions.
@@ -36,12 +41,11 @@
   Fix pvs -a output to not read volume groups from non-PV devices.
   Add MMC (mmcblk) device type to filters.
   Introduce memory pools per volume group (to reduce memory for large VGs).
-  Add memory pool leaks detection.
-  Use copy of PV structure when manipulating with global PV lists.
+  Use copy of PV structure when manipulating global PV lists.
   Always return exit error status when locking of volume group fails.
   Fix mirror log convert validation question.
   Avoid referencing files from DESTDIR during build process.
-  Avoid creating some static libraries without static_link.
+  Avoid creating some static libraries unless configured --enable-static_link.
   Enable use of cached metadata for pvs and pvdisplay commands.
   Add missing 'device-mapper' internal subdir build dependency.
   Fix memory leak in mirror allocation code.
@@ -52,14 +56,15 @@
   Block SIGTERM & SIGINT in clvmd subthreads.
   Detect and conditionally wipe swapspace signatures in pvcreate.
   Fix maximal volume count check for snapshots if max_lv set for volume group.
-  Fix lvcreate to remove cow volume if the snapshot creation fails.
+  Fix lvcreate to remove unused cow volume if the snapshot creation fails.
   Fix error messages when PV uuid or pe_start reading fails.
-  Rename liblvm.a to liblvm-internal.a and build new application library.
+  Build new liblvm application-level library.
+  Rename liblvm.a to liblvm-internal.a.
   Flush memory pool and fix locking in clvmd refresh and backup command.
-  Fix unlocks in clvmd-corosync. Broken in 2.02.45.
+  Fix unlocks in clvmd-corosync. (2.02.45)
   Fix error message when adding metadata directory to internal list fails.
   Fix size and error message of memory allocation at backup initialization.
-  Remove old metadata backup file after renaming vg.
+  Remove old metadata backup file after renaming VG.
   Restore log_suppress state when metadata backup file is up-to-date.
 
 Version 2.02.45 - 3rd March 2009
--- LVM2/WHATS_NEW_DM	2009/05/20 22:44:10	1.267
+++ LVM2/WHATS_NEW_DM	2009/05/21 03:04:52	1.268
@@ -1,5 +1,5 @@
-Version 1.02.32 - 
-================================
+Version 1.02.32 - 21st May 2009
+===============================
   Only generate libdevmapper.a when configured to link statically.
   Export dm_tree_node_size_changed() from libdevmapper.
   Propagate the table size_changed property up the dm device tree.
--- LVM2/lib/activate/activate.c	2009/05/20 12:58:03	1.151
+++ LVM2/lib/activate/activate.c	2009/05/21 03:04:52	1.152
@@ -711,7 +711,7 @@
 	 */
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
 		deactivate_lv(lv->vg->cmd, lv);
-			return 0;
+		return 0;
 	}
 
 	/*
--- LVM2/lib/locking/.exported_symbols	2009/05/20 12:58:04	1.2
+++ LVM2/lib/locking/.exported_symbols	2009/05/21 03:04:53	1.3
@@ -1,5 +1,5 @@
 locking_init
 locking_end
 lock_resource
-lock_resource_query
+query_resource
 reset_locking
--- LVM2/lib/locking/cluster_locking.c	2009/05/19 10:39:00	1.34
+++ LVM2/lib/locking/cluster_locking.c	2009/05/21 03:04:53	1.35
@@ -33,7 +33,7 @@
 
 #ifndef CLUSTER_LOCKING_INTERNAL
 int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags);
-int lock_resource_query(const char *resource, int *mode);
+int query_resource(const char *resource, int *mode);
 void locking_end(void);
 int locking_init(int type, struct config_tree *cf, uint32_t *flags);
 #endif
@@ -472,9 +472,9 @@
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
-static int _lock_resource_query(const char *resource, int *mode)
+static int _query_resource(const char *resource, int *mode)
 #else
-int lock_resource_query(const char *resource, int *mode)
+int query_resource(const char *resource, int *mode)
 #endif
 {
 	int i, status, len, num_responses, saved_errno;
@@ -549,7 +549,7 @@
 int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd)
 {
 	locking->lock_resource = _lock_resource;
-	locking->lock_resource_query = _lock_resource_query;
+	locking->query_resource = _query_resource;
 	locking->fin_locking = _locking_end;
 	locking->reset_locking = _reset_locking;
 	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED;
--- LVM2/lib/locking/external_locking.c	2009/05/20 12:58:04	1.16
+++ LVM2/lib/locking/external_locking.c	2009/05/21 03:04:53	1.17
@@ -89,8 +89,8 @@
 		return 0;
 	}
 
-	if (!(_lock_query_fn = dlsym(_locking_lib, "lock_resource_query")))
-		log_warn("WARNING: %s: _lock_resource_query() missing: "
+	if (!(_lock_query_fn = dlsym(_locking_lib, "query_resource")))
+		log_warn("WARNING: %s: _query_resource() missing: "
 			 "Using inferior activation method.", libname);
 
 	log_verbose("Loaded external locking library %s", libname);
--- LVM2/lib/locking/locking.c	2009/05/20 12:58:04	1.59
+++ LVM2/lib/locking/locking.c	2009/05/21 03:04:53	1.60
@@ -489,13 +489,13 @@
 	if (!locking_is_clustered())
 		return 0;
 
-	if (!_locking.lock_resource_query)
+	if (!_locking.query_resource)
 		return -1;
 
 	/*
 	 * If an error occured, expect that volume is active
 	 */
-	if (!_locking.lock_resource_query(vol, &mode)) {
+	if (!_locking.query_resource(vol, &mode)) {
 		stack;
 		return 1;
 	}
--- LVM2/lib/locking/locking.h	2009/05/19 10:39:00	1.46
+++ LVM2/lib/locking/locking.h	2009/05/21 03:04:53	1.47
@@ -118,9 +118,11 @@
 	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
-#define unlock_release_vg(cmd, vg, vol) do { unlock_vg(cmd, vol); \
-					     vg_release(vg); \
-					} while (0)
+#define unlock_and_release_vg(cmd, vg, vol) \
+	do { \
+		unlock_vg(cmd, vol); \
+		vg_release(vg); \
+	} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
--- LVM2/lib/locking/locking_types.h	2009/05/19 10:39:00	1.16
+++ LVM2/lib/locking/locking_types.h	2009/05/21 03:04:53	1.17
@@ -18,7 +18,7 @@
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
 				 uint32_t flags);
-typedef int (*lock_resource_query_fn) (const char *resource, int *mode);
+typedef int (*query_resource_fn) (const char *resource, int *mode);
 
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
@@ -29,7 +29,7 @@
 struct locking_type {
 	uint32_t flags;
 	lock_resource_fn lock_resource;
-	lock_resource_query_fn lock_resource_query;
+	query_resource_fn query_resource;
 
 	reset_lock_fn reset_locking;
 	fin_lock_fn fin_locking;
--- LVM2/lib/metadata/lv_manip.c	2009/05/20 09:55:34	1.173
+++ LVM2/lib/metadata/lv_manip.c	2009/05/21 03:04:53	1.174
@@ -1503,7 +1503,7 @@
 		if (!set_lv_segment_area_lv(seg, m, sub_lvs[m - old_area_count],
 					    0, status))
 			return_0;
-		lv_set_invisible(sub_lvs[m - old_area_count]);
+		lv_set_hidden(sub_lvs[m - old_area_count]);
 	}
 
 	lv->status |= MIRRORED;
@@ -1982,14 +1982,14 @@
 	log_debug("LV %s in VG %s is now visible.",  lv->name, lv->vg->name);
 }
 
-void lv_set_invisible(struct logical_volume *lv)
+void lv_set_hidden(struct logical_volume *lv)
 {
 	if (!lv_is_visible(lv))
 		return;
 
 	lv->status &= ~VISIBLE_LV;
 
-	log_debug("LV %s in VG %s is now invisible.",  lv->name, lv->vg->name);
+	log_debug("LV %s in VG %s is now hidden.",  lv->name, lv->vg->name);
 }
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
--- LVM2/lib/metadata/metadata-exported.h	2009/05/13 21:29:10	1.73
+++ LVM2/lib/metadata/metadata-exported.h	2009/05/21 03:04:53	1.74
@@ -372,7 +372,7 @@
 int link_lv_to_vg(struct volume_group *vg, struct logical_volume *lv);
 int unlink_lv_from_vg(struct logical_volume *lv);
 void lv_set_visible(struct logical_volume *lv);
-void lv_set_invisible(struct logical_volume *lv);
+void lv_set_hidden(struct logical_volume *lv);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
@@ -442,7 +442,12 @@
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
+/*
+ * vg_release() must be called on every struct volume_group allocated
+ * by vg_create() or vg_read_internal() to free it when no longer required.
+ */
 void vg_release(struct volume_group *vg);
+
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
--- LVM2/lib/metadata/metadata.c	2009/05/20 11:09:49	1.220
+++ LVM2/lib/metadata/metadata.c	2009/05/21 03:04:53	1.221
@@ -2633,12 +2633,12 @@
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
 	if (!vg_check_status(vg, status_flags)) {
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
--- LVM2/lib/metadata/mirror.c	2009/05/13 21:28:31	1.87
+++ LVM2/lib/metadata/mirror.c	2009/05/21 03:04:53	1.88
@@ -303,7 +303,7 @@
 		return 0;
 	}
 
-	lv_set_invisible(log_lv);
+	lv_set_hidden(log_lv);
 
 	if (was_active && !activate_lv(cmd, log_lv))
 		return_0;
@@ -1340,7 +1340,7 @@
 {
 	seg->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	lv_set_invisible(log_lv);
+	lv_set_hidden(log_lv);
 	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
@@ -1466,7 +1466,7 @@
 	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
 					  alloc, mirror_in_sync()))) {
 		stack;
-		goto out_remove_imgs;
+		goto out_remove_images;
 	}
 
 	/* The log initialization involves vg metadata commit.
@@ -1498,7 +1498,7 @@
 			       region_size)) {
 		log_error("Aborting. Failed to add mirror segment. "
 			  "Remove new LV and retry.");
-		goto out_remove_imgs;
+		goto out_remove_images;
 	}
 
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
@@ -1517,7 +1517,7 @@
 		else
 			backup(log_lv->vg);
 	}
-  out_remove_imgs:
+  out_remove_images:
 	alloc_destroy(ah);
 	return 0;
 }
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/13 21:28:31	1.42
+++ LVM2/lib/metadata/snapshot_manip.c	2009/05/21 03:04:53	1.43
@@ -68,7 +68,7 @@
 	seg->origin = origin;
 	seg->cow = cow;
 
-	lv_set_invisible(cow);
+	lv_set_hidden(cow);
 
 	cow->snapshot = seg;
 
--- LVM2/lib/report/columns.h	2009/05/12 19:12:10	1.36
+++ LVM2/lib/report/columns.h	2009/05/21 03:04:53	1.37
@@ -29,18 +29,17 @@
  * 3. Field type.  This must be either 'STR' or 'NUM'.
  * 4. Report heading.  This is the field heading that is displayed by the
  * reporting commands.
- * 5. Data value pointer.  This argument is is always a member of the
- * containing struct.  In some cases, the member points to the data value
- * of the field (for example, lv_uuid - see _uuid_disp()).  In other cases
- * it is pointer that may be used to derive the data value (for example,
- * seg_count - see _lvsegcount_disp()).  In the FIELD macro definition,
- * this is used in an offset calculation to derive the offset to the
- * data value from the containing struct base address.  Note that in some
+ * 5. Data value pointer.  This argument is always a member of the
+ * containing struct.  It may point directly to the data value (for example,
+ * lv_uuid - see _uuid_disp()) or may be used to derive the data value (for
+ * example, seg_count - see _lvsegcount_disp()).  In the FIELD macro
+ * definition, it is used in an offset calculation to derive the offset to
+ * the data value from the containing struct base address.  Note that in some
  * cases, the argument is the first member of the struct, in which case the
  * data value pointer points to the start of the struct itself (for example,
  * 'lvid' field of struct 'lv').
  * 6. Minimum display width.  This is the minimum width used to display
- * the field value.
+ * the field value, typically matching the width of the column heading.
  * 7. Display function identifier.  Used to derive the full name of the
  * function that displays this field.  Derivation is done by appending '_'
  * then prepending this argument to '_disp'.  For example, if this argument
--- LVM2/tools/lvconvert.c	2009/05/19 10:27:47	1.75
+++ LVM2/tools/lvconvert.c	2009/05/21 03:04:53	1.76
@@ -371,56 +371,61 @@
 	if (seg_type(lvseg, s) == AREA_LV) {
 		if (seg_lv(lvseg, s)->status & PARTIAL_LV)
 			return 1;
-	} else if (seg_type(lvseg, s) == AREA_PV) {
-		if (seg_pv(lvseg, s)->status & MISSING_PV)
-			return 1;
-	}
+	} else if ((seg_type(lvseg, s) == AREA_PV) &&
+		   (seg_pv(lvseg, s)->status & MISSING_PV))
+		return 1;
+
 	return 0;
 }
 
 /* FIXME we want to handle mirror stacks here... */
-static int _count_failed_mirrors(struct logical_volume *lv)
+static int _failed_mirrors_count(struct logical_volume *lv)
 {
 	struct lv_segment *lvseg;
 	int ret = 0;
 	int s;
+
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (!seg_is_mirrored(lvseg))
 			return -1;
-		for(s = 0; s < lvseg->area_count; ++s) {
+		for (s = 0; s < lvseg->area_count; s++)
 			if (_area_missing(lvseg, s))
-				++ ret;
-		}
+				ret++;
 	}
+
 	return ret;
 }
 
 static struct dm_list *_failed_pv_list(struct volume_group *vg)
 {
-	struct dm_list *r;
+	struct dm_list *failed_pvs;
 	struct pv_list *pvl, *new_pvl;
 
-	if (!(r = dm_pool_alloc(vg->vgmem, sizeof(*r)))) {
-		log_error("Allocation of list failed");
-		return_0;
+	if (!(failed_pvs = dm_pool_alloc(vg->vgmem, sizeof(*failed_pvs)))) {
+		log_error("Allocation of list of failed_pvs failed.");
+		return_NULL;
 	}
 
-	dm_list_init(r);
+	dm_list_init(failed_pvs);
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvl->pv->status & MISSING_PV))
 			continue;
 
 		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
-			log_error("Unable to allocate physical volume list.");
-			return_0;
+			log_error("Allocation of failed_pvs list entry failed.");
+			return_NULL;
 		}
 		new_pvl->pv = pvl->pv;
-		dm_list_add(r, &new_pvl->list);
+		dm_list_add(failed_pvs, &new_pvl->list);
 	}
-	return r;
+
+	return failed_pvs;
 }
 
-/* walk down the stacked mirror LV to the original mirror LV */
+/*
+ * Walk down the stacked mirror LV to the original mirror LV.
+ */
 static struct logical_volume *_original_lv(struct logical_volume *lv)
 {
 	struct logical_volume *next_lv = lv, *tmp_lv;
@@ -431,8 +436,8 @@
 	return next_lv;
 }
 
-static int lvconvert_mirrors(struct cmd_context * cmd, struct logical_volume * lv,
-			     struct lvconvert_params *lp)
+static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
 {
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
@@ -485,7 +490,7 @@
 			log_error("The mirror is consistent, nothing to repair.");
 			return 0;
 		}
-		if ((failed_mirrors = _count_failed_mirrors(lv)) < 0)
+		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
 			return_0;
 		lp->mirrors -= failed_mirrors;
 		log_error("Mirror status: %d/%d legs failed.",
@@ -828,7 +833,7 @@
 	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
-		if (!lvconvert_mirrors(cmd, lv, lp))
+		if (!_lvconvert_mirrors(cmd, lv, lp))
 			return ECMD_FAILED;
 	}
 
--- LVM2/tools/lvcreate.c	2009/05/13 21:29:10	1.188
+++ LVM2/tools/lvcreate.c	2009/05/21 03:04:53	1.189
@@ -998,6 +998,6 @@
 	if (!_lvcreate(cmd, vg, &lp))
 		r = ECMD_FAILED;
 
-	unlock_release_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
--- LVM2/tools/lvrename.c	2009/04/10 10:01:38	1.49
+++ LVM2/tools/lvrename.c	2009/05/21 03:04:53	1.50
@@ -121,6 +121,6 @@
 
 	r = ECMD_PROCESSED;
 error:
-	unlock_release_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
--- LVM2/tools/lvresize.c	2009/05/20 09:52:37	1.108
+++ LVM2/tools/lvresize.c	2009/05/21 03:04:53	1.109
@@ -681,7 +681,7 @@
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
-	unlock_release_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 
 	return r;
 }
--- LVM2/tools/polldaemon.c	2009/04/10 10:01:38	1.12
+++ LVM2/tools/polldaemon.c	2009/05/21 03:04:53	1.13
@@ -157,17 +157,17 @@
 							     parms->lv_type))) {
 			log_error("ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
-			unlock_release_vg(cmd, vg, vg->name);
+			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
 		if (!_check_mirror_status(cmd, vg, lv_mirr, name, parms,
 					  &finished)) {
-			unlock_release_vg(cmd, vg, vg->name);
+			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
-		unlock_release_vg(cmd, vg, vg->name);
+		unlock_and_release_vg(cmd, vg, vg->name);
 	}
 
 	return 1;
--- LVM2/tools/pvchange.c	2009/04/10 10:01:38	1.65
+++ LVM2/tools/pvchange.c	2009/05/21 03:04:53	1.66
@@ -201,7 +201,7 @@
 	log_print("Physical volume \"%s\" changed", pv_name);
 	r = 1;
 out:
-	unlock_release_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 
 }
--- LVM2/tools/pvmove.c	2009/05/19 09:51:03	1.59
+++ LVM2/tools/pvmove.c	2009/05/21 03:04:53	1.60
@@ -459,7 +459,7 @@
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:
-	unlock_release_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
 
--- LVM2/tools/toollib.c	2009/04/25 01:18:00	1.152
+++ LVM2/tools/toollib.c	2009/05/21 03:04:53	1.153
@@ -319,7 +319,7 @@
 		}
 
 		if (!vg_check_status(vg, CLUSTERED)) {
-			unlock_release_vg(cmd, vg, vgname);
+			unlock_and_release_vg(cmd, vg, vgname);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
 			continue;
@@ -350,7 +350,7 @@
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
 					    handle, process_single);
-		unlock_release_vg(cmd, vg, vgname);
+		unlock_and_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -469,7 +469,7 @@
 	}
 
 	if (!vg_check_status(vg, CLUSTERED)) {
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -477,7 +477,7 @@
 		/* Only process if a tag matches or it's on arg_vgnames */
 		if (!str_list_match_item(arg_vgnames, vg_name) &&
 		    !str_list_match_list(tags, &vg->tags)) {
-			unlock_release_vg(cmd, vg, vg_name);
+			unlock_and_release_vg(cmd, vg, vg_name);
 			return ret_max;
 		}
 	}
@@ -487,7 +487,7 @@
 		ret_max = ret;
 	}
 
-	unlock_release_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 
 	return ret_max;
 }
@@ -771,12 +771,12 @@
 					continue;
 				}
 				if (!consistent) {
-					unlock_release_vg(cmd, vg, sll->str);
+					unlock_and_release_vg(cmd, vg, sll->str);
 					continue;
 				}
 
 				if (!vg_check_status(vg, CLUSTERED)) {
-					unlock_release_vg(cmd, vg, sll->str);
+					unlock_and_release_vg(cmd, vg, sll->str);
 					continue;
 				}
 
@@ -784,7 +784,7 @@
 							    handle,
 							    process_single);
 
-				unlock_release_vg(cmd, vg, sll->str);
+				unlock_and_release_vg(cmd, vg, sll->str);
 
 				if (ret > ret_max)
 					ret_max = ret;
--- LVM2/tools/vgchange.c	2009/05/13 21:27:44	1.71
+++ LVM2/tools/vgchange.c	2009/05/21 03:04:53	1.72
@@ -532,7 +532,7 @@
 	}
 
 	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
--- LVM2/tools/vgconvert.c	2009/04/10 10:01:39	1.33
+++ LVM2/tools/vgconvert.c	2009/05/21 03:04:53	1.34
@@ -38,7 +38,7 @@
 	}
 
 	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
--- LVM2/tools/vgextend.c	2009/05/13 13:02:56	1.39
+++ LVM2/tools/vgextend.c	2009/05/21 03:04:53	1.40
@@ -76,7 +76,7 @@
 	r = ECMD_PROCESSED;
 
 error:
-	unlock_release_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
 	return r;
 }
--- LVM2/tools/vgmerge.c	2009/05/13 21:22:57	1.54
+++ LVM2/tools/vgmerge.c	2009/05/21 03:04:54	1.55
@@ -38,7 +38,7 @@
 					 LCK_VG_WRITE,
 					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
 					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
 
@@ -116,8 +116,8 @@
 		  vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
 bad:
-	unlock_release_vg(cmd, vg_from, vg_name_from);
-	unlock_release_vg(cmd, vg_to, vg_name_to);
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	unlock_and_release_vg(cmd, vg_to, vg_name_to);
 	return r;
 }
 
--- LVM2/tools/vgreduce.c	2009/05/13 13:02:56	1.90
+++ LVM2/tools/vgreduce.c	2009/05/21 03:04:54	1.91
@@ -454,7 +454,7 @@
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
 	r = ECMD_PROCESSED;
 bad:
-	unlock_release_vg(cmd, orphan_vg, VG_ORPHANS);
+	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }
 
@@ -574,7 +574,7 @@
 
 	}
 out:
-	unlock_release_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 
 	return ret;
 
--- LVM2/tools/vgrename.c	2009/05/13 13:02:56	1.61
+++ LVM2/tools/vgrename.c	2009/05/21 03:04:54	1.62
@@ -83,7 +83,7 @@
 	}
 
 	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
-		unlock_release_vg(cmd, vg, vg_name_old);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
 		return 0;
 	}
 
@@ -91,7 +91,7 @@
 	vg_check_status(vg, EXPORTED_VG);
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
-		unlock_release_vg(cmd, vg, vg_name_old);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
 		/* FIXME Remove this restriction */
@@ -101,7 +101,7 @@
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
 	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE)) {
-		unlock_release_vg(cmd, vg, vg_name_old);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
 	}
@@ -151,8 +151,8 @@
 	backup(vg);
 	backup_remove(cmd, vg_name_old);
 
-	unlock_release_vg(cmd, vg_new, vg_name_new);
-	unlock_release_vg(cmd, vg, vg_name_old);
+	unlock_and_release_vg(cmd, vg_new, vg_name_new);
+	unlock_and_release_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
 		  vg_name_old, vg_name_new);
@@ -164,8 +164,8 @@
 	return 1;
 
       error:
-	unlock_release_vg(cmd, vg_new, vg_name_new);
-	unlock_release_vg(cmd, vg, vg_name_old);
+	unlock_and_release_vg(cmd, vg_new, vg_name_new);
+	unlock_and_release_vg(cmd, vg, vg_name_old);
 	return 0;
 }
 
--- LVM2/tools/vgscan.c	2009/04/10 10:01:39	1.31
+++ LVM2/tools/vgscan.c	2009/05/21 03:04:54	1.32
@@ -25,7 +25,7 @@
 	}
 
 	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		/* Don't allow partial switch to this program */
--- LVM2/tools/vgsplit.c	2009/05/13 21:22:57	1.73
+++ LVM2/tools/vgsplit.c	2009/05/21 03:04:54	1.74
@@ -323,7 +323,7 @@
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vg_name_to);
-		unlock_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
 
@@ -466,7 +466,7 @@
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_release_vg(cmd, vg_from, vg_name_from);
-	unlock_release_vg(cmd, vg_to, vg_name_to);
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	unlock_and_release_vg(cmd, vg_to, vg_name_to);
 	return r;
 }


