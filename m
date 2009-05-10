From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:06:09 +0200
Subject: [PATCH] Use readahead of underlying device and not default (smaller) one.
In-Reply-To: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
References: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
Message-ID: <1241978772-6394-2-git-send-email-mbroz@redhat.com>
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
 lib/activate/dev_manager.c |    3 ++
 lib/device/dev-cache.c     |    2 +
 lib/device/dev-io.c        |   53 ++++++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h        |    2 +
 test/t-read-ahead.sh       |   18 +++++++++-----
 6 files changed, 72 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e9e7446..25ab1ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Inherit read ahead from underlying device.
   Fix first_seg() call for empty segment list.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 671f4c3..aa69b30 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1021,6 +1021,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
+		seg = first_seg(lv);
+		if (!read_ahead && seg && seg_type(seg, 0) == AREA_PV)
+		    dev_get_read_ahead(seg_pv(seg, 0)->dev, &read_ahead);
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
index c163d93..0fb37cf 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -262,6 +262,46 @@ static int _dev_get_size_dev(const struct device *dev, uint64_t *size)
 	return 1;
 }
 
+static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
+{
+	int fd = dev_fd(dev);
+	int use_dev_fd = (fd != -1);
+	long read_ahead_long;
+	const char *name = dev_name(dev);
+
+	/*
+	 * If device is in cache and has fd, use that fd and cache read_ahead.
+	 * otherwise just run BLKRAGET ioctl.
+	 */
+	if (use_dev_fd && dev->read_ahead != -1) {
+		*read_ahead = (uint32_t) dev->read_ahead;
+		return 1;
+	}
+
+	if (!use_dev_fd && (fd = open(name, O_RDONLY)) < 0) {
+		log_sys_error("open", name);
+		return 0;
+	}
+
+	if (ioctl(fd, BLKRAGET, &read_ahead_long) < 0) {
+		log_sys_error("ioctl BLKRAGET", name);
+		if (!use_dev_fd && close(fd))
+			log_sys_error("close", name);
+		return 0;
+	}
+
+	if (!use_dev_fd && close(fd))
+		log_sys_error("close", name);
+
+	*read_ahead = (uint32_t) read_ahead_long;
+	if (use_dev_fd)
+		dev->read_ahead = read_ahead_long; 
+
+	log_very_verbose("%s: read_ahead is %u sectors", name, *read_ahead);
+
+	return 1;
+}
+
 /*-----------------------------------------------------------------
  * Public functions
  *---------------------------------------------------------------*/
@@ -277,6 +317,19 @@ int dev_get_size(const struct device *dev, uint64_t *size)
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


