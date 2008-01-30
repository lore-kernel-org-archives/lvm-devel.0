From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jan 2008 13:19:56 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20080130131956.17434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-30 13:19:47

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c fs.c 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c 
	lib/datastruct : btree.c str_list.c 
	lib/device     : dev-cache.c dev-io.c device.c 
	lib/display    : display.c 
	lib/filters    : filter-composite.c filter-persistent.c 
	                 filter-regex.c filter.c 
	lib/format1    : disk-rep.c format1.c import-export.c 
	                 import-extents.c layout.c lvm1-label.c 
	                 vg_number.c 
	lib/format_pool: disk_rep.c format_pool.c import_export.c 
	lib/format_text: archive.c archiver.c export.c flags.c 
	                 format-text.c import.c import_vsn1.c tags.c 
	lib/label      : label.c 
	lib/locking    : external_locking.c 
	lib/metadata   : lv_manip.c merge.c metadata.c mirror.c 
	                 pv_manip.c pv_map.c snapshot_manip.c 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : lvchange.c lvconvert.c lvcreate.c lvmcmdline.c 
	                 lvresize.c pvchange.c pvmove.c pvresize.c 
	                 toollib.c vgmerge.c vgreduce.c 

Log message:
	Use stack return macros throughout.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.782&r2=1.783
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-composite.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/layout.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/vg_number.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2008/01/29 23:45:47	1.782
+++ LVM2/WHATS_NEW	2008/01/30 13:19:43	1.783
@@ -1,5 +1,6 @@
 Version 2.02.33 -
 ===================================
+  Use stack return macros throughout.
   Rely upon internally-cached PV labels while corresponding VG lock is held.
 
 Version 2.02.32 - 29th January 2008
--- LVM2/lib/activate/dev_manager.c	2008/01/08 16:47:10	1.132
+++ LVM2/lib/activate/dev_manager.c	2008/01/30 13:19:44	1.133
@@ -100,10 +100,8 @@
 {
 	struct dm_task *dmt;
 
-	if (!(dmt = dm_task_create(task))) {
-		stack;
-		return NULL;
-	}
+	if (!(dmt = dm_task_create(task)))
+		return_NULL;
 
 	if (name)
 		dm_task_set_name(dmt, name);
@@ -127,10 +125,8 @@
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
 
-	if (!(dmt = _setup_task(name, dlid, 0, dmtask))) {
-		stack;
-		return 0;
-	}
+	if (!(dmt = _setup_task(name, dlid, 0, dmtask)))
+		return_0;
 
 	if (!with_open_count)
 		if (!dm_task_no_open_count(dmt))
@@ -259,10 +255,8 @@
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS))) {
-		stack;
-		return 0;
-	}
+	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS)))
+		return_0;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
@@ -348,10 +342,8 @@
 	*percent = -1;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS))) {
-		stack;
-		return 0;
-	}
+				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS)))
+		return_0;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
@@ -443,10 +435,8 @@
 	struct dm_pool *mem;
 	struct dev_manager *dm;
 
-	if (!(mem = dm_pool_create("dev_manager", 16 * 1024))) {
-		stack;
-		return NULL;
-	}
+	if (!(mem = dm_pool_create("dev_manager", 16 * 1024)))
+		return_NULL;
 
 	if (!(dm = dm_pool_alloc(mem, sizeof(*dm))))
 		goto_bad;
@@ -509,10 +499,8 @@
 	 */
 	log_debug("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
-		       NULL))) {
-		stack;
-		return 0;
-	}
+		       NULL)))
+		return_0;
 
 	/* FIXME dm_pool_free ? */
 
@@ -544,10 +532,8 @@
 
 	log_debug("Getting device mirror status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       event_nr))) {
-		stack;
-		return 0;
-	}
+		       event_nr)))
+		return_0;
 
 	return 1;
 }
@@ -691,31 +677,25 @@
 		return NULL;
 	}
 
-	if (!_add_lv_to_dtree(dm, dtree, lv)) {
-		stack;
-		goto fail;
-	}
+	if (!_add_lv_to_dtree(dm, dtree, lv))
+		goto_bad;
 
 	/* Add any snapshots of this LV */
 	list_iterate_safe(snh, snht, &lv->snapshot_segs)
-		if (!_add_lv_to_dtree(dm, dtree, list_struct_base(snh, struct lv_segment, origin_list)->cow)) {
-			stack;
-			goto fail;
-		}
+		if (!_add_lv_to_dtree(dm, dtree, list_struct_base(snh, struct lv_segment, origin_list)->cow))
+			goto_bad;
 
 	/* Add any LVs used by segments in this LV */
 	list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
-				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s))) {
-					stack;
-					goto fail;
-				}
+				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s)))
+					goto_bad;
 			}
 
 	return dtree;
 
-fail:
+bad:
 	dm_tree_free(dtree);
 	return NULL;
 }
--- LVM2/lib/activate/fs.c	2007/08/20 20:55:24	1.40
+++ LVM2/lib/activate/fs.c	2008/01/30 13:19:44	1.41
@@ -175,10 +175,8 @@
 	}
 
 #ifdef HAVE_SELINUX
-        if (!dm_set_selinux_context(lv_path, S_IFLNK)) {
-                stack;
-                return 0;
-        }
+        if (!dm_set_selinux_context(lv_path, S_IFLNK))
+                return_0;
 #endif
 
 	return 1;
@@ -225,17 +223,13 @@
 	switch (type) {
 	case FS_ADD:
 		if (!_mk_dir(dev_dir, vg_name) ||
-		    !_mk_link(dev_dir, vg_name, lv_name, dev)) {
-			stack;
-			return 0;
-		}
+		    !_mk_link(dev_dir, vg_name, lv_name, dev))
+			return_0;
 		break;
 	case FS_DEL:
 		if (!_rm_link(dev_dir, vg_name, lv_name) ||
-		    !_rm_dir(dev_dir, vg_name)) {
-			stack;
-			return 0;
-		}
+		    !_rm_dir(dev_dir, vg_name))
+			return_0;
 		break;
 		/* FIXME Use rename() */
 	case FS_RENAME:
@@ -316,10 +310,8 @@
 {
 	if (memlock()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
-				  old_lv_name)) {
-			stack;
-			return 0;
-		}
+				  old_lv_name))
+			return_0;
 		return 1;
 	}
 
--- LVM2/lib/cache/lvmcache.c	2008/01/29 23:45:47	1.34
+++ LVM2/lib/cache/lvmcache.c	2008/01/30 13:19:44	1.35
@@ -803,10 +803,8 @@
 
 	if (!(existing = info_from_pvid(pvid_s, 0)) &&
 	    !(existing = info_from_pvid(dev->pvid, 0))) {
-		if (!(label = label_create(labeller))) {
-			stack;
-			return NULL;
-		}
+		if (!(label = label_create(labeller)))
+			return_NULL;
 		if (!(info = dm_malloc(sizeof(*info)))) {
 			log_error("lvmcache_info allocation failed");
 			label_destroy(label);
@@ -862,11 +860,9 @@
 		/* Has labeller changed? */
 		if (info->label->labeller != labeller) {
 			label_destroy(info->label);
-			if (!(info->label = label_create(labeller))) {
+			if (!(info->label = label_create(labeller)))
 				/* FIXME leaves info without label! */
-				stack;
-				return NULL;
-			}
+				return_NULL;
 			info->label->info = info;
 		}
 		label = info->label;
--- LVM2/lib/commands/toolcontext.c	2007/11/09 16:51:53	1.55
+++ LVM2/lib/commands/toolcontext.c	2008/01/30 13:19:44	1.56
@@ -282,10 +282,8 @@
 	if (!cmd->hosttags && find_config_int(cft->root, "tags/hosttags",
 					      DEFAULT_HOSTTAGS)) {
 		/* FIXME Strip out invalid chars: only A-Za-z0-9_+.- */
-		if (!_set_tag(cmd, cmd->hostname)) {
-			stack;
-			return 0;
-		}
+		if (!_set_tag(cmd, cmd->hostname))
+			return_0;
 		cmd->hosttags = 1;
 	}
 
@@ -301,17 +299,13 @@
 		}
 		if (cn->child) {
 			passes = 0;
-			if (!_check_host_filters(cmd, cn->child, &passes)) {
-				stack;
-				return 0;
-			}
+			if (!_check_host_filters(cmd, cn->child, &passes))
+				return_0;
 			if (!passes)
 				continue;
 		}
-		if (!_set_tag(cmd, tag)) {
-			stack;
-			return 0;
-		}
+		if (!_set_tag(cmd, tag))
+			return_0;
 	}
 
 	return 1;
@@ -385,10 +379,8 @@
 		return 1;
 	}
 
-	if (!_load_config_file(cmd, "")) {
-		stack;
-		return 0;
-	}
+	if (!_load_config_file(cmd, ""))
+		return_0;
 
 	return 1;
 }
@@ -400,11 +392,8 @@
 
 	/* Tag list may grow while inside this loop */
 	list_iterate_items(sl, &cmd->tags) {
-		if (!_load_config_file(cmd, sl->str)) {
-			stack;
-			return 0;
-		}
-
+		if (!_load_config_file(cmd, sl->str))
+			return_0;
 	}
 
 	return 1;
@@ -424,10 +413,8 @@
 
 	list_iterate_items(cfl, &cmd->config_files) {
 		/* Merge all config trees into cmd->cft using merge/tag rules */
-		if (!merge_config_tree(cmd, cmd->cft, cfl->cft)) {
-			stack;
-			return 0;
-		}
+		if (!merge_config_tree(cmd, cmd->cft, cfl->cft))
+			return_0;
 	}
 
 	return 1;
@@ -694,10 +681,8 @@
 				return 0;
 			}
 			if (!(lib = load_shared_library(cmd, cv->v.str,
-							"format", 0))) {
-				stack;
-				return 0;
-			}
+							"format", 0)))
+				return_0;
 
 			if (!(init_format_fn = dlsym(lib, "init_format"))) {
 				log_error("Shared library %s does not contain "
@@ -790,10 +775,8 @@
 				return 0;
 			}
 			if (!(lib = load_shared_library(cmd, cv->v.str,
-							"segment type", 0))) {
-				stack;
-				return 0;
-			}
+							"segment type", 0)))
+				return_0;
 
 			if (!(init_segtype_fn = dlsym(lib, "init_segtype"))) {
 				log_error("Shared library %s does not contain "
--- LVM2/lib/config/config.c	2007/08/22 14:38:15	1.65
+++ LVM2/lib/config/config.c	2008/01/30 13:19:44	1.66
@@ -196,10 +196,8 @@
 	off_t mmap_offset = 0;
 	char *buf = NULL;
 
-	if (!(p = dm_pool_alloc(c->mem, sizeof(*p)))) {
-		stack;
-		return 0;
-	}
+	if (!(p = dm_pool_alloc(c->mem, sizeof(*p))))
+		return_0;
 	p->mem = c->mem;
 
 	/* Only use mmap with regular files */
@@ -217,10 +215,8 @@
 		}
 		p->fb = p->fb + mmap_offset;
 	} else {
-		if (!(buf = dm_malloc(size + size2))) {
-			stack;
-			return 0;
-		}
+		if (!(buf = dm_malloc(size + size2)))
+			return_0;
 		if (!dev_read_circular(dev, (uint64_t) offset, size,
 				       (uint64_t) offset2, size2, buf)) {
 			goto out;
@@ -237,10 +233,8 @@
 
 	p->fe = p->fb + size + size2;
 
-	if (!_parse_config_file(p, cft)) {
-		stack;
-		goto out;
-	}
+	if (!_parse_config_file(p, cft))
+		goto_out;
 
 	r = 1;
 
@@ -537,10 +531,8 @@
 {
 	struct config_node *root = NULL, *n, *l = NULL;
 	while (p->t != TOK_EOF) {
-		if (!(n = _section(p))) {
-			stack;
-			return 0;
-		}
+		if (!(n = _section(p)))
+			return_0;
 
 		if (!root)
 			root = n;
@@ -555,25 +547,19 @@
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct config_node *root, *n, *l = NULL;
-	if (!(root = _create_node(p))) {
-		stack;
-		return 0;
-	}
+	if (!(root = _create_node(p)))
+		return_0;
 
-	if (!(root->key = _dup_tok(p))) {
-		stack;
-		return 0;
-	}
+	if (!(root->key = _dup_tok(p)))
+		return_0;
 
 	match(TOK_IDENTIFIER);
 
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);
 		while (p->t != TOK_SECTION_E) {
-			if (!(n = _section(p))) {
-				stack;
-				return 0;
-			}
+			if (!(n = _section(p)))
+				return_0;
 
 			if (!root->child)
 				root->child = n;
@@ -584,10 +570,8 @@
 		match(TOK_SECTION_E);
 	} else {
 		match(TOK_EQ);
-		if (!(root->v = _value(p))) {
-			stack;
-			return 0;
-		}
+		if (!(root->v = _value(p)))
+			return_0;
 	}
 
 	return root;
@@ -600,10 +584,8 @@
 	if (p->t == TOK_ARRAY_B) {
 		match(TOK_ARRAY_B);
 		while (p->t != TOK_ARRAY_E) {
-			if (!(l = _type(p))) {
-				stack;
-				return 0;
-			}
+			if (!(l = _type(p)))
+				return_0;
 
 			if (!h)
 				h = l;
@@ -656,10 +638,8 @@
 		v->type = CFG_STRING;
 
 		p->tb++, p->te--;	/* strip "'s */
-		if (!(v->v.str = _dup_tok(p))) {
-			stack;
-			return 0;
-		}
+		if (!(v->v.str = _dup_tok(p)))
+			return_0;
 		p->te++;
 		match(TOK_STRING);
 		break;
@@ -847,10 +827,8 @@
 {
 	size_t len = p->te - p->tb;
 	char *str = dm_pool_alloc(p->mem, len + 1);
-	if (!str) {
-		stack;
-		return 0;
-	}
+	if (!str)
+		return_0;
 	strncpy(str, p->tb, len);
 	str[len] = '\0';
 	return str;
--- LVM2/lib/datastruct/btree.c	2007/08/20 20:55:24	1.11
+++ LVM2/lib/datastruct/btree.c	2008/01/30 13:19:44	1.12
@@ -87,10 +87,8 @@
 	struct node *p, **c = _lookup(&t->root, key, &p), *n;
 
 	if (!*c) {
-		if (!(n = dm_pool_alloc(t->mem, sizeof(*n)))) {
-			stack;
-			return 0;
-		}
+		if (!(n = dm_pool_alloc(t->mem, sizeof(*n))))
+			return_0;
 
 		n->key = key;
 		n->data = data;
--- LVM2/lib/datastruct/str_list.c	2007/09/17 16:02:46	1.9
+++ LVM2/lib/datastruct/str_list.c	2008/01/30 13:19:44	1.10
@@ -20,10 +20,8 @@
 {
 	struct list *sl;
 
-	if (!(sl = dm_pool_alloc(mem, sizeof(struct list)))) {
-		stack;
-		return NULL;
-	}
+	if (!(sl = dm_pool_alloc(mem, sizeof(struct list))))
+		return_NULL;
 
 	list_init(sl);
 
@@ -34,19 +32,15 @@
 {
 	struct str_list *sln;
 
-	if (!str) {
-		stack;
-		return 0;
-	}
+	if (!str)
+		return_0;
 
 	/* Already in list? */
 	if (str_list_match_item(sll, str))
 		return 1;
 
-	if (!(sln = dm_pool_alloc(mem, sizeof(*sln)))) {
-		stack;
-		return 0;
-	}
+	if (!(sln = dm_pool_alloc(mem, sizeof(*sln))))
+		return_0;
 
 	sln->str = str;
 	list_add(sll, &sln->list);
@@ -74,10 +68,8 @@
 	list_init(sllnew);
 
 	list_iterate_items(sl, sllold) {
-		if (!str_list_add(mem, sllnew, dm_pool_strdup(mem, sl->str))) {
-			stack;
-			return 0;
-		}
+		if (!str_list_add(mem, sllnew, dm_pool_strdup(mem, sl->str)))
+			return_0;
 	}
 
 	return 1;
--- LVM2/lib/device/dev-cache.c	2007/08/20 20:55:25	1.50
+++ LVM2/lib/device/dev-cache.c	2008/01/30 13:19:44	1.51
@@ -236,10 +236,8 @@
 	const char *oldpath;
 	int prefer_old = 1;
 
-	if (!sl) {
-		stack;
-		return 0;
-	}
+	if (!sl)
+		return_0;
 
 	/* Is name already there? */
 	list_iterate_items(strl, &dev->aliases) {
@@ -249,10 +247,8 @@
 		}
 	}
 
-	if (!(sl->str = dm_pool_strdup(_cache.mem, path))) {
-		stack;
-		return 0;
-	}
+	if (!(sl->str = dm_pool_strdup(_cache.mem, path)))
+		return_0;
 
 	if (!list_empty(&dev->aliases)) {
 		oldpath = list_item(dev->aliases.n, struct str_list)->str;
@@ -294,14 +290,10 @@
 						   (uint32_t) d))) {
 		/* create new device */
 		if (loopfile) {
-			if (!(dev = dev_create_file(path, NULL, NULL, 0))) {
-				stack;
-				return 0;
-			}
-		} else if (!(dev = _dev_create(d))) {
-			stack;
-			return 0;
-		}
+			if (!(dev = dev_create_file(path, NULL, NULL, 0)))
+				return_0;
+		} else if (!(dev = _dev_create(d)))
+			return_0;
 
 		if (!(btree_insert(_cache.devices, (uint32_t) d, dev))) {
 			log_err("Couldn't insert device into binary tree.");
@@ -369,10 +361,8 @@
 				continue;
 			}
 
-			if (!(path = _join(dir, dirent[n]->d_name))) {
-				stack;
-				return 0;
-			}
+			if (!(path = _join(dir, dirent[n]->d_name)))
+				return_0;
 
 			_collapse_slashes(path);
 			r &= _insert(path, 1);
@@ -400,10 +390,8 @@
 		return 0;
 	}
 
-	if (!_insert_dev(path, 0)) {
-		stack;
-		return 0;
-	}
+	if (!_insert_dev(path, 0))
+		return_0;
 
 	return 1;
 }
@@ -439,10 +427,8 @@
 			return 0;
 		}
 
-		if (!_insert_dev(path, info.st_rdev)) {
-			stack;
-			return 0;
-		}
+		if (!_insert_dev(path, info.st_rdev))
+			return_0;
 
 		r = 1;
 	}
@@ -543,16 +529,13 @@
 	_cache.names = NULL;
 	_cache.has_scanned = 0;
 
-	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024))) {
-		stack;
-		return 0;
-	}
+	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
+		return_0;
 
 	if (!(_cache.names = dm_hash_create(128))) {
-		stack;
 		dm_pool_destroy(_cache.mem);
 		_cache.mem = 0;
-		return 0;
+		return_0;
 	}
 
 	if (!(_cache.devices = btree_create(_cache.mem))) {
--- LVM2/lib/device/dev-io.c	2008/01/29 23:45:47	1.60
+++ LVM2/lib/device/dev-io.c	2008/01/30 13:19:44	1.61
@@ -170,10 +170,8 @@
 	struct device_area widened;
 
 	if (!(where->dev->flags & DEV_REGULAR) &&
-	    !_get_block_size(where->dev, &block_size)) {
-		stack;
-		return 0;
-	}
+	    !_get_block_size(where->dev, &block_size))
+		return_0;
 
 	if (!block_size)
 		block_size = lvm_getpagesize();
@@ -200,10 +198,8 @@
 
 	/* channel the io through the bounce buffer */
 	if (!_io(&widened, bounce, 0)) {
-		if (!should_write) {
-			stack;
-			return 0;
-		}
+		if (!should_write)
+			return_0;
 		/* FIXME pre-extend the file */
 		memset(bounce, '\n', widened.size);
 	}
@@ -354,10 +350,8 @@
 
 	if (dev->flags & DEV_REGULAR)
 		name = dev_name(dev);
-	else if (!(name = dev_name_confirmed(dev, quiet))) {
-		stack;
-		return 0;
-	}
+	else if (!(name = dev_name_confirmed(dev, quiet)))
+		return_0;
 
 	if (!(dev->flags & DEV_REGULAR)) {
 		if (stat(name, &buf) < 0) {
@@ -557,10 +551,8 @@
 {
 	struct device_area where;
 
-	if (!dev->open_count) {
-		stack;
-		return 0;
-	}
+	if (!dev->open_count)
+		return_0;
 
 	where.dev = dev;
 	where.start = offset;
@@ -607,10 +599,8 @@
 {
 	int r;
 
-	if (!dev->open_count) {
-		stack;
-		return 0;
-	}
+	if (!dev->open_count)
+		return_0;
 
 	r = dev_write(dev, dev->end, len, buffer);
 	dev->end += (uint64_t) len;
@@ -625,10 +615,8 @@
 {
 	struct device_area where;
 
-	if (!dev->open_count) {
-		stack;
-		return 0;
-	}
+	if (!dev->open_count)
+		return_0;
 
 	where.dev = dev;
 	where.start = offset;
@@ -644,10 +632,8 @@
 	size_t s;
 	char buffer[4096] __attribute((aligned(8)));
 
-	if (!dev_open(dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(dev))
+		return_0;
 
 	if ((offset % SECTOR_SIZE) || (len % SECTOR_SIZE))
 		log_debug("Wiping %s at %" PRIu64 " length %" PRIsize_t,
--- LVM2/lib/device/device.c	2007/08/20 20:55:25	1.24
+++ LVM2/lib/device/device.c	2008/01/30 13:19:44	1.25
@@ -62,10 +62,8 @@
 		return -1;
 	}
 
-	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf)) {
-		stack;
-		goto out;
-	}
+	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
+		goto_out;
 
 	/* FIXME Check for other types of partition table too */
 
--- LVM2/lib/display/display.c	2007/11/12 20:51:53	1.83
+++ LVM2/lib/display/display.c	2008/01/30 13:19:44	1.84
@@ -360,10 +360,8 @@
 	if (!pv)
 		return 0;
 
-	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
+		return_0;
 
 	log_print("PV Name               %s     ", pv_dev_name(pv));
 	/* FIXME  pv->pv_number); */
@@ -407,10 +405,8 @@
 	struct lv_segment *snap_seg = NULL;
 	float snap_percent;	/* fused, fsize; */
 
-	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
+		return_0;
 
 	inkernel = lv_info(cmd, lv, &info, 1, 1) && info.exists;
 
--- LVM2/lib/filters/filter-composite.c	2007/08/20 20:55:25	1.13
+++ LVM2/lib/filters/filter-composite.c	2008/01/30 13:19:45	1.14
@@ -50,10 +50,8 @@
 {
 	struct dev_filter **filters_copy, *cft;
 
-	if (!filters) {
-		stack;
-		return NULL;
-	}
+	if (!filters)
+		return_NULL;
 
 	if (!(filters_copy = dm_malloc(sizeof(*filters) * (n + 1)))) {
 		log_error("composite filters allocation failed");
--- LVM2/lib/filters/filter-persistent.c	2007/08/20 20:55:25	1.33
+++ LVM2/lib/filters/filter-persistent.c	2008/01/30 13:19:45	1.34
@@ -42,10 +42,8 @@
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
 
-	if (!(pf->devices = dm_hash_create(128))) {
-		stack;
-		return 0;
-	}
+	if (!(pf->devices = dm_hash_create(128)))
+		return_0;
 
 	return 1;
 }
@@ -293,10 +291,8 @@
 	struct pfilter *pf;
 	struct dev_filter *f = NULL;
 
-	if (!(pf = dm_malloc(sizeof(*pf)))) {
-		stack;
-		return NULL;
-	}
+	if (!(pf = dm_malloc(sizeof(*pf))))
+		return_NULL;
 	memset(pf, 0, sizeof(*pf));
 
 	if (!(pf->file = dm_malloc(strlen(file) + 1)))
--- LVM2/lib/filters/filter-regex.c	2007/08/20 20:55:25	1.23
+++ LVM2/lib/filters/filter-regex.c	2008/01/30 13:19:45	1.24
@@ -70,10 +70,8 @@
 	/*
 	 * copy the regex
 	 */
-	if (!(r = dm_pool_strdup(mem, pat))) {
-		stack;
-		return 0;
-	}
+	if (!(r = dm_pool_strdup(mem, pat)))
+		return_0;
 
 	/*
 	 * trim the trailing character, having checked it's sep.
@@ -192,10 +190,8 @@
 	struct rfilter *rf;
 	struct dev_filter *f;
 
-	if (!mem) {
-		stack;
-		return NULL;
-	}
+	if (!mem)
+		return_NULL;
 
 	if (!(rf = dm_pool_alloc(mem, sizeof(*rf))))
 		goto_bad;
--- LVM2/lib/filters/filter.c	2007/08/22 14:38:16	1.43
+++ LVM2/lib/filters/filter.c	2008/01/30 13:19:45	1.44
@@ -277,9 +277,8 @@
 	f->private = NULL;
 
 	if (!_scan_proc_dev(proc, cn)) {
-		stack;
 		dm_free(f);
-		return NULL;
+		return_NULL;
 	}
 
 	return f;
--- LVM2/lib/format1/disk-rep.c	2007/11/02 20:40:04	1.70
+++ LVM2/lib/format1/disk-rep.c	2008/01/30 13:19:45	1.71
@@ -21,7 +21,6 @@
 
 #include <fcntl.h>
 
-#define fail do {stack; return 0;} while(0)
 #define xx16(v) disk->v = xlate16(disk->v)
 #define xx32(v) disk->v = xlate32(disk->v)
 #define xx64(v) disk->v = xlate64(disk->v)
@@ -218,7 +217,7 @@
 static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 {
 	if (!dev_read(dev, pos, sizeof(*disk), disk))
-		fail;
+		return_0;
 
 	_xlate_lvd(disk);
 
@@ -230,12 +229,12 @@
 	uint64_t pos = pvd->vg_on_disk.base;
 
 	if (!dev_read(dev, pos, sizeof(*vgd), vgd))
-		fail;
+		return_0;
 
 	_xlate_vgd(vgd);
 
 	if ((vgd->lv_max > MAX_LV) || (vgd->pv_max > MAX_PV))
-		fail;
+		return_0;
 		
 	/* If UUID is missing, create one */
 	if (vgd->vg_uuid[0] == '\0')
@@ -254,10 +253,10 @@
 
 	while (pos < end && num_read < data->vgd.pv_cur) {
 		if (!dev_read(data->dev, pos, sizeof(buffer), buffer))
-			fail;
+			return_0;
 
 		if (!(ul = dm_pool_alloc(data->mem, sizeof(*ul))))
-			fail;
+			return_0;
 
 		memcpy(ul->uuid, buffer, NAME_LEN);
 		ul->uuid[NAME_LEN - 1] = '\0';
@@ -288,10 +287,10 @@
 		ll = dm_pool_alloc(data->mem, sizeof(*ll));
 
 		if (!ll)
-			fail;
+			return_0;
 
 		if (!_read_lvd(data->dev, pos, &ll->lvd))
-			fail;
+			return_0;
 
 		if (!_check_lvd(&ll->lvd))
 			continue;
@@ -310,10 +309,10 @@
 	uint64_t pos = data->pvd.pe_on_disk.base;
 
 	if (!extents)
-		fail;
+		return_0;
 
 	if (!dev_read(data->dev, pos, len, extents))
-		fail;
+		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
 	data->extents = extents;
@@ -347,10 +346,8 @@
 	struct disk_list *dl = dm_pool_zalloc(mem, sizeof(*dl));
 	const char *name = dev_name(dev);
 
-	if (!dl) {
-		stack;
-		return NULL;
-	}
+	if (!dl)
+		return_NULL;
 
 	dl->dev = dev;
 	dl->mem = mem;
@@ -417,10 +414,8 @@
 {
 	struct disk_list *dl;
 
-	if (!dev_open(dev)) {
-		stack;
-		return NULL;
-	}
+	if (!dev_open(dev))
+		return_NULL;
 
 	dl = __read_disk(fmt, dev, mem, vg_name);
 
@@ -519,7 +514,7 @@
 
 	_xlate_vgd(vgd);
 	if (!dev_write(data->dev, pos, sizeof(*vgd), vgd))
-		fail;
+		return_0;
 
 	_xlate_vgd(vgd);
 
@@ -544,7 +539,7 @@
 			  pos, NAME_LEN);
 
 		if (!dev_write(data->dev, pos, NAME_LEN, ul->uuid))
-			fail;
+			return_0;
 
 		pos += NAME_LEN;
 	}
@@ -560,7 +555,7 @@
 
 	_xlate_lvd(disk);
 	if (!dev_write(dev, pos, sizeof(*disk), disk))
-		fail;
+		return_0;
 
 	_xlate_lvd(disk);
 
@@ -588,7 +583,7 @@
 		}
 
 		if (!_write_lvd(data->dev, pos + offset, &ll->lvd))
-			fail;
+			return_0;
 	}
 
 	return 1;
@@ -606,7 +601,7 @@
 
 	_xlate_extents(extents, data->pvd.pe_total);
 	if (!dev_write(data->dev, pos, len, extents))
-		fail;
+		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
 
@@ -643,7 +638,7 @@
 	_xlate_pvd((struct pv_disk *) buf);
 	if (!dev_write(data->dev, pos, size, buf)) {
 		dm_free(buf);
-		fail;
+		return_0;
 	}
 
 	dm_free(buf);
@@ -707,10 +702,8 @@
 {
 	int r;
 
-	if (!dev_open(data->dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(data->dev))
+		return_0;
 
 	r = __write_all_pvd(fmt, data);
 
@@ -731,7 +724,7 @@
 
 	list_iterate_items(dl, pvs) {
 		if (!(_write_all_pvd(fmt, dl)))
-			fail;
+			return_0;
 
 		log_very_verbose("Successfully wrote data to %s",
 				 dev_name(dl->dev));
--- LVM2/lib/format1/format1.c	2007/11/09 16:51:53	1.103
+++ LVM2/lib/format1/format1.c	2008/01/30 13:19:45	1.104
@@ -168,7 +168,6 @@
 	return vg;
 
       bad:
-	stack;
 	dm_pool_free(mem, vg);
 	return NULL;
 }
@@ -182,10 +181,8 @@
 	struct volume_group *vg = NULL;
 	list_init(&pvs);
 
-	if (!mem) {
-		stack;
-		return NULL;
-	}
+	if (!mem)
+		return_NULL;
 
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
@@ -209,10 +206,8 @@
 {
 	struct disk_list *dl = dm_pool_alloc(mem, sizeof(*dl));
 
-	if (!dl) {
-		stack;
-		return NULL;
-	}
+	if (!dl)
+		return_NULL;
 
 	dl->mem = mem;
 	dl->dev = pv->dev;
@@ -224,9 +219,8 @@
 	    !export_vg(&dl->vgd, vg) ||
 	    !export_uuids(dl, vg) ||
 	    !export_lvs(dl, vg, pv, dev_dir) || !calculate_layout(dl)) {
-		stack;
 		dm_pool_free(mem, dl);
-		return NULL;
+		return_NULL;
 	}
 
 	return dl;
@@ -241,10 +235,8 @@
 	struct disk_list *data;
 
 	list_iterate_items(pvl, &vg->pvs) {
-		if (!(data = _flatten_pv(fid, mem, vg, pvl->pv, dev_dir))) {
-			stack;
-			return 0;
-		}
+		if (!(data = _flatten_pv(fid, mem, vg, pvl->pv, dev_dir)))
+			return_0;
 
 		list_add(pvds, &data->list);
 	}
@@ -252,10 +244,8 @@
 	export_numbers(pvds, vg);
 	export_pv_act(pvds);
 
-	if (!export_vg_number(fid, pvds, vg->name, filter)) {
-		stack;
-		return 0;
-	}
+	if (!export_vg_number(fid, pvds, vg->name, filter))
+		return_0;
 
 	return 1;
 }
@@ -267,10 +257,8 @@
 	struct list pvds;
 	int r = 0;
 
-	if (!mem) {
-		stack;
-		return 0;
-	}
+	if (!mem)
+		return_0;
 
 	list_init(&pvds);
 
@@ -293,25 +281,17 @@
 
 	log_very_verbose("Reading physical volume data %s from disk", pv_name);
 
-	if (!mem) {
-		stack;
-		return 0;
-	}
+	if (!mem)
+		return_0;
 
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter))) {
-		stack;
-		goto out;
-	}
+	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
+		goto_out;
 
-	if (!(dl = read_disk(fmt, dev, mem, NULL))) {
-		stack;
-		goto out;
-	}
+	if (!(dl = read_disk(fmt, dev, mem, NULL)))
+		goto_out;
 
-	if (!import_pv(fmt, fmt->cmd->mem, dl->dev, NULL, pv, &dl->pvd, &dl->vgd)) {
-		stack;
-		goto out;
-	}
+	if (!import_pv(fmt, fmt->cmd->mem, dl->dev, NULL, pv, &dl->pvd, &dl->vgd))
+		goto_out;
 
 	pv->fmt = fmt;
 
@@ -344,10 +324,8 @@
 	/*
 	 * This works out pe_start and pe_count.
 	 */
-	if (!calculate_extent_count(pv, extent_size, extent_count, pe_start)) {
-		stack;
-		return 0;
-	}
+	if (!calculate_extent_count(pv, extent_size, extent_count, pe_start))
+		return_0;
 
 	/* Retain existing extent locations exactly */
 	if (((pe_start || extent_count) && (pe_start != pv->pe_start)) ||
@@ -390,10 +368,8 @@
 	struct lvmcache_info *info;
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  pv->vg_name, NULL, 0))) {
-		stack;
-		return 0;
-	}
+				  pv->vg_name, NULL, 0)))
+		return_0;
 	label = info->label;
 	info->device_size = pv->size << SECTOR_SHIFT;
 	info->fmt = fmt;
@@ -406,10 +382,8 @@
 	pv->pe_size = pv->pe_count = 0;
 	pv->pe_start = LVM1_PE_ALIGN;
 
-	if (!(mem = dm_pool_create("lvm1 pv_write", 1024))) {
-		stack;
-		return 0;
-	}
+	if (!(mem = dm_pool_create("lvm1 pv_write", 1024)))
+		return_0;
 
 	if (!(dl = dm_pool_alloc(mem, sizeof(*dl))))
 		goto_bad;
@@ -473,10 +447,8 @@
 static int _format1_segtype_supported(struct format_instance *fid __attribute((unused)), 
 				      const struct segment_type *segtype)
 {
-	if (!(segtype->flags & SEG_FORMAT1_SUPPORT)) {
-		stack;
-		return 0;
-	}
+	if (!(segtype->flags & SEG_FORMAT1_SUPPORT))
+		return_0;
 
 	return 1;
 }
@@ -494,19 +466,16 @@
 	struct format_instance *fid;
 	struct metadata_area *mda;
 
-	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid)))) {
-		stack;
-		return NULL;
-	}
+	if (!(fid = dm_pool_alloc(fmt->cmd->mem, sizeof(*fid))))
+		return_NULL;
 
 	fid->fmt = fmt;
 	list_init(&fid->metadata_areas);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
-		stack;
 		dm_pool_free(fmt->cmd->mem, fid);
-		return NULL;
+		return_NULL;
 	}
 
 	mda->ops = &_metadata_format1_ops;
@@ -547,10 +516,8 @@
 {
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
 
-	if (!fmt) {
-		stack;
-		return NULL;
-	}
+	if (!fmt)
+		return_NULL;
 
 	fmt->cmd = cmd;
 	fmt->ops = &_format1_ops;
--- LVM2/lib/format1/import-export.c	2008/01/16 19:00:59	1.92
+++ LVM2/lib/format1/import-export.c	2008/01/30 13:19:45	1.93
@@ -117,10 +117,8 @@
 	list_init(&pv->tags);
 	list_init(&pv->segments);
 
-	if (!alloc_pv_segment_whole_pv(mem, pv)) {
-		stack;
-		return 0;
-	}
+	if (!alloc_pv_segment_whole_pv(mem, pv))
+		return_0;
 
 	return 1;
 }
@@ -150,10 +148,8 @@
 	memcpy(pvd->pv_uuid, pv->id.uuid, ID_LEN);
 
 	if (pv->vg_name) {
-		if (!_check_vg_name(pv->vg_name)) {
-			stack;
-			return 0;
-		}
+		if (!_check_vg_name(pv->vg_name))
+			return_0;
 		strncpy((char *)pvd->vg_name, pv->vg_name, sizeof(pvd->vg_name));
 	}
 
@@ -167,10 +163,8 @@
 		if (!*vg->system_id ||
 		    strncmp(vg->system_id, EXPORTED_TAG,
 			    sizeof(EXPORTED_TAG) - 1)) {
-			if (!_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG)) {
-				stack;
-				return 0;
-			}
+			if (!_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
+				return_0;
 		}
 		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
 		    sizeof(pvd->vg_name)) {
@@ -184,18 +178,14 @@
 	/* Is VG being imported? */
 	if (vg && !(vg->status & EXPORTED_VG) && *vg->system_id &&
 	    !strncmp(vg->system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
-		if (!_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG)) {
-			stack;
-			return 0;
-		}
+		if (!_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
+			return_0;
 	}
 
 	/* Generate system_id if PV is in VG */
 	if (!pvd->system_id || !*pvd->system_id)
-		if (!_system_id(cmd, (char *)pvd->system_id, "")) {
-			stack;
-			return 0;
-		}
+		if (!_system_id(cmd, (char *)pvd->system_id, ""))
+			return_0;
 
 	/* Update internal system_id if we changed it */
 	if (vg &&
@@ -227,20 +217,14 @@
 	struct vg_disk *vgd = &dl->vgd;
 	memcpy(vg->id.uuid, vgd->vg_uuid, ID_LEN);
 
-	if (!_check_vg_name((char *)dl->pvd.vg_name)) {
-		stack;
-		return 0;
-	}
+	if (!_check_vg_name((char *)dl->pvd.vg_name))
+		return_0;
 
-	if (!(vg->name = dm_pool_strdup(mem, (char *)dl->pvd.vg_name))) {
-		stack;
-		return 0;
-	}
+	if (!(vg->name = dm_pool_strdup(mem, (char *)dl->pvd.vg_name)))
+		return_0;
 
-	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN))) {
-		stack;
-		return 0;
-	}
+	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN)))
+		return_0;
 
 	*vg->system_id = '\0';
 
@@ -315,10 +299,8 @@
 {
 	lvid_from_lvnum(&lv->lvid, &lv->vg->id, lvd->lv_number);
 
-	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name))) {
-		stack;
-		return 0;
-	}
+	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name)))
+		return_0;
 
 	lv->status |= VISIBLE_LV;
 
@@ -457,15 +439,11 @@
 	*count = 0;
 	list_iterate_items(dl, pvds) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
-		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv)))) {
-			stack;
-			return 0;
-		}
+		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv))))
+			return_0;
 
-		if (!import_pv(fmt, mem, dl->dev, vg, pvl->pv, &dl->pvd, &dl->vgd)) {
-			stack;
-			return 0;
-		}
+		if (!import_pv(fmt, mem, dl->dev, vg, pvl->pv, &dl->pvd, &dl->vgd))
+			return_0;
 
 		pvl->pv->fmt = fmt;
 		list_add(results, &pvl->list);
@@ -483,17 +461,13 @@
 	struct logical_volume *lv;
 
 	if (!(ll = dm_pool_zalloc(mem, sizeof(*ll))) ||
-	    !(ll->lv = dm_pool_zalloc(mem, sizeof(*ll->lv)))) {
-		stack;
-		return NULL;
-	}
+	    !(ll->lv = dm_pool_zalloc(mem, sizeof(*ll->lv))))
+		return_NULL;
 	lv = ll->lv;
 	lv->vg = vg;
 
-	if (!import_lv(mem, lv, lvd)) {
-		stack;
-		return NULL;
-	}
+	if (!import_lv(mem, lv, lvd))
+		return_NULL;
 
 	list_add(&vg->lvs, &ll->list);
 	vg->lv_count++;
@@ -512,10 +486,8 @@
 			lvd = &ll->lvd;
 
 			if (!find_lv(vg, (char *)lvd->lv_name) &&
-			    !_add_lv(mem, vg, lvd)) {
-				stack;
-				return 0;
-			}
+			    !_add_lv(mem, vg, lvd))
+				return_0;
 		}
 	}
 
@@ -533,49 +505,37 @@
 	uint32_t lv_num;
 	struct dm_hash_table *lvd_hash;
 
-	if (!_check_vg_name(vg->name)) {
-		stack;
-		return 0;
-	}
+	if (!_check_vg_name(vg->name))
+		return_0;
 
-	if (!(lvd_hash = dm_hash_create(32))) {
-		stack;
-		return 0;
-	}
+	if (!(lvd_hash = dm_hash_create(32)))
+		return_0;
 
 	/*
 	 * setup the pv's extents array
 	 */
 	len = sizeof(struct pe_disk) * dl->pvd.pe_total;
-	if (!(dl->extents = dm_pool_alloc(dl->mem, len))) {
-		stack;
-		goto out;
-	}
+	if (!(dl->extents = dm_pool_alloc(dl->mem, len)))
+		goto_out;
 	memset(dl->extents, 0, len);
 
 	list_iterate_items(ll, &vg->lvs) {
 		if (ll->lv->status & SNAPSHOT)
 			continue;
 
-		if (!(lvdl = dm_pool_alloc(dl->mem, sizeof(*lvdl)))) {
-			stack;
-			goto out;
-		}
+		if (!(lvdl = dm_pool_alloc(dl->mem, sizeof(*lvdl))))
+			goto_out;
 
 		_export_lv(&lvdl->lvd, vg, ll->lv, dev_dir);
 
 		lv_num = lvnum_from_lvid(&ll->lv->lvid);
 		lvdl->lvd.lv_number = lv_num;
 
-		if (!dm_hash_insert(lvd_hash, ll->lv->name, &lvdl->lvd)) {
-			stack;
-			goto out;
-		}
+		if (!dm_hash_insert(lvd_hash, ll->lv->name, &lvdl->lvd))
+			goto_out;
 
-		if (!export_extents(dl, lv_num + 1, ll->lv, pv)) {
-			stack;
-			goto out;
-		}
+		if (!export_extents(dl, lv_num + 1, ll->lv, pv))
+			goto_out;
 
 		if (lv_is_origin(ll->lv))
 			lvdl->lvd.lv_access |= LV_SNAPSHOT_ORG;
@@ -675,10 +635,8 @@
 	struct pv_list *pvl;
 
 	list_iterate_items(pvl, &vg->pvs) {
-		if (!(ul = dm_pool_alloc(dl->mem, sizeof(*ul)))) {
-			stack;
-			return 0;
-		}
+		if (!(ul = dm_pool_alloc(dl->mem, sizeof(*ul))))
+			return_0;
 
 		memset(ul->uuid, 0, sizeof(ul->uuid));
 		memcpy(ul->uuid, pvl->pv->id.uuid, ID_LEN);
@@ -723,10 +681,8 @@
 	struct disk_list *dl;
 	int vg_num;
 
-	if (!get_free_vg_number(fid, filter, vg_name, &vg_num)) {
-		stack;
-		return 0;
-	}
+	if (!get_free_vg_number(fid, filter, vg_name, &vg_num))
+		return_0;
 
 	list_iterate_items(dl, pvds)
 		dl->vgd.vg_number = vg_num;
--- LVM2/lib/format1/import-extents.c	2007/08/20 20:55:25	1.34
+++ LVM2/lib/format1/import-extents.c	2008/01/30 13:19:45	1.35
@@ -118,10 +118,8 @@
 		e = dl->extents;
 
 		/* build an array of lv's for this pv */
-		if (!_fill_lv_array(lvms, maps, dl)) {
-			stack;
-			return 0;
-		}
+		if (!_fill_lv_array(lvms, maps, dl))
+			return_0;
 
 		for (i = 0; i < dl->pvd.pe_total; i++) {
 			lv_num = e[i].lv_num;
@@ -189,10 +187,8 @@
 	for (n = dm_hash_get_first(maps); n; n = dm_hash_get_next(maps, n)) {
 		lvm = (struct lv_map *) dm_hash_get_data(maps, n);
 
-		if (!_check_single_map(lvm)) {
-			stack;
-			return 0;
-		}
+		if (!_check_single_map(lvm))
+			return_0;
 	}
 	return 1;
 }
@@ -216,10 +212,8 @@
 	struct lv_segment *seg;
 	struct segment_type *segtype;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped"))) {
-		stack;
-		return 0;
-	}
+	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+		return_0;
 
 	while (le < lvm->lv->le_count) {
 		len = _area_length(lvm, le);
@@ -334,10 +328,8 @@
 
 	for (n = dm_hash_get_first(maps); n; n = dm_hash_get_next(maps, n)) {
 		lvm = (struct lv_map *) dm_hash_get_data(maps, n);
-		if (!_build_segments(cmd, lvm)) {
-			stack;
-			return 0;
-		}
+		if (!_build_segments(cmd, lvm))
+			return_0;
 	}
 
 	return 1;
@@ -350,10 +342,8 @@
 	struct dm_pool *scratch = dm_pool_create("lvm1 import_extents", 10 * 1024);
 	struct dm_hash_table *maps;
 
-	if (!scratch) {
-		stack;
-		return 0;
-	}
+	if (!scratch)
+		return_0;
 
 	if (!(maps = _create_lv_maps(scratch, vg))) {
 		log_err("Couldn't allocate logical volume maps.");
@@ -365,10 +355,8 @@
 		goto out;
 	}
 
-	if (!_check_maps_are_complete(maps) && !(vg->status & PARTIAL_VG)) {
-		stack;
-		goto out;
-	}
+	if (!_check_maps_are_complete(maps) && !(vg->status & PARTIAL_VG))
+		goto_out;
 
 	if (!_build_all_segments(cmd, maps)) {
 		log_err("Couldn't build extent segments.");
--- LVM2/lib/format1/layout.c	2007/10/12 14:29:31	1.27
+++ LVM2/lib/format1/layout.c	2008/01/30 13:19:45	1.28
@@ -122,10 +122,8 @@
 	struct pv_disk *pvd = dm_malloc(sizeof(*pvd));
 	uint32_t end;
 
-	if (!pvd) {
-		stack;
-		return 0;
-	}
+	if (!pvd)
+		return_0;
 
 	/*
 	 * Guess how many extents will fit, bearing in mind that
--- LVM2/lib/format1/lvm1-label.c	2007/08/22 14:38:16	1.16
+++ LVM2/lib/format1/lvm1-label.c	2008/01/30 13:19:45	1.17
@@ -71,10 +71,8 @@
 	}
 
 	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, (char *)pvd->vg_name, vgid,
-				  exported))) {
-		stack;
-		return 0;
-	}
+				  exported)))
+		return_0;
 	*label = info->label;
 
 	info->device_size = xlate32(pvd->pv_size) << SECTOR_SHIFT;
--- LVM2/lib/format1/vg_number.c	2007/08/20 20:55:25	1.13
+++ LVM2/lib/format1/vg_number.c	2008/01/30 13:19:45	1.14
@@ -33,15 +33,11 @@
 
 	list_init(&all_pvs);
 
-	if (!mem) {
-		stack;
-		return 0;
-	}
+	if (!mem)
+		return_0;
 
-	if (!read_pvs_in_vg(fid->fmt, NULL, filter, mem, &all_pvs)) {
-		stack;
-		goto out;
-	}
+	if (!read_pvs_in_vg(fid->fmt, NULL, filter, mem, &all_pvs))
+		goto_out;
 
 	memset(numbers, 0, sizeof(numbers));
 
--- LVM2/lib/format_pool/disk_rep.c	2007/08/22 14:38:16	1.11
+++ LVM2/lib/format_pool/disk_rep.c	2008/01/30 13:19:45	1.12
@@ -45,10 +45,8 @@
 		return 0;
 	}
 
-	if (!read_pool_label(pl, fmt->labeller, dev, buf, NULL)) {
-		stack;
-		return 0;
-	}
+	if (!read_pool_label(pl, fmt->labeller, dev, buf, NULL))
+		return_0;
 
 	return 1;
 }
@@ -98,10 +96,8 @@
 	log_debug("Calculated uuid %s for %s", uuid, pd->pl_pool_name);
 
 	if (!(info = lvmcache_add(l, (char *) &pvid, dev, pd->pl_pool_name,
-				  (char *) &vgid, 0))) {
-		stack;
-		return 0;
-	}
+				  (char *) &vgid, 0)))
+		return_0;
 	if (label)
 		*label = info->label;
 
@@ -252,10 +248,8 @@
 
 	/* FIXME: maybe should return a different error in memory
 	 * allocation failure */
-	if (!(tmpmem = dm_pool_create("pool read_vg", 512))) {
-		stack;
-		return 0;
-	}
+	if (!(tmpmem = dm_pool_create("pool read_vg", 512)))
+		return_0;
 
 	list_iterate_items(info, &vginfo->infos) {
 		if (info->dev &&
@@ -354,20 +348,16 @@
 {
 	struct pool_list *pl;
 
-	if (!dev_open(dev)) {
-		stack;
-		return NULL;
-	}
+	if (!dev_open(dev))
+		return_NULL;
 
 	if (!(pl = dm_pool_zalloc(mem, sizeof(*pl)))) {
 		log_error("Unable to allocate pool list structure");
 		return 0;
 	}
 
-	if (!__read_pool_disk(fmt, dev, mem, pl, vg_name)) {
-		stack;
-		return NULL;
-	}
+	if (!__read_pool_disk(fmt, dev, mem, pl, vg_name))
+		return_NULL;
 
 	if (!dev_close(dev))
 		stack;
--- LVM2/lib/format_pool/format_pool.c	2007/08/22 14:38:16	1.11
+++ LVM2/lib/format_pool/format_pool.c	2008/01/30 13:19:45	1.12
@@ -128,44 +128,32 @@
 	list_init(&vg->lvs);
 	list_init(&vg->tags);
 
-	if (!import_pool_vg(vg, smem, pds)) {
-		stack;
-		return NULL;
-	}
+	if (!import_pool_vg(vg, smem, pds))
+		return_NULL;
 
-	if (!import_pool_pvs(fid->fmt, vg, &vg->pvs, smem, pds)) {
-		stack;
-		return NULL;
-	}
+	if (!import_pool_pvs(fid->fmt, vg, &vg->pvs, smem, pds))
+		return_NULL;
 
-	if (!import_pool_lvs(vg, smem, pds)) {
-		stack;
-		return NULL;
-	}
+	if (!import_pool_lvs(vg, smem, pds))
+		return_NULL;
 
 	/*
 	 * I need an intermediate subpool structure that contains all the
 	 * relevant info for this.  Then i can iterate through the subpool
 	 * structures for checking, and create the segments
 	 */
-	if (!(usp = _build_usp(pds, mem, &sp_count))) {
-		stack;
-		return NULL;
-	}
+	if (!(usp = _build_usp(pds, mem, &sp_count)))
+		return_NULL;
 
 	/*
 	 * check the subpool structures - we can't handle partial VGs in
 	 * the pool format, so this will error out if we're missing PVs
 	 */
-	if (!_check_usp(vg->name, usp, sp_count)) {
-		stack;
-		return NULL;
-	}
+	if (!_check_usp(vg->name, usp, sp_count))
+		return_NULL;
 
-	if (!import_pool_segments(&vg->lvs, smem, usp, sp_count)) {
-		stack;
-		return NULL;
-	}
+	if (!import_pool_segments(&vg->lvs, smem, usp, sp_count))
+		return_NULL;
 
 	return vg;
 }
@@ -182,25 +170,19 @@
 
 	/* We can safely ignore the mda passed in */
 
-	if (!mem) {
-		stack;
-		return NULL;
-	}
+	if (!mem)
+		return_NULL;
 
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
 
 	/* Read all the pvs in the vg */
-	if (!read_pool_pds(fid->fmt, vg_name, mem, &pds)) {
-		stack;
-		goto out;
-	}
+	if (!read_pool_pds(fid->fmt, vg_name, mem, &pds))
+		goto_out;
 
 	/* Do the rest of the vg stuff */
-	if (!(vg = _build_vg_from_pds(fid, mem, &pds))) {
-		stack;
-		goto out;
-	}
+	if (!(vg = _build_vg_from_pds(fid, mem, &pds)))
+		goto_out;
 
       out:
 	dm_pool_destroy(mem);
@@ -231,30 +213,22 @@
 
 	log_very_verbose("Reading physical volume data %s from disk", pv_name);
 
-	if (!mem) {
-		stack;
-		return 0;
-	}
+	if (!mem)
+		return_0;
 
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter))) {
-		stack;
-		goto out;
-	}
+	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
+		goto_out;
 
 	/*
 	 * I need to read the disk and populate a pv structure here
 	 * I'll probably need to abstract some of this later for the
 	 * vg_read code
 	 */
-	if (!(pl = read_pool_disk(fmt, dev, mem, NULL))) {
-		stack;
-		goto out;
-	}
+	if (!(pl = read_pool_disk(fmt, dev, mem, NULL)))
+		goto_out;
 
-	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl)) {
-		stack;
-		goto out;
-	}
+	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl))
+		goto_out;
 
 	pv->fmt = fmt;
 
--- LVM2/lib/format_pool/import_export.c	2008/01/16 19:00:59	1.19
+++ LVM2/lib/format_pool/import_export.c	2008/01/30 13:19:45	1.20
@@ -91,10 +91,8 @@
 		if (lv->name)
 			continue;
 
-		if (!(lv->name = dm_pool_strdup(mem, pl->pd.pl_pool_name))) {
-			stack;
-			return 0;
-		}
+		if (!(lv->name = dm_pool_strdup(mem, pl->pd.pl_pool_name)))
+			return_0;
 
 		get_pool_lv_uuid(lv->lvid.id, &pl->pd);
 		log_debug("Calculated lv uuid for lv %s: %s", lv->name,
@@ -178,10 +176,8 @@
 	list_init(&pv->tags);
 	list_init(&pv->segments);
 
-	if (!alloc_pv_segment_whole_pv(mem, pv)) {
-		stack;
-		return 0;
-	}
+	if (!alloc_pv_segment_whole_pv(mem, pv))
+		return_0;
 
 	return 1;
 }
@@ -216,10 +212,8 @@
 	area_len = (usp->devs[0].blocks) / POOL_PE_SIZE;
 
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd,
-						     "striped"))) {
-		stack;
-		return 0;
-	}
+						     "striped")))
+		return_0;
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur, 
 				     area_len * usp->num_devs, 0,
@@ -230,10 +224,8 @@
 	}
 
 	for (j = 0; j < usp->num_devs; j++)
-		if (!set_lv_segment_area_pv(seg, j, usp->devs[j].pv, 0)) {
-			stack;
-			return 0;
-		}
+		if (!set_lv_segment_area_pv(seg, j, usp->devs[j].pv, 0))
+			return_0;
 
 	/* add the subpool type to the segment tag list */
 	str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
@@ -254,10 +246,8 @@
 	unsigned j;
 	uint32_t area_len;
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped"))) {
-		stack;
-		return 0;
-	}
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+		return_0;
 
 	for (j = 0; j < usp->num_devs; j++) {
 		area_len = (usp->devs[j].blocks) / POOL_PE_SIZE;
@@ -274,10 +264,8 @@
 		/* add the subpool type to the segment tag list */
 		str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
 
-		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0)) {
-			stack;
-			return 0;
-		}
+		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0))
+			return_0;
 		list_add(&lv->segments, &seg->list);
 
 		*le_cur += seg->len;
@@ -302,15 +290,11 @@
 
 		for (i = 0; i < subpools; i++) {
 			if (usp[i].striping) {
-				if (!_add_stripe_seg(mem, &usp[i], lv, &le_cur)) {
-					stack;
-					return 0;
-				}
+				if (!_add_stripe_seg(mem, &usp[i], lv, &le_cur))
+					return_0;
 			} else {
-				if (!_add_linear_seg(mem, &usp[i], lv, &le_cur)) {
-					stack;
-					return 0;
-				}
+				if (!_add_linear_seg(mem, &usp[i], lv, &le_cur))
+					return_0;
 			}
 		}
 	}
--- LVM2/lib/format_text/archive.c	2007/08/20 20:55:26	1.29
+++ LVM2/lib/format_text/archive.c	2008/01/30 13:19:45	1.30
@@ -113,10 +113,8 @@
 	    !dm_pool_grow_object(mem, dir, strlen(dir)) ||
 	    !dm_pool_grow_object(mem, "/", 1) ||
 	    !dm_pool_grow_object(mem, name, strlen(name)) ||
-	    !dm_pool_grow_object(mem, "\0", 1)) {
-		stack;
-		return NULL;
-	}
+	    !dm_pool_grow_object(mem, "\0", 1))
+		return_NULL;
 
 	return dm_pool_end_object(mem);
 }
@@ -134,10 +132,8 @@
 	struct archive_file *af;
 	struct list *results;
 
-	if (!(results = dm_pool_alloc(mem, sizeof(*results)))) {
-		stack;
-		return NULL;
-	}
+	if (!(results = dm_pool_alloc(mem, sizeof(*results))))
+		return_NULL;
 
 	list_init(results);
 
@@ -161,10 +157,8 @@
 		if (strcmp(vgname, vgname_found))
 			continue;
 
-		if (!(path = _join_file_to_dir(mem, dir, dirent[i]->d_name))) {
-			stack;
-			goto out;
-		}
+		if (!(path = _join_file_to_dir(mem, dir, dirent[i]->d_name)))
+			goto_out;
 
 		/*
 		 * Create a new archive_file.
@@ -255,10 +249,9 @@
 	}
 
 	if (!text_vg_export_file(vg, desc, fp)) {
-		stack;
 		if (fclose(fp))
 			log_sys_error("fclose", temp_file);
-		return 0;
+		return_0;
 	}
 
 	if (lvm_fclose(fp, temp_file))
@@ -267,10 +260,8 @@
 	/*
 	 * Now we want to rename this file to <vg>_index.vg.
 	 */
-	if (!(archives = _scan_archive(vg->cmd->mem, vg->name, dir))) {
-		stack;
-		return 0;
-	}
+	if (!(archives = _scan_archive(vg->cmd->mem, vg->name, dir)))
+		return_0;
 
 	if (list_empty(archives))
 		ix = 0;
@@ -343,10 +334,8 @@
 	struct list *archives;
 	struct archive_file *af;
 
-	if (!(archives = _scan_archive(cmd->mem, vgname, dir))) {
-		stack;
-		return 0;
-	}
+	if (!(archives = _scan_archive(cmd->mem, vgname, dir)))
+		return_0;
 
 	if (list_empty(archives))
 		log_print("No archives found in %s.", dir);
@@ -379,10 +368,8 @@
 {
 	struct archive_file af;
 
-	if (!(af.path = _join_file_to_dir(cmd->mem, dir, vgname))) {
-		stack;
-		return 0;
-	}
+	if (!(af.path = _join_file_to_dir(cmd->mem, dir, vgname)))
+		return_0;
 
 	if (path_exists(af.path))
 		_display_archive(cmd, &af);
--- LVM2/lib/format_text/archiver.c	2008/01/29 23:45:47	1.11
+++ LVM2/lib/format_text/archiver.c	2008/01/30 13:19:45	1.12
@@ -78,17 +78,13 @@
 	size_t len = strlen(line) + 32;
 	char *buffer;
 
-	if (!(buffer = dm_pool_zalloc(mem, strlen(line) + 32))) {
-		stack;
-		return NULL;
-	}
+	if (!(buffer = dm_pool_zalloc(mem, strlen(line) + 32)))
+		return_NULL;
 
 	if (snprintf(buffer, len,
 		     "Created %s executing '%s'",
-		     before ? "*before*" : "*after*", line) < 0) {
-		stack;
-		return NULL;
-	}
+		     before ? "*before*" : "*after*", line) < 0)
+		return_NULL;
 
 	return buffer;
 }
@@ -97,10 +93,8 @@
 {
 	char *desc;
 
-	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 1))) {
-		stack;
-		return 0;
-	}
+	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 1)))
+		return_0;
 
 	return archive_vg(vg, vg->cmd->archive_params->dir, desc,
 			  vg->cmd->archive_params->keep_days,
@@ -196,10 +190,8 @@
 	char name[PATH_MAX];
 	char *desc;
 
-	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 0))) {
-		stack;
-		return 0;
-	}
+	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 0)))
+		return_0;
 
 	if (dm_snprintf(name, sizeof(name), "%s/%s",
 			 vg->cmd->backup_params->dir, vg->name) < 0) {
@@ -324,10 +316,8 @@
 		}
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
 
 	return 1;
 }
@@ -341,10 +331,8 @@
 	/*
 	 * Read in the volume group from the text file.
 	 */
-	if (!(vg = backup_read_vg(cmd, vg_name, file))) {
-		stack;
-		return 0;
-	}
+	if (!(vg = backup_read_vg(cmd, vg_name, file)))
+		return_0;
 
 	return backup_restore_vg(cmd, vg);
 }
--- LVM2/lib/format_text/export.c	2007/11/09 16:51:53	1.59
+++ LVM2/lib/format_text/export.c	2008/01/30 13:19:45	1.60
@@ -135,10 +135,8 @@
 {
 	/* If metadata doesn't fit, extend buffer */
 	if ((f->data.buf.used + 2 > f->data.buf.size) &&
-	    (!_extend_buffer(f))) {
-		stack;
-		return 0;
-	}
+	    (!_extend_buffer(f)))
+		return_0;
 
 	*(f->data.buf.start + f->data.buf.used) = '\n';
 	f->data.buf.used += 1;
@@ -195,10 +193,8 @@
 
 	/* If metadata doesn't fit, extend buffer */
 	if (n < 0 || (n + f->data.buf.used + 2 > f->data.buf.size)) {
-		if (!_extend_buffer(f)) {
-			stack;
-			return 0;
-		}
+		if (!_extend_buffer(f))
+			return_0;
 		return -1; /* Retry */
 	}
 
@@ -323,26 +319,20 @@
 {
 	char buffer[4096];
 
-	if (!id_write_format(&vg->id, buffer, sizeof(buffer))) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
+		return_0;
 
 	outf(f, "id = \"%s\"", buffer);
 
 	outf(f, "seqno = %u", vg->seqno);
 
-	if (!print_flags(vg->status, VG_FLAGS, buffer, sizeof(buffer))) {
-		stack;
-		return 0;
-	}
+	if (!print_flags(vg->status, VG_FLAGS, buffer, sizeof(buffer)))
+		return_0;
 	outf(f, "status = %s", buffer);
 
 	if (!list_empty(&vg->tags)) {
-		if (!print_tags(&vg->tags, buffer, sizeof(buffer))) {
-			stack;
-			return 0;
-		}
+		if (!print_tags(&vg->tags, buffer, sizeof(buffer)))
+			return_0;
 		outf(f, "tags = %s", buffer);
 	}
 
@@ -350,10 +340,8 @@
 		outf(f, "system_id = \"%s\"", vg->system_id);
 
 	if (!out_size(f, (uint64_t) vg->extent_size, "extent_size = %u",
-		      vg->extent_size)) {
-		stack;
-		return 0;
-	}
+		      vg->extent_size))
+		return_0;
 	outf(f, "max_lv = %u", vg->max_lv);
 	outf(f, "max_pv = %u", vg->max_pv);
 
@@ -390,52 +378,38 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
-		if (!(name = _get_pv_name(f, pv))) {
-			stack;
-			return 0;
-		}
+		if (!(name = _get_pv_name(f, pv)))
+			return_0;
 
 		outnl(f);
 		outf(f, "%s {", name);
 		_inc_indent(f);
 
-		if (!id_write_format(&pv->id, buffer, sizeof(buffer))) {
-			stack;
-			return 0;
-		}
+		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
+			return_0;
 
 		outf(f, "id = \"%s\"", buffer);
-		if (!out_hint(f, "device = \"%s\"", pv_dev_name(pv))) {
-			stack;
-			return 0;
-		}
+		if (!out_hint(f, "device = \"%s\"", pv_dev_name(pv)))
+			return_0;
 		outnl(f);
 
-		if (!print_flags(pv->status, PV_FLAGS, buffer, sizeof(buffer))) {
-			stack;
-			return 0;
-		}
+		if (!print_flags(pv->status, PV_FLAGS, buffer, sizeof(buffer)))
+			return_0;
 		outf(f, "status = %s", buffer);
 
 		if (!list_empty(&pv->tags)) {
-			if (!print_tags(&pv->tags, buffer, sizeof(buffer))) {
-				stack;
-				return 0;
-			}
+			if (!print_tags(&pv->tags, buffer, sizeof(buffer)))
+				return_0;
 			outf(f, "tags = %s", buffer);
 		}
 
-		if (!out_size(f, pv->size, "dev_size = %" PRIu64, pv->size)) {
-			stack;
-			return 0;
-		}
+		if (!out_size(f, pv->size, "dev_size = %" PRIu64, pv->size))
+			return_0;
 
 		outf(f, "pe_start = %" PRIu64, pv->pe_start);
 		if (!out_size(f, vg->extent_size * (uint64_t) pv->pe_count,
-			      "pe_count = %u", pv->pe_count)) {
-			stack;
-			return 0;
-		}
+			      "pe_count = %u", pv->pe_count))
+			return_0;
 
 		_dec_indent(f);
 		outf(f, "}");
@@ -456,27 +430,21 @@
 
 	outf(f, "start_extent = %u", seg->le);
 	if (!out_size(f, (uint64_t) seg->len * vg->extent_size,
-		      "extent_count = %u", seg->len)) {
-		stack;
-		return 0;
-	}
+		      "extent_count = %u", seg->len))
+		return_0;
 
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
 	if (!list_empty(&seg->tags)) {
-		if (!print_tags(&seg->tags, buffer, sizeof(buffer))) {
-			stack;
-			return 0;
-		}
+		if (!print_tags(&seg->tags, buffer, sizeof(buffer)))
+			return_0;
 		outf(f, "tags = %s", buffer);
 	}
 
 	if (seg->segtype->ops->text_export &&
-	    !seg->segtype->ops->text_export(seg, f)) {
-		stack;
-		return 0;
-	}
+	    !seg->segtype->ops->text_export(seg, f))
+		return_0;
 
 	_dec_indent(f);
 	outf(f, "}");
@@ -498,10 +466,8 @@
 	for (s = 0; s < seg->area_count; s++) {
 		switch (seg_type(seg, s)) {
 		case AREA_PV:
-			if (!(name = _get_pv_name(f, seg_pv(seg, s)))) {
-				stack;
-				return 0;
-			}
+			if (!(name = _get_pv_name(f, seg_pv(seg, s))))
+				return_0;
 
 			outf(f, "\"%s\", %u%s", name,
 			     seg_pe(seg, s),
@@ -534,24 +500,18 @@
 	_inc_indent(f);
 
 	/* FIXME: Write full lvid */
-	if (!id_write_format(&lv->lvid.id[1], buffer, sizeof(buffer))) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format(&lv->lvid.id[1], buffer, sizeof(buffer)))
+		return_0;
 
 	outf(f, "id = \"%s\"", buffer);
 
-	if (!print_flags(lv->status, LV_FLAGS, buffer, sizeof(buffer))) {
-		stack;
-		return 0;
-	}
+	if (!print_flags(lv->status, LV_FLAGS, buffer, sizeof(buffer)))
+		return_0;
 	outf(f, "status = %s", buffer);
 
 	if (!list_empty(&lv->tags)) {
-		if (!print_tags(&lv->tags, buffer, sizeof(buffer))) {
-			stack;
-			return 0;
-		}
+		if (!print_tags(&lv->tags, buffer, sizeof(buffer)))
+			return_0;
 		outf(f, "tags = %s", buffer);
 	}
 
@@ -579,10 +539,8 @@
 
 	seg_count = 1;
 	list_iterate_items(seg, &lv->segments) {
-		if (!_print_segment(f, lv->vg, seg_count++, seg)) {
-			stack;
-			return 0;
-		}
+		if (!_print_segment(f, lv->vg, seg_count++, seg))
+			return_0;
 	}
 
 	_dec_indent(f);
@@ -610,19 +568,15 @@
 	list_iterate_items(lvl, &vg->lvs) {
 		if (!(lvl->lv->status & VISIBLE_LV))
 			continue;
-		if (!_print_lv(f, lvl->lv)) {
-			stack;
-			return 0;
-		}
+		if (!_print_lv(f, lvl->lv))
+			return_0;
 	}
 
 	list_iterate_items(lvl, &vg->lvs) {
 		if ((lvl->lv->status & VISIBLE_LV))
 			continue;
-		if (!_print_lv(f, lvl->lv)) {
-			stack;
-			return 0;
-		}
+		if (!_print_lv(f, lvl->lv))
+			return_0;
 	}
 
 	_dec_indent(f);
@@ -671,10 +625,8 @@
 {
 	int r = 0;
 
-	if (!_build_pv_names(f, vg)) {
-		stack;
-		goto out;
-	}
+	if (!_build_pv_names(f, vg))
+		goto_out;
 
 	if (f->header && !_print_header(f, desc))
 		goto_out;
@@ -721,10 +673,8 @@
 
 	_init();
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
-		stack;
-		return 0;
-	}
+	if (!(f = dm_malloc(sizeof(*f))))
+		return_0;
 
 	memset(f, 0, sizeof(*f));
 	f->data.fp = fp;
@@ -748,10 +698,8 @@
 
 	_init();
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
-		stack;
-		return 0;
-	}
+	if (!(f = dm_malloc(sizeof(*f))))
+		return_0;
 
 	memset(f, 0, sizeof(*f));
 
@@ -767,9 +715,8 @@
 	f->nl = &_nl_raw;
 
 	if (!_text_vg_export(f, vg, desc)) {
-		stack;
 		dm_free(f->data.buf.start);
-		goto out;
+		goto_out;
 	}
 
 	r = f->data.buf.used + 1;
--- LVM2/lib/format_text/flags.c	2008/01/10 18:35:50	1.31
+++ LVM2/lib/format_text/flags.c	2008/01/30 13:19:45	1.32
@@ -91,10 +91,8 @@
 	int f, first = 1;
 	struct flag *flags;
 
-	if (!(flags = _get_flags(type))) {
-		stack;
-		return 0;
-	}
+	if (!(flags = _get_flags(type)))
+		return_0;
 
 	if (!emit_to_buffer(&buffer, &size, "["))
 		return 0;
@@ -135,10 +133,8 @@
 	uint32_t s = 0;
 	struct flag *flags;
 
-	if (!(flags = _get_flags(type))) {
-		stack;
-		return 0;
-	}
+	if (!(flags = _get_flags(type)))
+		return_0;
 
 	if (cv->type == CFG_EMPTY_ARRAY)
 		goto out;
--- LVM2/lib/format_text/format-text.c	2008/01/29 23:45:47	1.86
+++ LVM2/lib/format_text/format-text.c	2008/01/30 13:19:45	1.87
@@ -297,40 +297,38 @@
 		return NULL;
 	}
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
-		stack;
-		goto error;
-	}
+	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah))
+		goto_bad;
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
 		log_error("Incorrect metadata area header checksum");
-		goto error;
+		goto bad;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
 		log_error("Wrong magic number in metadata area header");
-		goto error;
+		goto bad;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d",
 			  mdah->version);
-		goto error;
+		goto bad;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: %"
 			  PRIu64, mdah->start);
-		goto error;
+		goto bad;
 	}
 
 	return mdah;
 
-error:
+bad:
 	dm_pool_free(fmt->cmd->mem, mdah);
 	return NULL;
 }
@@ -349,9 +347,8 @@
 					     sizeof(mdah->checksum_xl)));
 
 	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
-		stack;
 		dm_pool_free(fmt->cmd->mem, mdah);
-		return 0;
+		return_0;
 	}
 
 	return 1;
@@ -380,17 +377,15 @@
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), vgnamebuf)) {
-		stack;
-		goto error;
-	}
+		      sizeof(vgnamebuf), vgnamebuf))
+		goto_bad;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{')) {
 		return rlocn;
 	}
 
-      error:
+      bad:
 	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
 		lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN, 0, NULL);
 
@@ -422,15 +417,11 @@
 	int noprecommit = 0;
 	struct mda_header *mdah;
 
-	if (!dev_open(dev_area->dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(dev_area->dev))
+		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, dev_area))) {
-		stack;
-		return 0;
-	}
+	if (!(mdah = _raw_read_mda_header(fid->fmt, dev_area)))
+		return_0;
 
 	if (_find_vg_rlocn(dev_area, mdah, vgname, &noprecommit))
 		r = 1;
@@ -453,15 +444,11 @@
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!dev_open(area->dev)) {
-		stack;
-		return NULL;
-	}
+	if (!dev_open(area->dev))
+		return_NULL;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, area))) {
-		stack;
-		goto out;
-	}
+	if (!(mdah = _raw_read_mda_header(fid->fmt, area)))
+		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(area, mdah, vgname, &precommitted))) {
 		log_debug("VG %s not found on %s", vgname, dev_name(area->dev));
@@ -483,10 +470,8 @@
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
 				     wrap, calc_crc, rlocn->checksum, &when,
-				     &desc))) {
-		stack;
-		goto out;
-	}
+				     &desc)))
+		goto_out;
 	log_debug("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
 		  PRIu64, vg->name, precommitted ? "pre-commit " : "",
 		  vg->seqno, dev_name(area->dev),
@@ -544,15 +529,11 @@
 	if (!found)
 		return 1;
 
-	if (!dev_open(mdac->area.dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(mdac->area.dev))
+		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area))) {
-		stack;
-		goto out;
-	}
+	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+		goto_out;
 
 	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
@@ -589,10 +570,8 @@
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
 		       (size_t) (mdac->rlocn.size - new_wrap),
-		       fidtc->raw_metadata_buf)) {
-		stack;
-		goto out;
-	}
+		       fidtc->raw_metadata_buf))
+		goto_out;
 
 	if (new_wrap) {
 		log_debug("Writing metadata to %s at %" PRIu64 " len %" PRIu32,
@@ -603,10 +582,8 @@
 			       mdac->area.start + MDA_HEADER_SIZE,
 			       (size_t) new_wrap,
 			       fidtc->raw_metadata_buf + 
-			       mdac->rlocn.size - new_wrap)) {
-			stack;
-			goto out;
-		}
+			       mdac->rlocn.size - new_wrap))
+			goto_out;
 	}
 
 	mdac->rlocn.checksum = calc_crc(INITIAL_CRC, fidtc->raw_metadata_buf,
@@ -652,10 +629,8 @@
 	if (!found)
 		return 1;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area))) {
-		stack;
-		goto out;
-	}
+	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
@@ -759,15 +734,11 @@
 	int r = 0;
 	int noprecommit = 0;
 
-	if (!dev_open(mdac->area.dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(mdac->area.dev))
+		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area))) {
-		stack;
-		goto out;
-	}
+	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
 		rlocn = &mdah->raw_locns[0];
@@ -801,10 +772,8 @@
 	time_t when;
 	char *desc;
 
-	if (!(vg = text_vg_import_file(fid, read_path, &when, &desc))) {
-		stack;
-		return NULL;
-	}
+	if (!(vg = text_vg_import_file(fid, read_path, &when, &desc)))
+		return_NULL;
 
 	/*
 	 * Currently you can only have a single volume group per
@@ -1065,10 +1034,8 @@
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-	if (!dev_open(dev_area->dev)) {
-		stack;
-		return NULL;
-	}
+	if (!dev_open(dev_area->dev))
+		return_NULL;
 
 	if (!(mdah = _raw_read_mda_header(fmt, dev_area)))
 		goto_out;
@@ -1114,15 +1081,13 @@
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(vgname)) {
-		stack;
 		vgname = NULL;
-		goto out;
+		goto_out;
 	}
 
 	if (!id_write_format(vgid, uuid, sizeof(uuid))) {
-		stack;
 		vgname = NULL;
-		goto out;
+		goto_out;
 	}
 
 	log_debug("%s: Found metadata at %" PRIu64 " size %" PRIu64
@@ -1328,10 +1293,8 @@
 	/* FIXME Test mode don't update cache? */
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  ORPHAN, NULL, 0))) {
-		stack;
-		return 0;
-	}
+				  ORPHAN, NULL, 0)))
+		return_0;
 	label = info->label;
 
 	if (label_sector != -1)
@@ -1384,15 +1347,11 @@
 		}
 	}
 	if (!add_da
-	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0))) {
-		stack;
-		return 0;
-	}
+	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
+		return_0;
 
-	if (!dev_open(pv->dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(pv->dev))
+		return_0;
 
 	list_iterate_items(mda, &info->mdas) {
 		mdac = mda->metadata_locn;
@@ -1400,19 +1359,16 @@
 		mdah->size = mdac->area.size;
 		if (!_raw_write_mda_header(fmt, mdac->area.dev,
 					   mdac->area.start, mdah)) {
-			stack;
 			if (!dev_close(pv->dev))
 				stack;
-			return 0;
+			return_0;
 		}
 	}
 
 	label_write(pv->dev, label);
 
-	if (!dev_close(pv->dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_close(pv->dev))
+		return_0;
 
 	return 1;
 }
@@ -1449,16 +1405,12 @@
 	struct mda_context *mdac, *mdac_new;
 	struct data_area_list *da;
 
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter))) {
-		stack;
-		return 0;
-	}
+	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
+		return_0;
 
 	/* FIXME Optimise out repeated reading when cache lock held */
-	if (!(label_read(dev, &label, UINT64_C(0)))) {
-		stack;
-		return 0;
-	}
+	if (!(label_read(dev, &label, UINT64_C(0))))
+		return_0;
 	info = (struct lvmcache_info *) label->info;
 
 	/* Have we already cached vgname? */
@@ -1642,16 +1594,12 @@
 					continue;
 
 				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new)))) {
-					stack;
-					return 0;
-				}
+							   sizeof(*mda_new))))
+					return_0;
 
 				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new)))) {
-					stack;
-					return 0;
-				}
+							    sizeof(*mdac_new))))
+					return_0;
 				/* FIXME multiple dev_areas inside area */
 				memcpy(mda_new, mda, sizeof(*mda));
 				memcpy(mdac_new, mdac, sizeof(*mdac));
@@ -1687,11 +1635,8 @@
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, mdas, pv, vg)) {
-			stack;
-			return 0;
-		}
-
+				pvmetadatasize, mdas, pv, vg))
+			return_0;
 	}
 
 	return 1;
@@ -1732,10 +1677,8 @@
 	list_init(&fid->metadata_areas);
 
 	if (!vgname) {
-		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
-			stack;
-			return NULL;
-		}
+		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
 		list_add(&fid->metadata_areas, &mda->list);
@@ -1751,10 +1694,8 @@
 			}
 
 			context = create_text_context(fmt->cmd, path, NULL);
-			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
-				stack;
-				return NULL;
-			}
+			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
 			list_add(&fid->metadata_areas, &mda->list);
@@ -1767,15 +1708,11 @@
 			if (!_raw_holds_vgname(fid, &rl->dev_area, vgname))
 				continue;
 
-			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
-				stack;
-				return NULL;
-			}
+			if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
+				return_NULL;
 
-			if (!(mdac = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac)))) {
-				stack;
-				return NULL;
-			}
+			if (!(mdac = dm_pool_alloc(fmt->cmd->mem, sizeof(*mdac))))
+				return_NULL;
 			mda->metadata_locn = mdac;
 			/* FIXME Allow multiple dev_areas inside area */
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
@@ -1786,10 +1723,8 @@
 
 		/* Scan PVs in VG for any further MDAs */
 		lvmcache_label_scan(fmt->cmd, 0);
-		if (!(vginfo = vginfo_from_vgname(vgname, vgid))) {
-			stack;
-			goto out;
-		}
+		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
+			goto_out;
 		list_iterate_items(info, &vginfo->infos) {
 			mdas = &info->mdas;
 			list_iterate_items(mda, mdas) {
@@ -1798,16 +1733,12 @@
 
 				/* FIXME Check it holds this VG */
 				if (!(mda_new = dm_pool_alloc(fmt->cmd->mem,
-							   sizeof(*mda_new)))) {
-					stack;
-					return NULL;
-				}
+							   sizeof(*mda_new))))
+					return_NULL;
 
 				if (!(mdac_new = dm_pool_alloc(fmt->cmd->mem,
-							    sizeof(*mdac_new)))) {
-					stack;
-					return NULL;
-				}
+							    sizeof(*mdac_new))))
+					return_NULL;
 				/* FIXME multiple dev_areas inside area */
 				memcpy(mda_new, mda, sizeof(*mda));
 				memcpy(mdac_new, mdac, sizeof(*mdac));
@@ -1834,33 +1765,26 @@
 		return NULL;
 	}
 
-	if (!(tc = dm_pool_alloc(cmd->mem, sizeof(*tc)))) {
-		stack;
-		return NULL;
-	}
+	if (!(tc = dm_pool_alloc(cmd->mem, sizeof(*tc))))
+		return_NULL;
 
-	if (!(tc->path_live = dm_pool_strdup(cmd->mem, path))) {
-		stack;
-		goto no_mem;
-	}
+	if (!(tc->path_live = dm_pool_strdup(cmd->mem, path)))
+		goto_bad;
+
+	if (!(tc->path_edit = dm_pool_alloc(cmd->mem, strlen(path) + 5)))
+		goto_bad;
 
-	if (!(tc->path_edit = dm_pool_alloc(cmd->mem, strlen(path) + 5))) {
-		stack;
-		goto no_mem;
-	}
 	sprintf(tc->path_edit, "%s.tmp", path);
 
 	if (!desc)
 		desc = "";
 
-	if (!(tc->desc = dm_pool_strdup(cmd->mem, desc))) {
-		stack;
-		goto no_mem;
-	}
+	if (!(tc->desc = dm_pool_strdup(cmd->mem, desc)))
+		goto_bad;
 
 	return (void *) tc;
 
-      no_mem:
+      bad:
 	dm_pool_free(cmd->mem, tc);
 
 	log_err("Couldn't allocate text format context object.");
@@ -1956,10 +1880,8 @@
 	struct config_value *cv;
 	struct mda_lists *mda_lists;
 
-	if (!(fmt = dm_malloc(sizeof(*fmt)))) {
-		stack;
-		return NULL;
-	}
+	if (!(fmt = dm_malloc(sizeof(*fmt))))
+		return_NULL;
 
 	fmt->cmd = cmd;
 	fmt->ops = &_text_handler;
--- LVM2/lib/format_text/import.c	2007/08/20 20:55:26	1.43
+++ LVM2/lib/format_text/import.c	2008/01/30 13:19:45	1.44
@@ -111,10 +111,8 @@
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft))) {
-			stack;
-			goto out;
-		}
+		if (!(vg = (*vsn)->read_vg(fid, cft)))
+			goto_out;
 
 		(*vsn)->read_desc(fid->fmt->cmd->mem, cft, when, desc);
 		break;
--- LVM2/lib/format_text/import_vsn1.c	2008/01/16 19:00:59	1.47
+++ LVM2/lib/format_text/import_vsn1.c	2008/01/30 13:19:45	1.48
@@ -136,10 +136,8 @@
 	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
-	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv)))) {
-		stack;
-		return 0;
-	}
+	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
+		return_0;
 
 	pv = pvl->pv;
 
@@ -147,10 +145,8 @@
 	 * Add the pv to the pv hash for quick lookup when we read
 	 * the lv segments.
 	 */
-	if (!dm_hash_insert(pv_hash, pvn->key, pv)) {
-		stack;
-		return 0;
-	}
+	if (!dm_hash_insert(pv_hash, pvn->key, pv))
+		return_0;
 
 	if (!(pvn = pvn->child)) {
 		log_error("Empty pv section.");
@@ -180,10 +176,8 @@
 			return 0;
 	}
 
-	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name))) {
-		stack;
-		return 0;
-	}
+	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
+		return_0;
 
 	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 
@@ -250,10 +244,8 @@
                 }
         }
 
-	if (!alloc_pv_segment_whole_pv(mem, pv)) {
-		stack;
-		return 0;
-	}
+	if (!alloc_pv_segment_whole_pv(mem, pv))
+		return_0;
 
 	vg->pv_count++;
 	list_add(&vg->pvs, &pvl->list);
@@ -316,16 +308,12 @@
 		segtype_str = cv->v.str;
 	}
 
-	if (!(segtype = get_segtype_from_string(vg->cmd, segtype_str))) {
-		stack;
-		return 0;
-	}
+	if (!(segtype = get_segtype_from_string(vg->cmd, segtype_str)))
+		return_0;
 
 	if (segtype->ops->text_import_area_count &&
-	    !segtype->ops->text_import_area_count(sn, &area_count)) {
-		stack;
-		return 0;
-	}
+	    !segtype->ops->text_import_area_count(sn, &area_count))
+		return_0;
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
 				     extent_count, 0, 0, NULL, area_count,
@@ -335,10 +323,8 @@
 	}
 
 	if (seg->segtype->ops->text_import &&
-	    !seg->segtype->ops->text_import(seg, sn, pv_hash)) {
-		stack;
-		return 0;
-	}
+	    !seg->segtype->ops->text_import(seg, sn, pv_hash))
+		return_0;
 
 	/* Optional tags */
 	if ((cn = find_config_node(sn, "tags")) &&
@@ -403,10 +389,8 @@
 
 		/* FIXME Cope if LV not yet read in */
 		if ((pv = dm_hash_lookup(pv_hash, cv->v.str))) {
-			if (!set_lv_segment_area_pv(seg, s, pv, (uint32_t) cv->next->v.i)) {
-				stack;
-				return 0;
-			}
+			if (!set_lv_segment_area_pv(seg, s, pv, (uint32_t) cv->next->v.i))
+				return_0;
 		} else if ((lv1 = find_lv(seg->lv->vg, cv->v.str))) {
 			if (!set_lv_segment_area_lv(seg, s, lv1,
 						    (uint32_t) cv->next->v.i,
@@ -447,10 +431,8 @@
 		 * All sub-sections are assumed to be segments.
 		 */
 		if (!sn->v) {
-			if (!_read_segment(mem, vg, lv, sn, pv_hash)) {
-				stack;
-				return 0;
-			}
+			if (!_read_segment(mem, vg, lv, sn, pv_hash))
+				return_0;
 
 			count++;
 		}
@@ -475,18 +457,14 @@
 	/*
 	 * Check there are no gaps or overlaps in the lv.
 	 */
-	if (!check_lv_segments(lv, 0)) {
-		stack;
-		return 0;
-	}
+	if (!check_lv_segments(lv, 0))
+		return_0;
 
 	/*
 	 * Merge segments in case someones been editing things by hand.
 	 */
-	if (!lv_merge_segments(lv)) {
-		stack;
-		return 0;
-	}
+	if (!lv_merge_segments(lv))
+		return_0;
 
 	return 1;
 }
@@ -502,17 +480,13 @@
 	struct config_node *cn;
 
 	if (!(lvl = dm_pool_zalloc(mem, sizeof(*lvl))) ||
-	    !(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv)))) {
-		stack;
-		return 0;
-	}
+	    !(lvl->lv = dm_pool_zalloc(mem, sizeof(*lvl->lv))))
+		return_0;
 
 	lv = lvl->lv;
 
-	if (!(lv->name = dm_pool_strdup(mem, lvn->key))) {
-		stack;
-		return 0;
-	}
+	if (!(lv->name = dm_pool_strdup(mem, lvn->key)))
+		return_0;
 
 	if (!(lvn = lvn->child)) {
 		log_error("Empty logical volume section.");
@@ -538,10 +512,8 @@
 		}
 
 		lv->alloc = get_alloc_from_string(cv->v.str);
-		if (lv->alloc == ALLOC_INVALID) {
-			stack;
-			return 0;
-		}
+		if (lv->alloc == ALLOC_INVALID)
+			return_0;
 	}
 
 	if (!_read_int32(lvn, "read_ahead", &lv->read_ahead))
@@ -611,10 +583,8 @@
 
 	memcpy(&lv->lvid.id[0], &lv->vg->id, sizeof(lv->lvid.id[0]));
 
-	if (!_read_segments(mem, vg, lv, lvn, pv_hash)) {
-		stack;
-		return 0;
-	}
+	if (!_read_segments(mem, vg, lv, lvn, pv_hash))
+		return_0;
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
 
@@ -664,10 +634,8 @@
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash)) {
-			stack;
-			return 0;
-		}
+		if (!fn(fid, mem, vg, n, vgn, pv_hash))
+			return_0;
 	}
 
 	return 1;
@@ -689,10 +657,8 @@
 		return NULL;
 	}
 
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
-		stack;
-		return NULL;
-	}
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+		return_NULL;
 	vg->cmd = fid->fmt->cmd;
 
 	/* FIXME Determine format type from file contents */
@@ -770,10 +736,8 @@
 		}
 
 		vg->alloc = get_alloc_from_string(cv->v.str);
-		if (vg->alloc == ALLOC_INVALID) {
-			stack;
-			return 0;
-		}
+		if (vg->alloc == ALLOC_INVALID)
+			return_0;
 	}
 
 	/*
--- LVM2/lib/format_text/tags.c	2007/08/20 20:55:26	1.4
+++ LVM2/lib/format_text/tags.c	2008/01/30 13:19:45	1.5
@@ -24,30 +24,22 @@
 	struct str_list *sl;
 	int first = 1;
 
-	if (!emit_to_buffer(&buffer, &size, "[")) {
-		stack;
-		return 0;
-	}
+	if (!emit_to_buffer(&buffer, &size, "["))
+		return_0;
 
 	list_iterate_items(sl, tags) {
 		if (!first) {
-			if (!emit_to_buffer(&buffer, &size, ", ")) {
-				stack;
-				return 0;
-			}
+			if (!emit_to_buffer(&buffer, &size, ", "))
+				return_0;
 		} else
 			first = 0;
 
-		if (!emit_to_buffer(&buffer, &size, "\"%s\"", sl->str)) {
-			stack;
-			return 0;
-		}
+		if (!emit_to_buffer(&buffer, &size, "\"%s\"", sl->str))
+			return_0;
 	}
 
-	if (!emit_to_buffer(&buffer, &size, "]")) {
-		stack;
-		return 0;
-	}
+	if (!emit_to_buffer(&buffer, &size, "]"))
+		return_0;
 
 	return 1;
 }
@@ -63,10 +55,8 @@
 			return 0;
 		}
 
-		if (!str_list_add(mem, tags, dm_pool_strdup(mem, cv->v.str))) {
-			stack;
-			return 0;
-		}
+		if (!str_list_add(mem, tags, dm_pool_strdup(mem, cv->v.str)))
+			return_0;
 
 		cv = cv->next;
 	}
--- LVM2/lib/label/label.c	2008/01/29 23:45:48	1.39
+++ LVM2/lib/label/label.c	2008/01/30 13:19:45	1.40
@@ -86,10 +86,8 @@
 {
 	struct labeller_i *li;
 
-	if (!(li = _alloc_li(name, handler))) {
-		stack;
-		return 0;
-	}
+	if (!(li = _alloc_li(name, handler)))
+		return_0;
 
 	list_add(&_labellers, &li->list);
 	return 1;
@@ -203,10 +201,8 @@
 
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
-	if (!dev_open(dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(dev))
+		return_0;
 
 	/*
 	 * We flush the device just in case someone is stupid
@@ -322,18 +318,14 @@
 	lh->sector_xl = xlate64(label->sector);
 	lh->offset_xl = xlate32(sizeof(*lh));
 
-	if (!(label->labeller->ops->write)(label, buf)) {
-		stack;
-		return 0;
-	}
+	if (!(label->labeller->ops->write)(label, buf))
+		return_0;
 
 	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
 				      ((void *) &lh->offset_xl - (void *) lh)));
 
-	if (!dev_open(dev)) {
-		stack;
-		return 0;
-	}
+	if (!dev_open(dev))
+		return_0;
 
 	log_info("%s: Writing label to sector %" PRIu64, dev_name(dev),
 		 label->sector);
--- LVM2/lib/locking/external_locking.c	2007/08/22 14:38:17	1.13
+++ LVM2/lib/locking/external_locking.c	2008/01/30 13:19:46	1.14
@@ -73,10 +73,8 @@
 	libname = find_config_tree_str(cmd, "global/locking_library",
 				       DEFAULT_LOCKING_LIB);
 
-	if (!(_locking_lib = load_shared_library(cmd, libname, "locking", 1))) {
-		stack;
-		return 0;
-	}
+	if (!(_locking_lib = load_shared_library(cmd, libname, "locking", 1)))
+		return_0;
 
 	/* Get the functions we need */
 	if (!(_init_fn = dlsym(_locking_lib, "locking_init")) ||
--- LVM2/lib/metadata/lv_manip.c	2008/01/26 00:25:04	1.147
+++ LVM2/lib/metadata/lv_manip.c	2008/01/30 13:19:46	1.148
@@ -178,15 +178,12 @@
 	struct lv_segment *seg;
 	uint32_t areas_sz = area_count * sizeof(*seg->areas);
 
-	if (!(seg = dm_pool_zalloc(mem, sizeof(*seg)))) {
-		stack;
-		return NULL;
-	}
+	if (!(seg = dm_pool_zalloc(mem, sizeof(*seg))))
+		return_NULL;
 
 	if (!(seg->areas = dm_pool_zalloc(mem, areas_sz))) {
 		dm_pool_free(mem, seg);
-		stack;
-		return NULL;
+		return_NULL;
 	}
 
 	if (!segtype) {
@@ -290,10 +287,8 @@
 					seg_from->area_len);
 		release_lv_segment_area(seg_to, area_to, seg_to->area_len);
 
-		if (!set_lv_segment_area_pv(seg_to, area_to, pv, pe)) {
-			stack;
-			return 0;
-		}
+		if (!set_lv_segment_area_pv(seg_to, area_to, pv, pe))
+			return_0;
 
 		break;
 
@@ -326,10 +321,8 @@
 	seg->areas[area_num].type = AREA_PV;
 
 	if (!(seg_pvseg(seg, area_num) =
-	      assign_peg_to_lvseg(pv, pe, seg->area_len, seg, area_num))) {
-		stack;
-		return 0;
-	}
+	      assign_peg_to_lvseg(pv, pe, seg->area_len, seg, area_num)))
+		return_0;
 
 	return 1;
 }
@@ -365,10 +358,8 @@
 	struct lv_segment_area *newareas;
 	uint32_t areas_sz = new_area_count * sizeof(*newareas);
 
-	if (!(newareas = dm_pool_zalloc(lv->vg->cmd->mem, areas_sz))) {
-		stack;
-		return 0;
-	}
+	if (!(newareas = dm_pool_zalloc(lv->vg->cmd->mem, areas_sz)))
+		return_0;
 
 	memcpy(newareas, seg->areas, seg->area_count * sizeof(*seg->areas));
 
@@ -423,19 +414,15 @@
 		if (seg->len <= count) {
 			/* remove this segment completely */
 			/* FIXME Check this is safe */
-			if (seg->log_lv && !lv_remove(seg->log_lv)) {
-				stack;
-				return 0;
-			}
+			if (seg->log_lv && !lv_remove(seg->log_lv))
+				return_0;
 			list_del(&seg->list);
 			reduction = seg->len;
 		} else
 			reduction = count;
 
-		if (!_lv_segment_reduce(seg, reduction)) {
-			stack;
-			return 0;
-		}
+		if (!_lv_segment_reduce(seg, reduction))
+			return_0;
 		count -= reduction;
 	}
 
@@ -447,19 +434,15 @@
 
 	/* Remove the LV if it is now empty */
 	if (!lv->le_count) {
-		if (!(lvl = find_lv_in_vg(lv->vg, lv->name))) {
-			stack;
-			return 0;
-		}
+		if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
+			return_0;
 
 		list_del(&lvl->list);
 
 		lv->vg->lv_count--;
 	} else if (lv->vg->fid->fmt->ops->lv_setup &&
-		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv)) {
-		stack;
-		return 0;
-	}
+		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
+		return_0;
 
 	return 1;
 }
@@ -504,10 +487,8 @@
 int lv_remove(struct logical_volume *lv)
 {
 
-	if (!lv_reduce(lv, lv->le_count)) {
-		stack;
-		return 0;
-	}
+	if (!lv_reduce(lv, lv->le_count))
+		return_0;
 
 	return 1;
 }
@@ -684,12 +665,9 @@
 		return 0;
 	}
 
-	for (s = 0; s < area_count; s++) {
-		if (!set_lv_segment_area_pv(seg, s, aa[s].pv, aa[s].pe)) {
-			stack;
-			return 0;
-		}
-	}
+	for (s = 0; s < area_count; s++)
+		if (!set_lv_segment_area_pv(seg, s, aa[s].pv, aa[s].pe))
+			return_0;
 
 	list_add(&lv->segments, &seg->list);
 
@@ -717,10 +695,8 @@
 	list_iterate_items(aa, &alloced_areas[0]) {
 		if (!_setup_alloced_segment(lv, status, area_count,
 					    stripe_size, segtype, aa,
-					    region_size, log_lv)) {
-			stack;
-			return 0;
-		}
+					    region_size, log_lv))
+			return_0;
 	}
 
 	return 1;
@@ -1142,10 +1118,8 @@
 					  allocated,
 					  (ah->log_count && !ah->log_area.len) ?
 						*(areas + ix_offset + ix - 1) :
-						NULL)) {
-			stack;
-			return 0;
-		}
+						NULL))
+			return_0;
 
 	} while (!contiguous && *allocated != needed && can_split);
 
@@ -1187,10 +1161,8 @@
 	/*
 	 * Build the sets of available areas on the pv's.
 	 */
-	if (!(pvms = create_pv_maps(ah->mem, vg, allocatable_pvs))) {
-		stack;
-		return 0;
-	}
+	if (!(pvms = create_pv_maps(ah->mem, vg, allocatable_pvs)))
+		return_0;
 
 	if (!_log_parallel_areas(ah->mem, ah->parallel_areas))
 		stack;
@@ -1315,9 +1287,8 @@
 	if (!segtype_is_virtual(segtype) &&
 	    !_allocate(ah, vg, lv, (lv ? lv->le_count : 0) + extents,
 		       1, allocatable_pvs)) {
-		stack;
 		alloc_destroy(ah);
-		return NULL;
+		return_NULL;
 	}
 
 	return ah;
@@ -1348,10 +1319,8 @@
 	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
 				     num_areas, status,
 				     stripe_size, segtype,
-				     region_size, log_lv)) {
-		stack;
-		return 0;
-	}
+				     region_size, log_lv))
+		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {
 		log_err("Couldn't merge segments after extending "
@@ -1360,10 +1329,8 @@
 	}
 
 	if (lv->vg->fid->fmt->ops->lv_setup &&
-	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv)) {
-		stack;
-		return 0;
-	}
+	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
+		return_0;
 
 	return 1;
 }
@@ -1615,10 +1582,8 @@
 
 	if (mirrors < 2) {
 		if (!lv_add_segment(ah, 0, ah->area_count, lv, segtype, stripe_size,
-			    status, 0, NULL)) {
-			stack;
-			goto out;
-		}
+			    status, 0, NULL))
+			goto_out;
 	} else {
 		if (!_lv_extend_mirror(ah, lv, extents, 0))
 			return_0;
@@ -1787,15 +1752,13 @@
 	backup(vg);
 
 	if (!suspend_lv(cmd, lv)) {
-		stack;
 		vg_revert(vg);
-		return 0;
+		return_0;
 	}
 
 	if (!vg_commit(vg)) {
-		stack;
 		resume_lv(cmd, lv);
-		return 0;
+		return_0;
 	}
 
 	resume_lv(cmd, lv);
@@ -1890,10 +1853,9 @@
 		lv->lvid = *lvid;
 
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv)) {
-		stack;
 		if (ll)
 			dm_pool_free(cmd->mem, ll);
-		return NULL;
+		return_NULL;
 	}
 
 	if (!import)
@@ -1960,10 +1922,8 @@
 		/* Find next segment end */
 		/* FIXME Unnecessary nesting! */
 		if (!_for_each_pv(cmd, lv, current_le, spvs->len, &spvs->len,
-				  0, 0, -1, 0, _add_pvs, (void *) spvs)) {
-			stack;
-			return NULL;
-		}
+				  0, 0, -1, 0, _add_pvs, (void *) spvs))
+			return_NULL;
 
 		current_le = spvs->le + spvs->len;
 	} while (current_le < lv->le_count);
@@ -2055,10 +2015,8 @@
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
 		log_verbose("Removing snapshot %s", lv->name);
-		if (!vg_remove_snapshot(lv)) {
-			stack;
-			return 0;
-		}
+		if (!vg_remove_snapshot(lv))
+			return_0;
 	}
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
--- LVM2/lib/metadata/merge.c	2008/01/26 00:30:28	1.32
+++ LVM2/lib/metadata/merge.c	2008/01/30 13:19:46	1.33
@@ -305,10 +305,8 @@
 						     seg->area_len,
 						 seg_pvseg(seg, s)->len -
 						     seg->area_len,
-						 split_seg, s))) {
-				stack;
-				return 0;
-			}
+						 split_seg, s)))
+				return_0;
 			log_debug("Split %s:%u[%u] at %u: %s PE %u", lv->name,
 				  seg->le, s, le,
 				  dev_name(seg_dev(seg, s)),
@@ -344,15 +342,11 @@
 	if (le == seg->le)
 		return 1;
 
-	if (!_lv_split_segment(lv, seg, le)) {
-		stack;
-		return 0;
-	}
+	if (!_lv_split_segment(lv, seg, le))
+		return_0;
 
-	if (!vg_validate(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_validate(lv->vg))
+		return_0;
 
 	return 1;
 }
--- LVM2/lib/metadata/metadata.c	2008/01/22 16:02:26	1.154
+++ LVM2/lib/metadata/metadata.c	2008/01/30 13:19:46	1.155
@@ -154,10 +154,8 @@
 		return 0;
 	}
 
-	if (!alloc_pv_segment_whole_pv(mem, pv)) {
-		stack;
-		return 0;
-	}
+	if (!alloc_pv_segment_whole_pv(mem, pv))
+		return_0;
 
 	pvl->pv = pv;
 	list_add(&vg->pvs, &pvl->list);
@@ -189,10 +187,8 @@
 	}
 
 	if (!peg_dup(pv_to->fmt->cmd->mem, &pv_to->segments,
-		     &pv_from->segments)) {
-		stack;
-		return 0;
-	}
+		     &pv_from->segments))
+		return_0;
 
 	return 1;
 }
@@ -217,10 +213,8 @@
 
 	list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(pv, pvl->pv)) {
-				stack;
-				return 0;
-			}
+			if (!_copy_pv(pv, pvl->pv))
+				return_0;
 			return 1;
 		}
 	}
@@ -475,10 +469,8 @@
 	int consistent = 0;
 	int old_partial;
 
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
-		stack;
-		return NULL;
-	}
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+		return_NULL;
 
 	/* is this vg name already in use ? */
 	old_partial = partial_mode();
@@ -499,10 +491,8 @@
 
 	vg->cmd = cmd;
 
-	if (!(vg->name = dm_pool_strdup(mem, vg_name))) {
-		stack;
-		goto bad;
-	}
+	if (!(vg->name = dm_pool_strdup(mem, vg_name)))
+		goto_bad;
 
 	vg->seqno = 0;
 
@@ -595,22 +585,16 @@
 	vg->extent_size = new_size;
 
 	if (vg->fid->fmt->ops->vg_setup &&
-	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg)) {
-		stack;
-		return 0;
-	}
+	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg))
+		return_0;
 
 	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_size,
-			     new_size)) {
-		stack;
-		return 0;
-	}
+			     new_size))
+		return_0;
 
 	if (!_recalc_extents(&vg->free_count, vg->name, " free space",
-			     old_size, new_size)) {
-		stack;
-		return 0;
-	}
+			     old_size, new_size))
+		return_0;
 
 	/* foreach PV */
 	list_iterate_items(pvl, &vg->pvs) {
@@ -618,16 +602,12 @@
 
 		pv->pe_size = new_size;
 		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
-				     old_size, new_size)) {
-			stack;
-			return 0;
-		}
+				     old_size, new_size))
+			return_0;
 
 		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
-				     " allocated space", old_size, new_size)) {
-			stack;
-			return 0;
-		}
+				     " allocated space", old_size, new_size))
+			return_0;
 
 		/* foreach free PV Segment */
 		list_iterate_items(pvseg, &pv->segments) {
@@ -636,16 +616,12 @@
 
 			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
 					     " PV segment start", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
 					     " PV segment length", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 		}
 	}
 
@@ -654,39 +630,29 @@
 		lv = lvl->lv;
 
 		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
-				     new_size)) {
-			stack;
-			return 0;
-		}
+				     new_size))
+			return_0;
 
 		list_iterate_items(seg, &lv->segments) {
 			if (!_recalc_extents(&seg->le, lv->name,
 					     " segment start", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 
 			if (!_recalc_extents(&seg->len, lv->name,
 					     " segment length", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 
 			if (!_recalc_extents(&seg->area_len, lv->name,
 					     " area length", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 
 			if (!_recalc_extents(&seg->extents_copied, lv->name,
 					     " extents moved", old_size,
-					     new_size)) {
-				stack;
-				return 0;
-			}
+					     new_size))
+				return_0;
 
 			/* foreach area */
 			for (s = 0; s < seg->area_count; s++) {
@@ -696,27 +662,21 @@
 					    (&seg_pe(seg, s),
 					     lv->name,
 					     " pvseg start", old_size,
-					     new_size)) {
-						stack;
-						return 0;
-					}
+					     new_size))
+						return_0;
 					if (!_recalc_extents
 					    (&seg_pvseg(seg, s)->len,
 					     lv->name,
 					     " pvseg length", old_size,
-					     new_size)) {
-						stack;
-						return 0;
-					}
+					     new_size))
+						return_0;
 					break;
 				case AREA_LV:
 					if (!_recalc_extents
 					    (&seg_le(seg, s), lv->name,
 					     " area start", old_size,
-					     new_size)) {
-						stack;
-						return 0;
-					}
+					     new_size))
+						return_0;
 					break;
 				case AREA_UNASSIGNED:
 					log_error("Unassigned area %u found in "
@@ -804,10 +764,8 @@
 {
 	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
 
-	if (!pv) {
-		stack;
-		return NULL;
-	}
+	if (!pv)
+		return_NULL;
 
 	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN))) {
 		dm_pool_free(mem, pv);
@@ -1074,10 +1032,8 @@
 	/* Remove each copy of the metadata */
 	list_iterate_items(mda, &vg->fid->metadata_areas) {
 		if (mda->ops->vg_remove &&
-		    !mda->ops->vg_remove(vg->fid, vg, mda)) {
-			stack;
-			return 0;
-		}
+		    !mda->ops->vg_remove(vg->fid, vg, mda))
+			return_0;
 	}
 
 	return 1;
@@ -1260,10 +1216,8 @@
 	struct list *mdah;
 	struct metadata_area *mda;
 
-	if (!vg_validate(vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_validate(vg))
+		return_0;
 
 	if (vg->status & PARTIAL_VG) {
 		log_error("Cannot change metadata for partial volume group %s",
@@ -1378,10 +1332,8 @@
 	struct volume_group *vg;
 	struct physical_volume *pv;
 
-	if (!(vginfo = vginfo_from_vgname(ORPHAN, NULL))) {
-		stack;
-		return NULL;
-	}
+	if (!(vginfo = vginfo_from_vgname(ORPHAN, NULL)))
+		return_NULL;
 
 	if (!(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
 		log_error("vg allocation failed");
@@ -1477,15 +1429,11 @@
 	if (!(fmt = fmt_from_vgname(vgname, vgid))) {
 		lvmcache_label_scan(cmd, 0);
 		if (!(fmt = fmt_from_vgname(vgname, vgid))) {
-			if (memlock()) {
-				stack;
-				return NULL;
-			}
+			if (memlock())
+				return_NULL;
 			lvmcache_label_scan(cmd, 2);
-			if (!(fmt = fmt_from_vgname(vgname, vgid))) {
-				stack;
-				return NULL;
-			}
+			if (!(fmt = fmt_from_vgname(vgname, vgid)))
+				return_NULL;
 		}
 	}
 
@@ -1493,10 +1441,8 @@
 		use_precommitted = 0;
 
 	/* Store pvids for later so we can check if any are missing */
-	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
-		stack;
-		return NULL;
-	}
+	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+		return_NULL;
 
 	/* create format instance with appropriate metadata area */
 	if (!(fid = fmt->ops->create_instance(fmt, vgname, vgid, NULL))) {
@@ -1551,15 +1497,11 @@
 	if (!correct_vg) {
 		inconsistent = 0;
 
-		if (memlock()) {
-			stack;
-			return NULL;
-		}
+		if (memlock())
+			return_NULL;
 		lvmcache_label_scan(cmd, 2);
-		if (!(fmt = fmt_from_vgname(vgname, vgid))) {
-			stack;
-			return NULL;
-		}
+		if (!(fmt = fmt_from_vgname(vgname, vgid)))
+			return_NULL;
 
 		if (precommitted && !(fmt->features & FMT_PRECOMMIT))
 			use_precommitted = 0;
@@ -1605,10 +1547,8 @@
 		}
 
 		/* Give up looking */
-		if (!correct_vg) {
-			stack;
-			return NULL;
-		}
+		if (!correct_vg)
+			return_NULL;
 	}
 
 	lvmcache_update_vg(correct_vg);
@@ -1837,10 +1777,8 @@
 	struct lvmcache_info *info;
 	struct device *dev;
 
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		stack;
-		return NULL;
-	}
+	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
+		return_NULL;
 
 	if (!(label_read(dev, &label, UINT64_C(0)))) {
 		if (warnings)
@@ -1871,10 +1809,8 @@
 	if (!pv->size)
 		return NULL;
 	
-	if (!alloc_pv_segment_whole_pv(cmd->mem, pv)) {
-		stack;
-		return NULL;
-	}
+	if (!alloc_pv_segment_whole_pv(cmd->mem, pv))
+		return_NULL;
 
 	return pv;
 }
@@ -1996,10 +1932,8 @@
 		return 0;
 	}
 
-	if (!pv->fmt->ops->pv_write(pv->fmt, pv, mdas, label_sector)) {
-		stack;
-		return 0;
-	}
+	if (!pv->fmt->ops->pv_write(pv->fmt, pv, mdas, label_sector))
+		return_0;
 
 	return 1;
 }
--- LVM2/lib/metadata/mirror.c	2008/01/26 00:25:04	1.66
+++ LVM2/lib/metadata/mirror.c	2008/01/30 13:19:46	1.67
@@ -1002,10 +1002,8 @@
 {
 	struct physical_volume *pv;
 
-	if (!(pv = find_pv_by_name(cmd, name))) {
-		stack;
-		return NULL;
-	}
+	if (!(pv = find_pv_by_name(cmd, name)))
+		return_NULL;
 
 	return find_pvmove_lv(vg, pv->dev, lv_type);
 }
--- LVM2/lib/metadata/pv_manip.c	2007/11/15 22:11:18	1.18
+++ LVM2/lib/metadata/pv_manip.c	2008/01/30 13:19:46	1.19
@@ -53,10 +53,8 @@
 		return 1;
 
 	/* FIXME Cope with holes in PVs */
-	if (!(peg = _alloc_pv_segment(mem, pv, 0, pv->pe_count, NULL, 0))) {
-		stack;
-		return 0;
-	}
+	if (!(peg = _alloc_pv_segment(mem, pv, 0, pv->pe_count, NULL, 0)))
+		return_0;
 
 	list_add(&pv->segments, &peg->list);
 
@@ -72,10 +70,8 @@
 	list_iterate_items(pego, peg_old) {
 		if (!(peg = _alloc_pv_segment(mem, pego->pv, pego->pe,
 					      pego->len, pego->lvseg,
-					      pego->lv_area))) {
-			stack;
-			return 0;
-		} 
+					      pego->lv_area)))
+			return_0;
 		list_add(peg_new, &peg->list);
 	}
 
@@ -93,10 +89,8 @@
 
 	if (!(peg_new = _alloc_pv_segment(pv->fmt->cmd->mem, peg->pv, pe,
 					  peg->len + peg->pe - pe,
-					  NULL, 0))) {
-		stack;
-		return 0;
-	}
+					  NULL, 0)))
+		return_0;
 
 	peg->len = peg->len - peg_new->len;
 
@@ -130,10 +124,8 @@
 	if (pe == peg->pe)
 		return 1;
 
-	if (!_pv_split_segment(pv, peg, pe)) {
-		stack;
-		return 0;
-	}
+	if (!_pv_split_segment(pv, peg, pe))
+		return_0;
 
 	return 1;
 }
@@ -155,10 +147,8 @@
 		return &null_pv_segment;
 
 	if (!pv_split_segment(pv, pe) || 
-	    !pv_split_segment(pv, pe + area_len)) {
-		stack;
-		return NULL;
-	}
+	    !pv_split_segment(pv, pe + area_len))
+		return_NULL;
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
 		log_error("Missing PV segment on %s at %u.",
@@ -196,10 +186,8 @@
 	}
 
 	if (!pv_split_segment(peg->pv, peg->pe + peg->lvseg->area_len -
-				       area_reduction)) {
-		stack;
-		return 0;
-	}
+				       area_reduction))
+		return_0;
 
 	return 1;
 }
@@ -371,10 +359,8 @@
 		}
 	}
 
-	if (!pv_split_segment(pv, new_pe_count)) {
-		stack;
-		return 0;
-	}
+	if (!pv_split_segment(pv, new_pe_count))
+		return_0;
 
 	list_iterate_items_safe(peg, pegt, &pv->segments) {
  		if (peg->pe + peg->len > new_pe_count)
--- LVM2/lib/metadata/pv_map.c	2007/10/12 14:29:32	1.29
+++ LVM2/lib/metadata/pv_map.c	2008/01/30 13:19:46	1.30
@@ -40,10 +40,8 @@
 {
 	struct pv_area *pva;
 
-	if (!(pva = dm_pool_zalloc(mem, sizeof(*pva)))) {
-		stack;
-		return 0;
-	}
+	if (!(pva = dm_pool_zalloc(mem, sizeof(*pva))))
+		return_0;
 
 	log_debug("Allowing allocation on %s start PE %" PRIu32 " length %"
 		  PRIu32, pv_dev_name(pvm->pv), start, length);
@@ -88,10 +86,8 @@
 		area_len = (end >= peg->pe + peg->len - 1) ?
 			   peg->len - (pe - peg->pe) : end - pe + 1;
 
-		if (!_create_single_area(mem, pvm, pe, area_len)) {
-			stack;
-			return 0;
-		}
+		if (!_create_single_area(mem, pvm, pe, area_len))
+			return_0;
 
       next:
 		pe = peg->pe + peg->len;
@@ -108,20 +104,16 @@
 	if (!pe_ranges) {
 		/* Use whole PV */
 		if (!_create_alloc_areas_for_pv(mem, pvm, UINT32_C(0),
-						pvm->pv->pe_count)) {
-			stack;
-			return 0;
-		}
+						pvm->pv->pe_count))
+			return_0;
 
 		return 1;
 	}
 
 	list_iterate_items(aa, pe_ranges) {
 		if (!_create_alloc_areas_for_pv(mem, pvm, aa->start,
-						aa->count)) {
-			stack;
-			return 0;
-		}
+						aa->count))
+			return_0;
 	}
 
 	return 1;
@@ -145,20 +137,16 @@
 			}
 
 		if (!pvm) {
-			if (!(pvm = dm_pool_zalloc(mem, sizeof(*pvm)))) {
-				stack;
-				return 0;
-			}
+			if (!(pvm = dm_pool_zalloc(mem, sizeof(*pvm))))
+				return_0;
 
 			pvm->pv = pvl->pv;
 			list_init(&pvm->areas);
 			list_add(pvms, &pvm->list);
 		}
 
-		if (!_create_all_areas_for_pv(mem, pvm, pvl->pe_ranges)) {
-			stack;
-			return 0;
-		}
+		if (!_create_all_areas_for_pv(mem, pvm, pvl->pe_ranges))
+			return_0;
 	}
 
 	return 1;
--- LVM2/lib/metadata/snapshot_manip.c	2007/11/07 16:33:12	1.29
+++ LVM2/lib/metadata/snapshot_manip.c	2008/01/30 13:19:46	1.30
@@ -70,17 +70,13 @@
 
 	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg))) {
-		stack;
-		return 0;
-	}
+				     ALLOC_INHERIT, 1, origin->vg)))
+		return_0;
 
 	snap->le_count = extent_count;
 
-	if (!(seg = alloc_snapshot_seg(snap, 0, 0))) {
-		stack;
-		return 0;
-	}
+	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
+		return_0;
 
 	seg->chunk_size = chunk_size;
 	seg->origin = origin;
--- LVM2/lib/mirror/mirrored.c	2008/01/17 17:17:09	1.49
+++ LVM2/lib/mirror/mirrored.c	2008/01/30 13:19:46	1.50
@@ -555,10 +555,8 @@
 {
 	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
 
-	if (!segtype) {
-		stack;
-		return NULL;
-	}
+	if (!segtype)
+		return_NULL;
 
 	segtype->cmd = cmd;
 	segtype->ops = &_mirrored_ops;
--- LVM2/lib/report/report.c	2008/01/29 23:45:48	1.73
+++ LVM2/lib/report/report.c	2008/01/30 13:19:46	1.74
@@ -583,10 +583,8 @@
 	const char *disp, *repstr;
 	uint64_t *sortval;
 
-	if (!*(disp = display_size_units(private, (uint64_t) size))) {
-		stack;
-		return 0;
-	}
+	if (!*(disp = display_size_units(private, (uint64_t) size)))
+		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, disp))) {
 		log_error("dm_pool_strdup failed");
@@ -614,10 +612,8 @@
 	const char *disp, *repstr;
 	uint64_t *sortval;
 
-	if (!*(disp = display_size_units(private, size))) {
-		stack;
-		return 0;
-	}
+	if (!*(disp = display_size_units(private, size)))
+		return_0;
 
 	if (!(repstr = dm_pool_strdup(mem, disp))) {
 		log_error("dm_pool_strdup failed");
@@ -809,10 +805,8 @@
 		return 0;
 	}
 
-	if (!id_write_format((const struct id *) data, repstr, 40)) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format((const struct id *) data, repstr, 40))
+		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
--- LVM2/lib/snapshot/snapshot.c	2008/01/11 17:44:26	1.26
+++ LVM2/lib/snapshot/snapshot.c	2008/01/30 13:19:46	1.27
@@ -74,10 +74,8 @@
 	}
 
 	if (!vg_add_snapshot(seg->lv->name, org, cow,
-			     &seg->lv->lvid, seg->len, chunk_size)) {
-		stack;
-		return 0;
-	}
+			     &seg->lv->lvid, seg->len, chunk_size))
+		return_0;
 
 	return 1;
 }
@@ -304,10 +302,8 @@
 	char *dso;
 #endif
 
-	if (!segtype) {
-		stack;
-		return NULL;
-	}
+	if (!segtype)
+		return_NULL;
 
 	segtype->cmd = cmd;
 	segtype->ops = &_snapshot_ops;
--- LVM2/lib/striped/striped.c	2007/08/20 20:55:27	1.22
+++ LVM2/lib/striped/striped.c	2008/01/30 13:19:46	1.23
@@ -213,10 +213,8 @@
 {
 	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
 
-	if (!segtype) {
-		stack;
-		return NULL;
-	}
+	if (!segtype)
+		return_NULL;
 
 	segtype->cmd = cmd;
 	segtype->ops = &_striped_ops;
--- LVM2/lib/zero/zero.c	2007/08/22 14:38:18	1.14
+++ LVM2/lib/zero/zero.c	2008/01/30 13:19:46	1.15
@@ -96,10 +96,8 @@
 {
 	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
 
-	if (!segtype) {
-		stack;
-		return NULL;
-	}
+	if (!segtype)
+		return_NULL;
 
 	segtype->cmd = cmd;
 	segtype->ops = &_zero_ops;
--- LVM2/tools/lvchange.c	2008/01/26 00:25:04	1.87
+++ LVM2/tools/lvchange.c	2008/01/30 13:19:46	1.88
@@ -53,10 +53,8 @@
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(lv->vg))
+		return_0;
 
 	backup(lv->vg);
 
@@ -114,16 +112,12 @@
 	if (activate == CHANGE_ALN) {
 		log_verbose("Deactivating logical volume \"%s\" locally",
 			    lv->name);
-		if (!deactivate_lv_local(cmd, lv)) {
-			stack;
-			return 0;
-		}
+		if (!deactivate_lv_local(cmd, lv))
+			return_0;
 	} else if (activate == CHANGE_AN) {
 		log_verbose("Deactivating logical volume \"%s\"", lv->name);
-		if (!deactivate_lv(cmd, lv)) {
-			stack;
-			return 0;
-		}
+		if (!deactivate_lv(cmd, lv))
+			return_0;
 	} else {
 		if (lockingfailed() && (lv->vg->status & CLUSTERED)) {
 			log_verbose("Locking failed: ignoring clustered "
@@ -134,24 +128,18 @@
 		if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
 			log_verbose("Activating logical volume \"%s\" "
 				    "exclusively", lv->name);
-			if (!activate_lv_excl(cmd, lv)) {
-				stack;
-				return 0;
-			}
+			if (!activate_lv_excl(cmd, lv))
+				return_0;
 		} else if (activate == CHANGE_ALY) {
 			log_verbose("Activating logical volume \"%s\" locally",
 				    lv->name);
-			if (!activate_lv_local(cmd, lv)) {
-				stack;
-				return 0;
-			}
+			if (!activate_lv_local(cmd, lv))
+				return_0;
 		} else {
 			log_verbose("Activating logical volume \"%s\"",
 				    lv->name);
-			if (!activate_lv(cmd, lv)) {
-				stack;
-				return 0;
-			}
+			if (!activate_lv(cmd, lv))
+				return_0;
 		}
 
 		if ((lv->status & LOCKED) &&
@@ -357,18 +345,14 @@
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(lv->vg))
+		return_0;
 
 	backup(lv->vg);
 
 	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_commit(lv->vg))
+		return_0;
 
 	return 1;
 }
@@ -407,10 +391,8 @@
 		    lv->name);
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(lv->vg))
+		return_0;
 
 	backup(lv->vg);
 
@@ -488,17 +470,13 @@
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(lv->vg))
+		return_0;
 
 	backup(lv->vg);
 
-	if (!vg_commit(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_commit(lv->vg))
+		return_0;
 
 	if (active) {
 		log_verbose("Re-activating logical volume \"%s\"", lv->name);
@@ -542,18 +520,14 @@
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_write(lv->vg))
+		return_0;
 
 	backup(lv->vg);
 
 	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_commit(lv->vg))
+		return_0;
 
 	return 1;
 }
--- LVM2/tools/lvconvert.c	2008/01/16 22:54:49	1.57
+++ LVM2/tools/lvconvert.c	2008/01/30 13:19:46	1.58
@@ -743,21 +743,19 @@
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
 			  "volume group \"%s\"", lp.lv_name, lp.vg_name);
-		goto error;
+		goto bad;
 	}
 
 	if (lp.pv_count) {
 		if (!(lp.pvh = create_pv_list(cmd->mem, vg, lp.pv_count,
-					      lp.pvs, 1))) {
-			stack;
-			goto error;
-		}
+					      lp.pvs, 1)))
+			goto_bad;
 	} else
 		lp.pvh = &vg->pvs;
 
 	ret = lvconvert_single(cmd, lvl->lv, &lp);
 
-error:
+bad:
 	unlock_vg(cmd, lp.vg_name);
 
 	if (ret == ECMD_PROCESSED && lp.need_polling) {
--- LVM2/tools/lvcreate.c	2008/01/18 22:02:37	1.170
+++ LVM2/tools/lvcreate.c	2008/01/30 13:19:46	1.171
@@ -135,10 +135,8 @@
 		if ((ptr = strrchr(lp->lv_name, '/')))
 			lp->lv_name = ptr + 1;
 
-		if (!apply_lvname_restrictions(lp->lv_name)) {
-			stack;
-			return 0;
-		}
+		if (!apply_lvname_restrictions(lp->lv_name))
+			return_0;
 
 		if (!validate_name(lp->lv_name)) {
 			log_error("Logical volume name \"%s\" is invalid",
@@ -385,10 +383,8 @@
 		}
 		log_verbose("Setting chunksize to %d sectors.", lp->chunk_size);
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot"))) {
-			stack;
-			return 0;
-		}
+		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
 	} else {
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("-c is only available with snapshots");
@@ -409,10 +405,8 @@
 			return 0;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "striped"))) {
-			stack;
-			return 0;
-		}
+		if (!(lp->segtype = get_segtype_from_string(cmd, "striped")))
+			return_0;
 	} else {
 		if (arg_count(cmd, corelog_ARG)) {
 			log_error("--corelog is only available with mirrors");
@@ -435,10 +429,8 @@
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, cmd) ||
 	    !_read_stripe_params(lp, cmd) ||
-	    !_read_mirror_params(lp, cmd)) {
-		stack;
-		return 0;
-	}
+	    !_read_mirror_params(lp, cmd))
+		return_0;
 
 	/*
 	 * Should we zero the lv.
@@ -557,10 +549,8 @@
 	 */
 	if (lp->pv_count) {
 		if (!(pvh = create_pv_list(cmd->mem, vg,
-					   lp->pv_count, lp->pvs, 1))) {
-			stack;
-			return 0;
-		}
+					   lp->pv_count, lp->pvs, 1)))
+			return_0;
 	} else
 		pvh = &vg->pvs;
 
@@ -712,10 +702,8 @@
 
 	/* The snapshot segment gets created later */
 	if (lp->snapshot &&
-	    !(lp->segtype = get_segtype_from_string(cmd, "striped"))) {
-		stack;
-		return 0;
-	}
+	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
+		return_0;
 
 	if (!archive(vg))
 		return 0;
@@ -754,10 +742,8 @@
 	}
 
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
-				   status, lp->alloc, 0, vg))) {
-		stack;
-		goto error;
-	}
+				   status, lp->alloc, 0, vg)))
+		return_0;
 
 	if (lp->read_ahead) {
 		log_verbose("Setting read ahead sectors");
@@ -775,7 +761,7 @@
 	if (tag && !str_list_add(cmd->mem, &lv->tags, tag)) {
 		log_error("Failed to add tag %s to %s/%s",
 			  tag, lv->vg->name, lv->name);
-		goto error;
+		return 0;
 	}
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
@@ -880,9 +866,6 @@
 
 	return 1;
 
-error:
-	return 0;
-
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate failed new LV. "
--- LVM2/tools/lvmcmdline.c	2008/01/16 18:15:26	1.59
+++ LVM2/tools/lvmcmdline.c	2008/01/30 13:19:47	1.60
@@ -1028,10 +1028,8 @@
 
 	_cmdline.the_args = &_the_args[0];
 
-	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0))) {
-		stack;
-		return NULL;
-	}
+	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
+		return_NULL;
 
 	_init_rand();
 
--- LVM2/tools/lvresize.c	2007/12/20 18:55:46	1.90
+++ LVM2/tools/lvresize.c	2008/01/30 13:19:47	1.91
@@ -150,19 +150,13 @@
 		return 0;
 	}
 
-	if (!lp->nofsck) {
-		if (!exec_cmd("fsadm", "check", lv_path, NULL)) {
-			stack;
-			return 0;
-		}
-	}
-
-	if (lp->resize == LV_REDUCE) {
-		if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
-			stack;
-			return 0;
-		}
-	}
+	if (!lp->nofsck)
+		if (!exec_cmd("fsadm", "check", lv_path, NULL))
+			return_0;
+
+	if (lp->resize == LV_REDUCE)
+		if (!exec_cmd("fsadm", "resize", lv_path, size_buf))
+			return_0;
 
 	return 1;
 }
--- LVM2/tools/pvchange.c	2007/11/15 02:20:03	1.56
+++ LVM2/tools/pvchange.c	2008/01/30 13:19:47	1.57
@@ -164,9 +164,8 @@
 			return 0;
 		}
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-			stack;
 			unlock_vg(cmd, vg_name);
-			return 0;
+			return_0;
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (!is_orphan(pv)) {
--- LVM2/tools/pvmove.c	2007/12/22 12:13:29	1.46
+++ LVM2/tools/pvmove.c	2008/01/30 13:19:47	1.47
@@ -71,18 +71,13 @@
 	struct list *allocatable_pvs, *pvht, *pvh;
 	struct pv_list *pvl;
 
-	if (argc) {
-		if (!(allocatable_pvs = create_pv_list(cmd->mem, vg, argc,
-						       argv, 1))) {
-			stack;
-			return NULL;
-		}
-	} else {
-		if (!(allocatable_pvs = clone_pv_list(cmd->mem, &vg->pvs))) {
-			stack;
-			return NULL;
-		}
-	}
+	if (argc)
+		allocatable_pvs = create_pv_list(cmd->mem, vg, argc, argv, 1);
+	else
+		allocatable_pvs = clone_pv_list(cmd->mem, &vg->pvs);
+
+	if (!allocatable_pvs)
+		return_NULL;
 
 	list_iterate_safe(pvh, pvht, allocatable_pvs) {
 		pvl = list_item(pvh, struct pv_list);
@@ -197,10 +192,8 @@
 			continue;
 		}
 		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
-					    *lvs_changed)) {
-			stack;
-			return NULL;
-		}
+					    *lvs_changed))
+			return_NULL;
 	}
 
 	/* Is temporary mirror empty? */
@@ -236,10 +229,8 @@
 	backup(vg);
 
 	/* Suspend lvs_changed */
-	if (!suspend_lvs(cmd, lvs_changed)) {
-		stack;
-		return 0;
-	}
+	if (!suspend_lvs(cmd, lvs_changed))
+		return_0;
 
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
--- LVM2/tools/pvresize.c	2007/11/16 21:16:20	1.19
+++ LVM2/tools/pvresize.c	2008/01/30 13:19:47	1.20
@@ -144,9 +144,8 @@
 		}
 
 		if (!pv_resize(pv, vg, new_pe_count)) {
-			stack;
 			unlock_vg(cmd, vg_name);
-			return 0;
+			return_0;
 		}
 	}
 
--- LVM2/tools/toollib.c	2008/01/17 17:17:09	1.128
+++ LVM2/tools/toollib.c	2008/01/30 13:19:47	1.129
@@ -978,10 +978,8 @@
 
 	/* Default to whole PV */
 	if (!c) {
-		if (!_add_pe_range(mem, pvname, pe_ranges, UINT32_C(0), size)) {
-			stack;
-			return 0;
-		}
+		if (!_add_pe_range(mem, pvname, pe_ranges, UINT32_C(0), size))
+			return_0;
 		return 1;
 	}
 
@@ -1026,10 +1024,8 @@
 			return 0;
 		}
 
-		if (!_add_pe_range(mem, pvname, pe_ranges, start, end - start + 1)) {
-			stack;
-			return 0;
-		}
+		if (!_add_pe_range(mem, pvname, pe_ranges, start, end - start + 1))
+			return_0;
 
 	}
 
@@ -1084,10 +1080,8 @@
 
 	/* Determine selected physical extents */
 	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, pv_dev_name(pvl->pv),
-			pvl->pv->pe_count)) {
-		stack;
-		return 0;
-	}
+			pvl->pv->pe_count))
+		return_0;
 
 	return 1;
 }
@@ -1124,10 +1118,8 @@
 							tagname)) {
 					if (!_create_pv_entry(mem, pvl, NULL,
 							      allocatable_only,
-							      r)) {
-						stack;
-						return NULL;
-					}
+							      r))
+						return_NULL;
 				}
 			}
 			continue;
@@ -1149,10 +1141,8 @@
 				"Volume Group \"%s\"", pvname, vg->name);
 			return NULL;
 		}
-		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r)) {
-			stack;
-			return NULL;
-		}
+		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r))
+			return_NULL;
 	}
 
 	if (list_empty(r))
--- LVM2/tools/vgmerge.c	2008/01/16 19:54:39	1.43
+++ LVM2/tools/vgmerge.c	2008/01/30 13:19:47	1.44
@@ -42,12 +42,12 @@
 	}
 
 	if (!vgs_are_compatible(cmd, vg_from, vg_to))
-	    goto error;
+		goto_bad;
 
 	/* FIXME List arg: vg_show_with_pv_and_lv(vg_to); */
 
 	if (!archive(vg_from) || !archive(vg_to))
-		goto error;
+		goto_bad;
 
 	/* Merge volume groups */
 	while (!list_empty(&vg_from->pvs)) {
@@ -75,13 +75,11 @@
 					log_error("Failed to generate new "
 						  "random LVID for %s",
 						  lvl2->lv->name);
-					goto error;
+					goto bad;
 				}
                 		if (!id_write_format(&lvid2->id[1], uuid,
-						     sizeof(uuid))) {
-                        		stack;
-                        		goto error;
-		                }
+						     sizeof(uuid)))
+                        		goto_bad;
 
 				log_verbose("Changed LVID for %s to %s",
 					    lvl2->lv->name, uuid);
@@ -110,9 +108,8 @@
 
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
-	if (!vg_write(vg_to) || !vg_commit(vg_to)) {
-		goto error;
-	}
+	if (!vg_write(vg_to) || !vg_commit(vg_to))
+		goto_bad;
 
 	/* FIXME Remove /dev/vgfrom */
 
@@ -125,7 +122,7 @@
 		  vg_from->name, vg_to->name);
 	return ECMD_PROCESSED;
 
-      error:
+      bad:
 	unlock_vg(cmd, vg_name_from);
 	unlock_vg(cmd, vg_name_to);
 	return ECMD_FAILED;
--- LVM2/tools/vgreduce.c	2008/01/17 13:54:05	1.75
+++ LVM2/tools/vgreduce.c	2008/01/30 13:19:47	1.76
@@ -25,10 +25,8 @@
 		return 0;
 	}
 
-	if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
-		stack;
-		return 0;
-	}
+	if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+		return_0;
 
 	log_verbose("Removing PV with UUID %s from VG %s", uuid, vg->name);
 
@@ -91,16 +89,12 @@
 		}
 
 		*list_unsafe = 1;	/* May remove caller's lvht! */
-		if (!vg_remove_snapshot(cow)) {
-			stack;
-			return 0;
-		}
+		if (!vg_remove_snapshot(cow))
+			return_0;
 		log_verbose("Removing LV %s from VG %s", cow->name,
 			    lv->vg->name);
-		if (!lv_remove(cow)) {
-			stack;
-			return 0;
-		}
+		if (!lv_remove(cow))
+			return_0;
 
 		first = 0;
 	}
@@ -129,10 +123,8 @@
 	} else {
 		/* Remove LV immediately. */
 		log_verbose("Removing LV %s from VG %s", lv->name, lv->vg->name);
-		if (!lv_remove(lv)) {
-			stack;
-			return 0;
-		}
+		if (!lv_remove(lv))
+			return_0;
 	}
 
 	return 1;
@@ -177,10 +169,8 @@
 						only_mirror_images_found = 0;
 						continue;
 					}
-					if (!_remove_lv(cmd, lv, &list_unsafe, &lvs_changed)) {
-						stack;
-						return 0;
-					}
+					if (!_remove_lv(cmd, lv, &list_unsafe, &lvs_changed))
+						return_0;
 					if (list_unsafe)
 						goto restart_loop;
 				}
@@ -198,10 +188,8 @@
 		pvl = list_item(pvh, struct pv_list);
 		if (pvl->pv->dev)
 			continue;
-		if (!_remove_pv(vg, pvl)) {
-			stack;
-			return 0;
-		}
+		if (!_remove_pv(vg, pvl))
+			return_0;
 	}
 
 	/* VG is now consistent */
@@ -223,10 +211,9 @@
 			/* Suspend lvs_changed */
 			init_partial(1);
 			if (!suspend_lvs(cmd, &lvs_changed)) {
-				stack;
 				init_partial(0);
 				vg_revert(vg);
-				return 0;
+				return_0;
 			}
 			init_partial(0);
 		}
@@ -290,10 +277,8 @@
 
 			if ((mimages != mirrored_seg->area_count) || remove_log){
 				if (!reconfigure_mirror_images(mirrored_seg, mimages,
-							       NULL, remove_log)) {
-					stack;
-					return 0;
-				}
+							       NULL, remove_log))
+					return_0;
 
 				if (!vg_write(vg)) {
 					log_error("Failed to write out updated "
@@ -353,10 +338,8 @@
 				    lvl->lv->vg->name);
 				/* Skip LVs already removed by mirror code */
 				if (find_lv_in_vg(vg, lvl->lv->name) &&
-				    !lv_remove(lvl->lv)) {
-				stack;
-				return 0;
-			}
+				    !lv_remove(lvl->lv))
+					return_0;
 		}
 	}
 


