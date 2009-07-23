From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 22 Jul 2009 22:53:03 -0400
Subject: [PATCH 2/6] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <1248317587-11187-1-git-send-email-snitzer@redhat.com>
References: <1248317587-11187-1-git-send-email-snitzer@redhat.com>
Message-ID: <1248317587-11187-3-git-send-email-snitzer@redhat.com>
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
 WHATS_NEW                     |    1 +
 doc/example.conf              |    9 +++++
 lib/config/defaults.h         |    1 +
 lib/device/device.c           |   71 +++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h           |    3 ++
 lib/format_text/format-text.c |    8 +++-
 lib/metadata/metadata.c       |    8 +++++
 man/lvm.conf.5.in             |    9 +++++-
 8 files changed, 107 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 92fed6a..8b8a749 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add devices/data_alignment_offset_detection to lvm.conf.
   Add --dataalignmentoffset to pvcreate to pad aligned data area.
   Add liblvm2app Makefile installation targets.
   Add liblvm pkgconfig file.
diff --git a/doc/example.conf b/doc/example.conf
index 0682415..d52ab98 100644
--- a/doc/example.conf
+++ b/doc/example.conf
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
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index ee6d758..68a862e 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -34,6 +34,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
diff --git a/lib/device/device.c b/lib/device/device.c
index 3248dd6..ebd8141 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -282,3 +282,74 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
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
+			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev),
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
diff --git a/lib/device/device.h b/lib/device/device.h
index b016823..32aee41 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -100,4 +100,7 @@ unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
+unsigned long dev_alignment_offset(const char *sysfs_dir,
+				   struct device *dev);
+
 #endif
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 32af70b..1d2916c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1705,8 +1705,12 @@ static int _text_pv_setup(const struct format_type *fmt,
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
-		if (!pe_start)
-			set_pe_align_offset(pv, data_alignment_offset);
+		if (!pe_start &&
+		    (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset) &&
+		    data_alignment_offset)
+			log_warn("WARNING: %s: Overriding data alignment offset to "
+				 "%lu sectors (requested %lu sectors)",
+				 pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
 
 		if (pv->pe_start < pv->pe_align) {
 			pv->pe_start = pv->pe_align;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0dbb7bc..6ba8857 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -115,6 +115,14 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 	if (!pv->dev)
 		goto out;
 
+	if (find_config_tree_bool(pv->fmt->cmd,
+				  "devices/data_alignment_offset_detection",
+				  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION))
+		pv->pe_align_offset =
+			MAX(pv->pe_align_offset,
+			    dev_alignment_offset(pv->fmt->cmd->sysfs_dir,
+						 pv->dev));
+
 	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align_offset);
 
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 0e3a949..0e7ede4 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -142,10 +142,17 @@ when creating a new Physical Volume using the \fBlvm2\fP format.
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
-- 
1.6.2.5


