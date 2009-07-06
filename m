From: Mike Snitzer <snitzer@redhat.com>
Date: Sun,  5 Jul 2009 22:39:49 -0400
Subject: [PATCH v4 4/5] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <1246847990-13370-1-git-send-email-snitzer@redhat.com>
References: <1246847990-13370-1-git-send-email-snitzer@redhat.com>
Message-ID: <1246847990-13370-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the pvcreate --dataalignmentoffset option is not specified the start
of a PV's aligned data area will be padded with the associated
'alignment_offset' exposed in sysfs (unless
devices/data_alignment_offset_detection is disabled in lvm.conf).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW               |    1 
 doc/example.conf        |    9 ++++++
 lib/config/defaults.h   |    1 
 lib/device/device.c     |   71 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h     |    3 ++
 lib/metadata/metadata.c |    8 +++++
 man/lvm.conf.5.in       |    9 +++++-
 7 files changed, 101 insertions(+), 1 deletion(-)

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW
+++ LVM2/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Add devices/data_alignment_offset_detection to lvm.conf.
   Add --dataalignmentoffset to pvcreate to pad aligned data area.
   Update the man pages to document size units uniformly.
   Allow specifying commandline sizes in terms of bytes and sectors.
Index: LVM2/doc/example.conf
===================================================================
--- LVM2.orig/doc/example.conf
+++ LVM2/doc/example.conf
@@ -104,6 +104,15 @@ devices {
     # Set to 0 for the default alignment of 64KB or page size, if larger.
     data_alignment = 0
 
+    # By default, the start of a PV's aligned data area will be padded with
+    # the 'alignment_offset' exposed in sysfs.  This offset is often 0 but
+    # may be non-zero; e.g.: certain 4KB sector drives that compensate for
+    # windows partitioning will have an alignment_offset of 3584 bytes
+    # (sector 7 is the lowest aligned logical block, the 4KB sectors start
+    # at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
+    # 1 enables; 0 disables.
+    data_alignment_offset_detection = 1
+
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
Index: LVM2/lib/config/defaults.h
===================================================================
--- LVM2.orig/lib/config/defaults.h
+++ LVM2/lib/config/defaults.h
@@ -34,6 +34,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
Index: LVM2/lib/device/device.c
===================================================================
--- LVM2.orig/lib/device/device.c
+++ LVM2/lib/device/device.c
@@ -278,3 +278,74 @@ int _get_partition_type(struct dev_mgr *
 	return 0;
 }
 #endif
+
+#ifdef linux
+
+static unsigned long _dev_topology_attribute(const char *attribute,
+					     const char *sysfs_dir,
+					     struct device *dev)
+{
+	char path[PATH_MAX+1], buffer[64];
+	FILE *fp;
+	struct stat info;
+	unsigned long result = 0UL;
+
+	if (!attribute || !*attribute)
+		return_0;
+
+	if (!sysfs_dir || !*sysfs_dir)
+		return_0;
+
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/%s",
+			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev),
+			attribute) < 0) {
+		log_error("dm_snprintf %s failed", attribute);
+		return 0;
+	}
+
+	/* check if the desired sysfs attribute exists */
+	if (stat(path, &info) < 0)
+		return 0;
+
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_sys_error("fgets", path);
+		goto out;
+	}
+
+	if (sscanf(buffer, "%lu", &result) != 1) {
+		log_error("sysfs file %s not in expected format: %s", path,
+			  buffer);
+		goto out;
+	}
+
+	log_very_verbose("Device %s %s is %lu bytes.",
+			 dev_name(dev), attribute, result);
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return result >> SECTOR_SHIFT;
+}
+
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev)
+{
+	return _dev_topology_attribute("alignment_offset",
+				       sysfs_dir, dev);
+}
+
+#else
+
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev)
+{
+	return 0UL;
+}
+
+#endif
Index: LVM2/lib/device/device.h
===================================================================
--- LVM2.orig/lib/device/device.h
+++ LVM2/lib/device/device.h
@@ -100,4 +100,7 @@ unsigned long dev_md_stripe_width(const 
 
 int is_partitioned_dev(struct device *dev);
 
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev);
+
 #endif
Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c
+++ LVM2/lib/metadata/metadata.c
@@ -910,6 +910,14 @@ static struct physical_volume *_pv_creat
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
+	if (!pe_start && !data_alignment_offset &&
+	    find_config_tree_bool(pv->fmt->cmd,
+				  "devices/data_alignment_offset_detection",
+				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION)) {
+		data_alignment_offset =
+			dev_alignment_offset(pv->fmt->cmd->sysfs_dir, pv->dev);
+	}
+
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size, data_alignment,
 				data_alignment_offset,
Index: LVM2/man/lvm.conf.5.in
===================================================================
--- LVM2.orig/man/lvm.conf.5.in
+++ LVM2/man/lvm.conf.5.in
@@ -142,10 +142,17 @@ when creating a new Physical Volume usin
 If a Physical Volume is placed directly upon an md device and
 \fBmd_chunk_alignment\fP is enabled this parameter is ignored.
 Set to 0 to use the default alignment of 64KB or the page size, if larger.
+.IP
+\fBdata_alignment_offset_detection\fP \(em If set to 1, and your kernel
+provides topology information in sysfs for the Physical Volume, the
+start of the aligned data area of the Physical Volume will be padded
+with the alignment_offset exposed in sysfs.
 .sp
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
-\fBdata_alignment\fP.
+\fBdata_alignment\fP plus the alignment_offset from
+\fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
+commandline.
 .TP
 \fBlog\fP \(em Default log settings
 .IP


