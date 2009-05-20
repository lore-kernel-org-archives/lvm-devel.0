From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 May 2009 11:09:51 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20090520110951.1224.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-20 11:09:50

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c 
	lib/device     : dev-cache.c dev-io.c device.h 
	lib/metadata   : metadata.c metadata.h 
	test           : t-read-ahead.sh 

Log message:
	Use readahead of underlying device and not default (smaller) one.
	
	When we are stacking LV over device, which has for some reason
	increased read_ahead (e.g. MD RAID), the read_ahead hint
	for libdevmapper is wrong (it is zero).
	
	If the calculated read_ahead hint is zero, patch uses read_ahead of underlying device
	(if first segment is PV) when setting DM_READ_AHEAD_MINIMUM_FLAG.
	
	Because we are using dev-cache, it also store this value to cache for future use
	(if several LVs are over one PV, BLKRAGET is called only once for underlying device.)
	
	This should fix all the reamining problems with readahead mismatch reported
	for DM over MD configurations (and similar cases).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1118&r2=1.1119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.194&r2=1.195
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2009/05/20 09:55:33	1.1118
+++ LVM2/WHATS_NEW	2009/05/20 11:09:49	1.1119
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Inherit read ahead from underlying device.
   Use lock query instead of activate_lv_excl.
   Enable online resizing of mirrors.
   Use suspend with flush when device size was changed during table preload.
--- LVM2/lib/activate/activate.c	2009/05/20 09:52:37	1.149
+++ LVM2/lib/activate/activate.c	2009/05/20 11:09:49	1.150
@@ -469,6 +469,11 @@
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
+	/*
+	 * Cache read ahead value for PV devices now (before possible suspend)
+	 */
+	(void)lv_calculate_readhead(lv);
+
 	if (name)
 		dm_pool_free(cmd->mem, name);
 
--- LVM2/lib/activate/dev_manager.c	2009/05/20 09:52:37	1.149
+++ LVM2/lib/activate/dev_manager.c	2009/05/20 11:09:49	1.150
@@ -1022,6 +1022,8 @@
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
+		if (!read_ahead)
+			read_ahead = lv_calculate_readhead(lv);
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 	}
 
--- LVM2/lib/device/dev-cache.c	2008/11/03 22:14:27	1.54
+++ LVM2/lib/device/dev-cache.c	2009/05/20 11:09:49	1.55
@@ -104,6 +104,7 @@
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
+	dev->read_ahead = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
 
@@ -124,6 +125,7 @@
 	dev->fd = -1;
 	dev->open_count = 0;
 	dev->block_size = -1;
+	dev->read_ahead = -1;
 	dev->end = UINT64_C(0);
 	memset(dev->pvid, 0, sizeof(dev->pvid));
 	dm_list_init(&dev->open_list);
--- LVM2/lib/device/dev-io.c	2009/01/10 02:43:51	1.64
+++ LVM2/lib/device/dev-io.c	2009/05/20 11:09:49	1.65
@@ -262,6 +262,37 @@
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
@@ -277,6 +308,19 @@
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
--- LVM2/lib/device/device.h	2009/03/17 13:59:56	1.38
+++ LVM2/lib/device/device.h	2009/05/20 11:09:49	1.39
@@ -40,6 +40,7 @@
 	int fd;
 	int open_count;
 	int block_size;
+	int read_ahead;
 	uint32_t flags;
 	uint64_t end;
 	struct dm_list open_list;
@@ -64,6 +65,7 @@
  */
 int dev_get_size(const struct device *dev, uint64_t *size);
 int dev_get_sectsize(struct device *dev, uint32_t *size);
+int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
 
 /* Use quiet version if device number could change e.g. when opening LV */
 int dev_open(struct device *dev);
--- LVM2/lib/metadata/metadata.c	2009/05/13 21:29:10	1.219
+++ LVM2/lib/metadata/metadata.c	2009/05/20 11:09:49	1.220
@@ -1414,6 +1414,35 @@
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
--- LVM2/lib/metadata/metadata.h	2009/05/13 21:27:43	1.194
+++ LVM2/lib/metadata/metadata.h	2009/05/20 11:09:49	1.195
@@ -345,6 +345,11 @@
 unsigned snapshot_count(const struct volume_group *vg);
 
 /*
+ * Calculate readahead from underlying PV devices
+ */
+uint32_t lv_calculate_readhead(const struct logical_volume *lv);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
--- LVM2/test/t-read-ahead.sh	2009/05/11 16:17:12	1.5
+++ LVM2/test/t-read-ahead.sh	2009/05/20 11:09:50	1.6
@@ -32,17 +32,21 @@
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
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
 lvcreate -n $lv -l 50%FREE $vg
 lvchange -an $vg/$lv


