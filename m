From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 8 Jan 2018 19:58:28 -0500
Subject: master - label: Add label_read callback.
Message-ID: <201801090058.w090wSYV005519@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b02d4e22eeb0dbf61e2c93f3803fbbaeffb0291
Commit:        4b02d4e22eeb0dbf61e2c93f3803fbbaeffb0291
Parent:        6d322e68f302e5406e93ec7649f537776f78f641
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 8 23:08:22 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 8 23:30:50 2018 +0000

label: Add label_read callback.

---
 lib/cache/lvmcache.c |   15 +++++++++++++--
 lib/label/label.c    |   44 +++++++++++++++++++++++++++++++++++++-------
 lib/label/label.h    |    2 ++
 3 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 25bf7ee..53f1c95 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1095,6 +1095,14 @@ next:
 	goto next;
 }
 
+/* Track the number of outstanding label reads */
+static void _process_label_data(int failed, void *context, void *data)
+{
+	int *nr_labels_outstanding = context;
+
+	(*nr_labels_outstanding)--;
+}
+
 int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
@@ -1106,6 +1114,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	struct device *dev;
 	struct format_type *fmt;
 	int dev_count = 0;
+	int nr_labels_outstanding = 0;
 
 	int r = 0;
 
@@ -1144,13 +1153,15 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	_destroy_duplicate_device_list(&_found_duplicate_devs);
 
 	while ((dev = dev_iter_get(iter))) {
-		(void) label_read(dev, &label, UINT64_C(0));
+		nr_labels_outstanding++;
+		if (!label_read_callback(cmd->mem, dev, UINT64_C(0), _process_label_data, &nr_labels_outstanding))
+			nr_labels_outstanding--;
 		dev_count++;
 	}
 
 	dev_iter_destroy(iter);
 
-	log_very_verbose("Scanned %d device labels", dev_count);
+	log_very_verbose("Scanned %d device labels (%d outstanding)", dev_count, nr_labels_outstanding);
 
 	/*
 	 * _choose_preferred_devs() returns:
diff --git a/lib/label/label.c b/lib/label/label.c
index 0ed5c6a..b116ea6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -122,8 +122,10 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 struct find_labeller_params {
 	struct device *dev;
 	uint64_t scan_sector;	/* Sector to be scanned */
-
 	uint64_t label_sector;	/* Sector where label found */
+	lvm_callback_fn_t process_label_data_fn;
+	void *process_label_data_context;
+
 	struct label **result;
 
 	int ret;
@@ -134,8 +136,10 @@ static void _set_label_read_result(int failed, void *context, void *data)
 	struct find_labeller_params *flp = context;
 	struct label **result = flp->result;
 
-	if (failed)
+	if (failed) {
+		flp->ret = 0;
 		goto_out;
+	}
 
 	if (result && *result) {
 		(*result)->dev = flp->dev;
@@ -145,6 +149,9 @@ static void _set_label_read_result(int failed, void *context, void *data)
 out:
 	if (!dev_close(flp->dev))
 		stack;
+
+	if (flp->ret && flp->process_label_data_fn)
+		flp->process_label_data_fn(0, flp->process_label_data_context, NULL);
 }
 
 static void _find_labeller(int failed, void *context, void *data)
@@ -161,6 +168,12 @@ static void _find_labeller(int failed, void *context, void *data)
 	struct lvmcache_info *info;
 	uint64_t sector;
 
+	if (failed) {
+		log_debug_devs("%s: Failed to read label area", dev_name(dev));
+		_set_label_read_result(1, flp, NULL);
+		return;
+	}
+
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
@@ -222,7 +235,7 @@ static void _find_labeller(int failed, void *context, void *data)
 		flp->ret = 0;
 		_set_label_read_result(1, flp, NULL);
 	} else
-		flp->ret = (l->ops->read)(l, dev, labelbuf, result, &_set_label_read_result, flp);
+		(void) (l->ops->read)(l, dev, labelbuf, result, &_set_label_read_result, flp);
 }
 
 /* FIXME Also wipe associated metadata area headers? */
@@ -300,7 +313,8 @@ int label_remove(struct device *dev)
 	return r;
 }
 
-static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result)
+static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result,
+		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
 {
 	struct lvmcache_info *info;
 	struct find_labeller_params *flp;
@@ -309,6 +323,8 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
 		*result = lvmcache_get_label(info);
+		if (process_label_data_fn)
+			process_label_data_fn(0, process_label_data_context, NULL);
 		return 1;
 	}
 
@@ -320,6 +336,8 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 	flp->dev = dev;
 	flp->scan_sector = scan_sector;
 	flp->result = result;
+	flp->process_label_data_fn = process_label_data_fn;
+	flp->process_label_data_context = process_label_data_context;
 	flp->ret = 1;
 
 	/* Ensure result is always wiped as a precaution */
@@ -337,19 +355,31 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	if (!(readbuf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
+	if (!(dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, _find_labeller, flp))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		_set_label_read_result(1, flp, NULL);
 		return 0;
 	}
 
-	_find_labeller(0, flp, readbuf);
 	return flp->ret;
 }
 
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
 {
-	return _label_read(dev, scan_sector, result);
+	return _label_read(dev, scan_sector, result, NULL, NULL);
+}
+
+int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_sector,
+		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
+{
+	struct label **result;	/* FIXME Eliminate this */
+
+	if (!(result = dm_zalloc(sizeof(*result)))) {
+		log_error("Couldn't allocate memory for internal result pointer.");
+		return 0;
+	}
+
+	return _label_read(dev, scan_sector, result, process_label_data_fn, process_label_data_context);
 }
 
 /* Caller may need to use label_get_handler to create label struct! */
diff --git a/lib/label/label.h b/lib/label/label.h
index 984acce..1f12294 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -96,6 +96,8 @@ struct labeller *label_get_handler(const char *name);
 int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
+int label_read_callback(struct dm_pool *mem, struct device *dev, uint64_t scan_sector,
+	lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);


