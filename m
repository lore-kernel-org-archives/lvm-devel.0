From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Aug 2010 15:32:32 -0400
Subject: [PATCH] update heuristic used for default data alignment
Message-ID: <20100820193231.GA11735@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

1) --dataalignment or lvm.conf's "devices/data_alignment" is always used
   - neither MD nor IO Topology are even consulted
2) take MAX() of determined alignment value and existing pv->pe_align
3) allow lvm.conf's "device/default_data_alignment" to change the
   default alignment that LVM2 uses: 0==64k, 1==1MB, 2==2MB, etc.

set_pe_align() still looks to use the determined default (based on
lvm.conf's default_data_alignment) if the default is a multiple of the
MD or topology provided values.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 doc/example.conf.in           |    8 ++++++-
 lib/config/defaults.h         |    2 +
 lib/format_text/format-text.c |   20 ++++++++++------
 lib/metadata/metadata.c       |   48 ++++++++++++++++++++++++++++------------
 4 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 7edae71..830a7b8 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -98,6 +98,11 @@ devices {
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
+    # Default alignment of the start of a data area in MB.  If set to 0,
+    # a small value of 64KB will be used, which was the default until
+    # LVM2 version 2.02.73.  Set to 1 for 1MiB, 2 for 2MiB, etc.
+    default_data_alignment = 1
+
     # By default, the start of a PV's data area will be a multiple of
     # the 'minimum_io_size' or 'optimal_io_size' exposed in sysfs.
     # - minimum_io_size - the smallest request the device can perform
@@ -113,7 +118,8 @@ devices {
     # Alignment (in KB) of start of data area when creating a new PV.
     # If a PV is placed directly upon an md device and md_chunk_alignment or
     # data_alignment_detection is enabled this parameter is ignored.
-    # Set to 0 for the default alignment of 1MB or page size, if larger.
+    # Set to 0 for the default alignment (see: data_alignment_default)
+    # or page size, if larger.
     data_alignment = 0
 
     # By default, the start of the PV's aligned data area will be shifted by
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index b6308f4..d9c9e3b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -17,6 +17,7 @@
 #define _LVM_DEFAULTS_H
 
 #define DEFAULT_PE_ALIGN 2048
+#define DEFAULT_PE_ALIGN_OLD 128
 
 #define DEFAULT_ARCHIVE_ENABLED 1
 #define DEFAULT_BACKUP_ENABLED 1
@@ -33,6 +34,7 @@
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
+#define DEFAULT_DATA_ALIGNMENT 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c8cf89a..db5af2a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1861,16 +1861,20 @@ static int _text_pv_setup(const struct format_type *fmt,
 						      0) * 2;
 
 		if (set_pe_align(pv, data_alignment) != data_alignment &&
-		    data_alignment)
-			log_warn("WARNING: %s: Overriding data alignment to "
-				 "%lu sectors (requested %lu sectors)",
-				 pv_dev_name(pv), pv->pe_align, data_alignment);
+		    data_alignment) {
+			log_error("%s: invalid data alignment of "
+				  "%lu sectors (requested %lu sectors)",
+				  pv_dev_name(pv), pv->pe_align, data_alignment);
+			return 0;
+		}
 
 		if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
-		    data_alignment_offset)
-			log_warn("WARNING: %s: Overriding data alignment offset to "
-				 "%lu sectors (requested %lu sectors)",
-				 pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
+		    data_alignment_offset) {
+			log_error("%s: invalid data alignment offset of "
+				  "%lu sectors (requested %lu sectors)",
+				  pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
+			return 0;
+		}
 
 		if (pv->pe_align < pv->pe_align_offset) {
 			log_error("%s: pe_align (%lu sectors) must not be less "
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6cd7793..c79f618 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -62,23 +62,38 @@ static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
-static int _alignment_overrides_default(unsigned long data_alignment)
+static int _alignment_overrides_default(unsigned long data_alignment,
+					unsigned long default_pe_align)
 {
-	return data_alignment && (DEFAULT_PE_ALIGN % data_alignment);
+	return data_alignment && (default_pe_align % data_alignment);
 }
 
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
-	unsigned long temp_pe_align;
+	unsigned long default_pe_align, temp_pe_align;
 
 	if (pv->pe_align)
 		goto out;
 
-	if (data_alignment)
+	if (data_alignment) {
+		/* Always use specified data_alignment */
 		pv->pe_align = data_alignment;
+		goto out;
+	}
+
+	default_pe_align = find_config_tree_int(pv->fmt->cmd,
+						"devices/default_data_alignment",
+						DEFAULT_DATA_ALIGNMENT);
+
+	if (default_pe_align)
+		/* align on 1 MiB multiple */
+		default_pe_align *= DEFAULT_PE_ALIGN;
 	else
-		pv->pe_align = MAX((DEFAULT_PE_ALIGN << SECTOR_SHIFT),
-				   lvm_getpagesize()) >> SECTOR_SHIFT;
+		/* align on 64 KiB multiple (old default) */
+		default_pe_align = DEFAULT_PE_ALIGN_OLD;
+
+	pv->pe_align = MAX((default_pe_align << SECTOR_SHIFT),
+			   lvm_getpagesize()) >> SECTOR_SHIFT;
 
 	if (!pv->dev)
 		goto out;
@@ -89,8 +104,8 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
 				  DEFAULT_MD_CHUNK_ALIGNMENT)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align))
-			pv->pe_align = temp_pe_align;
+		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
+			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
 	}
 
 	/*
@@ -104,18 +119,18 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 				  "devices/data_alignment_detection",
 				  DEFAULT_DATA_ALIGNMENT_DETECTION)) {
 		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align))
-			pv->pe_align = temp_pe_align;
+		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
+			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
 
 		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align))
-			pv->pe_align = temp_pe_align;
+		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
+			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
 	}
 
+out:
 	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align);
 
-out:
 	return pv->pe_align;
 }
 
@@ -125,8 +140,11 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 	if (pv->pe_align_offset)
 		goto out;
 
-	if (data_alignment_offset)
+	if (data_alignment_offset) {
+		/* Always use specified data_alignment_offset */
 		pv->pe_align_offset = data_alignment_offset;
+		goto out;
+	}
 
 	if (!pv->dev)
 		goto out;
@@ -142,10 +160,10 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 		pv->pe_align_offset = MAX(pv->pe_align_offset, align_offset);
 	}
 
+out:
 	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align_offset);
 
-out:
 	return pv->pe_align_offset;
 }
 


