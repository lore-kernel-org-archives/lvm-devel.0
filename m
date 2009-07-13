From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:19 -0400
Subject: [PATCH 3/6] Add devices/data_alignment_detection to lvm.conf.
In-Reply-To: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
Message-ID: <1247515882-13736-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adds 'data_alignment_detection' config option to the devices section of
lvm.conf.  If your kernel provides topology information in sysfs (linux
>= 2.6.31) for the Physical Volume, the start of data area will be
aligned on a multiple of the ???minimum_io_size??? or ???optimal_io_size???
exposed in sysfs.

minimum_io_size is used if optimal_io_size is undefined (0).  If both
md_chunk_alignment and data_alignment_detection are enabled the result
of data_alignment_detection is used.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW               |    1 
 doc/example.conf        |   12 ++++++-
 lib/config/defaults.h   |    1 
 lib/device/device.c     |   75 ++++++++++++++++++++++++++++++++++++++++++++----
 lib/device/device.h     |    6 +++
 lib/metadata/metadata.c |   19 ++++++++++++
 man/lvm.conf.5.in       |   13 +++++++-
 7 files changed, 118 insertions(+), 9 deletions(-)

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW
+++ LVM2/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Add devices/data_alignment_detection to lvm.conf.
   Add devices/data_alignment_offset_detection to lvm.conf.
   Add --dataalignmentoffset to pvcreate to pad aligned data area.
   Fix dev name mismatch in vgcreate man page example.
Index: LVM2/doc/example.conf
===================================================================
--- LVM2.orig/doc/example.conf
+++ LVM2/doc/example.conf
@@ -98,9 +98,17 @@ devices {
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
+    # By default, the start of a PV's data area will be aligned with
+    # the 'minimum_io_size' or 'optimal_io_size' exposed in sysfs.
+    # minimum_io_size is used if optimal_io_size is undefined (0).
+    # If md_chunk_alignment is enabled, that detects the optimal_io_size.
+    # This setting takes precedence over md_chunk_alignment.
+    # 1 enables; 0 disables.
+    data_alignment_detection = 1
+
     # Alignment (in KB) of start of data area when creating a new PV.
-    # If a PV is placed directly upon an md device and md_chunk_alignment is
-    # enabled this parameter is ignored.
+    # If a PV is placed directly upon an md device and md_chunk_alignment or
+    # data_alignment_detection is enabled this parameter is ignored.
     # Set to 0 for the default alignment of 64KB or page size, if larger.
     data_alignment = 0
 
Index: LVM2/lib/config/defaults.h
===================================================================
--- LVM2.orig/lib/config/defaults.h
+++ LVM2/lib/config/defaults.h
@@ -35,6 +35,7 @@
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
+#define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
Index: LVM2/lib/device/device.c
===================================================================
--- LVM2.orig/lib/device/device.c
+++ LVM2/lib/device/device.c
@@ -285,13 +285,36 @@ int _get_partition_type(struct dev_mgr *
 
 #ifdef linux
 
+static int _primary_dev(const char *sysfs_dir,
+			struct device *dev, dev_t *result)
+{
+	char path[PATH_MAX+1];
+	struct stat info;
+
+	/* check if dev is a partition */
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
+			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
+		log_error("dm_snprintf partition failed");
+		return 0;
+	}
+
+	if (stat(path, &info) < 0)
+		return 0;
+
+	*result = dev->dev -
+		(MINOR(dev->dev) % max_partitions(MAJOR(dev->dev)));
+	return 1;
+}
+
 static unsigned long _dev_topology_attribute(const char *attribute,
 					     const char *sysfs_dir,
 					     struct device *dev)
 {
+	const char *sysfs_fmt_str = "%s/dev/block/%d:%d/%s";
 	char path[PATH_MAX+1], buffer[64];
 	FILE *fp;
 	struct stat info;
+	dev_t uninitialized_var(primary);
 	unsigned long result = 0UL;
 
 	if (!attribute || !*attribute)
@@ -300,16 +323,32 @@ static unsigned long _dev_topology_attri
 	if (!sysfs_dir || !*sysfs_dir)
 		return_0;
 
-	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/%s",
-			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev),
+	if (dm_snprintf(path, PATH_MAX, sysfs_fmt_str, sysfs_dir,
+			MAJOR(dev->dev), MINOR(dev->dev),
 			attribute) < 0) {
 		log_error("dm_snprintf %s failed", attribute);
 		return 0;
 	}
 
-	/* check if the desired sysfs attribute exists */
-	if (stat(path, &info) < 0)
-		return 0;
+	/*
+	 * check if the desired sysfs attribute exists
+	 * - if not: either the kernel doesn't have topology support
+	 *   or the device could be a partition
+	 */
+	if (stat(path, &info) < 0) {
+		if (!_primary_dev(sysfs_dir, dev, &primary))
+			return 0;
+
+		/* get attribute from partition's primary device */
+		if (dm_snprintf(path, PATH_MAX, sysfs_fmt_str, sysfs_dir,
+				MAJOR(primary), MINOR(primary),
+				attribute) < 0) {
+			log_error("pri dm_snprintf %s failed", attribute);
+			return 0;
+		}
+		if (stat(path, &info) < 0)
+			return 0;
+	}
 
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_error("fopen", path);
@@ -344,6 +383,20 @@ unsigned long dev_alignment_offset(const
 				       sysfs_dir, dev);
 }
 
+unsigned long dev_minimum_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return _dev_topology_attribute("queue/minimum_io_size",
+				       sysfs_dir, dev);
+}
+
+unsigned long dev_optimal_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return _dev_topology_attribute("queue/optimal_io_size",
+				       sysfs_dir, dev);
+}
+
 #else
 
 unsigned long dev_alignment_offset(const char *sysfs_dir,
@@ -352,4 +405,16 @@ unsigned long dev_alignment_offset(const
 	return 0UL;
 }
 
+unsigned long dev_minimum_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return 0UL;
+}
+
+unsigned long dev_optimal_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return 0UL;
+}
+
 #endif
Index: LVM2/lib/device/device.h
===================================================================
--- LVM2.orig/lib/device/device.h
+++ LVM2/lib/device/device.h
@@ -103,4 +103,10 @@ int is_partitioned_dev(struct device *de
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
 
+unsigned long dev_minimum_io_size(const char *sysfs_dir,
+				  struct device *dev);
+
+unsigned long dev_optimal_io_size(const char *sysfs_dir,
+				  struct device *dev);
+
 #endif
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c
+++ LVM2/lib/metadata/metadata.c
@@ -94,6 +94,25 @@ unsigned long set_pe_align(struct physic
 				   dev_md_stripe_width(pv->fmt->cmd->sysfs_dir,
 						       pv->dev));
 
+	/*
+	 * Align to topology's minimum_io_size or optimal_io_size if present
+	 * - minimum_io_size - the smallest request the device can perform
+	 *   w/o incurring a read-modify-write penalty (e.g. MD's chunk size)
+	 * - optimal_io_size - the device's preferred unit of receiving I/O
+	 *   (e.g. MD's stripe width)
+	 */
+	if (find_config_tree_bool(pv->fmt->cmd,
+				  "devices/data_alignment_detection",
+				  DEFAULT_DATA_ALIGNMENT_DETECTION)) {
+		pv->pe_align = MAX(pv->pe_align,
+				   dev_minimum_io_size(pv->fmt->cmd->sysfs_dir,
+						       pv->dev));
+
+		pv->pe_align = MAX(pv->pe_align,
+				   dev_optimal_io_size(pv->fmt->cmd->sysfs_dir,
+						       pv->dev));
+	}
+
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align);
 
Index: LVM2/man/lvm.conf.5.in
===================================================================
--- LVM2.orig/man/lvm.conf.5.in
+++ LVM2/man/lvm.conf.5.in
@@ -137,11 +137,20 @@ has been reused without wiping the md su
 directly upon an md device, LVM2 will align its data blocks with the
 md device's stripe-width.
 .IP
+\fBdata_alignment_detection\fP \(em If set to 1, and your kernel provides
+topology information in sysfs for the Physical Volume, the start of data
+area will be aligned on a multiple of the ???minimum_io_size??? or
+???optimal_io_size??? exposed in sysfs.  minimum_io_size is used if
+optimal_io_size is undefined (0).  If both \fBmd_chunk_alignment\fP and
+\fBdata_alignment_detection\fP are enabled the result of
+\fBdata_alignment_detection\fP is used.
+.IP
 \fBdata_alignment\fP \(em Default alignment (in KB) of start of data area
 when creating a new Physical Volume using the \fBlvm2\fP format.
 If a Physical Volume is placed directly upon an md device and
-\fBmd_chunk_alignment\fP is enabled this parameter is ignored.
-Set to 0 to use the default alignment of 64KB or the page size, if larger.
+\fBmd_chunk_alignment\fP or \fBdata_alignment_detection\fP is enabled
+this parameter is ignored.  Set to 0 to use the default alignment of
+64KB or the page size, if larger.
 .IP
 \fBdata_alignment_offset_detection\fP \(em If set to 1, and your kernel
 provides topology information in sysfs for the Physical Volume, the


