From: Milan Broz <mbroz@redhat.com>
Date: Mon, 11 May 2009 18:59:19 +0200
Subject: [PATCH v2] Use readahead of underlying device and not default (smaller) one.
In-Reply-To: <1241978772-6394-2-git-send-email-mbroz@redhat.com>
References: <1241978772-6394-2-git-send-email-mbroz@redhat.com>
Message-ID: <1242061159-22916-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we are stacking LV over device, which has for some reason
increased read_ahead (e.g. MD RAID), the read_ahead hint
for libdevmapper is wrong (it is zero).

If the calculated read_ahead hint is zero, patch uses read_ahead of underlying device
(if first segment is PV) when setting DM_READ_AHEAD_MINIMUM_FLAG.

Because we are using dev-cache, it also store this value to cache for future use
(if several LVs are over one PV, BLKRAGET is called only once for underlying device.)

This should fix all the reamining problems with readahead mismatch reported
for DM over MD configurations (and similar cases).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    5 +++++
 lib/activate/dev_manager.c |    2 ++
 lib/device/dev-cache.c     |    2 ++
 lib/device/dev-io.c        |   44 ++++++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h        |    2 ++
 lib/metadata/metadata.c    |   30 ++++++++++++++++++++++++++++++
 lib/metadata/metadata.h    |    5 +++++
 test/t-read-ahead.sh       |   18 +++++++++++-------
 9 files changed, 102 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4cea7d5..e47a365 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Inherit read ahead from underlying device.
   Fix first_seg() call for empty segment list.
   Add make install_lvm2 as complement to device-mapper install.
   Reject missing PVs from allocation in toollib.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7011a09..07aa67c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -469,6 +469,11 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
+	/*
+	 * Cache read ahead value for PV devices now (before possible suspend)
+	 */
+	(void)lv_calculate_readhead(lv);
+
 	if (name)
 		dm_pool_free(cmd->mem, name);
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 671f4c3..f3cd936 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1021,6 +1021,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
+		if (!read_ahead)
+			read_ahead = lv_calculate_readhead(lv);
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 	}
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d3c58fc..dd4ce6a 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -104,6 +104,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
+	dev->read_ahead = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
 
@@ -124,6 +125,7 @@ static struct device *_dev_create(dev_t d)
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
+	dev->read_ahead = -1;
 	dev->end = UINT64_C(0);
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index c163d93..06675e2 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -262,6 +262,37 @@ static int _dev_get_size_dev(const struct device *dev, uint64_t *size)
 	return 1;
 }
 
+static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
+{
+	long read_ahead_long;
+
+	if (dev->read_ahead != -1) {
+		*read_ahead = (uint32_t) dev->read_ahead;
+		return 1;
+	}
+
+	if (!dev_open(dev))
+		return_0;
+
+	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
+		log_sys_error("ioctl BLKRAGET", dev_name(dev));
+		if (!dev_close(dev))
+			stack;
+		return 0;
+	}
+
+	if (!dev_close(dev))
+		stack;
+
+	*read_ahead = (uint32_t) read_ahead_long;
+	dev->read_ahead = read_ahead_long;
+
+	log_very_verbose("%s: read_ahead is %u sectors",
+			 dev_name(dev), *read_ahead);
+
+	return 1;
+}
+
 /*-----------------------------------------------------------------
  * Public functions
  *---------------------------------------------------------------*/
@@ -277,6 +308,19 @@ int dev_get_size(const struct device *dev, uint64_t *size)
 		return _dev_get_size_dev(dev, size);
 }
 
+int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead)
+{
+	if (!dev)
+		return 0;
+
+	if (dev->flags & DEV_REGULAR) {
+		*read_ahead = 0;
+		return 1;
+	}
+
+	return _dev_read_ahead_dev(dev, read_ahead);
+}
+
 /* FIXME Unused
 int dev_get_sectsize(struct device *dev, uint32_t *size)
 {
diff --git a/lib/device/device.h b/lib/device/device.h
index abec650..94f17b4 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -40,6 +40,7 @@ struct device {
 	int fd;
 	int open_count;
 	int block_size;
+	int read_ahead;
 	uint32_t flags;
 	uint64_t end;
 	struct dm_list open_list;
@@ -64,6 +65,7 @@ struct device_area {
  */
 int dev_get_size(const struct device *dev, uint64_t *size);
 int dev_get_sectsize(struct device *dev, uint32_t *size);
+int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
 
 /* Use quiet version if device number could change e.g. when opening LV */
 int dev_open(struct device *dev);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index af4c69c..588ab3b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1386,6 +1386,7 @@ static int _lv_mark_if_partial(struct logical_volume *lv)
 	return _lv_postorder(lv, _lv_mark_if_partial_single, NULL);
 }
 
+
 /*
  * Mark LVs with missing PVs using PARTIAL_LV status flag. The flag is
  * propagated transitively, so LVs referencing other LVs are marked
@@ -1404,6 +1405,35 @@ static int _vg_mark_partial_lvs(struct volume_group *vg)
 	return 1;
 }
 
+/*
+ * Be sure that all PV devices have cached read ahead in dev-cache
+ * Currently it takes read_ahead from first PV segment only
+ */
+static int _lv_read_ahead_single(struct logical_volume *lv, void *data)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t seg_read_ahead = 0, *read_ahead = data;
+
+	if (seg && seg_type(seg, 0) == AREA_PV)
+		dev_get_read_ahead(seg_pv(seg, 0)->dev, &seg_read_ahead);
+
+	if (seg_read_ahead > *read_ahead)
+		*read_ahead = seg_read_ahead;
+
+	return 1;
+}
+
+uint32_t lv_calculate_readhead(const struct logical_volume *lv)
+{
+	uint32_t read_ahead = 0;
+
+	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
+		_lv_postorder((struct logical_volume *)lv, _lv_read_ahead_single, &read_ahead);
+
+	log_debug("Calculated readahead of LV %s is %u", lv->name, read_ahead);
+	return read_ahead;
+}
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index eff2380..a91bd5b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -345,6 +345,11 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 unsigned displayable_lvs_in_vg(const struct volume_group *vg);
 
 /*
+ * Calculate readahead from underlying PV devices
+ */
+uint32_t lv_calculate_readhead(const struct logical_volume *lv);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
diff --git a/test/t-read-ahead.sh b/test/t-read-ahead.sh
index 53903b4..00f9eb8 100755
--- a/test/t-read-ahead.sh
+++ b/test/t-read-ahead.sh
@@ -32,14 +32,18 @@ check_lvs_() {
 aux prepare_vg 5
 
 #COMM "test various read ahead settings (bz450922)"
-lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     
+lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"
 ra="$(get_lvs_ lv_kernel_read_ahead)"
 test "$(( ( $ra / 5 ) * 5 ))" -eq $ra
-lvdisplay "$vg"/"$lv"                             
-lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto     
-check_lvs_ lv_read_ahead auto                                  
-check_lvs_ lv_kernel_read_ahead 5120                           
-lvchange -r 400 "$vg/$lv"                         
-check_lvs_ lv_read_ahead 400                                   
+lvdisplay "$vg"/"$lv"
+lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
+check_lvs_ lv_read_ahead auto
+check_lvs_ lv_kernel_read_ahead 5120
+lvchange -r 400 "$vg/$lv"
+check_lvs_ lv_read_ahead 400
 lvremove -ff "$vg"
 
+#COMM "read ahead is properly inherited from underlying PV"
+blockdev --setra 768 $dev1
+lvcreate -n $lv -L4M $vg $dev1
+test $(blockdev --getra $G_dev_/$vg/$lv) -eq 768
-- 
1.6.2.4


