From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 21:54:55 -0500
Subject: master - label: Clean up storing of device and label sector.
Message-ID: <201801110254.w0B2stgb017482@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35cdd9cf48a8ec4e4e02fe62eec90dcce4fc8970
Commit:        35cdd9cf48a8ec4e4e02fe62eec90dcce4fc8970
Parent:        f771d3f870a3e0b86b729a730b1ef7797e35aec6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 11 02:39:30 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 11 02:54:00 2018 +0000

label: Clean up storing of device and label sector.

No longer use the external 'result' pointer internally to set up the
cached label.  The callback _set_label_read_result() is now given the
internal label pointer directly

Callers that don't need the result are no longer required to pass a
label pointer into label_read().
---
 lib/cache/lvmcache.c           |   15 +++++----------
 lib/format1/lvm1-label.c       |    7 ++++---
 lib/format_pool/pool_label.c   |    7 ++++---
 lib/format_text/text_label.c   |   19 ++++++++++---------
 lib/label/label.c              |   29 ++++++++++++++---------------
 lib/label/label.h              |    4 ++--
 lib/metadata/metadata-liblvm.c |    3 +--
 7 files changed, 40 insertions(+), 44 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a24fd0a..bc74562 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -548,7 +548,6 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
-	struct label *label;
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
@@ -593,7 +592,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 
 	dm_list_iterate_safe(devh, tmp, &devs) {
 		devl = dm_list_item(devh, struct device_list);
-		(void) label_read(devl->dev, &label, UINT64_C(0));
+		(void) label_read(devl->dev, NULL, UINT64_C(0));
 		dm_list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -776,10 +775,8 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 
 static void _rescan_entry(struct lvmcache_info *info)
 {
-	struct label *label;
-
 	if (info->status & CACHE_INVALID)
-		(void) label_read(info->dev, &label, UINT64_C(0));
+		(void) label_read(info->dev, NULL, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -1115,7 +1112,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	struct dm_list add_cache_devs;
 	struct lvmcache_info *info;
 	struct device_list *devl;
-	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
 	struct format_type *fmt;
@@ -1160,7 +1156,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	while ((dev = dev_iter_get(iter))) {
 		nr_labels_outstanding++;
-		if (!label_read_callback(cmd->mem, dev, UINT64_C(0), _process_label_data, &nr_labels_outstanding))
+		if (!label_read_callback(dev, UINT64_C(0), _process_label_data, &nr_labels_outstanding))
 			nr_labels_outstanding--;
 		dev_count++;
 	}
@@ -1201,7 +1197,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
-			(void) label_read(devl->dev, &label, UINT64_C(0));
+			(void) label_read(devl->dev, NULL, UINT64_C(0));
 		}
 
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
@@ -1522,7 +1518,6 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 				       const char *devname)
 {
 	struct device *dev;
-	struct label *label;
 
 	if (!(dev = dev_cache_get(devname, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
@@ -1530,7 +1525,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(label_read(dev, &label, UINT64_C(0))))
+	if (!(label_read(dev, NULL, UINT64_C(0))))
 		return NULL;
 
 	return dev->pvid;
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 84d6f4e..1452dea 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -54,12 +54,13 @@ static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
 	struct lvmcache_info *info;
+	struct label *label;
 	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
 	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
@@ -79,7 +80,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, struct
 				  exported)))
 		goto_out;
 
-	*label = lvmcache_get_label(info);
+	label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
 	lvmcache_set_ext_version(info, 0);
@@ -92,7 +93,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, struct
 
 out:
 	if (read_label_callback_fn)
-		read_label_callback_fn(!r, read_label_callback_context, NULL);
+		read_label_callback_fn(!r, read_label_callback_context, label);
 
 	return r;
 }
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 451d7d0..320cef2 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -55,16 +55,17 @@ static int _pool_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _pool_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+static int _pool_read(struct labeller *l, struct device *dev, void *buf,
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pool_list pl;
+	struct label *label;
 	int r;
 
-	r = read_pool_label(&pl, l, dev, buf, label);
+	r = read_pool_label(&pl, l, dev, buf, &label);
 
 	if (read_label_callback_fn)
-		read_label_callback_fn(!r, read_label_callback_context, NULL);
+		read_label_callback_fn(!r, read_label_callback_context, label);
 
 	return r;
 }
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7f3b2d3..44d43f1 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -321,7 +321,7 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 
 struct update_mda_baton {
 	struct lvmcache_info *info;
-	struct label *label;
+	struct labeller *labeller;
 	int nr_outstanding_mdas;
 	lvm_callback_fn_t read_label_callback_fn;
 	void *read_label_callback_context;
@@ -362,7 +362,7 @@ static void _process_mda_header(int failed, void *context, const void *data)
 	struct process_mda_header_params *pmp = context;
 	const struct mda_header *mdah = data;
 	struct update_mda_baton *umb = pmp->umb;
-	const struct format_type *fmt = umb->label->labeller->fmt;
+	const struct format_type *fmt = umb->labeller->fmt;
 	struct metadata_area *mda = pmp->mda;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
@@ -394,8 +394,8 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 {
 	struct process_mda_header_params *pmp;
 	struct update_mda_baton *umb = baton;
-	const struct format_type *fmt = umb->label->labeller->fmt;
-	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
+	const struct format_type *fmt = umb->labeller->fmt;
+	struct dm_pool *mem = umb->labeller->fmt->cmd->mem;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
@@ -434,7 +434,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	return pmp->ret;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label,
+static int _text_read(struct labeller *l, struct device *dev, void *buf, 
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct label_header *lh = (struct label_header *) buf;
@@ -446,6 +446,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf, struct
 	uint32_t ext_version;
 	struct dm_pool *mem = l->fmt->cmd->mem;
 	struct update_mda_baton *umb;
+	struct label *label = NULL;
 
 	/*
 	 * PV header base
@@ -457,7 +458,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf, struct
 				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
 		goto_bad;
 
-	*label = lvmcache_get_label(info);
+	label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
 
@@ -511,7 +512,7 @@ out:
 	}
 
 	umb->info = info;
-	umb->label = *label;
+	umb->labeller = label->labeller;
 	umb->read_label_callback_fn = read_label_callback_fn;
 	umb->read_label_callback_context = read_label_callback_context;
 	umb->nr_outstanding_mdas = 1;
@@ -526,13 +527,13 @@ out:
 			lvmcache_make_valid(info);
 
 	if (umb->read_label_callback_fn)
-		umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, NULL);
+		umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, label);
 
 	return 1;
 
 bad:
 	if (read_label_callback_fn)
-		read_label_callback_fn(1, read_label_callback_context, NULL);
+		read_label_callback_fn(1, read_label_callback_context, label);
 
 	return 0;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index 27b72d3..be05285 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -135,17 +135,22 @@ static void _set_label_read_result(int failed, void *context, const void *data)
 {
 	struct find_labeller_params *flp = context;
 	struct label **result = flp->result;
+	struct label *label = (struct label *) data;
 
 	if (failed) {
 		flp->ret = 0;
 		goto_out;
 	}
 
-	if (result && *result) {
-		(*result)->dev = flp->dev;
-		(*result)->sector = flp->label_sector;
+	/* Fix up device and label sector which the low-level code doesn't set */
+	if (label) {
+		label->dev = flp->dev;
+		label->sector = flp->label_sector;
 	}
 
+	if (result)
+		*result = (struct label *) label;
+
 out:
 	if (!dev_close(flp->dev))
 		stack;
@@ -160,7 +165,6 @@ static void _find_labeller(int failed, void *context, const void *data)
 	const char *readbuf = data;
 	struct device *dev = flp->dev;
 	uint64_t scan_sector = flp->scan_sector;
-	struct label **result = flp->result;
 	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct labeller_i *li;
 	struct labeller *l = NULL;	/* Set when a labeller claims the label */
@@ -233,7 +237,7 @@ static void _find_labeller(int failed, void *context, const void *data)
 		flp->ret = 0;
 		_set_label_read_result(1, flp, NULL);
 	} else
-		(void) (l->ops->read)(l, dev, labelbuf, result, &_set_label_read_result, flp);
+		(void) (l->ops->read)(l, dev, labelbuf, &_set_label_read_result, flp);
 }
 
 /* FIXME Also wipe associated metadata area headers? */
@@ -318,7 +322,8 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
-		*result = lvmcache_get_label(info);
+		if (result)
+			*result = lvmcache_get_label(info);
 		if (process_label_data_fn)
 			process_label_data_fn(0, process_label_data_context, NULL);
 		return 1;
@@ -360,22 +365,16 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 	return flp->ret;
 }
 
+/* result may be NULL if caller doesn't need it */
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
 {
 	return _label_read(dev, scan_sector, result, NULL, NULL);
 }
 
-int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_sector,
+int label_read_callback(struct device *dev, uint64_t scan_sector,
 		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
 {
-	struct label **result;	/* FIXME Eliminate this */
-
-	if (!(result = dm_pool_zalloc(mem, sizeof(*result)))) {
-		log_error("Couldn't allocate memory for internal result pointer.");
-		return 0;
-	}
-
-	return _label_read(dev, scan_sector, result, process_label_data_fn, process_label_data_context);
+	return _label_read(dev, scan_sector, NULL, process_label_data_fn, process_label_data_context);
 }
 
 /* Caller may need to use label_get_handler to create label struct! */
diff --git a/lib/label/label.h b/lib/label/label.h
index 7f365f2..c566870 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -62,7 +62,7 @@ struct label_ops {
 	/*
 	 * Read a label from a volume.
 	 */
-	int (*read) (struct labeller *l, struct device *dev, void *buf, struct label **label,
+	int (*read) (struct labeller *l, struct device *dev, void *buf,
 		     lvm_callback_fn_t label_read_callback_fn, void *label_read_callback_context);
 
 	/*
@@ -96,7 +96,7 @@ struct labeller *label_get_handler(const char *name);
 int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
-int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_sector,
+int label_read_callback(struct device *dev, uint64_t scan_sector,
 			lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index a4284bc..d192b15 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -491,7 +491,6 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 {
 	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
 	struct device *dev;
-	struct label *label;
 	struct pv_list *pvl;
 	struct physical_volume *pv = NULL;
 	int used;
@@ -506,7 +505,7 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!label_read(dev, &label, 0)) {
+	if (!label_read(dev, NULL, 0)) {
 		if (force_count)
 			return 1;
 		log_error("No PV label found on %s.", name);


