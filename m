From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:09 +0000 (GMT)
Subject: main - cleanup: correcting some log_print
Message-ID: <20230506204609.BB9963858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c451d7925d91c6fec56b1537e341a5bbc94fb545
Commit:        c451d7925d91c6fec56b1537e341a5bbc94fb545
Parent:        39b2bd06b8a992607ef6a315b08d2bf97cc6f24f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 14:40:11 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 20:38:49 2023 +0200

cleanup: correcting some log_print

Correcting to log_print_unless_silent(),
so -qq can do some work.
---
 lib/activate/activate.c        |  2 +-
 lib/cache/lvmcache.c           |  4 +-
 lib/device/dev-io.c            |  2 +-
 lib/device/dev-mpath.c         |  2 +-
 lib/device/dev-type.c          |  4 +-
 lib/device/device_id.c         | 10 ++---
 lib/device/filesystem.c        | 12 +++---
 lib/device/online.c            |  4 +-
 lib/device/online.h            |  4 +-
 lib/format_text/text_label.c   |  2 +-
 lib/label/label.c              | 23 ++++++-----
 lib/locking/lvmlockd.c         |  2 +-
 lib/metadata/integrity_manip.c | 18 ++++----
 lib/metadata/lv_manip.c        | 94 +++++++++++++++++++++---------------------
 14 files changed, 92 insertions(+), 91 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d6c1eca2f..41d4b9b13 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2555,7 +2555,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	    lv_is_partial(lv) && lv_is_raid(lv) && lv_raid_has_integrity((struct logical_volume *)lv)) {
 		cmd->partial_activation = 0;
 		cmd->degraded_activation = 0;
-		log_print("No degraded or partial activation for raid with integrity.");
+		log_print_unless_silent("No degraded or partial activation for raid with integrity.");
 	}
 
 	if ((!lv->vg->cmd->partial_activation) && lv_is_partial(lv)) {
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 127d29229..a18d213e1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -707,8 +707,8 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 
 		/* Different mpath devs with the same wwid shouldn't happen. */
 		if (dev_is_mp && dev_mp) {
-			log_print("Found multiple multipath devices for PVID %s WWID %s: %s %s",
-				   pvid, wwid1_buf, dev_name(dev_mp), dev_name(dev));
+			log_print_unless_silent("Found multiple multipath devices for PVID %s WWID %s: %s %s.",
+						pvid, wwid1_buf, dev_name(dev_mp), dev_name(dev));
 			continue;
 		}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 811ad8978..5875e7516 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -310,7 +310,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 
 	if (dm_list_empty(&dev->aliases)) {
 		/* shouldn't happen */
-		log_print("Cannot open device %d:%d with no valid paths.", (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
+		log_print_unless_silent("Cannot open device %d:%d with no valid paths.", (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 		return 0;
 	}
 	name = dev_name(dev);
diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 3679e4428..fb45d1858 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -209,7 +209,7 @@ static void _read_wwid_file(const char *config_wwids_file, int *entries)
 	int count = 0;
 
 	if (config_wwids_file[0] != '/') {
-		log_print("Ignoring unknown multipath_wwids_file.");
+		log_print_unless_silent("Ignoring unknown multipath_wwids_file.");
 		return;
 	}
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 999b939c5..9dba65e93 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -915,7 +915,7 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 		return 0;
 	} else if (rc == 1) {
 		/* no file system on the device */
-		log_print("No file system found on %s.", pathname);
+		log_print_unless_silent("No file system found on %s.", pathname);
 		fsi->nofs = 1;
 		blkid_free_probe(probe);
 		return 1;
@@ -925,7 +925,7 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 		strncpy(fsi->fstype, str, sizeof(fsi->fstype)-1);
 	else {
 		/* any difference from blkid_do_safeprobe rc=1? */
-		log_print("No file system type on %s.", pathname);
+		log_print_unless_silent("No file system type on %s.", pathname);
 		fsi->nofs = 1;
 		blkid_free_probe(probe);
 		return 1;
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 79da12884..38677d1fe 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1085,7 +1085,7 @@ static void _device_ids_update_try(struct cmd_context *cmd)
 	int held = 0;
 
 	if (cmd->expect_missing_vg_device) {
-		log_print("Devices file update skipped."); 
+		log_print_unless_silent("Devices file update skipped.");
 		return;
 	}
 
@@ -1520,7 +1520,7 @@ id_done:
 		} else {
 			if (!cmd->current_settings.yes &&
 			    yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
-				log_print("Device not added.");
+				log_print_unless_silent("Device not added.");
 				free((void *)check_idname);
 				return 1;
 			}
@@ -1923,9 +1923,9 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 				du->dev = dev;
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
-				log_print("Match device_id %s %s to vpd_pg83 %s %s",
-					  idtype_to_str(du->idtype), du->idname,
-					  idtype_to_str(id->idtype), dev_name(dev));
+				log_print_unless_silent("Match device_id %s %s to vpd_pg83 %s %s.",
+							idtype_to_str(du->idtype), du->idname,
+							idtype_to_str(id->idtype), dev_name(dev));
 				du->idtype = id->idtype;
 				return 1;
 			}
diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 5ec090a2c..2572bca69 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -162,8 +162,8 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 
 		memset(&info, 0, sizeof(info));
 
-		log_print("Checking crypt device %s on LV %s.",
-			  crypt_path, display_lvname(lv));
+		log_print_unless_silent("Checking crypt device %s on LV %s.",
+					crypt_path, display_lvname(lv));
 
 		if ((fd = open(crypt_path, O_RDONLY)) < 0) {
 			log_error("Failed to open crypt path %s", crypt_path);
@@ -470,16 +470,16 @@ int fs_reduce_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 
 	devpath = fsi->needs_crypt ? crypt_path : (char *)display_lvname(lv);
 
-	log_print("Reducing file system %s to %s (%llu bytes) on %s...",
-		  fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
-		  (unsigned long long)newsize_bytes_fs, devpath);
+	log_print_unless_silent("Reducing file system %s to %s (%llu bytes) on %s...",
+				fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
+				(unsigned long long)newsize_bytes_fs, devpath);
 
 	if (!exec_cmd(cmd, argv, &status, 1)) {
 		log_error("Failed to reduce file system with lvresize_fs_helper.");
 		return 0;
 	}
 
-	log_print("Reduced file system %s on %s.", fsi->fstype, devpath);
+	log_print_unless_silent("Reduced file system %s on %s.", fsi->fstype, devpath);
 
 	return 1;
 }
diff --git a/lib/device/online.c b/lib/device/online.c
index b97b71d92..7ceab1750 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -276,7 +276,7 @@ int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const c
 
 	if (vgname) {
 		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
-			log_print("Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
+			log_print_unless_silent("Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
 			/* can still continue without vgname */
 			len2 = 0;
 		}
@@ -285,7 +285,7 @@ int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const c
 	devnamelen = dm_snprintf(devname, sizeof(devname), "%s", dev_name(dev));
 	if ((devnamelen > 5) && (devnamelen < NAME_LEN-1)) {
 		if ((len3 = dm_snprintf(buf + len1 + len2, sizeof(buf) - len1 - len2, "dev:%s\n", devname)) < 0) {
-			log_print("Incomplete devname in online file for %s.", dev_name(dev));
+			log_print_unless_silent("Incomplete devname in online file for %s.", dev_name(dev));
 			/* can continue without devname */
 			len3 = 0;
 		}
diff --git a/lib/device/online.h b/lib/device/online.h
index 488129e3f..6d3264ae4 100644
--- a/lib/device/online.h
+++ b/lib/device/online.h
@@ -32,9 +32,9 @@ struct pv_online {
 #define log_print_pvscan(cmd, fmt, args...) \
 do \
 	if (cmd->udevoutput) \
-		log_print(fmt, ##args); \
+		log_print_unless_silent(fmt, ##args); \
 	else \
-		log_print("pvscan[%d] " fmt, getpid(), ##args); \
+		log_print_unless_silent("pvscan[%d] " fmt, getpid(), ##args); \
 while (0)
 
 #define log_error_pvscan(cmd, fmt, args...) \
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 324c86e44..468f593b7 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -383,7 +383,7 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
 		 * somehow between the two reads.)
 		 */
 		if (!retries) {
-			log_print("Retrying metadata scan.");
+			log_print_unless_silent("Retrying metadata scan.");
 			retries++;
 			dev_invalidate(mdac->area.dev);
 			goto retry;
diff --git a/lib/label/label.c b/lib/label/label.c
index c122a4ebb..330089f1a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -373,7 +373,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 			 * that now.  It's unlikely this is actually needed.
 			 */
 			if (dev->pvid[0]) {
-				log_print("Clear pvid and info for filtered dev %s", dev_name(dev));
+				log_print_unless_silent("Clear pvid and info for filtered dev %s.", dev_name(dev));
 				lvmcache_del_dev(dev);
 				memset(dev->pvid, 0, sizeof(dev->pvid));
 			}
@@ -400,7 +400,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 		/* See comment above */
 		if (dev->pvid[0]) {
-			log_print("Clear pvid and info for no lvm header %s", dev_name(dev));
+			log_print_unless_silent("Clear pvid and info for no lvm header %s", dev_name(dev));
 			lvmcache_del_dev(dev);
 			memset(dev->pvid, 0, sizeof(dev->pvid));
 		}
@@ -1115,8 +1115,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("%s excluded: %s.",
-				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			log_print_unless_silent("%s excluded: %s.",
+						dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
 		}
@@ -1147,7 +1147,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		int has_pvid;
 
 		if (!label_read_pvid(devl->dev, &has_pvid)) {
-			log_print("%s cannot read label.", dev_name(devl->dev));
+			log_print_unless_silent("%s cannot read label.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
 			continue;
@@ -1155,7 +1155,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 		if (!has_pvid) {
 			/* Not an lvm device */
-			log_print("%s not an lvm device.", dev_name(devl->dev));
+			log_print_unless_silent("%s not an lvm device.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
 			continue;
@@ -1167,8 +1167,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		 */
 		if (relax_deviceid_filter) {
 			if (!(du = get_du_for_pvid(cmd, devl->dev->pvid))) {
-				log_print("%s excluded by devices file (checking PVID).",
-					  dev_name(devl->dev));
+				log_print_unless_silent("%s excluded by devices file (checking PVID).",
+							dev_name(devl->dev));
 				dm_list_del(&devl->list);
 				dm_list_add(&devs_drop, &devl->list);
 				continue;
@@ -1181,8 +1181,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 		/* Applies all filters, including those that need data from dev. */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("%s excluded: %s.",
-				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			log_print_unless_silent("%s excluded: %s.",
+						dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
 		}
@@ -1346,7 +1346,8 @@ int label_scan(struct cmd_context *cmd)
 			dm_list_add(&filtered_devs, &devl->list);
 
 			if (dev->pvid[0]) {
-				log_print("Clear pvid and info for filtered dev %s", dev_name(dev));
+				log_print_unless_silent("Clear pvid and info for filtered dev %s.",
+							dev_name(dev));
 				lvmcache_del_dev(dev);
 				memset(dev->pvid, 0, sizeof(dev->pvid));
 			}
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 614c95642..191dbb9af 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -608,7 +608,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  (unsigned long long)old_size_bytes,
 		  (unsigned long long)new_size_bytes);
 
-	log_print("Zeroing %u MiB on extended internal lvmlock LV...", extend_mb);
+	log_print_unless_silent("Zeroing %u MiB on extended internal lvmlock LV...", extend_mb);
 
 	if (!(dev = dev_cache_get(cmd, path, NULL))) {
 		log_error("Extend sanlock LV %s cannot find device.", display_lvname(lv));
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 456795532..0c1c29436 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -359,8 +359,8 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		} else if (!lbs_4k && !lbs_512) {
 			if (!settings->block_size)
 				settings->block_size = 512;
-			log_print("Using integrity block size %u with unknown device logical block size.",
-				  settings->block_size);
+			log_print_unless_silent("Using integrity block size %u with unknown device logical block size.",
+						settings->block_size);
 		} else {
 			goto_bad;
 		}
@@ -408,8 +408,8 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 
 			settings->block_size = use_bs;
 
-			log_print("Using integrity block size %u for unknown file system block size, logical block size %u, physical block size %u.",
-				  settings->block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+			log_print_unless_silent("Using integrity block size %u for unknown file system block size, logical block size %u, physical block size %u.",
+						settings->block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
 			goto out;
 		}
 
@@ -419,13 +419,13 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 				   for an application that expects a given io size/alignment is possible. */
 				settings->block_size = 512;
 				if (fs_block_size > 512)
-					log_print("Limiting integrity block size to 512 because the LV is active.");
+					log_print_unless_silent("Limiting integrity block size to 512 because the LV is active.");
 			} else if (fs_block_size <= 4096)
 				settings->block_size = fs_block_size;
 			else
 				settings->block_size = 4096; /* dm-integrity max is 4096 */
-			log_print("Using integrity block size %u for file system block size %u.",
-				  settings->block_size, fs_block_size);
+			log_print_unless_silent("Using integrity block size %u for file system block size %u.",
+						settings->block_size, fs_block_size);
 		} else {
 			/* let user specify integrity block size that is less than fs block size */
 			if (settings->block_size > fs_block_size) {
@@ -433,8 +433,8 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 					  settings->block_size, fs_block_size);
 				goto bad;
 			}
-			log_print("Using integrity block size %u for file system block size %u.",
-				  settings->block_size, fs_block_size);
+			log_print_unless_silent("Using integrity block size %u for file system block size %u.",
+						settings->block_size, fs_block_size);
 		}
 	}
 out:
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8975bf180..b8e6ce053 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5634,8 +5634,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	}
 
 	if ((lp->extents == existing_logical_extents) && !lp->use_policies) {
-		log_print("New size (%d extents) matches existing size (%d extents).",
-			  lp->extents, existing_logical_extents);
+		log_print_unless_silent("New size (%d extents) matches existing size (%d extents).",
+					lp->extents, existing_logical_extents);
 		if (lp->resize == LV_ANY)
 			lp->resize = LV_EXTEND; /* lets pretend zero size extension */
 		*matches_existing = 1;
@@ -5694,8 +5694,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 		}
 		lp->resize = LV_EXTEND;
 	} else if ((lp->extents == existing_logical_extents) && !lp->use_policies) {
-		log_print("New size (%d extents) matches existing size (%d extents)",
-			  lp->extents, existing_logical_extents);
+		log_print_unless_silent("New size (%d extents) matches existing size (%d extents)",
+					lp->extents, existing_logical_extents);
 		if (lp->resize == LV_ANY)
 			lp->resize = LV_EXTEND;
 		*matches_existing = 1;
@@ -6048,13 +6048,13 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (!fsi->mounted)
-		log_print("File system %s%s found on %s.",
-			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
-			  display_lvname(lv));
+		log_print_unless_silent("File system %s%s found on %s.",
+					fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+					display_lvname(lv));
 	else
-		log_print("File system %s%s found on %s mounted at %s.",
-			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
-			  display_lvname(lv), fsi->mount_dir);
+		log_print_unless_silent("File system %s%s found on %s mounted at %s.",
+					fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+					display_lvname(lv), fsi->mount_dir);
 
 	if (!fsi->fs_last_byte) {
 		if (!strcmp(fsi->fstype, "reiserfs")) {
@@ -6072,15 +6072,15 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	else if ((larger = (fsi->fs_last_byte > newsize_bytes_fs)))
 		cmp_desc = "larger than";
 
-	log_print("File system size (%s) is %s the requested size (%s).",
-		  display_size(cmd, fsi->fs_last_byte/512), cmp_desc,
-		  display_size(cmd, newsize_bytes_fs/512));
+	log_print_unless_silent("File system size (%s) is %s the requested size (%s).",
+				display_size(cmd, fsi->fs_last_byte/512), cmp_desc,
+				display_size(cmd, newsize_bytes_fs/512));
 
 	/*
 	 * FS reduce is not needed, it's not using the affected space.
 	 */
 	if (smaller || equal) {
-		log_print("File system reduce is not needed, skipping.");
+		log_print_unless_silent("File system reduce is not needed, skipping.");
 		fsi->needs_reduce = 0;
 		return 1;
 	}
@@ -6100,7 +6100,7 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	 * FS reduce required, ext* supports it, xfs does not.
 	 */
 	if (is_ext_fstype) {
-		log_print("File system reduce is required using resize2fs.");
+		log_print_unless_silent("File system reduce is required using resize2fs.");
 	} else if (!strcmp(fsi->fstype, "reiserfs")) {
 		log_error("File system reduce for reiserfs requires --fs resize_fsadm.");
 		return 0;
@@ -6177,13 +6177,13 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 
 	if (fsi->needs_unmount)
-		log_print("File system unmount is needed for reduce.");
+		log_print_unless_silent("File system unmount is needed for reduce.");
 	if (fsi->needs_fsck)
-		log_print("File system fsck will be run before reduce.");
+		log_print_unless_silent("File system fsck will be run before reduce.");
 	if (fsi->needs_mount)
-		log_print("File system mount is needed for reduce.");
+		log_print_unless_silent("File system mount is needed for reduce.");
 	if (fsi->needs_crypt)
-		log_print("cryptsetup resize is needed for reduce.");
+		log_print_unless_silent("cryptsetup resize is needed for reduce.");
 
 	/*
 	 * Use a confirmation prompt because mount|unmount is needed, and
@@ -6230,13 +6230,13 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (!fsi->mounted)
-		log_print("File system %s%s found on %s.",
-			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
-			  display_lvname(lv));
+		log_print_unless_silent("File system %s%s found on %s.",
+					fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+					display_lvname(lv));
 	else
-		log_print("File system %s%s found on %s mounted at %s.",
-			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
-			  display_lvname(lv), fsi->mount_dir);
+		log_print_unless_silent("File system %s%s found on %s mounted at %s.",
+					fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+					display_lvname(lv), fsi->mount_dir);
 
 	/*
 	 * FS extend may require mounting or unmounting, check the fsopt value
@@ -6342,18 +6342,18 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	 * it's mounted.
 	 */
 	if (fsi->mounted && !fsi->needs_unmount && fsi->needs_fsck) {
-		log_print("File system fsck skipped for extending mounted fs.");
+		log_print_unless_silent("File system fsck skipped for extending mounted fs.");
 		fsi->needs_fsck = 0;
 	}
 
 	if (fsi->needs_unmount)
-		log_print("File system unmount is needed for extend.");
+		log_print_unless_silent("File system unmount is needed for extend.");
 	if (fsi->needs_fsck)
-		log_print("File system fsck will be run before extend.");
+		log_print_unless_silent("File system fsck will be run before extend.");
 	if (fsi->needs_mount)
-		log_print("File system mount is needed for extend.");
+		log_print_unless_silent("File system mount is needed for extend.");
 	if (fsi->needs_crypt)
-		log_print("cryptsetup resize is needed for extend.");
+		log_print_unless_silent("cryptsetup resize is needed for extend.");
 
 	/*
 	 * Use a confirmation prompt when mount|unmount is needed if
@@ -6412,8 +6412,8 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (fsinfo.needs_crypt) {
 		newsize_bytes_fs -= fsinfo.crypt_offset_bytes;
-		log_print("File system size %llub is adjusted for crypt data offset %ub.",
-			  (unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
+		log_print_unless_silent("File system size %llub is adjusted for crypt data offset %ub.",
+					(unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
 	}
 
 	/*
@@ -6433,8 +6433,8 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!fsinfo.needs_reduce && fsinfo.needs_crypt) {
 		/* Check if the crypt device is already sufficiently reduced. */
 		if (fsinfo.crypt_dev_size_bytes <= newsize_bytes_fs) {
-			log_print("crypt device is already reduced to %llu bytes.",
-				  (unsigned long long)fsinfo.crypt_dev_size_bytes);
+			log_print_unless_silent("crypt device is already reduced to %llu bytes.",
+						(unsigned long long)fsinfo.crypt_dev_size_bytes);
 			ret = 1;
 			goto out;
 		}
@@ -6461,14 +6461,14 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (test_mode()) {
 		if (fsinfo.needs_unmount)
-			log_print("Skip unmount in test mode.");
+			log_print_unless_silent("Skip unmount in test mode.");
 		if (fsinfo.needs_fsck)
-			log_print("Skip fsck in test mode.");
+			log_print_unless_silent("Skip fsck in test mode.");
 		if (fsinfo.needs_mount)
-			log_print("Skip mount in test mode.");
+			log_print_unless_silent("Skip mount in test mode.");
 		if (fsinfo.needs_crypt)
-			log_print("Skip cryptsetup in test mode.");
-		log_print("Skip fs reduce in test mode.");
+			log_print_unless_silent("Skip cryptsetup in test mode.");
+		log_print_unless_silent("Skip fs reduce in test mode.");
 		ret = 1;
 		goto out;
 	}
@@ -6496,7 +6496,7 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	cmd->can_use_one_scan = 1;
 	if (scan_text_mismatch(cmd, lv->vg->name, NULL)) {
-		log_print("VG was changed during fs operations, restarting.");
+		log_print_unless_silent("VG was changed during fs operations, restarting.");
 		lp->vg_changed_error = 1;
 		ret = 0;
 		goto out;
@@ -6551,8 +6551,8 @@ static int _fs_extend(struct cmd_context *cmd, struct logical_volume *lv,
 	newsize_bytes_fs = newsize_bytes_lv;
 	if (fsinfo.needs_crypt) {
 		newsize_bytes_fs -= fsinfo.crypt_offset_bytes;
-		log_print("File system size %llub is adjusted for crypt data offset %ub.",
-			  (unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
+		log_print_unless_silent("File system size %llub is adjusted for crypt data offset %ub.",
+					(unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
 	}
 
 	/*
@@ -6572,14 +6572,14 @@ static int _fs_extend(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (test_mode()) {
 		if (fsinfo.needs_unmount)
-			log_print("Skip unmount in test mode.");
+			log_print_unless_silent("Skip unmount in test mode.");
 		if (fsinfo.needs_fsck)
-			log_print("Skip fsck in test mode.");
+			log_print_unless_silent("Skip fsck in test mode.");
 		if (fsinfo.needs_mount)
-			log_print("Skip mount in test mode.");
+			log_print_unless_silent("Skip mount in test mode.");
 		if (fsinfo.needs_crypt)
-			log_print("Skip cryptsetup in test mode.");
-		log_print("Skip fs extend in test mode.");
+			log_print_unless_silent("Skip cryptsetup in test mode.");
+		log_print_unless_silent("Skip fs extend in test mode.");
 		ret = 1;
 		goto out;
 	}

