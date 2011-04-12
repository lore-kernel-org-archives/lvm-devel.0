From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 12 Apr 2011 21:59:05 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
Message-ID: <20110412215905.28447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-04-12 21:59:02

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/device     : dev-io.c device.c device.h 
	lib/metadata   : pv_manip.c 
	man            : lvm.conf.5.in 

Log message:
	Add "devices/issue_discards" to lvm.conf.
	Issue discards on lvremove if enabled and both storage and kernel have support.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1970&r2=1.1971
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2011/04/09 19:05:23	1.1970
+++ LVM2/WHATS_NEW	2011/04/12 21:59:01	1.1971
@@ -1,5 +1,7 @@
 Version 2.02.85 - 
 ===================================
+  Add "devices/issue_discards" to lvm.conf.
+  Issue discards on lvremove if enabled and both storage and kernel have support.
   Fix incorrect tests for dm_snprintf() failure.
   Fix some unmatching sign comparation gcc warnings in the code.
   Allow lv_extend() to work on zero length intrinsically layered LVs.
--- LVM2/doc/example.conf.in	2011/04/12 20:44:41	1.20
+++ LVM2/doc/example.conf.in	2011/04/12 21:59:01	1.21
@@ -151,6 +151,14 @@
     # Example: Ignore devices smaller than 2MB (i.e. floppy drives).
     # pv_min_size = 2048
     pv_min_size = 512
+
+    # Issue discards to an LV's underlying PV(s) when the LV is removed.
+    # Discards inform the storage that a region is no longer in use.  If set
+    # to 1, discards will only be issued if both the storage and kernel provide
+    # support.  Not all storage will support or benefit from discards but SSDs
+    # or thinly provisioned LUNs generally do.
+    # 1 enables; 0 disables.
+    issue_discards = 0
 }
 
 # This section allows you to configure the way in which LVM selects
--- LVM2/lib/config/defaults.h	2011/02/27 00:38:32	1.72
+++ LVM2/lib/config/defaults.h	2011/04/12 21:59:01	1.73
@@ -37,6 +37,7 @@
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
+#define DEFAULT_ISSUE_DISCARDS 0
 
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
--- LVM2/lib/device/dev-io.c	2011/03/29 20:19:03	1.75
+++ LVM2/lib/device/dev-io.c	2011/04/12 21:59:01	1.76
@@ -36,6 +36,9 @@
 #  ifndef BLKGETSIZE64		/* fs.h out-of-date */
 #    define BLKGETSIZE64 _IOR(0x12, 114, size_t)
 #  endif /* BLKGETSIZE64 */
+#  ifndef BLKDISCARD
+#    define BLKDISCARD	_IO(0x12,119)
+#  endif
 #else
 #  include <sys/disk.h>
 #  define BLKBSZGET DKIOCGETBLOCKSIZE
@@ -301,6 +304,33 @@
 	return 1;
 }
 
+static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes)
+{
+	uint64_t discard_range[2];
+
+	if (!dev_open(dev))
+		return_0;
+
+	discard_range[0] = offset_bytes;
+	discard_range[1] = size_bytes;
+
+	log_debug("Discarding %" PRIu64 " bytes offset %" PRIu64 " bytes on %s.",
+		  size_bytes, offset_bytes, dev_name(dev));
+	if (ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
+		log_error("%s: BLKDISCARD ioctl@offset %" PRIu64 " size %" PRIu64 " failed: %s.",
+			  dev_name(dev), offset_bytes, size_bytes, strerror(errno));
+		if (!dev_close(dev))
+			stack;
+		/* It doesn't matter if discard failed, so return success. */
+		return 1;
+	}
+
+	if (!dev_close(dev))
+		stack;
+
+	return 1;
+}
+
 /*-----------------------------------------------------------------
  * Public functions
  *---------------------------------------------------------------*/
@@ -329,6 +359,17 @@
 	return _dev_read_ahead_dev(dev, read_ahead);
 }
 
+int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes)
+{
+	if (!dev)
+		return 0;
+
+	if (dev->flags & DEV_REGULAR)
+		return 1;
+
+	return _dev_discard_blocks(dev, offset_bytes, size_bytes);
+}
+
 /* FIXME Unused
 int dev_get_sectsize(struct device *dev, uint32_t *size)
 {
--- LVM2/lib/device/device.c	2011/03/13 22:52:20	1.37
+++ LVM2/lib/device/device.c	2011/04/12 21:59:01	1.38
@@ -455,6 +455,20 @@
 				       sysfs_dir, dev);
 }
 
+unsigned long dev_discard_max_bytes(const char *sysfs_dir,
+				    struct device *dev)
+{
+	return _dev_topology_attribute("queue/discard_max_bytes",
+				       sysfs_dir, dev);
+}
+
+unsigned long dev_discard_granularity(const char *sysfs_dir,
+				      struct device *dev)
+{
+	return _dev_topology_attribute("queue/discard_granularity",
+				       sysfs_dir, dev);
+}
+
 #else
 
 int get_primary_dev(const char *sysfs_dir,
@@ -481,4 +495,16 @@
 	return 0UL;
 }
 
+unsigned long dev_discard_max_bytes(const char *sysfs_dir,
+				    struct device *dev)
+{
+	return 0UL;
+}
+
+unsigned long dev_discard_granularity(const char *sysfs_dir,
+				      struct device *dev)
+{
+	return 0UL;
+}
+
 #endif
--- LVM2/lib/device/device.h	2011/02/18 23:09:55	1.47
+++ LVM2/lib/device/device.h	2011/04/12 21:59:01	1.48
@@ -68,6 +68,7 @@
 int dev_get_size(const struct device *dev, uint64_t *size);
 int dev_get_sectsize(struct device *dev, uint32_t *size);
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
+int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes);
 
 /* Use quiet version if device number could change e.g. when opening LV */
 int dev_open(struct device *dev);
@@ -115,4 +116,10 @@
 unsigned long dev_optimal_io_size(const char *sysfs_dir,
 				  struct device *dev);
 
+unsigned long dev_discard_max_bytes(const char *sysfs_dir,
+				    struct device *dev);
+
+unsigned long dev_discard_granularity(const char *sysfs_dir,
+				      struct device *dev);
+
 #endif
--- LVM2/lib/metadata/pv_manip.c	2011/03/29 20:19:04	1.28
+++ LVM2/lib/metadata/pv_manip.c	2011/04/12 21:59:01	1.29
@@ -20,6 +20,7 @@
 #include "archiver.h"
 #include "locking.h"
 #include "lvmcache.h"
+#include "defaults.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -190,12 +191,38 @@
 
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 {
+	uint64_t discard_offset;
+	uint64_t pe_start = peg->pv->pe_start;
+	uint64_t discard_area_reduction = area_reduction;
+
 	if (!peg->lvseg) {
 		log_error("release_pv_segment with unallocated segment: "
 			  "%s PE %" PRIu32, pv_dev_name(peg->pv), peg->pe);
 		return 0;
 	}
 
+	/*
+	 * Only issue discards if enabled in lvm.conf and both
+	 * the device and kernel (>= 2.6.35) supports discards.
+	 */
+	if (find_config_tree_bool(peg->pv->fmt->cmd,
+				  "devices/issue_discards", DEFAULT_ISSUE_DISCARDS) &&
+	    dev_discard_max_bytes(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev) &&
+	    dev_discard_granularity(peg->pv->fmt->cmd->sysfs_dir, peg->pv->dev)) {
+		if (!pe_start) {
+			/* skip the first extent */
+			pe_start = peg->pv->vg->extent_size;
+			discard_area_reduction--;
+		}
+		discard_offset = peg->pe + peg->lvseg->area_len - area_reduction;
+		discard_offset = (discard_offset * peg->pv->vg->extent_size) + pe_start;
+		log_debug("Discarding %" PRIu32 " extents offset %" PRIu64 " sectors on %s.",
+			 discard_area_reduction, discard_offset, dev_name(peg->pv->dev));
+		if (!dev_discard_blocks(peg->pv->dev, discard_offset << SECTOR_SHIFT,
+					discard_area_reduction * peg->pv->vg->extent_size * SECTOR_SIZE))
+			return_0;
+	}
+
 	if (peg->lvseg->area_len == area_reduction) {
 		peg->pv->pe_alloc_count -= area_reduction;
 		peg->lvseg->lv->vg->free_count += area_reduction;
--- LVM2/man/lvm.conf.5.in	2011/04/12 21:21:08	1.18
+++ LVM2/man/lvm.conf.5.in	2011/04/12 21:59:02	1.19
@@ -180,6 +180,13 @@
 .IP
 pv_min_size = 2048
 .IP
+\fBissue_discards\fP \(em
+Issue discards to an LV's underlying PV(s) when the LV is removed.  Discards
+inform the storage that a region is no longer in use.  If set to 1, discards will
+only be issued if both the storage and kernel provide support.  Not all storage
+will support or benefit from discards but SSDs or thinly provisioned LUNs
+generally do.
+.IP
 .TP
 \fBallocation\fP \(em Space allocation policies
 .IP


