From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 20:02:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-gulm.c li ...
Message-ID: <20090715200251.31652.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 20:02:48

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-gulm.c 
	lib/commands   : toolcontext.c 
	lib/device     : dev-cache.c 
	lib/format1    : disk-rep.c import-export.c import-extents.c 
	                 lvm1-label.c 
	lib/format_text: archive.c archiver.c flags.c format-text.c 
	                 text_label.c 
	lib/label      : label.c 
	lib/metadata   : lv_manip.c metadata.c snapshot_manip.c 
	lib/misc       : lvm-file.c 
	lib/uuid       : uuid.c 
	libdm/mm       : pool-debug.c 
	tools          : lvcreate.c lvmcmdline.c toollib.c 
	                 vgcfgrestore.c 

Log message:
	Use log_error macro consistently throughout in place of log_err.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1188&r2=1.1189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.255&r2=1.256
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2009/07/15 15:38:41	1.1188
+++ LVM2/WHATS_NEW	2009/07/15 20:02:46	1.1189
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Use log_error macro consistently throughout in place of log_err.
 
 Version 2.02.49 - 15th July 2009
 ================================
--- LVM2/daemons/clvmd/clvmd-gulm.c	2009/04/21 13:11:28	1.26
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2009/07/15 20:02:46	1.27
@@ -950,7 +950,7 @@
 		}
 		else {
 			DEBUGLOG("Cannot resolve host name %s\n", nodename);
-			log_err("Cannot resolve host name %s\n", nodename);
+			log_error("Cannot resolve host name %s\n", nodename);
 		}
 	}
 	free(nodename);
--- LVM2/lib/commands/toolcontext.c	2009/07/14 12:17:15	1.79
+++ LVM2/lib/commands/toolcontext.c	2009/07/15 20:02:46	1.80
@@ -999,8 +999,8 @@
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_ARCHIVE_SUBDIR) == -1) {
-		log_err("Couldn't create default archive path '%s/%s'.",
-			cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
+		log_error("Couldn't create default archive path '%s/%s'.",
+			  cmd->system_dir, DEFAULT_ARCHIVE_SUBDIR);
 		return 0;
 	}
 
@@ -1021,8 +1021,8 @@
 	if (dm_snprintf
 	    (default_dir, sizeof(default_dir), "%s/%s", cmd->system_dir,
 	     DEFAULT_BACKUP_SUBDIR) == -1) {
-		log_err("Couldn't create default backup path '%s/%s'.",
-			cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
+		log_error("Couldn't create default backup path '%s/%s'.",
+			  cmd->system_dir, DEFAULT_BACKUP_SUBDIR);
 		return 0;
 	}
 
--- LVM2/lib/device/dev-cache.c	2009/05/20 11:09:49	1.55
+++ LVM2/lib/device/dev-cache.c	2009/07/15 20:02:46	1.56
@@ -298,19 +298,19 @@
 			return_0;
 
 		if (!(btree_insert(_cache.devices, (uint32_t) d, dev))) {
-			log_err("Couldn't insert device into binary tree.");
+			log_error("Couldn't insert device into binary tree.");
 			_free(dev);
 			return 0;
 		}
 	}
 
 	if (!loopfile && !_add_alias(dev, path)) {
-		log_err("Couldn't add alias to dev cache.");
+		log_error("Couldn't add alias to dev cache.");
 		return 0;
 	}
 
 	if (!dm_hash_insert(_cache.names, path, dev)) {
-		log_err("Couldn't add name to hash in dev cache.");
+		log_error("Couldn't add name to hash in dev cache.");
 		return 0;
 	}
 
@@ -541,7 +541,7 @@
 	}
 
 	if (!(_cache.devices = btree_create(_cache.mem))) {
-		log_err("Couldn't create binary tree for dev-cache.");
+		log_error("Couldn't create binary tree for dev-cache.");
 		goto bad;
 	}
 
@@ -561,7 +561,7 @@
 static void _check_closed(struct device *dev)
 {
 	if (dev->fd >= 0)
-		log_err("Device '%s' has been left open.", dev_name(dev));
+		log_error("Device '%s' has been left open.", dev_name(dev));
 }
 
 static void _check_for_open_devices(void)
--- LVM2/lib/format1/disk-rep.c	2008/11/03 22:14:28	1.78
+++ LVM2/lib/format1/disk-rep.c	2009/07/15 20:02:46	1.79
@@ -625,7 +625,7 @@
 	   happy (idea from AED) */
 	buf = dm_malloc(size);
 	if (!buf) {
-		log_err("Couldn't allocate temporary PV buffer.");
+		log_error("Couldn't allocate temporary PV buffer.");
 		return 0;
 	}
 
--- LVM2/lib/format1/import-export.c	2009/05/13 21:27:43	1.106
+++ LVM2/lib/format1/import-export.c	2009/07/15 20:02:46	1.107
@@ -579,15 +579,15 @@
 			lvnum = lvd->lv_number;
 
 			if (lvnum >= MAX_LV) {
-				log_err("Logical volume number "
-					"out of bounds.");
+				log_error("Logical volume number "
+					  "out of bounds.");
 				return 0;
 			}
 
 			if (!lvs[lvnum] &&
 			    !(lvs[lvnum] = find_lv(vg, (char *)lvd->lv_name))) {
-				log_err("Couldn't find logical volume '%s'.",
-					lvd->lv_name);
+				log_error("Couldn't find logical volume '%s'.",
+					  lvd->lv_name);
 				return 0;
 			}
 		}
@@ -606,8 +606,8 @@
 			lvnum = lvd->lv_number;
 			cow = lvs[lvnum];
 			if (!(org = lvs[lvd->lv_snapshot_minor])) {
-				log_err("Couldn't find origin logical volume "
-					"for snapshot '%s'.", lvd->lv_name);
+				log_error("Couldn't find origin logical volume "
+					  "for snapshot '%s'.", lvd->lv_name);
 				return 0;
 			}
 
@@ -619,7 +619,7 @@
 			if (!vg_add_snapshot(org, cow, NULL,
 					     org->le_count,
 					     lvd->lv_chunk_size)) {
-				log_err("Couldn't add snapshot.");
+				log_error("Couldn't add snapshot.");
 				return 0;
 			}
 		}
--- LVM2/lib/format1/import-extents.c	2008/11/03 22:14:28	1.37
+++ LVM2/lib/format1/import-extents.c	2009/07/15 20:02:46	1.38
@@ -50,8 +50,8 @@
 	struct lv_map *lvm;
 
 	if (!maps) {
-		log_err("Unable to create hash table for holding "
-			"extent maps.");
+		log_error("Unable to create hash table for holding "
+			  "extent maps.");
 		return NULL;
 	}
 
@@ -89,8 +89,8 @@
 	dm_list_iterate_items(ll, &dl->lvds) {
 		if (!(lvm = dm_hash_lookup(maps, strrchr((char *)ll->lvd.lv_name, '/')
 					+ 1))) {
-			log_err("Physical volume (%s) contains an "
-				"unknown logical volume (%s).",
+			log_error("Physical volume (%s) contains an "
+				  "unknown logical volume (%s).",
 				dev_name(dl->dev), ll->lvd.lv_name);
 			return 0;
 		}
@@ -144,14 +144,14 @@
 				le = e[i].le_num;
 
 				if (le >= lvm->lv->le_count) {
-					log_err("logical extent number "
-						"out of bounds");
+					log_error("logical extent number "
+						  "out of bounds");
 					return 0;
 				}
 
 				if (lvm->map[le].pv) {
-					log_err("logical extent (%u) "
-						"already mapped.", le);
+					log_error("logical extent (%u) "
+						  "already mapped.", le);
 					return 0;
 				}
 
@@ -170,8 +170,8 @@
 
 	for (i = 0; i < lvm->lv->le_count; i++) {
 		if (!lvm->map[i].pv) {
-			log_err("Logical volume (%s) contains an incomplete "
-				"mapping table.", lvm->lv->name);
+			log_error("Logical volume (%s) contains an incomplete "
+				  "mapping table.", lvm->lv->name);
 			return 0;
 		}
 	}
@@ -346,12 +346,12 @@
 		return_0;
 
 	if (!(maps = _create_lv_maps(scratch, vg))) {
-		log_err("Couldn't allocate logical volume maps.");
+		log_error("Couldn't allocate logical volume maps.");
 		goto out;
 	}
 
 	if (!_fill_maps(maps, vg, pvds)) {
-		log_err("Couldn't fill logical volume maps.");
+		log_error("Couldn't fill logical volume maps.");
 		goto out;
 	}
 
@@ -359,7 +359,7 @@
 		goto_out;
 
 	if (!_build_all_segments(cmd, maps)) {
-		log_err("Couldn't build extent segments.");
+		log_error("Couldn't build extent segments.");
 		goto out;
 	}
 	r = 1;
--- LVM2/lib/format1/lvm1-label.c	2008/11/03 22:14:28	1.20
+++ LVM2/lib/format1/lvm1-label.c	2009/07/15 20:02:46	1.21
@@ -26,8 +26,8 @@
 
 static void _not_supported(const char *op)
 {
-	log_err("The '%s' operation is not supported for the lvm1 labeller.",
-		op);
+	log_error("The '%s' operation is not supported for the lvm1 labeller.",
+		  op);
 }
 
 static int _lvm1_can_handle(struct labeller *l __attribute((unused)), void *buf, uint64_t sector)
@@ -119,7 +119,7 @@
 	struct labeller *l;
 
 	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_err("Couldn't allocate labeller object.");
+		log_error("Couldn't allocate labeller object.");
 		return NULL;
 	}
 
--- LVM2/lib/format_text/archive.c	2009/04/10 10:00:37	1.34
+++ LVM2/lib/format_text/archive.c	2009/07/15 20:02:47	1.35
@@ -139,7 +139,7 @@
 
 	/* Sort fails beyond 5-digit indexes */
 	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
-		log_err("Couldn't scan the archive directory (%s).", dir);
+		log_error("Couldn't scan the archive directory (%s).", dir);
 		return 0;
 	}
 
@@ -164,7 +164,7 @@
 		 * Create a new archive_file.
 		 */
 		if (!(af = dm_pool_alloc(mem, sizeof(*af)))) {
-			log_err("Couldn't create new archive file.");
+			log_error("Couldn't create new archive file.");
 			results = NULL;
 			goto out;
 		}
@@ -238,12 +238,12 @@
 	 */
 	if (!create_temp_name(dir, temp_file, sizeof(temp_file), &fd,
 			      &vg->cmd->rand_seed)) {
-		log_err("Couldn't create temporary archive name.");
+		log_error("Couldn't create temporary archive name.");
 		return 0;
 	}
 
 	if (!(fp = fdopen(fd, "w"))) {
-		log_err("Couldn't create FILE object for archive.");
+		log_error("Couldn't create FILE object for archive.");
 		if (close(fd))
 			log_sys_error("close", temp_file);
 		return 0;
@@ -356,7 +356,7 @@
 	af.path = (char *)file;
 
 	if (!path_exists(af.path)) {
-		log_err("Archive file %s not found.", af.path);
+		log_error("Archive file %s not found.", af.path);
 		return 0;
 	}
 
--- LVM2/lib/format_text/archiver.c	2009/07/08 22:18:32	1.26
+++ LVM2/lib/format_text/archiver.c	2009/07/15 20:02:47	1.27
@@ -250,7 +250,7 @@
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
 			 cmd->backup_params->dir, vg_name) < 0) {
-		log_err("Failed to generate backup filename (for removal).");
+		log_error("Failed to generate backup filename (for removal).");
 		return 0;
 	}
 
@@ -364,7 +364,7 @@
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
 			 cmd->backup_params->dir, vg_name) < 0) {
-		log_err("Failed to generate backup filename (for restore).");
+		log_error("Failed to generate backup filename (for restore).");
 		return 0;
 	}
 
--- LVM2/lib/format_text/flags.c	2009/04/25 01:17:59	1.36
+++ LVM2/lib/format_text/flags.c	2009/07/15 20:02:47	1.37
@@ -82,7 +82,7 @@
 		return _lv_flags;
 	}
 
-	log_err("Unknown flag set requested.");
+	log_error("Unknown flag set requested.");
 	return NULL;
 }
 
@@ -149,7 +149,7 @@
 
 	while (cv) {
 		if (cv->type != CFG_STRING) {
-			log_err("Status value is not a string.");
+			log_error("Status value is not a string.");
 			return 0;
 		}
 
@@ -169,7 +169,7 @@
 			 */
 			s |= PARTIAL_VG;
 		} else if (!flags[f].description && (type & STATUS_FLAG)) {
-			log_err("Unknown status flag '%s'.", cv->v.str);
+			log_error("Unknown status flag '%s'.", cv->v.str);
 			return 0;
 		}
 
--- LVM2/lib/format_text/format-text.c	2009/05/07 12:11:51	1.105
+++ LVM2/lib/format_text/format-text.c	2009/07/15 20:02:47	1.106
@@ -799,8 +799,8 @@
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
 		dm_pool_free(fid->fmt->cmd->mem, vg);
-		log_err("'%s' does not contain volume group '%s'.",
-			read_path, vgname);
+		log_error("'%s' does not contain volume group '%s'.",
+			  read_path, vgname);
 		return NULL;
 	} else
 		log_debug("Read volume group %s from %s", vg->name, read_path);
@@ -858,7 +858,7 @@
 
 	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
 			      &vg->cmd->rand_seed)) {
-		log_err("Couldn't create temporary text file name.");
+		log_error("Couldn't create temporary text file name.");
 		return 0;
 	}
 
@@ -1860,7 +1860,7 @@
       bad:
 	dm_pool_free(cmd->mem, tc);
 
-	log_err("Couldn't allocate text format context object.");
+	log_error("Couldn't allocate text format context object.");
 	return NULL;
 }
 
@@ -1936,9 +1936,10 @@
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
-			log_err("Couldn't find device.");
+			log_error("Couldn't find device.");
 		else
-			log_err("Couldn't find device with uuid '%s'.", buffer);
+			log_error("Couldn't find device with uuid '%s'.",
+				  buffer);
 
 		return 0;
 	}
--- LVM2/lib/format_text/text_label.c	2009/02/22 19:00:27	1.24
+++ LVM2/lib/format_text/text_label.c	2009/07/15 20:02:47	1.25
@@ -343,7 +343,7 @@
 	struct labeller *l;
 
 	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_err("Couldn't allocate labeller object.");
+		log_error("Couldn't allocate labeller object.");
 		return NULL;
 	}
 
--- LVM2/lib/label/label.c	2009/07/13 21:23:48	1.48
+++ LVM2/lib/label/label.c	2009/07/15 20:02:47	1.49
@@ -304,7 +304,7 @@
 	int r = 1;
 
 	if (!label->labeller->ops->write) {
-		log_err("Label handler does not support label writes");
+		log_error("Label handler does not support label writes");
 		return 0;
 	}
 
--- LVM2/lib/metadata/lv_manip.c	2009/06/06 16:37:15	1.181
+++ LVM2/lib/metadata/lv_manip.c	2009/07/15 20:02:47	1.182
@@ -1237,7 +1237,7 @@
 
 	/* Allocate an array of pv_areas to hold the largest space on each PV */
 	if (!(areas = dm_malloc(sizeof(*areas) * areas_size))) {
-		log_err("Couldn't allocate areas array.");
+		log_error("Couldn't allocate areas array.");
 		return 0;
 	}
 
@@ -1375,8 +1375,8 @@
 		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {
-		log_err("Couldn't merge segments after extending "
-			"logical volume.");
+		log_error("Couldn't merge segments after extending "
+			  "logical volume.");
 		return 0;
 	}
 
--- LVM2/lib/metadata/metadata.c	2009/07/15 17:26:26	1.255
+++ LVM2/lib/metadata/metadata.c	2009/07/15 20:02:47	1.256
@@ -636,7 +636,8 @@
 		goto_bad;
 
 	if (!id_create(&vg->id)) {
-		log_err("Couldn't create uuid for volume group '%s'.", vg_name);
+		log_error("Couldn't create uuid for volume group '%s'.",
+			  vg_name);
 		goto bad;
 	}
 
--- LVM2/lib/metadata/snapshot_manip.c	2009/05/21 03:04:53	1.43
+++ LVM2/lib/metadata/snapshot_manip.c	2009/07/15 20:02:47	1.44
@@ -94,7 +94,7 @@
 	 * Is the cow device already being used ?
 	 */
 	if (lv_is_cow(cow)) {
-		log_err("'%s' is already in use as a snapshot.", cow->name);
+		log_error("'%s' is already in use as a snapshot.", cow->name);
 		return 0;
 	}
 
--- LVM2/lib/misc/lvm-file.c	2008/12/07 04:27:57	1.26
+++ LVM2/lib/misc/lvm-file.c	2009/07/15 20:02:47	1.27
@@ -53,8 +53,8 @@
 
 		if (dm_snprintf(buffer, len, "%s/.lvm_%s_%d_%d",
 				 dir, hostname, pid, num) == -1) {
-			log_err("Not enough space to build temporary file "
-				"string.");
+			log_error("Not enough space to build temporary file "
+				  "string.");
 			return 0;
 		}
 
--- LVM2/lib/uuid/uuid.c	2008/12/07 04:23:37	1.29
+++ LVM2/lib/uuid/uuid.c	2009/07/15 20:02:47	1.30
@@ -139,7 +139,7 @@
 
 	for (i = 0; i < ID_LEN; i++)
 		if (!_inverse_c[id->uuid[i]]) {
-			log_err("UUID contains invalid character");
+			log_error("UUID contains invalid character");
 			return 0;
 		}
 
@@ -163,7 +163,7 @@
 
 	/* split into groups separated by dashes */
 	if (size < (32 + 6 + 1)) {
-		log_err("Couldn't write uuid, buffer too small.");
+		log_error("Couldn't write uuid, buffer too small.");
 		return 0;
 	}
 
@@ -191,7 +191,7 @@
 		}
 
 		if (out >= ID_LEN) {
-			log_err("Too many characters to be uuid.");
+			log_error("Too many characters to be uuid.");
 			return 0;
 		}
 
@@ -199,7 +199,8 @@
 	}
 
 	if (out != ID_LEN) {
-		log_err("Couldn't read uuid, incorrect number of characters.");
+		log_error("Couldn't read uuid: incorrect number of "
+			  "characters.");
 		return 0;
 	}
 
--- LVM2/libdm/mm/pool-debug.c	2009/04/10 09:56:59	1.8
+++ LVM2/libdm/mm/pool-debug.c	2009/07/15 20:02:48	1.9
@@ -149,12 +149,12 @@
 	assert(alignment == DEFAULT_ALIGNMENT);
 
 	if (!b) {
-		log_err("Out of memory");
+		log_error("Out of memory");
 		return NULL;
 	}
 
 	if (!(b->data = dm_malloc(s))) {
-		log_err("Out of memory");
+		log_error("Out of memory");
 		dm_free(b);
 		return NULL;
 	}
@@ -237,7 +237,7 @@
 		new_size = delta;
 
 	if (!(new = _new_block(new_size, DEFAULT_ALIGNMENT))) {
-		log_err("Couldn't extend object.");
+		log_error("Couldn't extend object.");
 		return 0;
 	}
 
--- LVM2/tools/lvcreate.c	2009/07/07 01:18:35	1.198
+++ LVM2/tools/lvcreate.c	2009/07/15 20:02:48	1.199
@@ -68,16 +68,16 @@
 
 	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		if (!argc) {
-			log_err("Please specify a logical volume to act as "
-				"the snapshot origin.");
+			log_error("Please specify a logical volume to act as "
+				  "the snapshot origin.");
 			return 0;
 		}
 
 		lp->origin = argv[0];
 		(*pargv)++, (*pargc)--;
 		if (!(lp->vg_name = extract_vgname(cmd, lp->origin))) {
-			log_err("The origin name should include the "
-				"volume group.");
+			log_error("The origin name should include the "
+				  "volume group.");
 			return 0;
 		}
 
@@ -92,7 +92,7 @@
 		 */
 		if (!argc) {
 			if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
-				log_err("Please provide a volume group name");
+				log_error("Please provide a volume group name");
 				return 0;
 			}
 
--- LVM2/tools/lvmcmdline.c	2009/07/13 19:49:49	1.99
+++ LVM2/tools/lvmcmdline.c	2009/07/15 20:02:48	1.100
@@ -955,7 +955,7 @@
 	return dm_pool_end_object(cmd->mem);
 
       bad:
-	log_err("Couldn't copy command line.");
+	log_error("Couldn't copy command line.");
 	dm_pool_abandon_object(cmd->mem);
 	return NULL;
 }
--- LVM2/tools/toollib.c	2009/07/15 12:22:59	1.164
+++ LVM2/tools/toollib.c	2009/07/15 20:02:48	1.165
@@ -1001,7 +1001,7 @@
 
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
-		log_err("No free extents on physical volume \"%s\"", pvname);
+		log_error("No free extents on physical volume \"%s\"", pvname);
 		return 1;
 	}
 
@@ -1013,7 +1013,7 @@
 	
 	if (!new_pvl) {
 		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
-			log_err("Unable to allocate physical volume list.");
+			log_error("Unable to allocate physical volume list.");
 			return 0;
 		}
 
@@ -1087,8 +1087,8 @@
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pvname))) {
-			log_err("Physical Volume \"%s\" not found in "
-				"Volume Group \"%s\"", pvname, vg->name);
+			log_error("Physical Volume \"%s\" not found in "
+				  "Volume Group \"%s\"", pvname, vg->name);
 			return NULL;
 		}
 		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r))
--- LVM2/tools/vgcfgrestore.c	2009/07/10 20:10:18	1.20
+++ LVM2/tools/vgcfgrestore.c	2009/07/15 20:02:48	1.21
@@ -26,7 +26,7 @@
 			return ECMD_FAILED;
 		}
 	} else if (!(arg_count(cmd, list_ARG) && arg_count(cmd, file_ARG))) {
-		log_err("Please specify a *single* volume group to restore.");
+		log_error("Please specify a *single* volume group to restore.");
 		return ECMD_FAILED;
 	}
 
@@ -60,7 +60,7 @@
 	      backup_restore(cmd, vg_name))) {
 		unlock_vg(cmd, vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
-		log_err("Restore failed.");
+		log_error("Restore failed.");
 		return ECMD_FAILED;
 	}
 


