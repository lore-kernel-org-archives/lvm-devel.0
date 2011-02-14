From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Feb 2011 20:11:56 +0100
Subject: [PATCH] Activate LVs read-only if underlying devices are read-only
Message-ID: <1297710716-31326-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Because of kernel changes, kernel now refuses to open device
read-write if it is internally marked read-only.

So we have to send read-only flag to kernel.

Try to check all underlying device if there are read-only
and override flag.

The same problems like scanning read-ahead here (cannot open device
while suspended so we have to cache read-only attribute).

(Patch includes mornfall's fix to postorder function.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c    |    3 ++
 lib/activate/dev_manager.c |   12 ++++++++-
 lib/device/dev-cache.c     |    2 +
 lib/device/dev-io.c        |   36 +++++++++++++++++++++++++
 lib/device/device.h        |    2 +
 lib/metadata/metadata.c    |   62 +++++++++++++++++++++++++++++++++++--------
 lib/metadata/metadata.h    |    5 +++
 7 files changed, 109 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9edb011..14b3a5e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1105,6 +1105,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	lv_calculate_readahead(lv, NULL);
+	lv_calculate_read_only(lv, NULL);
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
@@ -1279,6 +1280,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 		goto_out;
 
 	lv_calculate_readahead(lv, NULL);
+	lv_calculate_read_only(lv, NULL);
 
 	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
@@ -1376,6 +1378,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	lv_calculate_readahead(lv, NULL);
+	lv_calculate_read_only(lv, NULL);
 
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b485404..f78bd7d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -60,7 +60,17 @@ struct lv_layer {
 
 static int _read_only_lv(struct logical_volume *lv)
 {
-	return (!(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
+	int _read_only;
+
+	_read_only = (!(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
+
+	if (!_read_only) {
+		lv_calculate_read_only(lv, &_read_only);
+		if (_read_only && lv_is_visible(lv))
+			log_warn("WARNING: LV %s: activating read-only.", lv->name);
+	}
+
+	return _read_only;
 }
 
 /*
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8ba8515..10e9f5b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -108,6 +108,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 	dev->max_error_count = NO_DEV_ERROR_COUNT_LIMIT;
 	dev->block_size = -1;
 	dev->read_ahead = -1;
+	dev->read_only = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
 
@@ -130,6 +131,7 @@ static struct device *_dev_create(dev_t d)
 	dev->max_error_count = dev_disable_after_error_count();
 	dev->block_size = -1;
 	dev->read_ahead = -1;
+	dev->read_only = -1;
 	dev->end = UINT64_C(0);
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index eb80a89..495bd0a 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -301,6 +301,34 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 	return 1;
 }
 
+static int _dev_read_only_dev(struct device *dev, int *read_only)
+{
+	if (dev->read_only != -1) {
+		*read_only = dev->read_only;
+		return 1;
+	}
+
+	if (!dev_open(dev))
+		return_0;
+
+	if (ioctl(dev->fd, BLKROGET, read_only) < 0) {
+		log_sys_error("ioctl BLKROGET", dev_name(dev));
+		if (!dev_close(dev))
+			stack;
+		return 0;
+	}
+
+	if (!dev_close(dev))
+		stack;
+
+	dev->read_only = *read_only;
+
+	log_very_verbose("%s: read_only is %d",
+			 dev_name(dev), *read_only);
+
+	return 1;
+}
+
 /*-----------------------------------------------------------------
  * Public functions
  *---------------------------------------------------------------*/
@@ -329,6 +357,14 @@ int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead)
 	return _dev_read_ahead_dev(dev, read_ahead);
 }
 
+int dev_get_read_only(struct device *dev, int *read_only)
+{
+	if (!dev)
+		return 0;
+
+	return _dev_read_only_dev(dev, read_only);
+}
+
 /* FIXME Unused
 int dev_get_sectsize(struct device *dev, uint32_t *size)
 {
diff --git a/lib/device/device.h b/lib/device/device.h
index 694f503..bd7dbd7 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -43,6 +43,7 @@ struct device {
 	int max_error_count;
 	int block_size;
 	int read_ahead;
+	int read_only;
 	uint32_t flags;
 	uint64_t end;
 	struct dm_list open_list;
@@ -68,6 +69,7 @@ struct device_area {
 int dev_get_size(const struct device *dev, uint64_t *size);
 int dev_get_sectsize(struct device *dev, uint32_t *size);
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
+int dev_get_read_only(struct device *dev, int *read_only);
 
 /* Use quiet version if device number could change e.g. when opening LV */
 int dev_open(struct device *dev);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 771cdb0..37455d1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1969,18 +1969,6 @@ static int _lv_postorder_visit(struct logical_volume *,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data);
 
-static int _lv_postorder_level(struct logical_volume *lv, void *data)
-{
-	struct _lv_postorder_baton *baton = data;
-	if (lv->status & POSTORDER_OPEN_FLAG)
-		return 1; // a data structure loop has closed...
-	lv->status |= POSTORDER_OPEN_FLAG;
-	int r =_lv_postorder_visit(lv, baton->fn, baton->data);
-	lv->status &= ~POSTORDER_OPEN_FLAG;
-	lv->status |= POSTORDER_FLAG;
-	return r;
-};
-
 static int _lv_each_dependency(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data)
@@ -2022,6 +2010,12 @@ static int _lv_postorder_cleanup(struct logical_volume *lv, void *data)
 	return 1;
 }
 
+static int _lv_postorder_level(struct logical_volume *lv, void *data)
+{
+	struct _lv_postorder_baton *baton = data;
+	return _lv_postorder_visit(lv, baton->fn, baton->data);
+};
+
 static int _lv_postorder_visit(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data)
@@ -2031,13 +2025,20 @@ static int _lv_postorder_visit(struct logical_volume *lv,
 
 	if (lv->status & POSTORDER_FLAG)
 		return 1;
+	if (lv->status & POSTORDER_OPEN_FLAG)
+		return 1; // a data structure loop has closed
+	lv->status |= POSTORDER_OPEN_FLAG;
 
 	baton.fn = fn;
 	baton.data = data;
 	r = _lv_each_dependency(lv, _lv_postorder_level, &baton);
+
 	if (r)
 		r = fn(lv, data);
 
+	lv->status &= ~POSTORDER_OPEN_FLAG;
+	lv->status |= POSTORDER_FLAG;
+
 	return r;
 }
 
@@ -2154,6 +2155,43 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 	}
 }
 
+static int _lv_read_only_single(struct logical_volume *lv, void *data)
+{
+	struct lv_segment *lvseg;
+	int s, seg_read_only = 0, *read_only = data;
+
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; ++s) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				dev_get_read_only(seg_pv(lvseg, 0)->dev, &seg_read_only);
+				if (seg_read_only)
+					goto out;
+			}
+		}
+	}
+out:
+	if (seg_read_only)
+		*read_only = 1;
+
+	return 1;
+}
+
+/*
+ * Calculate read-only for logical volume from underlying PV devices.
+ * If any of the underlying devices is read-only, set read-only to 1.
+ */
+void lv_calculate_read_only(const struct logical_volume *lv, int *read_only)
+{
+	int _read_only = 0;
+
+	_lv_postorder((struct logical_volume *)lv, _lv_read_only_single, &_read_only);
+
+	if (read_only) {
+		log_debug("Calculated read-only of LV %s is %d", lv->name, _read_only);
+		*read_only = _read_only;
+	}
+}
+
 /*
  * Check that an LV and all its PV references are correctly listed in vg->lvs
  * and vg->pvs, respectively. This only looks at a single LV, but *not* at the
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c0f9148..f758921 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -384,6 +384,11 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahead);
 
 /*
+ * Calculate read-only from underlying PV devices
+ */
+void lv_calculate_read_only(const struct logical_volume *lv, int *read_only);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
-- 
1.7.2.3


