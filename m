From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Jun 2009 18:55:08 -0400
Subject: [PATCH 4/4] Add devices/data_alignment_detection to lvm.conf.
In-Reply-To: <1245452108-25318-1-git-send-email-snitzer@redhat.com>
References: <1245452108-25318-1-git-send-email-snitzer@redhat.com>
Message-ID: <1245452108-25318-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adds 'data_alignment_detection' config option to the devices section of
lvm.conf.  If your kernel provides topology information in sysfs for the
Physical Volume, the start of data area will be aligned on a multiple of
the ?minimum_io_size? or ?optimal_io_size? exposed in sysfs.

minimum_io_size is used if optimal_io_size is undefined (0).  If both
md_chunk_alignment and data_alignment_detection are enabled the result
of data_alignment_detection is used.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW               |    1 +
 doc/example.conf        |   14 +++++++++++---
 lib/config/defaults.h   |    1 +
 lib/device/device.c     |   26 ++++++++++++++++++++++++++
 lib/device/device.h     |    6 ++++++
 lib/metadata/metadata.c |   18 ++++++++++++++++++
 man/lvm.conf.5.in       |   13 +++++++++++--
 7 files changed, 74 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d78cd3d..8701733 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Add devices/data_alignment_detection to lvm.conf.
   Add devices/data_alignment_offset_detection to lvm.conf.
   Implement pvcreate --dataalignmentoffset to pad offset of pe_start.
   Update the man pages to uniformly document size units.
diff --git a/doc/example.conf b/doc/example.conf
index 864bf65..fbdcc1c 100644
--- a/doc/example.conf
+++ b/doc/example.conf
@@ -94,13 +94,21 @@ devices {
     md_component_detection = 1
 
     # By default, if a PV is placed directly upon an md device, LVM2
-    # will align its data blocks with the the chunk_size exposed in sysfs.
+    # will align its data blocks with the chunk_size exposed in sysfs.
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
+    # By default, the start of a PV's data area will be aligned with
+    # the 'minimum_io_size' or 'optimal_io_size' exposed in sysfs.
+    # minimum_io_size is used if optimal_io_size is undefined (0).
+    # This offers a superset of what md_chunk_alignment detects
+    # (aka minimum_io_size) and is therefore preferred over it.
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
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 4433ee4..f809dfe 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -35,6 +35,7 @@
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
+#define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
diff --git a/lib/device/device.c b/lib/device/device.c
index 537dcec..c5922f6 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -341,6 +341,20 @@ unsigned long dev_alignment_offset(const char *sysfs_dir,
 					sysfs_dir, dev);
 }
 
+unsigned long dev_minimum_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return __dev_topology_attribute("minimum_io_size",
+					sysfs_dir, dev);
+}
+
+unsigned long dev_optimal_io_size(const char *sysfs_dir,
+				  struct device *dev)
+{
+	return __dev_topology_attribute("optimal_io_size",
+					sysfs_dir, dev);
+}
+
 #else
 
 unsigned long dev_alignment_offset(const char *sysfs_dir,
@@ -349,4 +363,16 @@ unsigned long dev_alignment_offset(const char *sysfs_dir,
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
diff --git a/lib/device/device.h b/lib/device/device.h
index 722cc4a..3bb97dd 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -103,4 +103,10 @@ int is_partitioned_dev(struct device *dev);
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
 
+unsigned long dev_minimum_io_size(const char *sysfs_dir,
+				  struct device *dev);
+
+unsigned long dev_optimal_io_size(const char *sysfs_dir,
+				  struct device *dev);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 68bf8b1..3759fce 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -90,6 +90,24 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
 						     pv->dev));
 
+	/*
+	 * Align to topology's minimum_io_size or optimal_io_size if present
+	 * - minimum_io_size offers the smallest request the device can perform
+	 *   without incurring a read-modify-write penalty (e.g. MD's chunk size)
+	 * - optimal_io_size offers the device's preferred unit of receiving I/O
+	 *   (e.g. MD's stripe width)
+	 */
+	if (find_config_tree_bool(pv->fmt->cmd, "devices/data_alignment_detection",
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
 
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 68bcffa..9d59f59 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -134,13 +134,22 @@ superblocks. This doesn't always work satisfactorily e.g. if a device
 has been reused without wiping the md superblocks first.
 .IP
 \fBmd_chunk_alignment\fP \(em If set to 1, and a Physical Volume is placed
-directly upon an md device, LVM2 will align its data blocks with the the
+directly upon an md device, LVM2 will align its data blocks with the
 chunk_size exposed in sysfs.
 .IP
+\fBdata_alignment_detection\fP \(em If set to 1, and your kernel provides
+topology information in sysfs for the Physical Volume, the start of data
+area will be aligned on a multiple of the ?minimum_io_size? or
+?optimal_io_size? exposed in sysfs.  minimum_io_size is used if
+optimal_io_size is undefined (0).  If both \fBmd_chunk_alignment\fP and
+\fBdata_alignment_detection\fP are enabled the result of
+\fBdata_alignment_detection\fP is used.
+.IP
 \fBdata_alignment\fP \(em Default alignment (in KB) of start of data area
 when creating a new Physical Volume using the \fBlvm2\fP format.
 If a Physical Volume is placed directly upon an md device and
-\fBmd_chunk_alignment\fP is enabled this parameter is ignored.
+\fBmd_chunk_alignment\fP or \fBdata_alignment_detection\fP is enabled
+this parameter is ignored.
 Set to 0 to use the default alignment of 64KB or the page size, if larger.
 .IP
 \fBdata_alignment_offset_detection\fP \(em If set to 1, and your kernel
-- 
1.6.2.2


