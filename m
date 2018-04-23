From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:48:21 -0400
Subject: master - scan: use new label_scan for lvmcache_label_scan
Message-ID: <201804231348.w3NDmLga031429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4507ba3596a549697733e1b839f25af454ccf878
Commit:        4507ba3596a549697733e1b839f25af454ccf878
Parent:        a7cb76ae94a90c89b86a810ceb4b6a91bab3441e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 7 13:14:08 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:19:32 2018 -0500

scan: use new label_scan for lvmcache_label_scan

To do label scanning, lvm code calls lvmcache_label_scan().
Change lvmcache_label_scan() to use the new label_scan()
based on bcache.

Also add lvmcache_label_rescan_vg() which calls the new
label_scan_devs() which does label scanning on only the
specified devices.  This is for a subsequent commit and
is not yet used.
---
 lib/cache/lvmcache.c           |  234 ++++++++++++++++++++++++++++------------
 lib/cache/lvmcache.h           |   12 ++-
 lib/format_text/format-text.c  |    2 +-
 lib/format_text/import_vsn1.c  |    3 +-
 lib/metadata/metadata-liblvm.c |    2 +-
 5 files changed, 174 insertions(+), 79 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index fb81002..c0b2202 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -72,6 +72,7 @@ struct lvmcache_vginfo {
 	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 	unsigned cached_vg_invalidated;	/* Signal to regenerate cached_vg */
+	int independent_metadata_location; /* metadata read from independent areas */
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -542,7 +543,6 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
-	struct label *label;
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
@@ -587,7 +587,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 
 	dm_list_iterate_safe(devh, tmp, &devs) {
 		devl = dm_list_item(devh, struct device_list);
-		(void) label_read(devl->dev, &label, UINT64_C(0));
+		label_read(devl->dev, NULL, UINT64_C(0));
 		dm_list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -750,7 +750,7 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 	struct lvmcache_info *info;
 	char *vgname;
 
-	if (!lvmcache_device_from_pvid(cmd, (const struct id *)pvid, NULL, NULL)) {
+	if (!lvmcache_device_from_pvid(cmd, (const struct id *)pvid, NULL)) {
 		log_error("Couldn't find device with uuid %s.", pvid);
 		return NULL;
 	}
@@ -766,19 +766,42 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 	return vgname;
 }
 
-static void _rescan_entry(struct lvmcache_info *info)
+/*
+ * FIXME: get rid of the CACHE_INVALID state and rescanning
+ * infos with that flag.  The code should just know which devices
+ * need scanning and when.
+ */
+static int _label_scan_invalid(struct cmd_context *cmd)
 {
-	struct label *label;
+	struct dm_list devs;
+	struct dm_hash_node *n;
+	struct device_list *devl;
+	struct lvmcache_info *info;
+	int dev_count = 0;
+	int ret;
 
-	if (info->status & CACHE_INVALID)
-		(void) label_read(info->dev, &label, UINT64_C(0));
-}
+	dm_list_init(&devs);
 
-static int _scan_invalid(void)
-{
-	dm_hash_iter(_pvid_hash, (dm_hash_iterate_fn) _rescan_entry);
+	dm_hash_iterate(n, _pvid_hash) {
+		if (!(info = dm_hash_get_data(_pvid_hash, n)))
+			continue;
 
-	return 1;
+		if (!(info->status & CACHE_INVALID))
+			continue;
+
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			return_0;
+
+		devl->dev = info->dev;
+		dm_list_add(&devs, &devl->list);
+		dev_count++;
+	}
+
+	log_debug_cache("Scanning %d devs with invalid info.", dev_count);
+
+	ret = label_scan_devs(cmd, &devs);
+
+	return ret;
 }
 
 /*
@@ -1093,17 +1116,89 @@ next:
 	goto next;
 }
 
+/*
+ * The initial label_scan at the start of the command is done without
+ * holding VG locks.  Then for each VG identified during the label_scan,
+ * vg_read(vgname) is called while holding the VG lock.  The labels
+ * and metadata on this VG's devices could have changed between the
+ * initial unlocked label_scan and the current vg_read().  So, we reread
+ * the labels/metadata for each device in the VG now that we hold the
+ * lock, and use this for processing the VG.
+ *
+ * FIXME: In some cases, the data read by label_scan may be fine, and not
+ * need to be reread here. e.g. a reporting command, possibly with a
+ * special option, could skip this second reread.  Or, we could look
+ * at the VG seqno in each copy of the metadata read in the first label
+ * scan, and if they all match, consider it good enough to use for
+ * reporting without rereading it.  (A command modifying the VG would
+ * always want to reread while the lock is held before modifying.)
+ *
+ * A label scan is ultimately creating associations between devices
+ * and VGs so that when vg_read wants to get VG metadata, it knows
+ * which devices to read.  In the special case where VG metadata is
+ * stored in files on the file system (configured in lvm.conf), the
+ * vginfo->independent_metadata_location flag is set during label scan.
+ * When we get here to rescan, we are revalidating the device to VG
+ * mapping from label scan by repeating the label scan on a subset of
+ * devices.  If we see independent_metadata_location is set from the
+ * initial label scan, we know that there is nothing to do because
+ * there is no device to VG mapping to revalidate, since the VG metadata
+ * comes directly from files.
+ */
+
+int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct dm_list devs;
+	struct device_list *devl;
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+
+	if (lvmetad_used())
+		return 1;
+
+	dm_list_init(&devs);
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
+		return_0;
+
+	/*
+	 * When the VG metadata is from an independent location,
+	 * then rescanning the devices in the VG won't find the
+	 * metadata, and will destroy the vginfo/info associations
+	 * that were created during label scan when the
+	 * independent locations were read.
+	 */
+	if (vginfo->independent_metadata_location)
+		return 1;
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!(devl = dm_malloc(sizeof(*devl)))) {
+			log_error("device_list element allocation failed");
+			return 0;
+		}
+		devl->dev = info->dev;
+		dm_list_add(&devs, &devl->list);
+	}
+
+	label_scan_devs(cmd, &devs);
+
+	/*
+	 * TODO: grab vginfo again, and compare vginfo->infos
+	 * to what was found above before rereading labels.
+	 * If there are any info->devs now that were not in the
+	 * first devs list, then do label_read on those also.
+	 */
+
+	return 1;
+}
+
 int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
 	struct lvmcache_info *info;
 	struct device_list *devl;
-	struct label *label;
-	struct dev_iter *iter;
-	struct device *dev;
 	struct format_type *fmt;
-	int dev_count = 0;
 
 	int r = 0;
 
@@ -1121,34 +1216,40 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		goto out;
 	}
 
+	/*
+	 * Scan devices whose info struct has the INVALID flag set.
+	 * When scanning has read the pv_header, mda_header and
+	 * mda locations, it will clear the INVALID flag (via
+	 * lvmcache_make_valid).
+	 */
 	if (_has_scanned && !_force_label_scan) {
-		r = _scan_invalid();
+		r = _label_scan_invalid(cmd);
 		goto out;
 	}
 
 	if (_force_label_scan && (cmd->full_filter && !cmd->full_filter->use_count) && !refresh_filters(cmd))
 		goto_out;
 
-	if (!cmd->full_filter || !(iter = dev_iter_create(cmd->full_filter, _force_label_scan))) {
-		log_error("dev_iter creation failed");
+	if (!cmd->full_filter) {
+		log_error("label scan is missing full filter");
 		goto out;
 	}
 
-	log_very_verbose("Scanning device labels");
-
 	/*
 	 * Duplicates found during this label scan are added to _found_duplicate_devs().
 	 */
 	_destroy_duplicate_device_list(&_found_duplicate_devs);
 
-	while ((dev = dev_iter_get(iter))) {
-		(void) label_read(dev, &label, UINT64_C(0));
-		dev_count++;
-	}
-
-	dev_iter_destroy(iter);
-
-	log_very_verbose("Scanned %d device labels", dev_count);
+	/*
+	 * Do the actual scanning.  This populates lvmcache
+	 * with infos/vginfos based on reading headers from
+	 * each device, and a vg summary from each mda.
+	 *
+	 * Note that this will *skip* scanning a device if
+	 * an info struct already exists in lvmcache for
+	 * the device.
+	 */
+	label_scan(cmd);
 
 	/*
 	 * _choose_preferred_devs() returns:
@@ -1182,7 +1283,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
-			(void) label_read(devl->dev, &label, UINT64_C(0));
+			label_read(devl->dev, NULL, UINT64_C(0));
 		}
 
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
@@ -1441,61 +1542,45 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 	return pvids;
 }
 
-static struct device *_device_from_pvid(const struct id *pvid,
-					uint64_t *label_sector)
+int lvmcache_get_vg_devs(struct cmd_context *cmd,
+			 struct lvmcache_vginfo *vginfo,
+			 struct dm_list *devs)
 {
 	struct lvmcache_info *info;
-	struct label *label;
+	struct device_list *devl;
 
-	if ((info = lvmcache_info_from_pvid((const char *) pvid, NULL, 0))) {
-		if (lvmetad_used()) {
-			if (info->label && label_sector)
-				*label_sector = info->label->sector;
-			return info->dev;
-		}
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			return_0;
 
-		if (label_read(info->dev, &label, UINT64_C(0))) {
-			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->dev->pvid)) {
-				if (label_sector)
-					*label_sector = label->sector;
-				return info->dev;
-                        }
-		}
+		devl->dev = info->dev;
+		dm_list_add(devs, &devl->list);
 	}
-	return NULL;
+	return 1;
 }
 
-struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
-				unsigned *scan_done_once, uint64_t *label_sector)
+static struct device *_device_from_pvid(const struct id *pvid, uint64_t *label_sector)
 {
-	struct device *dev;
-
-	/* Already cached ? */
-	dev = _device_from_pvid(pvid, label_sector);
-	if (dev)
-		return dev;
-
-	lvmcache_label_scan(cmd);
+	struct lvmcache_info *info;
 
-	/* Try again */
-	dev = _device_from_pvid(pvid, label_sector);
-	if (dev)
-		return dev;
+	if ((info = lvmcache_info_from_pvid((const char *) pvid, NULL, 0))) {
+		if (info->label && label_sector)
+			*label_sector = info->label->sector;
+		return info->dev;
+	}
 
-	if (critical_section() || (scan_done_once && *scan_done_once))
-		return NULL;
+	return NULL;
+}
 
-	lvmcache_force_next_label_scan();
-	lvmcache_label_scan(cmd);
-	if (scan_done_once)
-		*scan_done_once = 1;
+struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector)
+{
+	struct device *dev;
 
-	/* Try again */
 	dev = _device_from_pvid(pvid, label_sector);
 	if (dev)
 		return dev;
 
+	log_debug_devs("No device with uuid %s.", (const char *)pvid);
 	return NULL;
 }
 
@@ -1503,7 +1588,6 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 				       const char *devname)
 {
 	struct device *dev;
-	struct label *label;
 
 	if (!(dev = dev_cache_get(devname, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
@@ -1511,7 +1595,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(label_read(dev, &label, UINT64_C(0))))
+	if (!(label_read(dev, NULL, UINT64_C(0))))
 		return NULL;
 
 	return dev->pvid;
@@ -2657,6 +2741,14 @@ int lvmcache_vgid_is_cached(const char *vgid) {
 	return 1;
 }
 
+void lvmcache_set_independent_location(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if ((vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
+		vginfo->independent_metadata_location = 1;
+}
+
 /*
  * Return true iff it is impossible to find out from this info alone whether the
  * PV in question is or is not an orphan.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 847c208..826e91e 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -74,6 +74,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
  */
 void lvmcache_force_next_label_scan(void);
 int lvmcache_label_scan(struct cmd_context *cmd);
+int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
@@ -105,10 +106,8 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *dev, int valid_only);
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname);
-struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
-				unsigned *scan_done_once, uint64_t *label_sector);
-const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
-				       const char *devname);
+struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector);
+const char *lvmcache_pvid_from_devname(struct cmd_context *cmd, const char *devname);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
@@ -215,4 +214,9 @@ void lvmcache_remove_unchosen_duplicate(struct device *dev);
 
 int lvmcache_pvid_in_unchosen_duplicates(const char *pvid);
 
+int lvmcache_get_vg_devs(struct cmd_context *cmd,
+			 struct lvmcache_vginfo *vginfo,
+			 struct dm_list *devs);
+void lvmcache_set_independent_location(const char *vgname);
+
 #endif
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e9a34e6..c438b2d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2534,7 +2534,7 @@ static int _get_config_disk_area(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(dev_area.dev = lvmcache_device_from_pvid(cmd, &id, NULL, NULL))) {
+	if (!(dev_area.dev = lvmcache_device_from_pvid(cmd, &id, NULL))) {
 		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d51397a..b41d83c 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -216,8 +216,7 @@ static int _read_pv(struct format_instance *fid,
 	/*
 	 * Convert the uuid into a device.
 	 */
-	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once,
-                                         &pv->label_sector))) {
+	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, &pv->label_sector))) {
 		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index a4284bc..388e8d9 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -314,7 +314,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 	}
 
 	if (pp->pva.idp) {
-		if ((dev = lvmcache_device_from_pvid(cmd, pp->pva.idp, NULL, NULL)) &&
+		if ((dev = lvmcache_device_from_pvid(cmd, pp->pva.idp, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->full_filter))) {
 			if (!id_write_format((const struct id*)&pp->pva.idp->uuid,
 			    buffer, sizeof(buffer)))


