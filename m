From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:53:34 -0400
Subject: master - scan: use separate fd for bcache
Message-ID: <201804231353.w3NDrYsv001201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c67c7557c266063db962807aca18fc088ba921e
Commit:        6c67c7557c266063db962807aca18fc088ba921e
Parent:        4343280ebc0e2aae0de5fe959c24574b13d0d7be
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 08:58:35 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: use separate fd for bcache

Create a new dev->bcache_fd that the scanning code owns
and is in charge of opening/closing.  This prevents other
parts of lvm code (which do various open/close) from
interfering with the bcache fd.  A number of dev_open
and dev_close are removed from the reading path since
the read path now uses the bcache.

With that in place, open(O_EXCL) for pvcreate/pvremove
can then be fixed.  That wouldn't work previously because
of other open fds.
---
 lib/cache/lvmetad.c            |   12 +++-
 lib/config/config.c            |    4 +-
 lib/device/dev-io.c            |   28 ++++----
 lib/device/device.h            |    2 +
 lib/format_text/format-text.c  |   55 +++-----------
 lib/format_text/text_label.c   |   13 ---
 lib/label/label.c              |  166 +++++++++++++++++++++++++++++++---------
 lib/label/label.h              |    1 +
 lib/metadata/metadata-liblvm.c |    1 +
 tools/toollib.c                |   44 ++++-------
 10 files changed, 187 insertions(+), 139 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 81ba1b7..ed0bcde 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2551,11 +2551,18 @@ static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *p
  */
 static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
 {
-	struct device *dev;
 
-	log_debug_devs("device %d:%d open to update udev",
+	/*
+	 * FIXME: this is diabled as part of removing dev_opens
+	 * to integrate bcache.  If this is really needed, we
+	 * can do a separate open/close here.
+	 */
+	log_debug_devs("SKIP device %d:%d open to update udev",
 		       (int)MAJOR(devt), (int)MINOR(devt));
 
+#if 0
+	struct device *dev;
+
 	if (!(dev = dev_cache_get_by_devt(devt, cmd->lvmetad_filter))) {
 		log_error("_update_pv_in_udev no dev found");
 		return;
@@ -2568,6 +2575,7 @@ static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
 
 	if (!dev_close(dev))
 		stack;
+#endif
 }
 
 /*
diff --git a/lib/config/config.c b/lib/config/config.c
index 2d7db69..0711b8c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -534,11 +534,11 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			return 0;
 		}
 
-		if (!bcache_read_bytes(scan_bcache, dev->fd, offset, size, buf))
+		if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, offset, size, buf))
 			goto out;
 
 		if (size2) {
-			if (!bcache_read_bytes(scan_bcache, dev->fd, offset2, size2, buf + size))
+			if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, offset2, size2, buf + size))
 				goto out;
 		}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index c321e61..39d5d30 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -330,6 +330,8 @@ static int _dev_get_size_file(struct device *dev, uint64_t *size)
 static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 {
 	const char *name = dev_name(dev);
+	int fd = dev->bcache_fd;
+	int do_close = 0;
 
 	if (dev->size_seqno == _dev_size_seqno) {
 		log_very_verbose("%s: using cached size %" PRIu64 " sectors",
@@ -338,12 +340,16 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 		return 1;
 	}
 
-	if (!dev_open_readonly(dev))
-		return_0;
+	if (fd <= 0) {
+		if (!dev_open_readonly(dev))
+			return_0;
+		fd = dev_fd(dev);
+		do_close = 1;
+	}
 
-	if (ioctl(dev_fd(dev), BLKGETSIZE64, size) < 0) {
+	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
 		log_sys_error("ioctl BLKGETSIZE64", name);
-		if (!dev_close(dev))
+		if (do_close && !dev_close(dev))
 			log_sys_error("close", name);
 		return 0;
 	}
@@ -352,7 +358,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	dev->size = *size;
 	dev->size_seqno = _dev_size_seqno;
 
-	if (!dev_close(dev))
+	if (do_close && !dev_close(dev))
 		log_sys_error("close", name);
 
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
@@ -629,17 +635,12 @@ int dev_open_readonly_quiet(struct device *dev)
 
 int dev_test_excl(struct device *dev)
 {
-	int flags;
-	int r;
+	int flags = 0;
 
-	flags = vg_write_lock_held() ? O_RDWR : O_RDONLY;
 	flags |= O_EXCL;
+	flags |= O_RDWR;
 
-	r = dev_open_flags(dev, flags, 1, 1);
-	if (r)
-		dev_close_immediate(dev);
-
-	return r;
+	return dev_open_flags(dev, flags, 1, 1);
 }
 
 static void _close(struct device *dev)
@@ -659,7 +660,6 @@ static void _close(struct device *dev)
 
 static int _dev_close(struct device *dev, int immediate)
 {
-
 	if (dev->fd < 0) {
 		log_error("Attempt to close device '%s' "
 			  "which is not open.", dev_name(dev));
diff --git a/lib/device/device.h b/lib/device/device.h
index d5eb00f..36d1e3e 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -32,6 +32,7 @@
 #define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 #define DEV_IN_BCACHE		0x00000800      /* dev fd is open and used in bcache */
+#define DEV_BCACHE_EXCL		0x00001000      /* bcache_fd should be open EXCL */
 
 /*
  * Support for external device info.
@@ -66,6 +67,7 @@ struct device {
 	int phys_block_size;
 	int block_size;
 	int read_ahead;
+	int bcache_fd;
 	uint32_t flags;
 	unsigned size_seqno;
 	uint64_t size;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 8740a05..a5d8397 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -320,7 +320,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	log_debug_metadata("Reading mda header sector from %s@%llu",
 			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 
-	if (!bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
+	if (!bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to read metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
@@ -462,7 +462,7 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
-	bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
+	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
@@ -510,18 +510,12 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	int noprecommit = 0;
 	struct mda_header *mdah;
 
-	if (!dev_open_readonly(dev_area->dev))
-		return_0;
-
 	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
 		return_0;
 
 	if (_read_metadata_location_vg(dev_area, mdah, 0, vgname, &noprecommit))
 		r = 1;
 
-	if (!dev_close(dev_area->dev))
-		stack;
-
 	return r;
 }
 
@@ -595,14 +589,8 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	if (!dev_open_readonly(mdac->area.dev))
-		return_NULL;
-
 	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
 
-	if (!dev_close(mdac->area.dev))
-		stack;
-
 	return vg;
 }
 
@@ -615,14 +603,8 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	if (!dev_open_readonly(mdac->area.dev))
-		return_NULL;
-
 	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, mda_is_primary(mda));
 
-	if (!dev_close(mdac->area.dev))
-		stack;
-
 	return vg;
 }
 
@@ -653,9 +635,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!found)
 		return 1;
 
-	if (!dev_open(mdac->area.dev))
-		return_0;
-
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
@@ -694,6 +673,9 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	label_scan_invalidate(mdac->area.dev);
 
+	if (!dev_open(mdac->area.dev))
+		return_0;
+
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
 		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
@@ -879,9 +861,6 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	int r = 0;
 	int noprecommit = 0;
 
-	if (!dev_open(mdac->area.dev))
-		return_0;
-
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
@@ -895,6 +874,9 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn->checksum = 0;
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
+	if (!dev_open(mdac->area.dev))
+		return_0;
+
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
@@ -1227,7 +1209,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
+	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1338,15 +1320,9 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 	dm_list_iterate_items(rl, raw_list) {
 		log_debug_metadata("Scanning independent dev %s", dev_name(rl->dev_area.dev));
 
-		/* FIXME We're reading mdah twice here... */
-		if (!dev_open_readonly(rl->dev_area.dev)) {
-			stack;
-			continue;
-		}
-
 		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area, 0))) {
 			stack;
-			goto close_dev;
+			continue;
 		}
 
 		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
@@ -1356,9 +1332,6 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 				lvmcache_set_independent_location(vg->name);
 			}
 		}
-	close_dev:
-		if (!dev_close(rl->dev_area.dev))
-			stack;
 	}
 
 	return 1;
@@ -1488,9 +1461,6 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	if (!lvmcache_update_das(info, pv))
 		return_0;
 
-	if (!dev_open(pv->dev))
-		return_0;
-
 	baton.pv = pv;
 	baton.fmt = fmt;
 
@@ -1502,8 +1472,6 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 
 	if (!label_write(pv->dev, label)) {
 		stack;
-		if (!dev_close(pv->dev))
-			stack;
 		return 0;
 	}
 
@@ -1513,9 +1481,6 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	 *        update the cache afterwards?
 	 */
 
-	if (!dev_close(pv->dev))
-		return_0;
-
 	return 1;
 }
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 1c322dd..206ae3f 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -338,12 +338,6 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 	 * TODO: make lvmcache smarter and move this cache logic there
 	 */
 
-	if (!dev_open_readonly(mdac->area.dev)) {
-		mda_set_ignored(mda, 1);
-		stack;
-		return 1;
-	}
-
 	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
 		stack;
 		goto close_dev;
@@ -355,23 +349,16 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
 				   dev_name(mdac->area.dev),
 				   mdac->area.start);
-		if (!dev_close(mdac->area.dev))
-			stack;
 		return 1;
 	}
 
 	if (read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
 			     &mdac->free_sectors) &&
 	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
-		if (!dev_close(mdac->area.dev))
-			stack;
 		return_0;
 	}
 
 close_dev:
-	if (!dev_close(mdac->area.dev))
-		stack;
-
 	return 1;
 }
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 57d5248..2ec187c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -116,6 +116,8 @@ int label_remove(struct device *dev)
 
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
+	label_scan_invalidate(dev);
+
 	if (!dev_open(dev))
 		return_0;
 
@@ -125,8 +127,6 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
-	label_scan_invalidate(dev);
-
 	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
@@ -396,6 +396,71 @@ static int _process_block(struct device *dev, struct block *bb, int *is_lvm_devi
 	return ret;
 }
 
+static int _scan_dev_open(struct device *dev)
+{
+	const char *name;
+	int flags = 0;
+	int fd;
+
+	if (dev->flags & DEV_IN_BCACHE) {
+		log_error("scan_dev_open %s DEV_IN_BCACHE already set", dev_name(dev));
+		dev->flags &= ~DEV_IN_BCACHE;
+	}
+
+	if (dev->bcache_fd > 0) {
+		log_error("scan_dev_open %s already open with fd %d",
+			  dev_name(dev), dev->bcache_fd);
+		return 0;
+	}
+
+	if (!(name = dev_name_confirmed(dev, 1))) {
+		log_error("scan_dev_open %s no name", dev_name(dev));
+		return 0;
+	}
+
+	flags |= O_RDWR;
+	flags |= O_DIRECT;
+	flags |= O_NOATIME;
+
+	if (dev->flags & DEV_BCACHE_EXCL)
+		flags |= O_EXCL;
+
+	fd = open(name, flags, 0777);
+
+	if (fd < 0) {
+		if ((errno == EBUSY) && (flags & O_EXCL)) {
+			log_error("Can't open %s exclusively.  Mounted filesystem?",
+				  dev_name(dev));
+		} else {
+			log_error("scan_dev_open %s failed errno %d", dev_name(dev), errno);
+		}
+		return 0;
+	}
+
+	dev->flags |= DEV_IN_BCACHE;
+	dev->bcache_fd = fd;
+	return 1;
+}
+
+static int _scan_dev_close(struct device *dev)
+{
+	if (!(dev->flags & DEV_IN_BCACHE))
+		log_error("scan_dev_close %s no DEV_IN_BCACHE set", dev_name(dev));
+
+	dev->flags &= ~DEV_IN_BCACHE;
+	dev->flags &= ~DEV_BCACHE_EXCL;
+
+	if (dev->bcache_fd < 0) {
+		log_error("scan_dev_close %s already closed", dev_name(dev));
+		return 0;
+	}
+
+	if (close(dev->bcache_fd))
+		log_warn("close %s errno %d", dev_name(dev), errno);
+	dev->bcache_fd = -1;
+	return 1;
+}
+
 /*
  * Read or reread label/metadata from selected devs.
  *
@@ -407,7 +472,7 @@ static int _process_block(struct device *dev, struct block *bb, int *is_lvm_devi
  * its info is removed from lvmcache.
  */
 
-static int _scan_list(struct dm_list *devs)
+static int _scan_list(struct dm_list *devs, int *failed)
 {
 	struct dm_list wait_devs;
 	struct dm_list done_devs;
@@ -439,19 +504,16 @@ static int _scan_list(struct dm_list *devs)
 		if (!rem_prefetches)
 			break;
 
-		/*
-		 * The in-bcache flag corresponds with this dev_open.
-		 * Clearing the in-bcache flag should be paired with
-		 * a dev_close.  (This dev may already be in bcache.)
-		 */
 		if (!_in_bcache(devl->dev)) {
-			if (!dev_open_readonly(devl->dev)) {
+			if (!_scan_dev_open(devl->dev)) {
 				log_debug_devs("%s: Failed to open device.", dev_name(devl->dev));
+				dm_list_del(&devl->list);
+				scan_failed_count++;
 				continue;
 			}
 		}
 
-		bcache_prefetch(scan_bcache, devl->dev->fd, 0);
+		bcache_prefetch(scan_bcache, devl->dev->bcache_fd, 0);
 
 		rem_prefetches--;
 
@@ -462,12 +524,12 @@ static int _scan_list(struct dm_list *devs)
 	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
 		bb = NULL;
 
-		if (!bcache_get(scan_bcache, devl->dev->fd, 0, 0, &bb)) {
+		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
 			log_debug_devs("%s: Failed to scan device.", dev_name(devl->dev));
 			scan_failed_count++;
 			scan_failed = 1;
 		} else {
-			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->fd, bb);
+			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
 			_process_block(devl->dev, bb, &is_lvm_device);
 			scan_lvm_count++;
 			scan_failed = 0;
@@ -483,12 +545,8 @@ static int _scan_list(struct dm_list *devs)
 		 * drop it from bcache.
 		 */
 		if (scan_failed || !is_lvm_device) {
-			devl->dev->flags &= ~DEV_IN_BCACHE;
-			bcache_invalidate_fd(scan_bcache, devl->dev->fd);
-			dev_close(devl->dev);
-		} else {
-			/* The device must be kept open while it's in bcache. */
-			devl->dev->flags |= DEV_IN_BCACHE;
+			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_scan_dev_close(devl->dev);
 		}
 
 		dm_list_del(&devl->list);
@@ -498,12 +556,13 @@ static int _scan_list(struct dm_list *devs)
 	if (!dm_list_empty(devs))
 		goto scan_more;
 
-	/* FIXME: let the caller know if some lvm devices failed to be scanned. */
-
 	log_debug_devs("Scanned %d devices: %d for lvm, %d failed.",
 			dm_list_size(&done_devs), scan_lvm_count, scan_failed_count);
 
-	return 0;
+	if (failed)
+		*failed = scan_failed_count;
+
+	return 1;
 }
 
 /*
@@ -548,8 +607,10 @@ int label_scan(struct cmd_context *cmd)
 		 * label_scan should not generally be called a second time,
 		 * so this will usually not be true.
 		 */
-		if (_in_bcache(dev))
-			bcache_invalidate_fd(scan_bcache, dev->fd);
+		if (_in_bcache(dev)) {
+			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+			_scan_dev_close(dev);
+		}
 	};
 	dev_iter_destroy(iter);
 
@@ -573,7 +634,9 @@ int label_scan(struct cmd_context *cmd)
 			return 0;
 	}
 
-	return _scan_list(&all_devs);
+	_scan_list(&all_devs, NULL);
+
+	return 1;
 }
 
 /*
@@ -589,19 +652,48 @@ int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
 	struct device_list *devl;
 
 	dm_list_iterate_items(devl, devs) {
-		if (_in_bcache(devl->dev))
-			bcache_invalidate_fd(scan_bcache, devl->dev->fd);
+		if (_in_bcache(devl->dev)) {
+			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_scan_dev_close(devl->dev);
+		}
+	}
+
+	_scan_list(devs, NULL);
+
+	/* FIXME: this function should probably fail if any devs couldn't be scanned */
+
+	return 1;
+}
+
+int label_scan_devs_excl(struct dm_list *devs)
+{
+	struct device_list *devl;
+	int failed = 0;
+
+	dm_list_iterate_items(devl, devs) {
+		if (_in_bcache(devl->dev)) {
+			bcache_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_scan_dev_close(devl->dev);
+		}
+		/*
+		 * With this flag set, _scan_dev_open() done by
+		 * _scan_list() will do open EXCL
+		 */
+		devl->dev->flags |= DEV_BCACHE_EXCL;
 	}
 
-	return _scan_list(devs);
+	_scan_list(devs, &failed);
+
+	if (failed)
+		return 0;
+	return 1;
 }
 
 void label_scan_invalidate(struct device *dev)
 {
 	if (_in_bcache(dev)) {
-		dev->flags &= ~DEV_IN_BCACHE;
-		bcache_invalidate_fd(scan_bcache, dev->fd);
-		dev_close(dev);
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
 	}
 }
 
@@ -645,7 +737,7 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 {
 	struct dm_list one_dev;
 	struct device_list *devl;
-	int ret;
+	int failed = 0;
 
 	/* scanning is done by list, so make a single item list for this dev */
 	if (!(devl = dm_zalloc(sizeof(*devl))))
@@ -654,10 +746,12 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 	dm_list_init(&one_dev);
 	dm_list_add(&one_dev, &devl->list);
 
-	if (_in_bcache(dev))
-		bcache_invalidate_fd(scan_bcache, dev->fd);
+	if (_in_bcache(dev)) {
+		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_scan_dev_close(dev);
+	}
 
-	ret = _scan_list(&one_dev);
+	_scan_list(&one_dev, &failed);
 
 	/*
 	 * FIXME: this ugliness of returning a pointer to the label is
@@ -671,7 +765,9 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 			*labelp = lvmcache_get_label(info);
 	}
 
-	return ret;
+	if (failed)
+		return 0;
+	return 1;
 }
 
 /*
diff --git a/lib/label/label.h b/lib/label/label.h
index d9e36bc..eb62f64 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -104,6 +104,7 @@ extern struct bcache *scan_bcache;
 
 int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs);
+int label_scan_devs_excl(struct dm_list *devs);
 void label_scan_invalidate(struct device *dev);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index 388e8d9..d8b3b2a 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -241,6 +241,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 			  name);
 		goto out;
 	}
+	dev_close(dev);
 
 	if (!wipe_known_signatures(cmd, dev, name,
 				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
diff --git a/tools/toollib.c b/tools/toollib.c
index f6169ae..0cc2edd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5082,16 +5082,6 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	log_debug("Checking pvcreate arg %s which has existing PVID: %.32s.",
 		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "<none>");
 
-	/*
-	 * This test will fail if the device belongs to an MD array.
-	 */
-	if (!dev_test_excl(pv->dev)) {
-		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  pv_dev_name(pv));
-		dm_list_move(&pp->arg_fail, &pd->list);
-		return 1;
-	}
 
 	/*
 	 * Don't allow using a device with duplicates.
@@ -5223,14 +5213,6 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 	if (!found)
 		return 1;
 
-	/* Repeat the same from check_single. */
-	if (!dev_test_excl(pv->dev)) {
-		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  pv_dev_name(pv));
-		goto fail;
-	}
-
 	/*
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
@@ -5323,16 +5305,6 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	log_debug("Checking device %s for pvremove %.32s.",
 		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
 
-	/*
-	 * This test will fail if the device belongs to an MD array.
-	 */
-	if (!dev_test_excl(pv->dev)) {
-		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  pv_dev_name(pv));
-		dm_list_move(&pp->arg_fail, &pd->list);
-		return 1;
-	}
 
 	/*
 	 * Is there a pv here already?
@@ -5458,8 +5430,10 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct volume_group *orphan_vg;
 	struct dm_list remove_duplicates;
 	struct dm_list arg_sort;
+	struct dm_list rescan_devs;
 	struct pv_list *pvl;
 	struct pv_list *vgpvl;
+	struct device_list *devl;
 	const char *pv_name;
 	int consistent = 0;
 	int must_use_all = (cmd->cname->flags & MUST_USE_ALL_ARGS);
@@ -5470,6 +5444,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	dm_list_init(&remove_duplicates);
 	dm_list_init(&arg_sort);
+	dm_list_init(&rescan_devs);
 
 	handle->custom_handle = pp;
 
@@ -5715,6 +5690,19 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 do_command:
 
+	dm_list_iterate_items(pd, &pp->arg_process) {
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			goto bad;
+		devl->dev = pd->dev;
+		dm_list_add(&rescan_devs, &devl->list);
+	}
+
+	log_debug("Rescanning devices with exclusive open");
+	if (!label_scan_devs_excl(&rescan_devs)) {
+		log_debug("Failed to rescan devs excl");
+		goto bad;
+	}
+
 	/*
 	 * Reorder arg_process entries to match the original order of args.
 	 */


