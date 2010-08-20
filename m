From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Aug 2010 20:59:09 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
Message-ID: <20100820205909.18007.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-20 20:59:07

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Update heuristic used for default and detected data alignment.
	
	Add "devices/default_data_alignment" to lvm.conf to control the internal
	default that LVM2 uses: 0==64k, 1==1MB, 2==2MB, etc.
	
	If --dataalignment (or lvm.conf's "devices/data_alignment") is specified
	then it is always used to align the start of the data area.  This means
	the md_chunk_alignment and data_alignment_detection are disabled if set.
	
	(Same now applies to pvcreate --dataalignmentoffset, the specified value
	will be used instead of the result from data_alignment_offset_detection)
	
	set_pe_align() still looks to use the determined default alignment
	(based on lvm.conf's default_data_alignment) if the default is a
	multiple of the MD or topology detected values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1718&r2=1.1719
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.395&r2=1.396

--- LVM2/WHATS_NEW	2010/08/20 20:35:55	1.1718
+++ LVM2/WHATS_NEW	2010/08/20 20:59:05	1.1719
@@ -1,5 +1,7 @@
 Version 2.02.74 - 
 ==================================
+  Update heuristic used for default and detected data alignment.
+  Add "devices/default_data_alignment" to lvm.conf.
   Add implmentation for simple numeric 'get' property functions.
   Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' function
   Add properties.[ch] to lib/report, defined based on columns.h.
--- LVM2/doc/example.conf.in	2010/08/16 22:54:36	1.8
+++ LVM2/doc/example.conf.in	2010/08/20 20:59:05	1.9
@@ -98,6 +98,11 @@
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
@@ -111,9 +116,9 @@
     data_alignment_detection = 1
 
     # Alignment (in KB) of start of data area when creating a new PV.
-    # If a PV is placed directly upon an md device and md_chunk_alignment or
-    # data_alignment_detection is enabled this parameter is ignored.
-    # Set to 0 for the default alignment of 1MB or page size, if larger.
+    # md_chunk_alignment and data_alignment_detection are disabled if set.
+    # Set to 0 for the default alignment (see: data_alignment_default)
+    # or page size, if larger.
     data_alignment = 0
 
     # By default, the start of the PV's aligned data area will be shifted by
@@ -122,6 +127,7 @@
     # windows partitioning will have an alignment_offset of 3584 bytes
     # (sector 7 is the lowest aligned logical block, the 4KB sectors start
     # at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
+    # But note that pvcreate --dataalignmentoffset will skip this detection.
     # 1 enables; 0 disables.
     data_alignment_offset_detection = 1
 
--- LVM2/lib/config/defaults.h	2010/08/16 22:54:36	1.66
+++ LVM2/lib/config/defaults.h	2010/08/20 20:59:05	1.67
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
 
--- LVM2/lib/format_text/format-text.c	2010/08/03 18:19:42	1.142
+++ LVM2/lib/format_text/format-text.c	2010/08/20 20:59:07	1.143
@@ -1861,16 +1861,20 @@
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
--- LVM2/lib/metadata/metadata.c	2010/08/20 12:43:49	1.395
+++ LVM2/lib/metadata/metadata.c	2010/08/20 20:59:07	1.396
@@ -62,23 +62,38 @@
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
@@ -89,8 +104,8 @@
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
 				  DEFAULT_MD_CHUNK_ALIGNMENT)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align))
-			pv->pe_align = temp_pe_align;
+		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
+			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
 	}
 
 	/*
@@ -104,18 +119,18 @@
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
 
@@ -125,8 +140,11 @@
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
@@ -142,10 +160,10 @@
 		pv->pe_align_offset = MAX(pv->pe_align_offset, align_offset);
 	}
 
+out:
 	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
 			 dev_name(pv->dev), pv->pe_align_offset);
 
-out:
 	return pv->pe_align_offset;
 }
 


