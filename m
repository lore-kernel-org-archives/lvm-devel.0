From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jan 2008 14:00:19 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20080130140019.12827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-30 14:00:02

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c fs.c 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/datastruct : btree.c 
	lib/device     : dev-cache.c dev-io.c device.c 
	lib/display    : display.c 
	lib/error      : errseg.c 
	lib/filters    : filter-composite.c filter-persistent.c 
	                 filter-regex.c filter-sysfs.c 
	lib/format1    : disk-rep.c format1.c import-export.c 
	                 import-extents.c layout.c lvm1-label.c 
	                 vg_number.c 
	lib/format_pool: disk_rep.c format_pool.c import_export.c 
	                 pool_label.c 
	lib/format_text: archive.c archiver.c export.c flags.c 
	                 format-text.c import.c import_vsn1.c tags.c 
	                 text_label.c 
	lib/locking    : cluster_locking.c external_locking.c 
	                 file_locking.c locking.c no_locking.c 
	lib/log        : log.c 
	lib/metadata   : lv_manip.c merge.c metadata.c mirror.c 
	                 pv_manip.c pv_map.c segtype.c snapshot_manip.c 
	lib/mirror     : mirrored.c 
	lib/misc       : crc.c lvm-exec.c lvm-file.c lvm-string.c 
	                 sharedlib.c 
	lib/mm         : memlock.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/uuid       : uuid.c 
	lib/zero       : zero.c 
	tools          : dumpconfig.c formats.c lvchange.c lvconvert.c 
	                 lvcreate.c lvdisplay.c lvextend.c lvm-static.c 
	                 lvm.c lvmchange.c lvmcmdlib.c lvmcmdline.c 
	                 lvreduce.c lvremove.c lvrename.c lvresize.c 
	                 lvscan.c polldaemon.c pvchange.c pvcreate.c 
	                 pvdisplay.c pvmove.c pvresize.c pvscan.c 
	                 reporter.c segtypes.c toollib.c vgcfgbackup.c 
	                 vgcfgrestore.c vgchange.c vgck.c vgdisplay.c 
	                 vgexport.c vgextend.c vgimport.c vgmerge.c 
	                 vgmknodes.c vgreduce.c vgremove.c vgrename.c 
	                 vgscan.c vgsplit.c 

Log message:
	Some whitespace tidy-ups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.783&r2=1.784
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-composite.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/layout.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/vg_number.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/sharedlib.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/formats.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvdisplay.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvextend.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmchange.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvreduce.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/segtypes.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmknodes.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2008/01/30 13:19:43	1.783
+++ LVM2/WHATS_NEW	2008/01/30 13:59:56	1.784
@@ -1,5 +1,6 @@
 Version 2.02.33 -
 ===================================
+  Some whitespace tidy-ups.
   Use stack return macros throughout.
   Rely upon internally-cached PV labels while corresponding VG lock is held.
 
--- LVM2/lib/activate/activate.c	2008/01/17 17:17:08	1.131
+++ LVM2/lib/activate/activate.c	2008/01/30 13:59:57	1.132
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/activate/dev_manager.c	2008/01/30 13:19:44	1.133
+++ LVM2/lib/activate/dev_manager.c	2008/01/30 13:59:57	1.134
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -156,9 +156,9 @@
 	struct dm_task *dmt;
 	struct dm_info info;
 	const char *name;
-        uint64_t start, length;
-        char *target_type = NULL;
-        char *params;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
 	void *next = NULL;
 	int r = 0;
 
@@ -186,13 +186,13 @@
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
 	/* For now, we exclude all mirrors */
 
-        do {
-                next = dm_get_next_target(dmt, next, &start, &length,
-                                          &target_type, &params);
-                /* Skip if target type doesn't match */
-                if (target_type && !strcmp(target_type, "mirror"))
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length,
+					  &target_type, &params);
+		/* Skip if target type doesn't match */
+		if (target_type && !strcmp(target_type, "mirror"))
 			goto out;
-        } while (next);
+	} while (next);
 
 	/* FIXME Also check dependencies? */
 
@@ -629,11 +629,11 @@
 	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
 		return_0;
 
-        log_debug("Getting device info for %s [%s]", name, dlid);
-        if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
-                log_error("Failed to get info for %s [%s].", name, dlid);
-                return 0;
-        }
+	log_debug("Getting device info for %s [%s]", name, dlid);
+	if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
+		log_error("Failed to get info for %s [%s].", name, dlid);
+		return 0;
+	}
 
 	if (info.exists && !dm_tree_add_dev(dtree, info.major, info.minor)) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
@@ -967,10 +967,10 @@
 		name = dm_tree_node_get_name(child);
 
 		if (name && lvlayer->old_name && *lvlayer->old_name && strcmp(name, lvlayer->old_name)) {
-	        	if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &vgname, &lvname, &layer)) {
-                		log_error("_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
-                		return 0;
-        		}
+			if (!dm_split_lvm_name(dm->mem, lvlayer->old_name, &vgname, &lvname, &layer)) {
+				log_error("_create_lv_symlinks: Couldn't split up old device name %s", lvlayer->old_name);
+				return 0;
+			}
 			fs_rename_lv(lvlayer->lv, name, lvname);
 		} else if (!dev_manager_lv_mknodes(lvlayer->lv))
 			r = 0;
@@ -990,7 +990,7 @@
 	int r = 1;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
-        	if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child), &vgname, &lvname, &layer)) {
+		if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child), &vgname, &lvname, &layer)) {
 			r = 0;
 			continue;
 		}
@@ -1019,10 +1019,10 @@
 		if (!(uuid = dm_tree_node_get_uuid(child)))
 			continue;
 
-        	if (!dm_split_lvm_name(dm->mem, name, &vgname, &lvname, &layer)) {
-                	log_error("_clean_tree: Couldn't split up device name %s.", name);
-                	return 0;
-        	}
+		if (!dm_split_lvm_name(dm->mem, name, &vgname, &lvname, &layer)) {
+			log_error("_clean_tree: Couldn't split up device name %s.", name);
+			return 0;
+		}
 
 		/* Not meant to be top level? */
 		if (!*layer)
--- LVM2/lib/activate/fs.c	2008/01/30 13:19:44	1.41
+++ LVM2/lib/activate/fs.c	2008/01/30 13:59:57	1.42
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -138,7 +138,7 @@
 	}
 
 	/* To reach this point, the VG must have been locked.
-	 * As locking fails if the VG is active under LVM1, it's 
+	 * As locking fails if the VG is active under LVM1, it's
 	 * now safe to remove any LVM1 devices we find here
 	 * (as well as any existing LVM2 symlink). */
 	if (!lstat(lvm1_group_path, &buf)) {
@@ -175,8 +175,8 @@
 	}
 
 #ifdef HAVE_SELINUX
-        if (!dm_set_selinux_context(lv_path, S_IFLNK))
-                return_0;
+	if (!dm_set_selinux_context(lv_path, S_IFLNK))
+		return_0;
 #endif
 
 	return 1;
--- LVM2/lib/cache/lvmcache.c	2008/01/30 13:19:44	1.35
+++ LVM2/lib/cache/lvmcache.c	2008/01/30 13:59:58	1.36
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -135,7 +135,7 @@
 		return NULL;
 
 	if (vgid)
-		do 
+		do
 			if (!strncmp(vgid, vginfo->vgid, ID_LEN))
 				return vginfo;
 		while ((vginfo = vginfo->next));
@@ -335,7 +335,7 @@
 	}
 
 	list_iterate_items(vginfo, &_vginfos) {
-		if (!str_list_add(cmd->mem, vgids, 
+		if (!str_list_add(cmd->mem, vgids,
 				  dm_pool_strdup(cmd->mem, vginfo->vgid))) {
 			log_error("strlist allocation failed");
 			return NULL;
@@ -358,7 +358,7 @@
 	}
 
 	list_iterate_items(vginfo, &_vginfos) {
-		if (!str_list_add(cmd->mem, vgnames, 
+		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
 			log_error("strlist allocation failed");
 			return NULL;
@@ -384,7 +384,7 @@
 		return pvids;
 
 	list_iterate_items(info, &vginfo->infos) {
-		if (!str_list_add(cmd->mem, pvids, 
+		if (!str_list_add(cmd->mem, pvids,
 				  dm_pool_strdup(cmd->mem, info->dev->pvid))) {
 			log_error("strlist allocation failed");
 			return NULL;
@@ -446,12 +446,12 @@
 	if (info->vginfo && list_empty(&info->vginfo->infos)) {
 		dm_hash_remove(_vgname_hash, info->vginfo->vgname);
 		if (info->vginfo->next) {
-                	if (!dm_hash_insert(_vgname_hash, info->vginfo->vgname, info->vginfo->next)) {
-                        	log_error("vg hash re-insertion failed: %s",
+			if (!dm_hash_insert(_vgname_hash, info->vginfo->vgname, info->vginfo->next)) {
+				log_error("vg hash re-insertion failed: %s",
 					  info->vginfo->vgname);
-                        	return 0;
+				return 0;
 			}
-                }
+		}
 
 		if (info->vginfo->vgname)
 			dm_free(info->vginfo->vgname);
@@ -477,7 +477,7 @@
 	_drop_vginfo(info);
 
 	info->label->labeller->ops->destroy_label(info->label->labeller,
-						info->label); 
+						info->label);
 	dm_free(info);
 
 	return;
@@ -617,7 +617,7 @@
 	struct lvmcache_vginfo *vginfo, *primary_vginfo;
 	// struct lvmcache_vginfo  *old_vginfo, *next;
 
-	/* If vgname is NULL and we don't already have a vgname, 
+	/* If vgname is NULL and we don't already have a vgname,
 	 * assume ORPHAN - we want every entry to have a vginfo
 	 * attached for scanning reasons.
 	 */
@@ -643,9 +643,9 @@
 				dm_hash_remove(_vgname_hash, old_vginfo->vgname);
 				if (old_vginfo->next) {
 					if (!dm_hash_insert(_vgname_hash, old_vginfo->vgname, old_vginfo->next)) {
-                        			log_error("vg hash re-insertion failed: %s",
+						log_error("vg hash re-insertion failed: %s",
 							  old_vginfo->vgname);
-                        			return 0;
+						return 0;
 					}
 				}
 			} else do {
@@ -662,11 +662,11 @@
 				return 0;
 			}
 
-			// Rename so can assume new name does not already exist 
+			// Rename so can assume new name does not already exist
 			if (!dm_hash_insert(_vgname_hash, vginfo->vgname, vginfo->next)) {
 				log_error("vg hash re-insertion failed: %s",
 					  vginfo->vgname);
-                      		return 0;
+		      		return 0;
 			}
 		} else {
 ***/
--- LVM2/lib/commands/toolcontext.c	2008/01/30 13:19:44	1.56
+++ LVM2/lib/commands/toolcontext.c	2008/01/30 13:59:58	1.57
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -529,7 +529,7 @@
 
 	/*
 	 * sysfs filter. Only available on 2.6 kernels.  Non-critical.
-	 * Listed first because it's very efficient at eliminating 
+	 * Listed first because it's very efficient at eliminating
 	 * unavailable devices.
 	 */
 	if (find_config_tree_bool(cmd, "devices/sysfs_scan",
--- LVM2/lib/datastruct/btree.c	2008/01/30 13:19:44	1.12
+++ LVM2/lib/datastruct/btree.c	2008/01/30 13:59:58	1.13
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/device/dev-cache.c	2008/01/30 13:19:44	1.51
+++ LVM2/lib/device/dev-cache.c	2008/01/30 13:59:58	1.52
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -488,7 +488,7 @@
 		if (v->type != CFG_STRING) {
 			log_error("preferred_names patterns must be enclosed in quotes");
 			return 0;
-		}       
+		}
 
 		count++;
 	}
--- LVM2/lib/device/dev-io.c	2008/01/30 13:19:44	1.61
+++ LVM2/lib/device/dev-io.c	2008/01/30 13:59:58	1.62
@@ -336,7 +336,7 @@
 
 		if (dev->open_count && !need_excl) {
 			/* FIXME Ensure we never get here */
-			log_debug("WARNING: %s already opened read-only", 
+			log_debug("WARNING: %s already opened read-only",
 				  dev_name(dev));
 			dev->open_count++;
 		}
@@ -516,7 +516,7 @@
 
 	/* Close unless device is known to belong to a locked VG */
 	if (immediate ||
-	    (dev->open_count < 1 && 
+	    (dev->open_count < 1 &&
 	     (!(info = info_from_pvid(dev->pvid, 0)) ||
 	      !info->vginfo ||
 	      !vgname_is_locked(info->vginfo->vgname))))
--- LVM2/lib/device/device.c	2008/01/30 13:19:44	1.25
+++ LVM2/lib/device/device.c	2008/01/30 13:59:58	1.26
@@ -27,16 +27,16 @@
 #define PART_OFFSET UINT64_C(0x1BE)
 
 struct partition {
-        uint8_t boot_ind;
-        uint8_t head;
-        uint8_t sector;
-        uint8_t cyl;
-        uint8_t sys_ind;	/* partition type */
-        uint8_t end_head;
-        uint8_t end_sector;
-        uint8_t end_cyl;
-        uint32_t start_sect;
-        uint32_t nr_sects;
+	uint8_t boot_ind;
+	uint8_t head;
+	uint8_t sector;
+	uint8_t cyl;
+	uint8_t sys_ind;	/* partition type */
+	uint8_t end_head;
+	uint8_t end_sector;
+	uint8_t end_cyl;
+	uint32_t start_sect;
+	uint32_t nr_sects;
 } __attribute__((packed));
 
 static int _is_partitionable(struct device *dev)
--- LVM2/lib/display/display.c	2008/01/30 13:19:44	1.84
+++ LVM2/lib/display/display.c	2008/01/30 13:59:58	1.85
@@ -694,7 +694,7 @@
 		(uint64_t) vg->extent_count * (vg->extent_size / 2),
 		vg->extent_size / 2,
 		vg->extent_count,
-		vg->extent_count - vg->free_count, 
+		vg->extent_count - vg->free_count,
 		vg->free_count,
 		uuid[0] ? uuid : "none");
 	return;
--- LVM2/lib/error/errseg.c	2007/08/22 14:38:16	1.15
+++ LVM2/lib/error/errseg.c	2008/01/30 13:59:58	1.16
@@ -77,7 +77,7 @@
 
 	return 1;
 }
- 
+
 static void _errseg_destroy(const struct segment_type *segtype)
 {
 	dm_free((void *)segtype);
--- LVM2/lib/filters/filter-composite.c	2008/01/30 13:19:45	1.14
+++ LVM2/lib/filters/filter-composite.c	2008/01/30 13:59:58	1.15
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/filters/filter-persistent.c	2008/01/30 13:19:45	1.34
+++ LVM2/lib/filters/filter-persistent.c	2008/01/30 13:59:58	1.35
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -97,13 +97,13 @@
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	struct config_tree *cft;
-        struct stat info;
+	struct stat info;
 	int r = 0;
 
-        if (!stat(pf->file, &info))
+	if (!stat(pf->file, &info))
 		pf->ctime = info.st_ctime;
 	else {
-                log_very_verbose("%s: stat failed: %s", pf->file,
+		log_very_verbose("%s: stat failed: %s", pf->file,
 				 strerror(errno));
 		return_0;
 	}
--- LVM2/lib/filters/filter-regex.c	2008/01/30 13:19:45	1.24
+++ LVM2/lib/filters/filter-regex.c	2008/01/30 13:59:58	1.25
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/filters/filter-sysfs.c	2007/10/10 11:31:21	1.18
+++ LVM2/lib/filters/filter-sysfs.c	2008/01/30 13:59:58	1.19
@@ -236,21 +236,21 @@
  */
 static int _read_devs(struct dev_set *ds, const char *dir, unsigned sysfs_depth)
 {
-        struct dirent *d;
-        DIR *dr;
+	struct dirent *d;
+	DIR *dr;
 	struct stat info;
 	char path[PATH_MAX];
 	char file[PATH_MAX];
 	dev_t dev = { 0 };
 	int r = 1;
 
-        if (!(dr = opendir(dir))) {
-                log_sys_error("opendir", dir);
-                return 0;
-        }
+	if (!(dr = opendir(dir))) {
+		log_sys_error("opendir", dir);
+		return 0;
+	}
 
-        while ((d = readdir(dr))) {
-                if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
+	while ((d = readdir(dr))) {
+		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
 			continue;
 
 		if (dm_snprintf(path, sizeof(path), "%s/%s", dir,
@@ -278,8 +278,8 @@
 		}
 	}
 
-        if (closedir(dr))
-                log_sys_error("closedir", dir);
+	if (closedir(dr))
+		log_sys_error("closedir", dir);
 
 	return r;
 }
--- LVM2/lib/format1/disk-rep.c	2008/01/30 13:19:45	1.71
+++ LVM2/lib/format1/disk-rep.c	2008/01/30 13:59:59	1.72
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -133,15 +133,15 @@
 		return 0;
 	}
 
-        /* UUID too long? */
-        if (pvd->pv_uuid[ID_LEN]) {
+	/* UUID too long? */
+	if (pvd->pv_uuid[ID_LEN]) {
 		/* Retain ID_LEN chars from end */
-                for (e = ID_LEN; e < sizeof(pvd->pv_uuid); e++) {
-                        if (!pvd->pv_uuid[e]) {
-                                e--;
-                                break;
-                        }
-                }
+		for (e = ID_LEN; e < sizeof(pvd->pv_uuid); e++) {
+			if (!pvd->pv_uuid[e]) {
+				e--;
+				break;
+			}
+		}
 		for (b = 0; b < ID_LEN; b++) {
 			pvd->pv_uuid[b] = pvd->pv_uuid[++e - ID_LEN];
 			/* FIXME Remove all invalid chars */
@@ -149,7 +149,7 @@
 				pvd->pv_uuid[b] = '#';
 		}
 		memset(&pvd->pv_uuid[ID_LEN], 0, sizeof(pvd->pv_uuid) - ID_LEN);
-        }
+	}
 
 	/* If UUID is missing, create one */
 	if (pvd->pv_uuid[0] == '\0') {
@@ -160,8 +160,8 @@
 	return 1;
 }
 
-/* 
- * If exported, remove "PV_EXP" from end of VG name 
+/*
+ * If exported, remove "PV_EXP" from end of VG name
  */
 static void _munge_exported_vg(struct pv_disk *pvd)
 {
@@ -177,8 +177,8 @@
 	s = sizeof(EXPORTED_TAG);
 	if (!strncmp((char *)pvd->vg_name + l - s + 1, EXPORTED_TAG, s)) {
 		pvd->vg_name[l - s + 1] = '\0';
-                pvd->pv_status |= VG_EXPORTED;
-        }
+		pvd->pv_status |= VG_EXPORTED;
+	}
 }
 
 int munge_pvd(struct device *dev, struct pv_disk *pvd)
--- LVM2/lib/format1/format1.c	2008/01/30 13:19:45	1.104
+++ LVM2/lib/format1/format1.c	2008/01/30 13:59:59	1.105
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -444,7 +444,7 @@
 	return 1;
 }
 
-static int _format1_segtype_supported(struct format_instance *fid __attribute((unused)), 
+static int _format1_segtype_supported(struct format_instance *fid __attribute((unused)),
 				      const struct segment_type *segtype)
 {
 	if (!(segtype->flags & SEG_FORMAT1_SUPPORT))
--- LVM2/lib/format1/import-export.c	2008/01/30 13:19:45	1.93
+++ LVM2/lib/format1/import-export.c	2008/01/30 13:59:59	1.94
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -618,7 +618,7 @@
 
 			/* insert the snapshot */
 			if (!vg_add_snapshot(NULL, org, cow, NULL,
-					     org->le_count, 
+					     org->le_count,
 					     lvd->lv_chunk_size)) {
 				log_err("Couldn't add snapshot.");
 				return 0;
--- LVM2/lib/format1/import-extents.c	2008/01/30 13:19:45	1.35
+++ LVM2/lib/format1/import-extents.c	2008/01/30 13:59:59	1.36
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -280,7 +280,7 @@
 	while (first_area_le < total_area_len) {
 		area_len = 1;
 
-		/* 
+		/*
 		 * Find how many extents are contiguous in all stripes
 		 * and so can form part of this segment
 		 */
--- LVM2/lib/format1/layout.c	2008/01/30 13:19:45	1.28
+++ LVM2/lib/format1/layout.c	2008/01/30 13:59:59	1.29
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format1/lvm1-label.c	2008/01/30 13:19:45	1.17
+++ LVM2/lib/format1/lvm1-label.c	2008/01/30 13:59:59	1.18
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format1/vg_number.c	2008/01/30 13:19:45	1.14
+++ LVM2/lib/format1/vg_number.c	2008/01/30 13:59:59	1.15
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_pool/disk_rep.c	2008/01/30 13:19:45	1.12
+++ LVM2/lib/format_pool/disk_rep.c	2008/01/30 13:59:59	1.13
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_pool/format_pool.c	2008/01/30 13:19:45	1.12
+++ LVM2/lib/format_pool/format_pool.c	2008/01/30 13:59:59	1.13
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_pool/import_export.c	2008/01/30 13:19:45	1.20
+++ LVM2/lib/format_pool/import_export.c	2008/01/30 13:59:59	1.21
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -215,7 +215,7 @@
 						     "striped")))
 		return_0;
 
-	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur, 
+	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
 				     usp->striping, NULL, usp->num_devs,
 				     area_len, 0, 0, 0))) {
--- LVM2/lib/format_pool/pool_label.c	2007/08/22 14:38:16	1.7
+++ LVM2/lib/format_pool/pool_label.c	2008/01/30 13:59:59	1.8
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_text/archive.c	2008/01/30 13:19:45	1.30
+++ LVM2/lib/format_text/archive.c	2008/01/30 13:59:59	1.31
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_text/archiver.c	2008/01/30 13:19:45	1.12
+++ LVM2/lib/format_text/archiver.c	2008/01/30 13:59:59	1.13
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -115,9 +115,9 @@
 		return 0;
 
 	/* Trap a read-only file system */
-        if ((access(vg->cmd->archive_params->dir, R_OK | W_OK | X_OK) == -1) &&
+	if ((access(vg->cmd->archive_params->dir, R_OK | W_OK | X_OK) == -1) &&
 	     (errno == EROFS))
-                return 0;
+		return 0;
 
 	log_verbose("Archiving volume group \"%s\" metadata (seqno %u).", vg->name,
 		    vg->seqno);
@@ -219,9 +219,9 @@
 		return 0;
 
 	/* Trap a read-only file system */
-        if ((access(vg->cmd->backup_params->dir, R_OK | W_OK | X_OK) == -1) &&
+	if ((access(vg->cmd->backup_params->dir, R_OK | W_OK | X_OK) == -1) &&
 	    (errno == EROFS))
-                return 0;
+		return 0;
 
 	if (!__backup(vg)) {
 		log_error("Backup of volume group %s metadata failed.",
--- LVM2/lib/format_text/export.c	2008/01/30 13:19:45	1.60
+++ LVM2/lib/format_text/export.c	2008/01/30 13:59:59	1.61
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -37,7 +37,7 @@
  * Then argument list is reset and out_with_comment_fn is called again.
  */
 #define _out_with_comment(f, buffer, fmt, ap) \
-        do { \
+	do { \
 		va_start(ap, fmt); \
 		r = f->out_with_comment(f, buffer, fmt, ap); \
 		va_end(ap); \
--- LVM2/lib/format_text/flags.c	2008/01/30 13:19:45	1.32
+++ LVM2/lib/format_text/flags.c	2008/01/30 13:59:59	1.33
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_text/format-text.c	2008/01/30 13:19:45	1.87
+++ LVM2/lib/format_text/format-text.c	2008/01/30 13:59:59	1.88
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -250,7 +250,7 @@
 static int _text_lv_setup(struct format_instance *fid __attribute((unused)),
 			  struct logical_volume *lv)
 {
-/******** FIXME Any LV size restriction? 
+/******** FIXME Any LV size restriction?
 	uint64_t max_size = UINT_MAX;
 
 	if (lv->size > max_size) {
@@ -581,7 +581,7 @@
 		if (!dev_write(mdac->area.dev,
 			       mdac->area.start + MDA_HEADER_SIZE,
 			       (size_t) new_wrap,
-			       fidtc->raw_metadata_buf + 
+			       fidtc->raw_metadata_buf +
 			       mdac->rlocn.size - new_wrap))
 			goto_out;
 	}
@@ -1092,7 +1092,7 @@
 
 	log_debug("%s: Found metadata at %" PRIu64 " size %" PRIu64
 		  " (in area at %" PRIu64 " size %" PRIu64
-		  ") for %s (%s)", 
+		  ") for %s (%s)",
 		  dev_name(dev_area->dev), dev_area->start + rlocn->offset,
 		  rlocn->size, dev_area->start, dev_area->size, vgname, uuid);
 
@@ -1330,7 +1330,7 @@
 	else
 		list_init(&info->das);
 
-	/* Set pe_start to first aligned sector after any metadata 
+	/* Set pe_start to first aligned sector after any metadata
 	 * areas that begin before pe_start */
 	pv->pe_start = pe_align();
 	list_iterate_items(mda, &info->mdas) {
--- LVM2/lib/format_text/import.c	2008/01/30 13:19:45	1.44
+++ LVM2/lib/format_text/import.c	2008/01/30 13:59:59	1.45
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -51,7 +51,7 @@
 				    offset2, size2, checksum_fn, checksum)))
 		goto_out;
 
-	/* 
+	/*
 	 * Find a set of version functions that can read this file
 	 */
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
@@ -104,7 +104,7 @@
 		goto out;
 	}
 
-	/* 
+	/*
 	 * Find a set of version functions that can read this file
 	 */
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
--- LVM2/lib/format_text/import_vsn1.c	2008/01/30 13:19:45	1.48
+++ LVM2/lib/format_text/import_vsn1.c	2008/01/30 13:59:59	1.49
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -225,24 +225,24 @@
 	pv->pe_alloc_count = 0;
 	pv->fmt = fid->fmt;
 
-        /* Fix up pv size if missing or impossibly large */
-        if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
-                if (!dev_get_size(pv->dev, &pv->size)) {
-                        log_error("%s: Couldn't get size.", pv_dev_name(pv));
-                        return 0;
-                }
-                log_verbose("Fixing up missing size (%s) "
-                            "for PV %s", display_size(fid->fmt->cmd, pv->size),
-                            pv_dev_name(pv));
-                if (vg) {
-                        size = pv->pe_count * (uint64_t) vg->extent_size +
-                               pv->pe_start;
-                        if (size > pv->size)
-                                log_error("WARNING: Physical Volume %s is too "
-                                          "large for underlying device",
-                                          pv_dev_name(pv));
-                }
-        }
+	/* Fix up pv size if missing or impossibly large */
+	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
+		if (!dev_get_size(pv->dev, &pv->size)) {
+			log_error("%s: Couldn't get size.", pv_dev_name(pv));
+			return 0;
+		}
+		log_verbose("Fixing up missing size (%s) "
+			    "for PV %s", display_size(fid->fmt->cmd, pv->size),
+			    pv_dev_name(pv));
+		if (vg) {
+			size = pv->pe_count * (uint64_t) vg->extent_size +
+			       pv->pe_start;
+			if (size > pv->size)
+				log_error("WARNING: Physical Volume %s is too "
+					  "large for underlying device",
+					  pv_dev_name(pv));
+		}
+	}
 
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
@@ -834,7 +834,7 @@
 	old_suppress = log_suppress(2);
 	*creation_host = dm_pool_strdup(mem,
 					find_config_str(cft->root,
-						        "creation_host", ""));
+							"creation_host", ""));
 	log_suppress(old_suppress);
 
 	/* skip any top-level values */
--- LVM2/lib/format_text/tags.c	2008/01/30 13:19:45	1.5
+++ LVM2/lib/format_text/tags.c	2008/01/30 13:59:59	1.6
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/format_text/text_label.c	2007/11/05 17:17:55	1.19
+++ LVM2/lib/format_text/text_label.c	2008/01/30 13:59:59	1.20
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -239,7 +239,7 @@
 
 	list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
-		if ((vgname = vgname_from_mda(info->fmt, &mdac->area, 
+		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
 		    !lvmcache_update_vgname_and_id(info, vgname,
--- LVM2/lib/locking/cluster_locking.c	2007/12/05 13:17:18	1.24
+++ LVM2/lib/locking/cluster_locking.c	2008/01/30 13:59:59	1.25
@@ -104,8 +104,8 @@
 	/* Send it to CLVMD */
  rewrite:
 	if ( (err = write(_clvmd_sock, inbuf, inlen)) != inlen) {
-	        if (err == -1 && errno == EINTR)
-		        goto rewrite;
+		if (err == -1 && errno == EINTR)
+			goto rewrite;
 		log_error("Error writing data to clvmd: %s", strerror(errno));
 		return 0;
 	}
@@ -113,8 +113,8 @@
 	/* Get the response */
  reread:
 	if ((len = read(_clvmd_sock, outbuf, sizeof(struct clvm_header))) < 0) {
-	        if (errno == EINTR)
-		        goto reread;
+		if (errno == EINTR)
+			goto reread;
 		log_error("Error reading data from clvmd: %s", strerror(errno));
 		return 0;
 	}
@@ -330,7 +330,7 @@
 	 * locks are cluster-wide.
 	 * Also, if the lock is exclusive it makes no sense to try to
 	 * acquire it on all nodes, so just do that on the local node too.
-	 * One exception, is that P_ locks /do/ get distributed across 
+	 * One exception, is that P_ locks /do/ get distributed across
 	 * the cluster because they might have side-effects.
 	 */
 	if (strncmp(name, "P_", 2) &&
@@ -446,10 +446,10 @@
 
 	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
 			 lock_type,
-			 flags & LCK_NONBLOCK ? "" : "B", 
-			 flags & LCK_HOLD ? "H" : "", 
-			 flags & LCK_LOCAL ? "L" : "", 
-			 flags & LCK_CLUSTER_VG ? "C" : "", 
+			 flags & LCK_NONBLOCK ? "" : "B",
+			 flags & LCK_HOLD ? "H" : "",
+			 flags & LCK_LOCAL ? "L" : "",
+			 flags & LCK_CLUSTER_VG ? "C" : "",
 			 flags);
 
 	/* Send a message to the cluster manager */
@@ -479,7 +479,7 @@
 
 	_clvmd_sock = _open_local_sock();
 	if (_clvmd_sock == -1)
-	        stack;
+		stack;
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
--- LVM2/lib/locking/external_locking.c	2008/01/30 13:19:46	1.14
+++ LVM2/lib/locking/external_locking.c	2008/01/30 13:59:59	1.15
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/locking/file_locking.c	2007/11/16 21:16:20	1.33
+++ LVM2/lib/locking/file_locking.c	2008/01/30 13:59:59	1.34
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/locking/locking.c	2007/11/16 21:16:20	1.43
+++ LVM2/lib/locking/locking.c	2008/01/30 13:59:59	1.44
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -253,7 +253,7 @@
 	}
 
 	if ((type == 2 || type == 3) &&
-            find_config_tree_int(cmd, "locking/fallback_to_local_locking",
+	    find_config_tree_int(cmd, "locking/fallback_to_local_locking",
 				 DEFAULT_FALLBACK_TO_LOCAL_LOCKING)) {
 		log_warn("WARNING: Falling back to local file-based locking.");
 		log_warn("Volume Groups with the clustered attribute will "
--- LVM2/lib/locking/no_locking.c	2007/08/22 14:38:17	1.13
+++ LVM2/lib/locking/no_locking.c	2008/01/30 13:59:59	1.14
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/log/log.c	2007/08/20 20:55:26	1.41
+++ LVM2/lib/log/log.c	2008/01/30 13:59:59	1.42
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/metadata/lv_manip.c	2008/01/30 13:19:46	1.148
+++ LVM2/lib/metadata/lv_manip.c	2008/01/30 14:00:00	1.149
@@ -1679,8 +1679,8 @@
  */
 static int _for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
 			    int (*func)(struct cmd_context *cmd,
-				        struct logical_volume *lv,
-				        void *data),
+					struct logical_volume *lv,
+					void *data),
 			    void *data)
 {
 	struct lv_segment *seg;
--- LVM2/lib/metadata/merge.c	2008/01/30 13:19:46	1.33
+++ LVM2/lib/metadata/merge.c	2008/01/30 14:00:00	1.34
@@ -24,7 +24,7 @@
 /*
  * Attempt to merge two adjacent segments.
  * Currently only supports striped segments on AREA_PV.
- * Returns success if successful, in which case 'first' 
+ * Returns success if successful, in which case 'first'
  * gets adjusted to contain both areas.
  */
 static int _merge(struct lv_segment *first, struct lv_segment *second)
@@ -76,7 +76,7 @@
 			r = 0;
 		}
 
-		area_multiplier = segtype_is_striped(seg->segtype) ? 
+		area_multiplier = segtype_is_striped(seg->segtype) ?
 					seg->area_count : 1;
 
 		if (seg->area_len * area_multiplier != seg->len) {
--- LVM2/lib/metadata/metadata.c	2008/01/30 13:19:46	1.155
+++ LVM2/lib/metadata/metadata.c	2008/01/30 14:00:00	1.156
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -36,9 +36,9 @@
 #define pv_field(handle, field)				\
 	(((const struct physical_volume *)(handle))->field)
 
-static struct physical_volume *_pv_read(struct cmd_context *cmd, 
+static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					const char *pv_name,
-					struct list *mdas, 
+					struct list *mdas,
 					uint64_t *label_sector,
 					int warnings);
 
@@ -51,7 +51,7 @@
 				  int pvmetadatacopies,
 				  uint64_t pvmetadatasize, struct list *mdas);
 
-static int _pv_write(struct cmd_context *cmd __attribute((unused)), 
+static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 		     struct physical_volume *pv,
 	     	     struct list *mdas, int64_t label_sector);
 
@@ -748,7 +748,7 @@
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct list *mdas)
 {
-	return _pv_create(fmt, dev, id, size, pe_start, 
+	return _pv_create(fmt, dev, id, size, pe_start,
 			  existing_extent_count,
 			  existing_extent_size,
 			  pvmetadatacopies,
@@ -1392,7 +1392,7 @@
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned unless PARTIAL_VG.
  * If consistent is 0, caller must check whether consistent == 1 on return
- * and take appropriate action if it isn't (e.g. abort; get write lock 
+ * and take appropriate action if it isn't (e.g. abort; get write lock
  * and call vg_read again).
  *
  * If precommitted is set, use precommitted metadata if present.
@@ -1649,8 +1649,8 @@
 	return vg;
 }
 
-/* This is only called by lv_from_lvid, which is only called from 
- * activate.c so we know the appropriate VG lock is already held and 
+/* This is only called by lv_from_lvid, which is only called from
+ * activate.c so we know the appropriate VG lock is already held and
  * the vg_read is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
@@ -1688,7 +1688,7 @@
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
-	// The slow way - full scan required to cope with vgrename 
+	// The slow way - full scan required to cope with vgrename
 	if (!(vgnames = get_vgs(cmd, 2))) {
 		log_error("vg_read_by_vgid: get_vgs failed");
 		return NULL;
@@ -1697,7 +1697,7 @@
 	list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
 		if (!vgname || is_orphan_vg(vgname))
-			continue;	// FIXME Unnecessary? 
+			continue;	// FIXME Unnecessary?
 		consistent = 0;
 		if ((vg = _vg_read(cmd, vgname, vgid, &consistent,
 				   precommitted)) &&
@@ -1766,9 +1766,9 @@
 }
 
 /* FIXME Use label functions instead of PV functions */
-static struct physical_volume *_pv_read(struct cmd_context *cmd, 
+static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					const char *pv_name,
-					struct list *mdas, 
+					struct list *mdas,
 					uint64_t *label_sector,
 					int warnings)
 {
@@ -1917,7 +1917,7 @@
 	return _pv_write(cmd, pv, mdas, label_sector);
 }
 
-static int _pv_write(struct cmd_context *cmd __attribute((unused)), 
+static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 		     struct physical_volume *pv,
 	     	     struct list *mdas, int64_t label_sector)
 {
--- LVM2/lib/metadata/mirror.c	2008/01/30 13:19:46	1.67
+++ LVM2/lib/metadata/mirror.c	2008/01/30 14:00:00	1.68
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -33,8 +33,8 @@
 #define MIRROR_DISK_VERSION 2
 
 /* These are the flags that represent the mirror failure restoration policies */
-#define MIRROR_REMOVE            0
-#define MIRROR_ALLOCATE          1
+#define MIRROR_REMOVE		 0
+#define MIRROR_ALLOCATE		 1
 #define MIRROR_ALLOCATE_ANYWHERE 2
 
 /*
--- LVM2/lib/metadata/pv_manip.c	2008/01/30 13:19:46	1.19
+++ LVM2/lib/metadata/pv_manip.c	2008/01/30 14:00:00	1.20
@@ -146,7 +146,7 @@
 	if (!pv)
 		return &null_pv_segment;
 
-	if (!pv_split_segment(pv, pe) || 
+	if (!pv_split_segment(pv, pe) ||
 	    !pv_split_segment(pv, pe + area_len))
 		return_NULL;
 
--- LVM2/lib/metadata/pv_map.c	2008/01/30 13:19:46	1.30
+++ LVM2/lib/metadata/pv_map.c	2008/01/30 14:00:00	1.31
@@ -56,7 +56,7 @@
 static int _create_alloc_areas_for_pv(struct dm_pool *mem, struct pv_map *pvm,
 				      uint32_t start, uint32_t count)
 {
-        struct pv_segment *peg;
+	struct pv_segment *peg;
 	uint32_t pe, end, area_len;
 
 	/* Only select extents from start to end inclusive */
@@ -67,7 +67,7 @@
 	pe = start;
 
 	/* Walk through complete ordered list of device segments */
-        list_iterate_items(peg, &pvm->pv->segments) {
+	list_iterate_items(peg, &pvm->pv->segments) {
 		/* pe holds the next extent we want to check */
 
 		/* Beyond the range we're interested in? */
@@ -91,7 +91,7 @@
 
       next:
 		pe = peg->pe + peg->len;
-        }
+	}
 
 	return 1;
 }
--- LVM2/lib/metadata/segtype.c	2007/08/20 20:55:26	1.2
+++ LVM2/lib/metadata/segtype.c	2008/01/30 14:00:00	1.3
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/metadata/snapshot_manip.c	2008/01/30 13:19:46	1.30
+++ LVM2/lib/metadata/snapshot_manip.c	2008/01/30 14:00:00	1.31
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/mirror/mirrored.c	2008/01/30 13:19:46	1.50
+++ LVM2/lib/mirror/mirrored.c	2008/01/30 14:00:00	1.51
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -110,19 +110,19 @@
 		}
 	}
 
-        if ((cn = find_config_node(sn, "mirror_log"))) {
-                if (!cn->v || !cn->v->v.str) {
-                        log_error("Mirror log type must be a string.");
-                        return 0;
-                }
-                logname = cn->v->v.str;
+	if ((cn = find_config_node(sn, "mirror_log"))) {
+		if (!cn->v || !cn->v->v.str) {
+			log_error("Mirror log type must be a string.");
+			return 0;
+		}
+		logname = cn->v->v.str;
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
 			log_error("Unrecognised mirror log in segment %s.",
 				  sn->key);
 			return 0;
 		}
 		seg->log_lv->status |= MIRROR_LOG;
-        }
+	}
 
 	if (logname && !seg->region_size) {
 		log_error("Missing region size for mirror log for segment "
@@ -232,7 +232,7 @@
 	uint32_t log_flags = 0;
 
 	/*
-	 * Use clustered mirror log for non-exclusive activation 
+	 * Use clustered mirror log for non-exclusive activation
 	 * in clustered VG.
 	 */
 	if ((!(seg->lv->status & ACTIVATE_EXCL) &&
@@ -266,10 +266,10 @@
 }
 
 static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem,
-                                struct cmd_context *cmd, void **target_state,
-                                struct lv_segment *seg,
-                                struct dm_tree_node *node, uint64_t len,
-                                uint32_t *pvmove_mirror_count)
+				struct cmd_context *cmd, void **target_state,
+				struct lv_segment *seg,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count)
 {
 	struct mirror_state *mirr_state;
 	uint32_t area_count = seg->area_count;
@@ -349,7 +349,7 @@
 	static int _mirrored_present = 0;
 	uint32_t maj, min, patchlevel;
 	unsigned maj2, min2, patchlevel2;
-        char vsn[80];
+	char vsn[80];
 
 	if (!_mirrored_checked) {
 		_mirrored_present = target_present("mirror", 1);
@@ -361,8 +361,8 @@
 		/* FIXME Move this into libdevmapper */
 
 		if (target_version("mirror", &maj, &min, &patchlevel) &&
-		    maj == 1 && 
-		    ((min >= 1 && min <= 11) || 
+		    maj == 1 &&
+		    ((min >= 1 && min <= 11) ||
 		     (min == 0 && driver_version(vsn, sizeof(vsn)) &&
 		      sscanf(vsn, "%u.%u.%u", &maj2, &min2, &patchlevel2) == 3 &&
 		      maj2 == 4 && min2 == 5 && patchlevel2 == 0)))	/* RHEL4U3 */
--- LVM2/lib/misc/crc.c	2007/08/20 20:55:27	1.5
+++ LVM2/lib/misc/crc.c	2008/01/30 14:00:00	1.6
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/misc/lvm-exec.c	2007/08/20 20:55:27	1.2
+++ LVM2/lib/misc/lvm-exec.c	2008/01/30 14:00:00	1.3
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/misc/lvm-file.c	2007/08/20 20:55:27	1.24
+++ LVM2/lib/misc/lvm-file.c	2008/01/30 14:00:00	1.25
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/misc/lvm-string.c	2007/08/22 14:38:17	1.15
+++ LVM2/lib/misc/lvm-string.c	2008/01/30 14:00:00	1.16
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/misc/sharedlib.c	2007/08/20 20:55:27	1.14
+++ LVM2/lib/misc/sharedlib.c	2008/01/30 14:00:00	1.15
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/mm/memlock.c	2007/08/20 20:55:27	1.10
+++ LVM2/lib/mm/memlock.c	2008/01/30 14:00:00	1.11
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -151,8 +151,8 @@
 					   "activation/reserved_memory",
 					   DEFAULT_RESERVED_MEMORY) * 1024;
 	_default_priority = find_config_tree_int(cmd,
-				            "activation/process_priority",
-				            DEFAULT_PROCESS_PRIORITY);
+					    "activation/process_priority",
+					    DEFAULT_PROCESS_PRIORITY);
 }
 
 #endif
--- LVM2/lib/report/report.c	2008/01/30 13:19:46	1.74
+++ LVM2/lib/report/report.c	2008/01/30 14:00:00	1.75
@@ -115,7 +115,7 @@
 		}
 
 		if (dm_snprintf(extent_str, sizeof(extent_str),
-			        "%s%" PRIu32 "%s",
+				"%s%" PRIu32 "%s",
 				range_format ? ":" : "(", extent,
 				range_format ? "-"  : ")") < 0) {
 			log_error("Extent number dm_snprintf failed");
@@ -128,7 +128,7 @@
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
-				        "%" PRIu32, extent + seg->area_len - 1) < 0) {
+					"%" PRIu32, extent + seg->area_len - 1) < 0) {
 				log_error("Extent number dm_snprintf failed");
 				return 0;
 			}
@@ -830,7 +830,7 @@
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	struct lvmcache_info *info; 
+	struct lvmcache_info *info;
 	uint32_t count;
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
@@ -856,7 +856,7 @@
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info; 
+	struct lvmcache_info *info;
 	uint64_t freespace = UINT64_MAX, mda_free;
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 	struct metadata_area *mda;
--- LVM2/lib/snapshot/snapshot.c	2008/01/30 13:19:46	1.27
+++ LVM2/lib/snapshot/snapshot.c	2008/01/30 14:00:01	1.28
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/lib/striped/striped.c	2008/01/30 13:19:46	1.23
+++ LVM2/lib/striped/striped.c	2008/01/30 14:00:01	1.24
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -154,11 +154,11 @@
 #ifdef DEVMAPPER_SUPPORT
 static int _striped_add_target_line(struct dev_manager *dm,
 				struct dm_pool *mem __attribute((unused)),
-                                struct cmd_context *cmd __attribute((unused)),
+				struct cmd_context *cmd __attribute((unused)),
 				void **target_state __attribute((unused)),
-                                struct lv_segment *seg,
-                                struct dm_tree_node *node, uint64_t len,
-                                uint32_t *pvmove_mirror_count __attribute((unused)))
+				struct lv_segment *seg,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count __attribute((unused)))
 {
 	if (!seg->area_count) {
 		log_error("Internal error: striped add_target_line called "
--- LVM2/lib/uuid/uuid.c	2007/08/20 20:55:27	1.23
+++ LVM2/lib/uuid/uuid.c	2008/01/30 14:00:01	1.24
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -93,10 +93,10 @@
 	if (close(randomfile))
 		stack;
 
-        /*
-         * Skip out the last 2 chars in randomized creation for LVM1
-         * backwards compatibility.
-         */
+	/*
+	 * Skip out the last 2 chars in randomized creation for LVM1
+	 * backwards compatibility.
+	 */
 	for (i = 0; i < len; i++)
 		id->uuid[i] = _c[id->uuid[i] % (sizeof(_c) - 3)];
 
--- LVM2/lib/zero/zero.c	2008/01/30 13:19:46	1.15
+++ LVM2/lib/zero/zero.c	2008/01/30 14:00:01	1.16
@@ -40,12 +40,12 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _zero_add_target_line(struct dev_manager *dm __attribute((unused)),
-				struct dm_pool *mem __attribute((unused)),
-                                struct cmd_context *cmd __attribute((unused)),
-				void **target_state __attribute((unused)),
-                                struct lv_segment *seg __attribute((unused)),
-                                struct dm_tree_node *node,uint64_t len,
-                                uint32_t *pvmove_mirror_count __attribute((unused)))
+				 struct dm_pool *mem __attribute((unused)),
+				 struct cmd_context *cmd __attribute((unused)),
+				 void **target_state __attribute((unused)),
+				 struct lv_segment *seg __attribute((unused)),
+				 struct dm_tree_node *node,uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute((unused)))
 {
 	return dm_tree_node_add_zero_target(node, len);
 }
--- LVM2/tools/dumpconfig.c	2007/08/20 20:55:30	1.6
+++ LVM2/tools/dumpconfig.c	2008/01/30 14:00:01	1.7
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/formats.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/formats.c	2008/01/30 14:00:01	1.4
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvchange.c	2008/01/30 13:19:46	1.88
+++ LVM2/tools/lvchange.c	2008/01/30 14:00:01	1.89
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvconvert.c	2008/01/30 13:19:46	1.58
+++ LVM2/tools/lvconvert.c	2008/01/30 14:00:01	1.59
@@ -238,7 +238,7 @@
 static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
 					      const char *lv_name)
 {
-        dev_close_all();
+	dev_close_all();
 
         return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
 				NULL, LCK_VG_WRITE,
--- LVM2/tools/lvcreate.c	2008/01/30 13:19:46	1.171
+++ LVM2/tools/lvcreate.c	2008/01/30 14:00:01	1.172
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -435,7 +435,7 @@
 	/*
 	 * Should we zero the lv.
 	 */
-	lp->zero = strcmp(arg_str_value(cmd, zero_ARG, 
+	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
 		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
 
 	/*
@@ -663,7 +663,7 @@
 			log_error("Snapshots and mirrors may not yet be mixed.");
 			return 0;
 		}
- 
+
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
--- LVM2/tools/lvdisplay.c	2007/08/20 20:55:30	1.19
+++ LVM2/tools/lvdisplay.c	2008/01/30 14:00:01	1.20
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvextend.c	2007/08/20 20:55:30	1.6
+++ LVM2/tools/lvextend.c	2008/01/30 14:00:01	1.7
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvm-static.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/lvm-static.c	2008/01/30 14:00:01	1.4
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvm.c	2007/08/20 20:55:30	1.103
+++ LVM2/tools/lvm.c	2008/01/30 14:00:02	1.104
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvmchange.c	2007/08/20 20:55:30	1.7
+++ LVM2/tools/lvmchange.c	2008/01/30 14:00:02	1.8
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvmcmdlib.c	2007/08/20 20:55:30	1.5
+++ LVM2/tools/lvmcmdlib.c	2008/01/30 14:00:02	1.6
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvmcmdline.c	2008/01/30 13:19:47	1.60
+++ LVM2/tools/lvmcmdline.c	2008/01/30 14:00:02	1.61
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -945,7 +945,7 @@
 		if (!refresh_toolcontext(cmd))
 			stack;
 	}
- 
+
 	/* FIXME Move this? */
 	cmd->current_settings = cmd->default_settings;
 	_apply_settings(cmd);
@@ -1159,7 +1159,7 @@
 	    strcmp(base, "initrd-lvm"))
 		alias = 1;
 
-	if (is_static && strcmp(base, "lvm.static") && 
+	if (is_static && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
 		setenv("LVM_DID_EXEC", base, 1);
--- LVM2/tools/lvreduce.c	2007/08/20 20:55:30	1.7
+++ LVM2/tools/lvreduce.c	2008/01/30 14:00:02	1.8
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvremove.c	2007/08/20 20:55:30	1.53
+++ LVM2/tools/lvremove.c	2008/01/30 14:00:02	1.54
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvrename.c	2007/11/15 02:20:03	1.47
+++ LVM2/tools/lvrename.c	2008/01/30 14:00:02	1.48
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/lvresize.c	2008/01/30 13:19:47	1.91
+++ LVM2/tools/lvresize.c	2008/01/30 14:00:02	1.92
@@ -130,7 +130,7 @@
 	return 1;
 }
 
-static int do_resizefs_reduce(const struct cmd_context *cmd, 
+static int do_resizefs_reduce(const struct cmd_context *cmd,
 			      const struct volume_group *vg,
 			      const struct lvresize_params *lp)
 {
--- LVM2/tools/lvscan.c	2007/11/12 20:51:54	1.34
+++ LVM2/tools/lvscan.c	2008/01/30 14:00:02	1.35
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/polldaemon.c	2007/12/22 12:13:29	1.9
+++ LVM2/tools/polldaemon.c	2008/01/30 14:00:02	1.10
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -202,7 +202,7 @@
 			continue;
 		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv_mirr)))
 			continue;
-		/* FIXME Need to do the activation from _set_up_pvmove here 
+		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting */
 		if (_check_mirror_status(cmd, vg, lv_mirr, name,
 					 parms, &finished) && !finished)
--- LVM2/tools/pvchange.c	2008/01/30 13:19:47	1.57
+++ LVM2/tools/pvchange.c	2008/01/30 14:00:02	1.58
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/pvcreate.c	2008/01/16 18:15:26	1.60
+++ LVM2/tools/pvcreate.c	2008/01/30 14:00:02	1.61
@@ -45,10 +45,10 @@
 	pv = pv_read(cmd, name, NULL, NULL, 0);
 
 	/*
-         * If a PV has no MDAs it may appear to be an orphan until the
-         * metadata is read off another PV in the same VG.  Detecting
-         * this means checking every VG by scanning every PV on the
-         * system.
+	 * If a PV has no MDAs it may appear to be an orphan until the
+	 * metadata is read off another PV in the same VG.  Detecting
+	 * this means checking every VG by scanning every PV on the
+	 * system.
 	 */
 	if (pv && is_orphan(pv)) {
 		if (!scan_vgs_for_pvs(cmd))
@@ -109,7 +109,7 @@
 	if (dev_is_md(dev, &md_superblock) &&
 	    ((!arg_count(cmd, uuidstr_ARG) &&
 	      !arg_count(cmd, restorefile_ARG)) ||
-	     arg_count(cmd, yes_ARG) || 
+	     arg_count(cmd, yes_ARG) ||
 	     (yes_no_prompt("Software RAID md superblock "
 			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
 		log_print("Wiping software RAID md superblock on %s", name);
--- LVM2/tools/pvdisplay.c	2008/01/16 18:15:26	1.45
+++ LVM2/tools/pvdisplay.c	2008/01/30 14:00:02	1.46
@@ -30,10 +30,10 @@
 		vg_name = pv_vg_name(pv);
 		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
 					    LCK_VG_READ, CLUSTERED, 0))) {
-                 	log_error("Skipping volume group %s", vg_name);
+		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
-                 	return ECMD_FAILED;
-         	}
+		 	return ECMD_FAILED;
+	 	}
 
 	 	/*
 		 * Replace possibly incomplete PV structure with new one
@@ -42,8 +42,8 @@
 		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			 log_error("Unable to find \"%s\" in volume group \"%s\"",
 				   pv_name, vg->name);
-	                 ret = ECMD_FAILED;
-	                 goto out;
+			 ret = ECMD_FAILED;
+			 goto out;
 		 }
 
 		 pv = pvl->pv;
@@ -52,7 +52,7 @@
 	if (is_orphan(pv))
 		size = pv_size(pv);
 	else
-		size = (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * 
+		size = (pv_pe_count(pv) - pv_pe_alloc_count(pv)) *
 			pv_pe_size(pv);
 
 	if (arg_count(cmd, short_ARG)) {
@@ -80,8 +80,8 @@
 		pvdisplay_segments(pv);
 
 out:
-        if (vg_name)
-                unlock_vg(cmd, vg_name);
+	if (vg_name)
+		unlock_vg(cmd, vg_name);
 
 	return ret;
 }
--- LVM2/tools/pvmove.c	2008/01/30 13:19:47	1.47
+++ LVM2/tools/pvmove.c	2008/01/30 14:00:02	1.48
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -530,12 +530,12 @@
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
 		return_0;
 
-        if (activation() && segtype->ops->target_present &&
-            !segtype->ops->target_present(NULL)) {
-                log_error("%s: Required device-mapper target(s) not "
-                          "detected in your kernel", segtype->name);
-                return 0;
-        }
+	if (activation() && segtype->ops->target_present &&
+	    !segtype->ops->target_present(NULL)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", segtype->name);
+		return 0;
+	}
 
 	if (argc) {
 		pv_name = argv[0];
--- LVM2/tools/pvresize.c	2008/01/30 13:19:47	1.20
+++ LVM2/tools/pvresize.c	2008/01/30 14:00:02	1.21
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2005 Zak Kipling. All rights reserved.
  *
--- LVM2/tools/pvscan.c	2007/11/02 14:54:40	1.44
+++ LVM2/tools/pvscan.c	2008/01/30 14:00:02	1.45
@@ -89,9 +89,9 @@
 	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
 		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
 		  pv->fmt ? pv->fmt->name : "    ",
-		  display_size(cmd, (uint64_t) pv_pe_count(pv) * 
+		  display_size(cmd, (uint64_t) pv_pe_count(pv) *
 					       pv_pe_size(pv)),
-		  display_size(cmd, (uint64_t) (pv_pe_count(pv) - 
+		  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
 						pv_pe_alloc_count(pv)) *
 					   pv_pe_size(pv)));
 	return;
--- LVM2/tools/reporter.c	2008/01/20 01:23:46	1.34
+++ LVM2/tools/reporter.c	2008/01/30 14:00:02	1.35
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -111,7 +111,7 @@
 			goto out;
 		}
 
-                 pv = pvl->pv;
+		 pv = pvl->pv;
 	}
 
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
@@ -132,7 +132,7 @@
 	if (!vg) {
 		log_error("Volume group %s not found", vg_name);
 		return ECMD_FAILED;
-	}                     
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
@@ -145,7 +145,7 @@
 	if (!vg) {
 		log_error("Volume group %s not found", vg_name);
 		return ECMD_FAILED;
-	}                     
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
--- LVM2/tools/segtypes.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/segtypes.c	2008/01/30 14:00:02	1.4
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/toollib.c	2008/01/30 13:19:47	1.129
+++ LVM2/tools/toollib.c	2008/01/30 14:00:02	1.130
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -736,13 +736,13 @@
 					continue;
 				}
 
-        			/*
-			         * If a PV has no MDAs it may appear to be an
+				/*
+				 * If a PV has no MDAs it may appear to be an
 				 * orphan until the metadata is read off
 				 * another PV in the same VG.  Detecting this
 				 * means checking every VG by scanning every
 				 * PV on the system.
-			         */
+				 */
 				if (!scanned && is_orphan(pv)) {
 					if (!scan_vgs_for_pvs(cmd)) {
 						stack;
@@ -1251,7 +1251,7 @@
 	    arg_uint_value(cmd, physicalextentsize_ARG, vp_def->extent_size);
 
 	if (arg_count(cmd, clustered_ARG))
-        	vp_new->clustered =
+		vp_new->clustered =
 			!strcmp(arg_str_value(cmd, clustered_ARG,
 					      vp_def->clustered ? "y":"n"), "y");
 	else
--- LVM2/tools/vgcfgbackup.c	2007/08/20 20:55:30	1.23
+++ LVM2/tools/vgcfgbackup.c	2008/01/30 14:00:02	1.24
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgcfgrestore.c	2007/11/02 20:40:05	1.17
+++ LVM2/tools/vgcfgrestore.c	2008/01/30 14:00:02	1.18
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgchange.c	2007/11/14 00:08:25	1.62
+++ LVM2/tools/vgchange.c	2008/01/30 14:00:02	1.63
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -256,8 +256,8 @@
 	}
 
 	if (clustered) {
-        	list_iterate_items(lvl, &vg->lvs) {
-                	if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
+		list_iterate_items(lvl, &vg->lvs) {
+			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
 				log_error("Volume group %s contains snapshots "
 					  "that are not yet supported.",
 					  vg->name);
--- LVM2/tools/vgck.c	2007/08/20 20:55:30	1.17
+++ LVM2/tools/vgck.c	2008/01/30 14:00:02	1.18
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgdisplay.c	2007/08/20 20:55:30	1.19
+++ LVM2/tools/vgdisplay.c	2008/01/30 14:00:02	1.20
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -89,8 +89,8 @@
 
 	/* FIXME -D disk_ARG is now redundant */
 
-/********* FIXME: Do without this - or else 2(+) passes! 
-	   Figure out longest volume group name 
+/********* FIXME: Do without this - or else 2(+) passes!
+	   Figure out longest volume group name
 	for (c = opt; opt < argc; opt++) {
 		len = strlen(argv[opt]);
 		if (len > max_len)
@@ -101,8 +101,8 @@
 	process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
 			vgdisplay_single);
 
-/******** FIXME Need to count number processed 
-	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ? 
+/******** FIXME Need to count number processed
+	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ?
 
 	if (opt == argc) {
 		log_print("no ");
--- LVM2/tools/vgexport.c	2007/08/20 20:55:30	1.17
+++ LVM2/tools/vgexport.c	2008/01/30 14:00:02	1.18
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgextend.c	2007/11/15 02:20:03	1.36
+++ LVM2/tools/vgextend.c	2008/01/30 14:00:02	1.37
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -42,7 +42,7 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE | LCK_NONBLOCK,
-				    CLUSTERED | EXPORTED_VG | 
+				    CLUSTERED | EXPORTED_VG |
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		 unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgimport.c	2007/08/20 20:55:30	1.16
+++ LVM2/tools/vgimport.c	2008/01/30 14:00:02	1.17
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgmerge.c	2008/01/30 13:19:47	1.44
+++ LVM2/tools/vgmerge.c	2008/01/30 14:00:02	1.45
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -70,23 +70,23 @@
 		list_iterate_items(lvl2, &vg_from->lvs) {
 			union lvid *lvid2 = &lvl2->lv->lvid;
 
-                	if (id_equal(&lvid1->id[1], &lvid2->id[1])) {
+			if (id_equal(&lvid1->id[1], &lvid2->id[1])) {
 				if (!id_create(&lvid2->id[1])) {
 					log_error("Failed to generate new "
 						  "random LVID for %s",
 						  lvl2->lv->name);
 					goto bad;
 				}
-                		if (!id_write_format(&lvid2->id[1], uuid,
+				if (!id_write_format(&lvid2->id[1], uuid,
 						     sizeof(uuid)))
-                        		goto_bad;
+					goto_bad;
 
 				log_verbose("Changed LVID for %s to %s",
 					    lvl2->lv->name, uuid);
 			}
 		}
 	}
- 
+
 	while (!list_empty(&vg_from->lvs)) {
 		struct list *lvh = vg_from->lvs.n;
 
--- LVM2/tools/vgmknodes.c	2007/08/20 20:55:30	1.5
+++ LVM2/tools/vgmknodes.c	2008/01/30 14:00:02	1.6
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgreduce.c	2008/01/30 13:19:47	1.76
+++ LVM2/tools/vgreduce.c	2008/01/30 14:00:02	1.77
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -100,7 +100,7 @@
 	}
 
 	/*
-	 * If LV is active, replace it with error segment 
+	 * If LV is active, replace it with error segment
 	 * and add to list of LVs to be removed later.
 	 * Doesn't apply to snapshots/origins yet - they're already deactivated.
 	 */
--- LVM2/tools/vgremove.c	2007/11/02 20:40:05	1.45
+++ LVM2/tools/vgremove.c	2008/01/30 14:00:02	1.46
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -41,7 +41,7 @@
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      LCK_VG_WRITE | LCK_NONBLOCK, 1, 
+			      LCK_VG_WRITE | LCK_NONBLOCK, 1,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgrename.c	2008/01/15 22:56:30	1.49
+++ LVM2/tools/vgrename.c	2008/01/30 14:00:02	1.50
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -150,8 +150,8 @@
 		  vg_name_old, vg_name_new);
 
 	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
-        persistent_filter_wipe(cmd->filter);
-        lvmcache_destroy();
+	persistent_filter_wipe(cmd->filter);
+	lvmcache_destroy();
 
 	return 1;
 
--- LVM2/tools/vgscan.c	2007/08/23 15:02:26	1.28
+++ LVM2/tools/vgscan.c	2008/01/30 14:00:02	1.29
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
--- LVM2/tools/vgsplit.c	2008/01/22 03:49:39	1.49
+++ LVM2/tools/vgsplit.c	2008/01/30 14:00:02	1.50
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -181,7 +181,7 @@
 		if (!(lv->status & MIRRORED))
 			continue;
 
-		seg = first_seg(lv); 
+		seg = first_seg(lv);
 
 		seg_in = 0;
 		for (s = 0; s < seg->area_count; s++)
@@ -190,8 +190,8 @@
 
 		log_in = (!seg->log_lv || _lv_is_in_vg(vg_to, seg->log_lv));
 		
-		if ((seg_in && seg_in < seg->area_count) || 
-		    (seg_in && seg->log_lv && !log_in) || 
+		if ((seg_in && seg_in < seg->area_count) ||
+		    (seg_in && seg->log_lv && !log_in) ||
 		    (!seg_in && seg->log_lv && log_in)) {
 			log_error("Can't split mirror %s between "
 				  "two Volume Groups", lv->name);


