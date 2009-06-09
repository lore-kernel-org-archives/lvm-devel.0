From: Mike Snitzer <snitzer@redhat.com>
Date: Tue,  9 Jun 2009 00:42:16 -0400
Subject: [PATCH 3/3] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
References: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
Message-ID: <1244522536-2132-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the pvcreate --dataalignmentoffset option is not specified the offset
of the start of a PV's aligned data area will be padded with the
associated 'alignment_offset' exposed in sysfs (unless
devices/data_alignment_offset_detection is disabled in lvm.conf).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                     |    1 +
 doc/example.conf              |    5 +++
 lib/config/defaults.h         |    1 +
 lib/device/device.c           |   60 +++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h           |    3 ++
 lib/format_text/format-text.c |    9 ++++++
 man/lvm.conf.5.in             |    8 +++++-
 7 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aff0f04..a2e3d7f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Add devices/data_alignment_offset_detection to lvm.conf.
   Implement pvcreate --dataalignmentoffset to pad offset of pe_start.
   Allow specifying commandline sizes in terms of bytes and sectors.
   Round up requested readahead to at least one page and print warning.
diff --git a/doc/example.conf b/doc/example.conf
index 73f17c2..864bf65 100644
--- a/doc/example.conf
+++ b/doc/example.conf
@@ -104,6 +104,11 @@ devices {
     # Set to 0 for the default alignment of 64KB or page size, if larger.
     data_alignment = 0
 
+    # By default, the offset of the start of a PV's aligned data area
+    # will be padded with the 'alignment_offset' exposed in sysfs.
+    # 1 enables; 0 disables.
+    data_alignment_offset_detection = 1
+
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 98c023a..4433ee4 100644
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
index 9d3c1cf..fa08568 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -278,3 +278,63 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 	return 0;
 }
 #endif
+
+#ifdef linux
+
+unsigned long dev_data_alignment_offset(const char *sysfs_dir,
+					struct device *dev)
+{
+	char path[PATH_MAX+1], buffer[64];
+	FILE *fp;
+	struct stat info;
+	unsigned long data_alignment_offset = 0UL;
+
+	if (!sysfs_dir || !*sysfs_dir)
+		return_0;
+
+	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/alignment_offset",
+			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
+		log_error("dm_snprintf alignment_offset failed");
+		return 0;
+	}
+
+	/* old sysfs structure not applicable (topology support is newer) */
+
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
+	if (sscanf(buffer, "%lu", &data_alignment_offset) != 1) {
+		log_error("sysfs file %s not in expected format: %s", path,
+			  buffer);
+		goto out;
+	}
+
+	log_very_verbose("Device %s data_alignment is %lu bytes.",
+			 dev_name(dev), data_alignment_offset);
+
+out:
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return data_alignment_offset >> SECTOR_SHIFT;
+}
+
+#else
+
+unsigned long dev_data_alignment_offset(const char *sysfs_dir,
+					struct device *dev)
+{
+	return 0UL;
+}
+
+#endif
diff --git a/lib/device/device.h b/lib/device/device.h
index 94f17b4..25ac0d5 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -100,4 +100,7 @@ unsigned long dev_md_chunk_size(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
+unsigned long dev_data_alignment_offset(const char *sysfs_dir,
+					struct device *dev);
+
 #endif
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a0fe852..f7b87ac 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -29,6 +29,7 @@
 #include "label.h"
 #include "memlock.h"
 #include "lvmcache.h"
+#include "defaults.h"
 
 #include <unistd.h>
 #include <sys/file.h>
@@ -1720,6 +1721,14 @@ static int _text_pv_setup(const struct format_type *fmt,
 				 "%lu sectors (requested %lu sectors)",
 				 pv_dev_name(pv), pv->pe_align, data_alignment);
 
+		if (!pe_start && !data_alignment_offset &&
+		    find_config_tree_bool(pv->fmt->cmd,
+					  "devices/data_alignment_offset_detection",
+					  DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION)) {
+			data_alignment_offset =
+				dev_data_alignment_offset(pv->fmt->cmd->sysfs_dir, pv->dev);
+		}
+
 		if (pv->pe_start < pv->pe_align)
 			pv->pe_start = pv->pe_align;
 
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 68024b6..40ce390 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -142,10 +142,16 @@ when creating a new Physical Volume using the \fBlvm2\fP format.
 If a Physical Volume is placed directly upon an md device and
 \fBmd_chunk_alignment\fP is enabled this parameter is ignored.
 Set to 0 to use the default alignment of 64KB or the page size, if larger.
+.IP
+\fBdata_alignment_offset_detection\fP \(em If set to 1, the offset to
+the start of a PV's aligned data area will be set to the
+alignment_offset exposed in sysfs.
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
1.6.2.2


